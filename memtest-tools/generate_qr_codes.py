import click
import json
import os
import secrets
import uuid

import qrcode
from PIL import Image

@click.command()
@click.option('--study-id', prompt="Bitte geben Sie Ihre Studien-ID ein",
              help='Die ID der Studie für die QR-Codes.')
@click.option('--count', default=1, prompt="Bitte geben Sie die Anzahl der zu generierenden QR-Codes ein",
              help='Die Anzahl der zu generierenden QR-Codes.', type=int)
@click.option('--output-dir', default=None,
              help='Der Verzeichnisname, in dem die QR-Codes gespeichert werden. Standard ist die Studien-ID.')
def generate_qr_codes(study_id, count, output_dir):
    # Directory for saving the QR codes
    output_dir = output_dir or study_id

    try:
        os.makedirs(output_dir, exist_ok=True)
    except OSError as e:
        click.echo(f"Fehler beim Erstellen des Verzeichnisses {output_dir}: {e}", err=True)
        return

    for i in range(count):
        # Generate UUID
        unique_id = uuid.uuid4()

        # Generate AES key
        aes_key = secrets.token_urlsafe(64)

        qrCodeData = {
            "study_id": study_id,
            "id": unique_id.hex,
            "key": aes_key
        }

        # Create QR code
        qr = qrcode.QRCode(
            version=1,
            error_correction=qrcode.constants.ERROR_CORRECT_L,
            box_size=10,
            border=4,
        )

        qr.add_data(json.dumps(qrCodeData))
        qr.make(fit=True)

        img = qr.make_image(fill_color="black", back_color="white")

        # Save QR code image
        img_filename = f"{output_dir}/qr_code_{i}.png"
        img.save(img_filename)
        click.echo(f"QR-Code gespeichert unter: {img_filename}")

    # Optionally, show the first QR code image
    if count > 0:
        img = Image.open(f"{output_dir}/qr_code_0.png")
        img.show()

if __name__ == '__main__':
    generate_qr_codes()
