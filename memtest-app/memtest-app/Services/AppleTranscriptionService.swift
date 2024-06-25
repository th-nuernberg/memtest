//
//  AppleTranscriptionService.swift
//  memtest-app
//
//  Created by Christopher Witzl on 13.04.24.
//

import Foundation
import Speech
import AVFoundation

/// `AppleTranscriptionService` handles audio transcription using Apple's `SFSpeechRecognizer`
///
/// Features:
/// - Requests authorization for speech recognition
/// - Starts and stops transcribing audio
/// - Provides real-time updates of transcribed text
///
/// - Parameters:
///   - usedSampleRate: The sample rate used for audio processing
///   - onTranscriptionUpdate: Callback for updating the transcribed text
class AppleTranscriptionService: NSObject, TranscriptionService, SFSpeechRecognizerDelegate {
    var usedSampleRate: Double?
    
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
    
    /// Requests authorization for speech recognition
    ///
    /// - Parameter completion: A closure called with the authorization status
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status == .authorized)
            }
        }
    }
    
    /// Starts transcribing audio
    func startTranscribing() {
        // Remove existing transcription task if it exists
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
                
                // Use callback to propagate the transcribed text
                self?.onTranscriptionUpdate?(result.bestTranscription.formattedString)
                
                self?.isTranscribing = !result.isFinal
            }
            
            if error != nil || (result?.isFinal ?? false) {
                self?.stopTranscribing()
            }
        }
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        // Install tap for speech transcribing
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
    
    /// Stops transcribing audio
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
    
    /// Toggles the transcribing state
    func toggleTranscribing() {
        if isTranscribing {
            stopTranscribing()
        } else {
            startTranscribing()
        }
    }
    
    /// Processes an audio buffer (no operation needed for Apple transcription)
    ///
    /// this is for conforming to the TranscriptionServiceProtocol -> apple Transcription works a little bit different than the WhisperTranscription
    ///
    /// - Parameters:
    ///   - buffer: The audio buffer to process
    ///   - sampleRate: The sample rate of the audio buffer
    ///   - bufferSize: The size of the audio buffer
    func processAudioBuffer(_ buffer: AVAudioPCMBuffer, sampleRate: Int, bufferSize: Int) {
        // No operation needed for Apple transcription
    }
}
