//
//  AudioService.swift
//  memtest-app
//
//  Created by Christopher Witzl on 21.03.24.
//

import Foundation
import Speech
import AVFoundation
import NaturalLanguage

protocol AudioServiceDelegate: AnyObject {
    func audioService(_ service: AudioService, didRecognizeText text: String)
    func audioService(_ service: AudioService, didChangeAvailability isAvailable: Bool)
    func audioService(_ service: AudioService, didUpdateInputLevel level: Float)
}

/// `AudioService` is responsible for handling audio recording and transcription using a specified transcription service
///
/// Features:
/// - Starts and stops audio recording
/// - Updates input audio level for visual indicators
/// - Interfaces with different transcription services
///
/// - Parameters:
///   - concreteTranscriptionService: The transcription service to use for audio transcription
class AudioService: NSObject, SFSpeechRecognizerDelegate {
    static let shared = AudioService(concreteTranscriptionService: AppleTranscriptionService())
    
    private var concreteTranscriptionService: TranscriptionService
    
    private let audioEngine = AVAudioEngine()
    private var audioFile: AVAudioFile?
    weak var delegate: AudioServiceDelegate?
    
    private var inputLevelUpdateTimer: Timer?
    
    init(concreteTranscriptionService: TranscriptionService) {
        self.concreteTranscriptionService = concreteTranscriptionService
        super.init()
    }
    
    /// Starts audio recording and transcription
    ///
    /// - Parameter testName: The name of the test for which audio is being recorded
    func startRecording(to testName: String) throws {
        prepareRecordingDirectory(for: testName)
        try configureAudioSession()
        try startAudioEngineRecording(to: testName)
        
        self.concreteTranscriptionService.onTranscriptionUpdate = { [weak self] updatedText in
            DispatchQueue.main.async {
                self?.delegate?.audioService(self!, didRecognizeText: updatedText)
            }
        }
        
        concreteTranscriptionService.startTranscribing()
    }
    
    /// Stops audio recording and transcription
    ///
    /// - Parameter completion: An optional closure to be executed after stopping the recording
    func stopRecording(completion: (() -> Void)? = nil) {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        concreteTranscriptionService.stopTranscribing()
        audioFile = nil
        completion?()
    }
    
    // MARK: - SFSpeechRecognizerDelegate
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        delegate?.audioService(self, didChangeAvailability: available)
    }
    
    // MARK: - Private Methods
    
    // Creates a directory for the audio recording
    private func prepareRecordingDirectory(for testName: String) {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let testDirectory = documentsDirectory.appendingPathComponent("\(DataService.shared.getUUID())/\(testName)")
        
        // Create the directory if it does not exist
        if !fileManager.fileExists(atPath: testDirectory.path) {
            try? fileManager.createDirectory(at: testDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        
        let filePath = testDirectory.appendingPathComponent("\(testName).m4a")
        self.audioFile = try? AVAudioFile(forWriting: filePath, settings: [:])
    }
    
    // Configures the audio session
    private func configureAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }
    
    // Starts audio engine recording
    private func startAudioEngineRecording(to testName: String) throws {
        prepareRecordingDirectory(for: testName)
        
        // Use sample rate defined in the used TranscriptionService implementation
        if let sampleRate = concreteTranscriptionService.usedSampleRate {
            try AVAudioSession.sharedInstance().setPreferredSampleRate(sampleRate)
        }
        
        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        
        // Remove previous existing tap
        audioEngine.inputNode.removeTap(onBus: 0)
        
        // Install a new tap
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer, _) in
            self?.appendAudioToFile(buffer)
            self?.updateInputLevel(buffer: buffer)
            self?.concreteTranscriptionService.processAudioBuffer(buffer, sampleRate: Int(AVAudioSession.sharedInstance().sampleRate), bufferSize: Int(buffer.frameLength))
        }
        
        // Prepare and start the audio engine
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    // Updates the input audio level for visual indicators
    private func updateInputLevel(buffer: AVAudioPCMBuffer) {
        let level = calculateAudioLevel(from: buffer)
        DispatchQueue.main.async {
            self.delegate?.audioService(self, didUpdateInputLevel: level)
        }
    }
    
    // Appends audio to the file
    private func appendAudioToFile(_ buffer: AVAudioPCMBuffer) {
        guard let audioFile = self.audioFile else { return }
        do {
            try audioFile.write(from: buffer)
        } catch {
            print("Could not write to audio file: \(error)")
        }
    }
    
    // Calculates the audio level in a logarithmic scale
    private func calculateAudioLevel(from buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData else { return 0.0 }
        
        let frameLength = Int(buffer.frameLength)
        var sum: Float = 0
        for i in 0..<frameLength {
            let sample = channelData.pointee[i]
            sum += sample * sample
        }
        
        let meanSquare = sum / Float(frameLength)
        let rms = sqrt(meanSquare)
        
        if rms == 0 { return 0.0 }
        let dB = 20 * log10(rms)
        
        let minDB: Float = -70.0
        let normalizedDB = min(max(minDB, dB), 0)
        let level = pow((normalizedDB - minDB) / (-minDB), 1/2.0)
        
        return level
    }
}

// Protocol that every transcription service must conform to
protocol TranscriptionService {
    var isTranscribing: Bool { get }
    var transcription: String { get set }
    var usedSampleRate: Double? { get }
    
    var onTranscriptionUpdate: ((String) -> Void)? { get set }
    
    func startTranscribing()
    func stopTranscribing()
    func toggleTranscribing()
    func processAudioBuffer(_ buffer: AVAudioPCMBuffer, sampleRate: Int, bufferSize: Int)
}

/// `SpeechRecognitionManager` a class used for interfacing with transcribed audio, updating input audio level, and animating the avatar on speech detection
///
/// - Features:
///   - Publishes recognized words and input level
///   - Notifies about avatar animation on speech detection
class SpeechRecognitionManager: ObservableObject, AudioServiceDelegate {
    static let shared = SpeechRecognitionManager()
    
    @Published var recognizedWords: [String] = []
    @Published var inputLevel: Float = 0.0
    @Published var shouldAnimateAvatar: Bool = false
    
    private var lastNotificationTime: Date?
    private let throttleInterval: TimeInterval = 0.75
    
    private init() {
        AudioService.shared.delegate = self
    }
    
    func audioService(_ service: AudioService, didRecognizeText text: String) {
        DispatchQueue.main.async {
            let words = text.split(separator: " ").map(String.init)
            self.recognizedWords.append(contentsOf: words)
            self.throttleNotification()
        }
    }
    
    // Throttles the notification to prevent frequent updates
    private func throttleNotification() {
        let now = Date()
        if let lastTime = lastNotificationTime, now.timeIntervalSince(lastTime) < throttleInterval {
            return
        }
        
        lastNotificationTime = now
        NotificationCenter.default.post(name: .triggerAvatarAnimation, object: nil)
    }
    
    func removeLastWord() {
        if !recognizedWords.isEmpty {
            recognizedWords.removeLast()
        }
    }
    
    func audioService(_ service: AudioService, didChangeAvailability isAvailable: Bool) {}
    
    func audioService(_ service: AudioService, didUpdateInputLevel level: Float) {
        self.inputLevel = level
    }
}

extension Notification.Name {
    static let didRecognizeNoun = Notification.Name("didRecognizeNoun")
    static let triggerAvatarAnimation = Notification.Name("triggerAvatarAnimation")
}
