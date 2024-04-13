//
//  AudioService.swift
//  memtest-app
//
//  Created by Christopher Witzl on 21.03.24.
//

import Foundation
import Speech
import AVFoundation

protocol AudioServiceDelegate: AnyObject {
    func audioService(_ service: AudioService, didRecognizeText text: String)
    func audioService(_ service: AudioService, didChangeAvailability isAvailable: Bool)
    
    func audioService(_ service: AudioService, didUpdateInputLevel level: Float)
}


class AudioService: NSObject, SFSpeechRecognizerDelegate {
    static let shared = AudioService()
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "de-DE"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var audioFile: AVAudioFile?
    weak var delegate: AudioServiceDelegate?
    
    private var inputLevelUpdateTimer: Timer?
    
    override init() {
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
    
    func startRecording(to testName: String) throws {
        prepareRecordingDirectory(for: testName)
        resetRecognitionTask()
        try configureAudioSession()
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create request.") }
        
        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.requiresOnDeviceRecognition = false
        
        startRecognitionTask(using: recognitionRequest)
        try startAudioEngineRecording(to: testName)
    }
    
    func stopRecording(completion: (() -> Void)? = nil) {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        audioFile = nil
        completion?()
    }
    
    // MARK: - SFSpeechRecognizerDelegate
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        delegate?.audioService(self, didChangeAvailability: available)
    }
    
    // MARK: - Private Methods
    
    private func prepareRecordingDirectory(for testName: String) {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let testDirectory = documentsDirectory.appendingPathComponent("tests/\(testName)")
        
        // Create the directory if it does not exist
        if !fileManager.fileExists(atPath: testDirectory.path) {
            try? fileManager.createDirectory(at: testDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        
        let filePath = testDirectory.appendingPathComponent("\(testName).m4a")
        self.audioFile = try? AVAudioFile(forWriting: filePath, settings: [:])
    }
    
    private func resetRecognitionTask() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
    }
    
    private func configureAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }
    
    private func startRecognitionTask(using request: SFSpeechAudioBufferRecognitionRequest) {
        recognitionTask = speechRecognizer.recognitionTask(with: request) { [weak self] result, error in
            var isFinal = false
            if let result = result {
                self?.delegate?.audioService(self!, didRecognizeText: result.bestTranscription.formattedString)
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self?.stopRecording()
            }
        }
    }
    
    private func startAudioEngineRecording(to testName: String) throws {
        prepareRecordingDirectory(for: testName)
        
        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        
        audioEngine.inputNode.removeTap(onBus: 0)
        
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer, _) in
            self?.recognitionRequest?.append(buffer)
            self?.appendAudioToFile(buffer)
            self?.updateInputLevel(buffer: buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    private func updateInputLevel(buffer: AVAudioPCMBuffer) {
        let level = self.calculateAudioLevel(from: buffer)
        DispatchQueue.main.async {
            self.delegate?.audioService(self, didUpdateInputLevel: level)
        }
    }
    
    
    private func appendAudioToFile(_ buffer: AVAudioPCMBuffer) {
        guard let audioFile = self.audioFile else { return }
        do {
            try audioFile.write(from: buffer)
        } catch {
            print("Could not write to audio file: \(error)")
        }
    }
    
    func startInputLevelMonitoring() {
        let inputNode = audioEngine.inputNode // 'inputNode' is not optional, so we don't use 'if let' or 'guard let'
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer, _) in
            self?.updateInputLevel(buffer: buffer)
        }

        do {
            try audioEngine.start()
        } catch {
            print("AudioEngine couldn't start because of an error: \(error)")
        }
    }

    // Call this function to stop monitoring the audio input level
    func stopInputLevelMonitoring() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        inputLevelUpdateTimer?.invalidate()
        inputLevelUpdateTimer = nil
    }
    
    private func calculateAudioLevel(from buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData else { return 0.0 }

        // Calculate the sum of squares of each sample
        let frameLength = Int(buffer.frameLength)
        var sum: Float = 0
        for i in 0..<frameLength {
            let sample = channelData.pointee[i]
            sum += sample * sample
        }
        
        // Calculate the mean squared value
        let meanSquare = sum / Float(frameLength)
        
        // Calculate the RMS value
        let rms = sqrt(meanSquare)

        // Normalize the RMS value
        let normalizedLevel = min(1.0, rms * 60)
        
        return normalizedLevel
    }
}


class SpeechRecognitionManager: ObservableObject, AudioServiceDelegate {
    static let shared = SpeechRecognitionManager()
       
   @Published var recognizedWords: [String] = []
   @Published var inputLevel: Float = 0.0

   private init() {
       AudioService.shared.delegate = self
   }
    
    func audioService(_ service: AudioService, didRecognizeText text: String) {
        DispatchQueue.main.async {
            let words = text.split(separator: " ").map(String.init)
            self.recognizedWords.append(contentsOf: words)
        }
    }
    
    func removeLastWord() {
        if !recognizedWords.isEmpty {
            recognizedWords.removeLast()
        }
    }

    func audioService(_ service: AudioService, didChangeAvailability isAvailable: Bool) {
        // TODO
    }
    
    func audioService(_ service: AudioService, didUpdateInputLevel level: Float) {
        self.inputLevel = level
    }
}

