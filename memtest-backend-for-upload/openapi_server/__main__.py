#!/usr/bin/env python3

import sys
import os
from pathlib import Path

# Set the current working directory to the parent directory
current_dir = Path(__file__).resolve().parent
project_root = current_dir.parent
sys.path.insert(0, str(project_root))

import connexion
from openapi_server import encoder

def main():
    app = connexion.App(__name__, specification_dir='../../memtest-app/memtest-server-client/')
    app.app.json_encoder = encoder.JSONEncoder
    app.add_api('openapi.yaml',
                arguments={'title': 'Memtest'},
                pythonic_params=True)

    app.run(port=8080)

if __name__ == '__main__':
    main()
