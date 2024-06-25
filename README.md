# memtest 


## memtest-backend-for-upload
Used for uploading the test results to the server and getting the saved results 

## memtest-tools - python scripts for manging study secrets generating qrcodes and decrypting the testresults

- __download.py__: This script is used for downloading the test results from the server and decrypting it using pdfs
- __generate_qr_codes.py__: This script is used for generating unqiue QR codes for each participant in the study
- __manage_studykey.py__: This script is used for managing the study secrets like generating and deleting secrets

## iOS - App
### App Directory Structure Overview
#### memtest-app Directory

- __Assets.xcassets__: Contains all graphical assets used in the app, such as app icons, images for various screens, and color definitions. 
- __Launch Screen.storyboard__: For the app's launch screen
- __Models__: Contains data models defining things like results formats and symbols used in tests.
- __Resources__: Houses additional resources such as textual data, animations, and machine learning models (for whisper.cpp, not yet implemented. branch: https://github.com/th-nuernberg/memtest/tree/feature/31-implement-whisper_cpp) necessary for the app's functionalities.
- __Services__: Implements business logic and backend services like data handling, audio management, and secure data storage. Essential for the app’s operations and user data management.
- __Util__: Provides utility functions and helpers that streamline and support various functionalities across the app, such as QR code handling and timer mechanisms.
- __Views__: Contains all the UI components organized by their function and usage within the app.

#### Detailed Breakdown of Key Directories
##### Services:
Core services that handle critical functionalities like audio recording (AudioService.swift), data persistence (DataService.swift), and security (KeychainService.swift).

##### Views:
The main components of the app's user interface, structured into subdirectories for organization:

- __AdminSettingsView.swift__: Manages settings that affect the app’s configuration and administration.
- __Calibration__: Contains views related to device and user calibration for accurate test execution.
- __DataInputView__: Includes views for gathering patient data and metadata.
- __HomeView.swift__: The central hub after app launch, directing to various functionalities.
- __RoutingView.swift__: Manages navigation and transitions between different views and routes to Sub-RoutingViews, like the SKTRoutingView, the WelcomeRoutingView, etc..
- __Tests__: Contains individual views for each test , such as *SKT*, *PDT*, *VFT*, and *BNT*. Each test folder may contain specific subviews for different phases or aspects of the test.
- __Welcome__: Introduces the app to new users, providing initial information and guidance and where the QR code is scanned.

##### memtest-server-client

- __openapi,yaml__: The OpenAPI specification for the server API. This file is used to generate the server and client code.
- __MemtestClient.swift__: The client code that uses the generated code from the OpenAPI specification to interact with the server.


### Notes 
Additionally, it is important to build in Release mode to use the -O2 optimization!

### For Whisper.cpp Implementation (WIP): 
https://github.com/th-nuernberg/memtest/tree/feature/31-implement-whisper_cpp
####[Whisper.cpp](https://github.com/ggerganov/whisper.cpp/tree/master) Speech Recognition:
For [whisper.cpp](https://github.com/ggerganov/whisper.cpp/tree/master) add the desired model`.bin` and model`-encoder.mlmodelc`to the `Resources/models` folder in the iOS XCode Project.\
How to download and convert a model is explained [here](https://github.com/ggerganov/whisper.cpp/tree/master/models).

##### Commit Conventions
https://www.conventionalcommits.org/en/v1.0.0/


