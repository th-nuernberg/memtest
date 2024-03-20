//
//  SpeechRecognitionService.swift
//  memtest-app
//
//  Created by Christopher Witzl on 20.03.24.
//

import Foundation
import Speech

protocol SpeechRecognitionServiceDelegate: AnyObject {
    func speechRecognitionService(_ service: SpeechRecognitionService, didRecognizeText text: String)
    func speechRecognitionServiceDidChangeAvailability(_ service: SpeechRecognitionService, isAvailable: Bool)
}

class SpeechRecognitionService: NSObject, SFSpeechRecognizerDelegate {
    static let shared = SpeechRecognitionService() // Singleton instance, if appropriate for your use case
    
    private let speechRecognizer: SFSpeechRecognizer
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    weak var delegate: SpeechRecognitionServiceDelegate?
    
    override init() {
        // Initialize with your desired locale
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "de-DE"))!
        super.init()
        speechRecognizer.delegate = self
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                completion(authStatus == .authorized)
            }
        }
    }
    
    func startRecording() throws {
        // Ensure there's no ongoing recognition task
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { throw NSError(domain: "SpeechRecognitionServiceError", code: 0, userInfo: nil) }
        
        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.requiresOnDeviceRecognition = false // Modify as needed
        
        // Start recognition task
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            var isFinal = false
            if let result = result {
                isFinal = result.isFinal
                self?.delegate?.speechRecognitionService(self!, didRecognizeText: result.bestTranscription.formattedString)
            }
            if error != nil || isFinal {
                self?.stopRecording()
            }
        }
        
        // Setup audio engine and microphone input
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer, _) in
            self?.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask = nil
    }
    
    // SFSpeechRecognizerDelegate method
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        delegate?.speechRecognitionServiceDidChangeAvailability(self, isAvailable: available)
    }
}




class SpeechRecognitionManager: ObservableObject, SpeechRecognitionServiceDelegate {
    @Published var recognizedText = ""
    
    init() {
        SpeechRecognitionService.shared.delegate = self
    }
    
    func speechRecognitionService(_ service: SpeechRecognitionService, didRecognizeText text: String) {
        DispatchQueue.main.async {
            self.recognizedText = text
        }
    }
    
    func speechRecognitionServiceDidChangeAvailability(_ service: SpeechRecognitionService, isAvailable: Bool) {
        // Handle the availability change if needed
    }
}
