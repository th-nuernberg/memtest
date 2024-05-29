from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives import padding
from cryptography.hazmat.backends import default_backend
import os

def main():
    keys = [b"_R2xKn52k7pN6AIKyS0sT1AcFcA5LhMbogF_5jvPZrHkuc2b6grcUyyxfoyrBBMOH54eXGVyUZk636CDcphfuQ"[:32], b"0RhgnKZkwy6J4t7JXYPW58T3ZwqH817C690uABqay8CkCXvm66D6ZnQc82qClj73l3Iu_-vfHvGyPR1ZM7j1nA"[:32], b"D2PCLP31d0G1IL69cjYxf3hDmzLpoymzvXi0XLlDCDZkB4Yf45xQm9kNmIMqHbLxDA5ZYkIOIGDGLHh3PuZFSw"[:32]]
    
    directory = os.getcwd()
    for file in os.listdir(directory):
        filename = os.fsdecode(file)
        if filename.endswith(".zip"):
            with open(file, 'rb') as file:
                original = file.read()
            key = ""
            if filename == "6614a2d033a2477bad1791f07b0f8d03.zip":
                key = keys[2]
            elif filename == "8dc4230982f7409687b47f6e7af686f5.zip":
                key = keys[0] #should be right
            elif filename == "ac39eebc898a403281028a8e8f82e166.zip":
                key = keys[1]
            
            iv = os.urandom(16)
            
            cipher = Cipher(algorithms.AES(key), modes.CBC(iv))
            encryptor = cipher.encryptor()
            
            padder = padding.PKCS7(algorithms.AES.block_size).padder()
            
            paddedOriginal = padder.update(original) + padder.finalize()
            
            ciphertext = encryptor.update(paddedOriginal) + encryptor.finalize()
            
            decrFilePath = os.path.join(directory, "encrypted", filename)
            with open(decrFilePath, 'wb') as encryptedFile:
                encryptedFile.write(iv + ciphertext)
                
            
if __name__ == "__main__":
    main()