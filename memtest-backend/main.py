from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives import serialization
import qrcode
from PIL import Image
import os
import json

# RSA-Schlüsselpaar generieren
def generate_rsa_keypair():
    private_key = rsa.generate_private_key(
        public_exponent=65537,
        key_size=2048,
        backend=default_backend()
    )
    public_key = private_key.public_key()

    # Schlüssel in Bytes umwandeln
    private_key_bytes = private_key.private_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption()
    )
    public_key_bytes = public_key.public_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PublicFormat.SubjectPublicKeyInfo
    )

    return private_key_bytes, public_key_bytes


# Studien-ID über Console einlesen
study_id = input("Bitte geben Sie Ihre Studien-ID ein: ")

# Anzahl der zu generierenden QR-Codes einlesen
number_of_qr_codes = int(input("Bitte geben Sie die Anzahl der zu generierenden QR-Codes ein: "))

for i in range(number_of_qr_codes):
    # RSA-Schlüsselpaar generieren
    private_key_bytes, public_key_bytes = generate_rsa_keypair()

    # Daten in JSON-Format konvertieren
    data = {
        "id": study_id,
        "publicKey": public_key_bytes.decode(),
        "privateKey": private_key_bytes.decode()
    }
    qr_content = json.dumps(data)

    # QR-Code mit den Daten im JSON-Format generieren
    qr_code = qrcode.make(qr_content)

    # erstelle Ordner, falls nicht vorhanden
    if not os.path.exists(study_id):
        os.makedirs(study_id)

    qr_code_filename = f"{study_id}/qr_code_{i}.png"
    qr_code.save(qr_code_filename)

print("QR-Codes mit RSA öffentlichem Schlüssel und eindeutiger ID wurden generiert und gespeichert.")

# show image
img = Image.open(f"{study_id}/qr_code_0.png")
img.show()
