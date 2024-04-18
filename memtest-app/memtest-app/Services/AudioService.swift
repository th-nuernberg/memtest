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

    
    func startRecording(to testName: String) throws {
        prepareRecordingDirectory(for: testName)
        try configureAudioSession()
        
        try startAudioEngineRecording(to: testName)
        
        
        self.concreteTranscriptionService.onTranscriptionUpdate = { [weak self] updatedText in
            DispatchQueue.main.async {                
                self?.delegate?.audioService(self!, didRecognizeText:updatedText)
                
            }
        }

        
        concreteTranscriptionService.startTranscribing()
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
    
    private func configureAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }

    private func startAudioEngineRecording(to testName: String) throws {
        prepareRecordingDirectory(for: testName)
        // TODO: use 16000 for whisper
        try! AVAudioSession.sharedInstance().setPreferredSampleRate(16000)
        
        print("Sample Rate: \(AVAudioSession.sharedInstance().sampleRate)")
        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        
        audioEngine.inputNode.removeTap(onBus: 0)
        
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer, _) in
            
            self?.appendAudioToFile(buffer)
            self?.updateInputLevel(buffer: buffer)
            self?.concreteTranscriptionService.processAudioBuffer(buffer, sampleRate: Int(AVAudioSession.sharedInstance().sampleRate), bufferSize: Int(buffer.frameLength))
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

protocol TranscriptionService {
    var isTranscribing: Bool { get }
    var transcription: String { get set }
    
    var onTranscriptionUpdate: ((String) -> Void)? { get set }
    
    func startTranscribing()
    func stopTranscribing()
    func toggleTranscribing()
    func processAudioBuffer(_ buffer: AVAudioPCMBuffer, sampleRate: Int, bufferSize: Int)
}



import NaturalLanguage
class SpeechRecognitionManager: ObservableObject, AudioServiceDelegate {
    static let shared = SpeechRecognitionManager()
       
    @Published var recognizedWords: [String] = []
    @Published var inputLevel: Float = 0.0
    @Published var shouldAnimateAvatar: Bool = false  

    private var lastNotificationTime: Date?
    private let throttleInterval: TimeInterval = 4.0
    
    private init() {
       AudioService.shared.delegate = self
    }

    func audioService(_ service: AudioService, didRecognizeText text: String) {
        DispatchQueue.main.async {
            let words = text.split(separator: " ").map(String.init)
            self.recognizedWords.append(contentsOf: words)
            
            let tokenizer = NLTokenizer(unit: .word)
            tokenizer.string = text
            
            if self.isNounInText(text: text) {
                self.throttleNotification()
            }
        }
    }

    private func isNounInText(text: String) -> Bool {
        return true
        /*
        
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text
        let wholeText = text.startIndex..<text.endIndex
        tagger.setLanguage(.german, range: wholeText)
        let options: NLTagger.Options = [.omitWhitespace, .omitPunctuation]
        var containsNoun = false
        tagger.enumerateTags(in: wholeText, unit: .word, scheme: .lexicalClass, options: options) { tag, range in
            if tag == .noun {
                containsNoun = true
                return false // Stop enumeration early since a noun is found
            }
            return true // Continue enumeration
        }
        return containsNoun */
    }
    
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

    func audioService(_ service: AudioService, didChangeAvailability isAvailable: Bool) {
        // TODO
    }

    func audioService(_ service: AudioService, didUpdateInputLevel level: Float) {
        self.inputLevel = level
    }
}

extension Notification.Name {
    static let didRecognizeNoun = Notification.Name("didRecognizeNoun")
    static let triggerAvatarAnimation = Notification.Name("triggerAvatarAnimation")
}

