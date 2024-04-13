//
//  AppleTranscriptionService.swift
//  memtest-app
//
//  Created by Christopher Witzl on 13.04.24.
//
import Foundation
import Speech
import AVFoundation

class AppleTranscriptionService: NSObject, TranscriptionService, SFSpeechRecognizerDelegate {
    private var speechRecognizer: SFSpeechRecognizer
    private var audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    var onTranscriptionUpdate: ((String) -> Void)?
    
    var isTranscribing: Bool = false
    var transcription: String = ""

    override init() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "de-DE"))!
        super.init()
        speechRecognizer.delegate = self
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status == .authorized)
            }
        }
    }
    
    func startTranscribing() {
        // Ensure there's no ongoing transcription task
        print("Start Apple Transcription")
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }

        // Configure audio session for recording
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to set up audio session: \(error)")
            return
        }

        // Create a new recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create a new SFSpeechAudioBufferRecognitionRequest.")
        }

        // Configure the recognition request
        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.requiresOnDeviceRecognition = false

        // Create a recognition task
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            if let result = result {
                self?.transcription = result.bestTranscription.formattedString
        
                
                self?.onTranscriptionUpdate?(result.bestTranscription.formattedString)
                
                //print(self?.transcription)
                self?.isTranscribing = !result.isFinal
            }
            
            if error != nil || (result?.isFinal ?? false) {
                self?.stopTranscribing()
            }
        }

        // Start audio input capture
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            recognitionRequest.append(buffer)
        }

        // Prepare and start the audio engine
        audioEngine.prepare()
        do {
            try audioEngine.start()
            isTranscribing = true
        } catch {
            print("Could not start audio engine: \(error)")
            recognitionRequest.endAudio()
            recognitionTask?.cancel()
            isTranscribing = false
        }
    }

    func stopTranscribing() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        isTranscribing = false
        transcription = ""
    }

    func toggleTranscribing() {
        if isTranscribing {
            stopTranscribing()
        } else {
            startTranscribing()
        }
    }
}
