import zipfile
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives import padding
from cryptography.hazmat.backends import default_backend
from io import BytesIO
import os

def decryptZip(zipFilePath, key, id):
    bytesObject = key.encode('utf-8')
    key = bytesObject[:32]
        
    with open(zipFilePath, 'rb') as encryptedFile:
        iv = encryptedFile.read(16)
        ciphertext = encryptedFile.read()
        
    cipher = Cipher(algorithms.AES(key), modes.CBC(iv))
    decryptor = cipher.decryptor()

    paddedPlaintext = decryptor.update(ciphertext) + decryptor.finalize()

    unpadder = padding.PKCS7(algorithms.AES.block_size).unpadder()
    plaintext = unpadder.update(paddedPlaintext) + unpadder.finalize()

    # Write the decrypted content to a bytes buffer
    zip_buffer = BytesIO(plaintext)
    
    # Create a new zip buffer for the decrypted files
    decrypted_zip_buffer = BytesIO()
    with zipfile.ZipFile(zip_buffer, 'r') as zipf:
        with zipfile.ZipFile(decrypted_zip_buffer, 'w') as decrypted_zipf:
            for file_name in zipf.namelist():
                file_content = zipf.read(file_name)
                decrypted_zipf.writestr(file_name, file_content)

    decrypted_zip_buffer.seek(0)
    zipFileName = f"{id}.zip"

    return decrypted_zip_buffer, zipFileName