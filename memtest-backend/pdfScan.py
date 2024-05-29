import fitz
import os
from PIL import Image
from pyzbar.pyzbar import decode
from io import BytesIO
import json

def extractQRCodeFromPDF(fileName):
    filePath = os.path.join("static\\files", fileName)
    
    document = fitz.open(filePath)
    
    pageNums = len(document)
    images = []
    qrCodes = []
    
    for pageNum in range(pageNums):
        pageContent = document[pageNum]
        images.extend(pageContent.get_images())
        
    if len(images) == 0:
        return "No images"
    
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
    return json.loads(decoded[0].data)