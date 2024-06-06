import fitz
import os
from PIL import Image
from pyzbar.pyzbar import decode
from io import BytesIO
import json

def extractQRCodeFromPDF(fileName):
    filePath = os.path.join("static\\files", fileName)
    
    if not os.path.exists(filePath):
        return 'File does not exist'
    
    document = fitz.open(filePath)
    
    if not document:
        return 'Failed to open PDF document'
    
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
        imageExtension = baseImage['ext']
        imageName = str(i) + '.' + imageExtension
        
        pilImage = Image.open(BytesIO(imageBytes))
        pilImage.filename = imageName
        
        decodedImage = decode(pilImage)
        
        if decodedImage:
            for obj in decodedImage:
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
