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
    // requesting authorization for audio processing
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status == .authorized)
            }
        }
    }
    
    func startTranscribing() {
        // remove transcription task if still exists
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }

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

        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.requiresOnDeviceRecognition = false

        // Create a recognition task
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            if let result = result {
                self?.transcription = result.bestTranscription.formattedString
        
                // use callback to propagate the transcribed text
                self?.onTranscriptionUpdate?(result.bestTranscription.formattedString)
                
                self?.isTranscribing = !result.isFinal
            }
            
            if error != nil || (result?.isFinal ?? false) {
                self?.stopTranscribing()
            }
        }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
    
        // install tap for speech transcribing
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            recognitionRequest.append(buffer)
        }

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
    // this is for conforming to the TranscriptionServiceProtocol -> apple Transcription works a little bit different than the WhisperTranscription
    func processAudioBuffer(_ buffer: AVAudioPCMBuffer, sampleRate: Int, bufferSize: Int) {
        // DO NOTHING
    }
}
