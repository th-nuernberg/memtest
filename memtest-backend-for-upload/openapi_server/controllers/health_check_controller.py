import connexion
from typing import Dict
from typing import Tuple
from typing import Union

from openapi_server.models.get_health_status200_response import GetHealthStatus200Response  # noqa: E501
from openapi_server import util
from datetime import datetime, timezone


def get_health_status():  # noqa: E501
    """Health Check Endpoint

    Returns the health status of the API server # noqa: E501


    :rtype: Union[GetHealthStatus200Response, Tuple[GetHealthStatus200Response, int], Tuple[GetHealthStatus200Response, int, Dict[str, str]]
    """

    status_response = GetHealthStatus200Response()
    status_response.status = "healthy"
    status_response.timestamp = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%S%z')

    return status_response
