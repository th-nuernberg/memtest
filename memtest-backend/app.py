import connexion
from flask import Flask, request, render_template, send_file, jsonify
from werkzeug.utils import secure_filename
from werkzeug.datastructures import FileStorage
import os
import shutil
from io import BytesIO
from zipfile import ZipFile
import tempfile
from decrypt import decryptZip  # Ensure this function returns bytes and filename
from pdfScan import extractQRCodeFromPDF, scanQRCode

# Erstellen Sie eine Connexion-Anwendung
app = connexion.FlaskApp(__name__, specification_dir='../memtest-app/memtest-server-client/')

# Lesen Sie die OpenAPI-Spezifikation und konfigurieren Sie die Pfade
#app.add_api('openapi.yaml')

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
        
        for file in files:
    
            filename = secure_filename(os.path.basename(file.name))

            if file.filename == '':
                return 'No selected file'

            if file:
                filePath = saveFileToStatic(file)
                QRCodes = extractQRCodeFromPDF(filePath)
                os.remove(filePath)
                
                # Create a temporary directory to store the decrypted ZIP files
                with tempfile.TemporaryDirectory() as tmpdirname:
                    outputDirectory = os.path.normpath(request.form["outputDirectory"])
                    if os.path.exists(outputDirectory):
                        for code in QRCodes:
                            QRCodeData = scanQRCode(code)
                            decryptedZip, zipFileName = fetchZip(QRCodeData["id"], QRCodeData["key"])
                            # Save the decrypted ZIP file in the temporary directory
                            decryptedZipPath = os.path.join(tmpdirname, zipFileName)
                            with open(decryptedZipPath, 'wb') as f:
                                shutil.copyfileobj(decryptedZip, f)
                                                    
                        for filename in os.listdir(tmpdirname):
                            filePath = os.path.join(tmpdirname, filename)
                            saveFileToOutput(filePath, outputDirectory, filename)
                    else:
                        return 'Invalid output directory'
                    
        return render_template('success.html')
    return render_template('upload.html')

def fetchZip(id, key): #fetchzip gets the data from the testData folder for testing purposes
    orgZipFilePath = os.path.join(os.path.dirname(__file__), "testData", "encrypted", f"{id}.zip")
    destZipFilePath = os.path.join(os.path.dirname(__file__), "static", "fetchedFiles", f"{id}.zip")
    shutil.copyfile(orgZipFilePath, destZipFilePath)
    
    # Decrypt the ZIP file and get its content as bytes
    return decryptZip(destZipFilePath, key, id)

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

if __name__ == '__main__':
    app.run(host="127.0.0.1", port=8080)
