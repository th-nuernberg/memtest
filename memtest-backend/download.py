import os
import tempfile
import argparse
import json
import fitz
import requests
from werkzeug.datastructures import FileStorage
from zipfile import ZipFile
from io import BytesIO
from PIL import Image
from pyzbar.pyzbar import decode
import logging

logging.basicConfig(level=logging.INFO, format=' %(levelname)s - %(message)s')

def main():
    
    parser = argparse.ArgumentParser(description="Download and decrypt the patiend data")
    parser.add_argument('--outdir', type=str, help="Output directory for the patient data (If left empty uses the downloads folder as output)")
    parser.add_argument('--indir', type=str, help='input directory for the patient data (local)')
    parser.add_argument('--pdfdir', type=str, help='Directory containing the PDF files')
    parser.add_argument('pdf_files', nargs='+', type=str, help="PDF files to process (use 'all' to process all PDFs in the directory)")
    args = parser.parse_args()

    #Check input for validity
    if(args.indir != None):
        indir = os.path.normpath(args.indir)
    else:
        indir = None

    if(args.outdir != None):
        outdir = os.path.normpath(args.outdir) 
    else:
        outdir = os.path.join(os.path.expanduser("~"), "Downloads")

    if(args.pdfdir != None):
        pdfdir = os.path.normpath(args.pdfdir)
    else:
        pdfdir = os.path.dirname(os.path.abspath(__file__))


    pdfs = args.pdf_files

    process_files(indir, outdir, pdfdir, pdfs)

def process_files(indir, outdir, pdfdir, pdfs):
    files = []

    #Check if all the directories exist     
    if not os.path.exists(pdfdir):
        logging.error("Invalid pdf input directory")
        return 
    if indir != None and not os.path.exists(indir):
        logging.error("Invalid File Input directory")
        return
    if not os.path.exists(outdir):
        logging.error("Invalid Output directory")
        return
    
    #Pdfs list does not include all => Only certain pdfs should be added to the list
    if pdfs[0] != 'all':
        for pdf in pdfs:
            pdfPath = os.path.join(pdfdir, pdf)
            if os.path.exists(pdfPath):
                with open(pdfPath, 'rb') as file:
                    file_content = file.read()
                    file_storage = FileStorage(stream=BytesIO(file_content), filename=pdf, name="file", content_type="application/pdf")
                    files.append(file_storage)
            else:
                logging.error(f"PDF file not found: {pdf}")
    else:
        #All pdfs in the pdfdir are added to the list
        for pdf in os.listdir(pdfdir):
            if pdf.endswith('.pdf'):
                pdfPath = os.path.join(pdfdir, pdf)
                with open(pdfPath, 'rb') as file:
                    file_content = file.read()
                    file_storage = FileStorage(stream=BytesIO(file_content), filename=pdf, name="file", content_type="application/pdf")
                    files.append(file_storage)

    for file in files:

        if file:
            QRCodes = extractQRCodeFromPDF(file)
            
            if isinstance(QRCodes, str) and ("File does not exist" in QRCodes or "Failed to open PDF document" in QRCodes or "No images found in the PDF document" in QRCodes):
                logging.error(QRCodes + file.filename) #log the error and continue with the next file
                continue
            
            if os.path.exists(outdir):
                for code in QRCodes:
                    QRCodeData = scanQRCode(code)
                    if isinstance(QRCodeData, str) and ("Couldn't retrieve id and key" in QRCodeData or "Failed to decode QR code" in QRCodeData):
                        logging.error(QRCodeData + " in " + file.filename) #log the error message and continue
                        continue
                    
                    if indir != None: #Filelocation is local
                        if os.path.exists(os.path.join(indir, QRCodeData["id"] + ".zip")):
                            removePasswordAndSave(os.path.join(indir, QRCodeData["id"] + ".zip"), QRCodeData["key"], QRCodeData["id"], outdir)
                        else:
                            logging.error(f"Test result not found for {QRCodeData['id']}")
                            continue
                    else: #fileLocation == remote
                        error = getZipFromRemote(QRCodeData["id"], QRCodeData["key"], outdir)
                        if error:
                            logging.error(error)
                            continue
                                            
            else:
                logging.error("Invalid output directory")
                return
    return

def getZipFromRemote(id, key, outdir):
    url = f"http://127.0.0.1:8080/api/v1/testresult/{id}"
    
    error = None
    
    try:
        response = requests.get(url)
        
        if response.status_code == 200:
            with tempfile.NamedTemporaryFile(delete=False) as tmpfile:
                tmpfile.write(response.content)
                path = tmpfile.name
            removePasswordAndSave(path, key, id, outdir)
        elif response.status_code == 404:
            error = f"Test result not found for {id}"
        elif response.status_code == 500:
            error = f"Server error occurred for {id}"
        else:
            error = f"Unexpected error occurred for {id} error code: {response.status_code}"
    except requests.RequestException as e:
        logging.error(f"Request failed: {e}")
    return error

def removePasswordAndSave(zipFilePath, key, id, outdir):

    with ZipFile(zipFilePath, 'r') as zip_ref:
        zip_ref.extractall(pwd=bytes(key, 'utf-8'), path=outdir)
    return

#PDFscan functions

def extractQRCodeFromPDF(fileStorage):
    
    fileContent = fileStorage.read()
    fileBytes = BytesIO(fileContent)

    document = fitz.open(stream = fileBytes, filetype="pdf")
    
    if not document:
        return f'Failed to open {fileStorage.filename}'
    
    pageNums = len(document)
    images = []
    qrCodes = []
    
    for pageNum in range(pageNums):
        pageContent = document[pageNum]
        images.extend(pageContent.get_images())
        
    if len(images) == 0:
        return "No images found in the PDF document"
        
    for i, image in enumerate(images, start=1):
        xref = image[0]
        baseImage = document.extract_image(xref)
        imageBytes = baseImage['image']
        
        pilImage = Image.open(BytesIO(imageBytes))
        
        decodedImage = decode(pilImage)
        
        if decodedImage:
            qrCodes.append(pilImage)
    
    return qrCodes

def scanQRCode(QRCode):
    decoded = decode(QRCode)
    
    if not decoded:
        return 'Failed to decode QR code'
    
    try:
        data = json.loads(decoded[0].data)
    except json.JSONDecodeError:
        return 'Couldn\'t retrieve id and key from the QR code'
    
    if "id" not in data or "key" not in data:
        return 'Couldn\'t retrieve id and key from the QR code'
    
    return data

if __name__ == '__main__':
    main()
