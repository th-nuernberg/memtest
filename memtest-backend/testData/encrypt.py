from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives import padding
from cryptography.hazmat.backends import default_backend
import os

def main():
    keys = [
        b"_R2xKn52k7pN6AIKyS0sT1AcFcA5LhMbogF_5jvPZrHkuc2b6grcUyyxfoyrBBMOH54eXGVyUZk636CDcphfuQ"[:32],
        b"0RhgnKZkwy6J4t7JXYPW58T3ZwqH817C690uABqay8CkCXvm66D6ZnQc82qClj73l3Iu_-vfHvGyPR1ZM7j1nA"[:32],
        b"D2PCLP31d0G1IL69cjYxf3hDmzLpoymzvXi0XLlDCDZkB4Yf45xQm9kNmIMqHbLxDA5ZYkIOIGDGLHh3PuZFSw"[:32],
        b"d9vYKKspic8F-yTjvOlzGTlhK6zwtD75EmSbStEeqi0PfrzA8MAG-gpTseIp4yOk1kWfoyOoOTJDELSJI1IEtA"[:32]
    ]

    directory = os.getcwd()
    output_directory = os.path.join(directory, "encrypted")
    os.makedirs(output_directory, exist_ok=True)

    for file in os.listdir(directory):
        filename = os.fsdecode(file)
        if filename.endswith(".zip"):
            with open(file, 'rb') as f:
                original = f.read()
            
            key = None
            if filename == "6614a2d033a2477bad1791f07b0f8d03.zip":
                key = keys[2]
            elif filename == "8dc4230982f7409687b47f6e7af686f5.zip":
                key = keys[0]
            elif filename == "ac39eebc898a403281028a8e8f82e166.zip":
                key = keys[1]
            elif filename == "6d9f6166bd0f4bb9be7a637f8795f7a0.zip":  # Added .zip extension
                key = keys[3]
            
            if key is None:
                print(f"No key found for file {filename}")
                continue
            
            iv = os.urandom(16)
            
            cipher = Cipher(algorithms.AES(key), modes.CBC(iv))
            encryptor = cipher.encryptor()
            
            padder = padding.PKCS7(algorithms.AES.block_size).padder()
            
            padded_original = padder.update(original) + padder.finalize()
            
            ciphertext = encryptor.update(padded_original) + encryptor.finalize()
            
            encrypted_file_path = os.path.join(output_directory, filename)
            with open(encrypted_file_path, 'wb') as encrypted_file:
                encrypted_file.write(iv + ciphertext)

if __name__ == "__main__":
    main()
