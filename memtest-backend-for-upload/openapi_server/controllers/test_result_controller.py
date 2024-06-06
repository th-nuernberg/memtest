import connexion
import os
from typing import Dict
from typing import Tuple
from typing import Union

from flask import send_file

from openapi_server.models.api_response import ApiResponse  # noqa: E501
from openapi_server import util


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
    

def upload_test_result(qrcode_uuid, body):  # noqa: E501
    """Uploads a test result zip file

     # noqa: E501

    :param qrcode_uuid: UUID associated with the QR code
    :type qrcode_uuid: str
    :param body: Encrypted ZIP file containing test results
    :type body: str

    :rtype: Union[ApiResponse, Tuple[ApiResponse, int], Tuple[ApiResponse, int, Dict[str, str]]
    """
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    upload_folder = os.path.join(base_dir, 'upload_folder')

    if not os.path.exists(upload_folder):
        os.makedirs(upload_folder)

    file_path = os.path.join(upload_folder, f'{qrcode_uuid}.zip')

    print("Body length:", len(body))
    if len(body) == 0:
        return ApiResponse(code=400, type="error", message="Uploaded file is empty"), 400

    with open(file_path, 'wb') as f:
        f.write(body)

    if os.path.exists(file_path) and os.path.getsize(file_path) > 0:
        print("File saved successfully.")
        return ApiResponse(code=200, type="success", message="File uploaded successfully"), 200
    else:
        print("Error: File not saved.")
        return ApiResponse(code=500, type="error", message="Error: File not saved"), 500