import unittest

from flask import json

from openapi_server.models.get_health_status200_response import GetHealthStatus200Response  # noqa: E501
from openapi_server.test import BaseTestCase


class TestHealthCheckController(BaseTestCase):
    """HealthCheckController integration test stubs"""

    def test_get_health_status(self):
        """Test case for get_health_status

        Health Check Endpoint
        """
        headers = { 
            'Accept': 'application/json',
        }
        response = self.client.open(
            '/api/v1/health',
            method='GET',
            headers=headers)
        self.assert200(response,
                       'Response body is : ' + response.data.decode('utf-8'))


if __name__ == '__main__':
    unittest.main()
