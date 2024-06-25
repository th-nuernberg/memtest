import connexion
import os
import json
from typing import Dict, Tuple, Union
from flask import send_file
from openapi_server.models.api_response import ApiResponse  # noqa: E501
from openapi_server import util
from pathlib import Path

def get_test_result(qrcode_uuid):  # noqa: E501
    """Retrieves a specific test result by UUID as an encrypted ZIP file

     # noqa: E501

    :param qrcode_uuid: UUID associated with the specific test result
    :type qrcode_uuid: str

    :rtype: Union[file, Tuple[file, int], Tuple[file, int, Dict[str, str]]
    """

    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    upload_folder = os.path.join(base_dir, 'upload_folder')
    file_path = os.path.join(upload_folder, f'{qrcode_uuid}.zip')

    if os.path.exists(file_path):
        return send_file(file_path, as_attachment=True)
    else:
        return 'Test result not found', 404


def upload_test_result(qrcode_uuid, study_secret, body):  # noqa: E501
    """Uploads a test result zip file

    # noqa: E501

    :param qrcode_uuid: UUID associated with the QR code
    :type qrcode_uuid: str
    :param study_secret: Secret associated with the study
    :type study_secret: str
    :param body: Encrypted ZIP file containing test results
    :type body: str

    :rtype: Union[ApiResponse, Tuple[ApiResponse, int], Tuple[ApiResponse, int, Dict[str, str]]
    """

    try:
        with open('../../memtest-tools/studykey.json', 'r') as f:
            studies = json.load(f)
    except Exception as e:
        return ApiResponse(code=500, type="error", message="Error reading studies.json"), 500

    # Check if the study_secret matches any in the JSON
    authorized = False
    for study in studies:
        if study_secret == study['secret']:
            authorized = True
            break

    if not authorized:
        return ApiResponse(code=401, type="error", message="Unauthorized to upload Study-Files"), 401

    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    upload_folder = os.path.join(base_dir, 'upload_folder')
    if not os.path.exists(upload_folder):
        os.makedirs(upload_folder)

    file_path = os.path.join(upload_folder, f'{qrcode_uuid}.zip')
    print(f"Received Testresult with the UUID: {qrcode_uuid}")
    print(f"Study Secret: {study_secret}")

    # Check if the file already exists before saving it
    if os.path.exists(file_path):
        print("Error: File already exists.")
        return ApiResponse(code=409, type="error",
                           message=f"Testresult with {qrcode_uuid} already exists. The file will not be saved!"), 409

    print("Body length:", len(body))
    if len(body) == 0:
        return ApiResponse(code=400, type="error", message="Uploaded Testresult is empty"), 400

    # Save the file if it does not exist
    try:
        with open(file_path, 'wb') as f:
            f.write(body)
    except Exception as e:
        print(f"Error saving file: {e}")
        return ApiResponse(code=500, type="error", message="Error saving Testresult"), 500

    if (os.path.exists(file_path) and os.path.getsize(file_path) > 0):
        print("File saved successfully.")
        return ApiResponse(code=200, type="success", message="Testresult uploaded successfully"), 200
    else:
        print("Error: File not saved.")
        return ApiResponse(code=500, type="error", message="Error: Testresult not saved"), 500