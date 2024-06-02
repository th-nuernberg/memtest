import connexion
from flask import Flask, request, render_template, send_file
from werkzeug.utils import secure_filename
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
        if 'file' not in request.files:
            return 'No file part'
        
        file = request.files['file']

        if file.filename == '':
            return 'No selected file'

        if file:
            filePath = saveFile(file)
            QRCodes = extractQRCodeFromPDF(filePath)
            os.remove(filePath)
            
            # Create a temporary directory to store the decrypted ZIP files
            with tempfile.TemporaryDirectory() as tmpdirname:
                for code in QRCodes:
                    QRCodeData = scanQRCode(code)
                    decryptedZip, zipFileName = fetchZip(QRCodeData["id"], QRCodeData["key"])
                    # Save the decrypted ZIP file in the temporary directory
                    decryptedZipPath = os.path.join(tmpdirname, zipFileName)
                    with open(decryptedZipPath, 'wb') as f:
                        shutil.copyfileobj(decryptedZip, f)
                
                # Create a combined ZIP file of all decrypted ZIP files
                combinedZipBytes = BytesIO()
                with ZipFile(combinedZipBytes, 'w') as combinedZip:
                    for filename in os.listdir(tmpdirname):
                        filePath = os.path.join(tmpdirname, filename)
                        combinedZip.write(filePath, arcname=filename)
                
                combinedZipBytes.seek(0)
                
                return send_file(
                    combinedZipBytes,
                    as_attachment=True,
                    download_name='combined.zip'
                )
                
    return render_template('upload.html')

def fetchZip(id, key): #fetchzip gets the data from the testData folder for testing purposes
    orgZipFilePath = os.path.join(os.path.dirname(__file__), "testData", "encrypted", f"{id}.zip")
    destZipFilePath = os.path.join(os.path.dirname(__file__), "static", "fetchedFiles", f"{id}.zip")
    shutil.copyfile(orgZipFilePath, destZipFilePath)
    
    # Decrypt the ZIP file and get its content as bytes
    return decryptZip(destZipFilePath, key, id)

def saveFile(file):
    filename = secure_filename(file.filename)
    splitFilename = filename.rsplit('.', 1)
    if len(splitFilename) == 2 and splitFilename[1]:
        filePath = os.path.join(os.path.abspath(os.path.dirname(__file__)), "static", "files", filename) 
        file.save(filePath)
        return filePath


if __name__ == '__main__':
    app.run(host="127.0.0.1", port=8080) #runs via localhost for testing purposes
    #app.run(host="0.0.0.0", port=8080)