# memtest


## Notes for Demo:

If it is desired to also demonstrate the QR code functionality, it is only necessary to uncomment one line and comment out another in the ContentView.swift file of the iOS app (the explanation is provided in the comments).

Additionally, it is important to build in Release mode to use the -O2 optimization!

### [Whisper.cpp](https://github.com/ggerganov/whisper.cpp/tree/master) Speech Recognition:
For [whisper.cpp](https://github.com/ggerganov/whisper.cpp/tree/master) add the desired model`.bin` and model`-encoder.mlmodelc`to the `Resources/models` folder in the iOS XCode Project.\
How to download an convert a model is explained [here](https://github.com/ggerganov/whisper.cpp/tree/master/models).

#### Commit Conventions
https://www.conventionalcommits.org/en/v1.0.0/


