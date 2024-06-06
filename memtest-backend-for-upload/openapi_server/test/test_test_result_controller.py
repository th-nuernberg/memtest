import unittest

from flask import json

from openapi_server.models.api_response import ApiResponse  # noqa: E501
from openapi_server.test import BaseTestCase


class TestTestResultController(BaseTestCase):
    """TestResultController integration test stubs"""

    def test_get_test_result(self):
        """Test case for get_test_result

        Retrieves a specific test result by UUID as an encrypted ZIP file
        """
        headers = { 
            'Accept': 'application/zip',
        }
        response = self.client.open(
            '/api/v1/testresult/{qrcode_uuid}'.format(qrcode_uuid='qrcode_uuid_example'),
            method='GET',
            headers=headers)
        self.assert200(response,
                       'Response body is : ' + response.data.decode('utf-8'))

    @unittest.skip("application/zip not supported by Connexion")
    def test_upload_test_result(self):
        """Test case for upload_test_result

        Uploads a test result zip file
        """
        body = '/path/to/file'
        headers = { 
            'Accept': 'application/json',
            'Content-Type': 'application/zip',
        }
        response = self.client.open(
            '/api/v1/testresult/upload/{qrcode_uuid}'.format(qrcode_uuid='qrcode_uuid_example'),
            method='PUT',
            headers=headers,
            data=json.dumps(body),
            content_type='application/zip')
        self.assert200(response,
                       'Response body is : ' + response.data.decode('utf-8'))


if __name__ == '__main__':
    unittest.main()
