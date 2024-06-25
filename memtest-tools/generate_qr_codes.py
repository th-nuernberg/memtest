# create uuid and aes key
import json
import os
import secrets
import uuid

import qrcode
from PIL import Image

study_id = input("Bitte geben Sie Ihre Studien-ID ein: ")

number_of_qr_codes = int(input("Bitte geben Sie die Anzahl der zu generierenden QR-Codes ein: "))

for i in range(number_of_qr_codes):
    # UUID generieren
    uuid = uuid.uuid4()

    # AES-Schlüssel generieren
    aes_key = secrets.token_urlsafe(64)

    qrCodeData = {
        "study_id": study_id,
        "id": uuid.hex,
        "key": aes_key
    }

    # QR-Code generieren
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_L,
        box_size=10,
        border=4,
    )

    qr.add_data(json.dumps(qrCodeData))
    qr.make(fit=True)

    img = qr.make_image(fill_color="black", back_color="white")
    # make study_id dir
    try:
        os.mkdir(study_id)
    except FileExistsError:
        pass

    img.save(f"{study_id}/qr_code_{i}.png")

# show image
img = Image.open(f"{study_id}/qr_code_0.png")
img.show()
