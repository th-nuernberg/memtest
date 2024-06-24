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


class AudioService: NSObject, SFSpeechRecognizerDelegate {
    // using the AppleTranscriptionService
    static let shared = AudioService(concreteTranscriptionService: AppleTranscriptionService())
    
    // The used Transcription Service (e.g. AppleTranscriptionService or the WhisperTranscriptionService)
    private var concreteTranscriptionService: TranscriptionService
    
    private let audioEngine = AVAudioEngine()
    private var audioFile: AVAudioFile?
    weak var delegate: AudioServiceDelegate?
    
    private var inputLevelUpdateTimer: Timer?
    
    init(concreteTranscriptionService: TranscriptionService) {
        self.concreteTranscriptionService = concreteTranscriptionService
        super.init()
    }

    
    // this is called in every Test that needs audio to be recorded
    func startRecording(to testName: String) throws {
        prepareRecordingDirectory(for: testName)
        try configureAudioSession()
        
        try startAudioEngineRecording(to: testName)
        
        
        self.concreteTranscriptionService.onTranscriptionUpdate = { [weak self] updatedText in
            DispatchQueue.main.async {                
                self?.delegate?.audioService(self!, didRecognizeText:updatedText)
                
            }
        }

        
        // concreteTranscriptionService.startTranscribing()
    }
    
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
    
    // Create a directory for the audio recording -> foo -> /Documents/uuid/foo/foo.m4a
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
    
    private func configureAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }

    private func startAudioEngineRecording(to testName: String) throws {
        prepareRecordingDirectory(for: testName)
        
        // use sample rate defined in the used TranscriptionService Implementation
        if concreteTranscriptionService.neededSampleRate {
            try! AVAudioSession.sharedInstance().setPreferredSampleRate(concreteTranscriptionService.neededSampleRate)
        }
        
        
        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        
        // remove previous exsisting tap -> if not removed an error is thrown on installing a new tap
        audioEngine.inputNode.removeTap(onBus: 0)
        
        // the buffer size can not be set arbitrarily -> if accumulation is needed, like in the WhisperTranscriptionService the accumulation of the audio has to haoppen in the processAudioBuffer method
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer, _) in
            self?.appendAudioToFile(buffer)
            // used for the AudioIndicatorView
            self?.updateInputLevel(buffer: buffer)
            // the actual transcriptioning is happening here
            self?.concreteTranscriptionService.processAudioBuffer(buffer, sampleRate: Int(AVAudioSession.sharedInstance().sampleRate), bufferSize: Int(buffer.frameLength))
        }
        
        // Trying to prepare and start the recording | transcription
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    // Needed for the AudioIndicatorView
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
    
    // logarithmic calculation for displaying the audio in a human friendly way
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
        
        let level = pow((normalizedDB - minDB) / (-minDB), 1/2.0) // Using a square root to increase sensitivity

        return level
    }
}

// The protocol every new subcription Service has to conform
protocol TranscriptionService {
    var isTranscribing: Bool { get }
    var transcription: String { get set }
    let neededSampleRate: Int?
    
    var onTranscriptionUpdate: ((String) -> Void)? { get set }
    
    func startTranscribing()
    func stopTranscribing()
    func toggleTranscribing()
    func processAudioBuffer(_ buffer: AVAudioPCMBuffer, sampleRate: Int, bufferSize: Int)
}


// this singleton class is used for interfacing with the transcribed audio, the inputAudioLevel for displaying the "loudness" and for animating the avatar if speech has been detected
// not the best implementation
// the speech detection should ideally be done by a VAD
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
    
    // throtteling the notification sending to prevent weird gif behavior
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

