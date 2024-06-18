import connexion
from flask import Flask, request, render_template, send_file, jsonify
from werkzeug.utils import secure_filename
from werkzeug.datastructures import FileStorage
import os
import shutil
from io import BytesIO
from zipfile import ZipFile
import tempfile
import requests
#from decrypt import decryptZip  # Ensure this function returns bytes and filename
from pdfScan import extractQRCodeFromPDF, scanQRCode

# Erstellen Sie eine Connexion-Anwendung
app = connexion.FlaskApp(__name__)

@app.route("/", methods=['GET', 'POST'])
def upload_file():
    
    if request.method == 'POST':
        
        files = []
        
        if request.form['fileOption'] == 'single':
            if 'file' not in request.files:
                return 'No file part'
            else:
                files.append(request.files['file'])
                
        elif request.form['fileOption'] == 'multiple':
            directory = os.path.normpath(request.form["fileDirectory"])
            
            if not os.path.exists(directory):
                return 'Invalid file directory'
            
            for filename in os.listdir(directory):
                if filename.endswith(".pdf"):
                    file_path = os.path.join(directory, filename)
                    with open(file_path, 'rb') as file:
                        file_content = file.read()
                        file_storage = FileStorage(stream=BytesIO(file_content), filename=filename, name='file', content_type='application/pdf')
                        files.append(file_storage)
        
        if request.form['fileLocation'] == 'local':
            if not os.path.exists(os.path.normpath(request.form["inputDirectory"])):
                return "Invalid input directory"
        
        errors = [] #keep a list of all errors that happen during requests
        
        for file in files:
    
            filename = secure_filename(os.path.basename(file.name))

            if file.filename == '':
                return 'No selected file'

            if file:
                filePath = saveFileToStatic(file)
                QRCodes = extractQRCodeFromPDF(filePath)
                os.remove(filePath)
                
                if isinstance(QRCodes, str) and ("File does not exist" in QRCodes or "Failed to open PDF document" in QRCodes or "No images found in the PDF document" in QRCodes):
                    errors.append(QRCodes)
                    continue
                
                # Create a temporary directory to store the decrypted ZIP files
                with tempfile.TemporaryDirectory() as tmpdirname:
                    outputDirectory = os.path.normpath(request.form["outputDirectory"])
                    if os.path.exists(outputDirectory):
                        for code in QRCodes:
                            QRCodeData = scanQRCode(code)
                            if isinstance(QRCodeData, str) and ("Couldn't retrieve id and key" in QRCodeData or "Failed to decode QR code" in QRCodeData):
                                errors.append(QRCodeData)
                                continue
                            
                            inputDir = os.path.normpath(request.form["inputDirectory"])
                            
                            if request.form["fileLocation"] == "local":
                                if os.path.exists(os.path.join(inputDir, QRCodeData["id"] + ".zip")):
                                    decryptedZip, zipFileName = removePassword(os.path.join(inputDir, QRCodeData["id"] + ".zip"), QRCodeData["key"], QRCodeData["id"])
                                else:
                                    errors.append(f"Test result not found for {QRCodeData['id']}")
                                    continue
                            else: #fileLocation == remote
                                decryptedZip, zipFileName, error = getZipFromRemote(QRCodeData["id"], QRCodeData["key"])
                                if error:
                                    errors.append(error)
                                    continue
                                    
                            # Save the decrypted ZIP file in the temporary directory
                            decryptedZipPath = os.path.join(tmpdirname, zipFileName)
                            with open(decryptedZipPath, 'wb') as f:
                                shutil.copyfileobj(decryptedZip, f)
                                                    
                        for filename in os.listdir(tmpdirname):
                            filePath = os.path.join(tmpdirname, filename)
                            saveFileToOutput(filePath, outputDirectory, filename)
                    else:
                        return 'Invalid output directory'
        allErrors = errors
        errors = []
        return render_template('success.html', errors=allErrors)
    return render_template('upload.html')

def getZipFromRemote(id, key):
    url = f"http://127.0.0.1:8080/api/v1/testresult/{id}"
    
    error = None
    decryptedZip = None
    zipFileName = None
    
    try:
        response = requests.get(url)
        
        if response.status_code == 200:
            with tempfile.NamedTemporaryFile(delete=False) as tmpfile:
                tmpfile.write(response.content)
                path = tmpfile.name
            decryptedZip, zipFileName = removePassword(path, key, id)
        elif response.status_code == 404:
            error = f"Test result not found for {id}"
        elif response.status_code == 500:
            error = f"Server error occurred for {id}"
        else:
            error = f"Unexpected error occurred for {id} error code: {response.status_code}"
    except requests.RequestException as e:
        print(f"Request failed: {e}")
    return decryptedZip, zipFileName, error

def saveFileToStatic(file):
    filename = secure_filename(file.filename)
    splitFilename = filename.rsplit('.', 1)
    if len(splitFilename) == 2 and splitFilename[1]:
        filePath = os.path.join(os.path.abspath(os.path.dirname(__file__)), "static", "files", filename) 
        file.save(filePath)
        return filePath

def saveFileToOutput(src_file, outputdir, filename):
    output_path = os.path.join(outputdir, filename)
    shutil.copyfile(src_file, output_path)

def removePassword(zipFilePath, key, id):
    zipName = f"{id}.zip"

    decryptedZip = BytesIO()

    with ZipFile(zipFilePath, 'r') as zip_ref:
        zip_ref.extractall(pwd=bytes(key, 'utf-8'))
        with ZipFile(decryptedZip, 'w') as new_zip:
            for file_name in zip_ref.namelist():
                new_zip.write(file_name)
    
    decryptedZip.seek(0)
    return decryptedZip, zipName

if __name__ == '__main__':
    app.run(host="127.0.0.1", port=3000)
