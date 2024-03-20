//
//  QRCodeScannerView.swift
//  memtest-app
//
//  Created by Christopher Witzl on 06.03.24.
//

import SwiftUI
import AVFoundation

struct QRCodeScannerView: UIViewControllerRepresentable {
    @Binding var qrCodeData: QRCodeData?
    @Binding var isScanning: Bool // Hinzufügen eines Bindings für isScanning
    @Environment(\.presentationMode) var presentationMode
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: QRCodeScannerView
        
        init(parent: QRCodeScannerView) {
            self.parent = parent
        }
        
        @objc func cancelScanning() {
           parent.isScanning = false
           parent.presentationMode.wrappedValue.dismiss()
       }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                parent.qrCodeData = decodeQRCodeString(stringValue)
                parent.isScanning = false // Setzen Sie isScanning auf false, da ein QR-Code gescannt wurde
                parent.presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return viewController }
        let metadataOutput = AVCaptureMetadataOutput()
        
        do {
            let input = try AVCaptureDeviceInput(device: videoCaptureDevice)
            captureSession.addInput(input)
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } catch {
            // Fehlerbehandlung
            return viewController
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = viewController.view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)
        
        // Leiste am unteren Bildschirmrand
        let screenHeight = viewController.view.frame.size.height
        let barHeight: CGFloat = 60
        let bottomBar = UIView(frame: CGRect(x: 0, y: screenHeight - barHeight, width: viewController.view.frame.width, height: barHeight))
        bottomBar.backgroundColor = UIColor.black.withAlphaComponent(0.6) // Halbtransparent
        viewController.view.addSubview(bottomBar)
        
        // Abbrechen-Button
        let buttonWidth: CGFloat = 100
        let buttonHeight: CGFloat = 40
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Abbrechen", for: .normal)
        cancelButton.setTitleColor(.red, for: .normal)
        cancelButton.frame = CGRect(x: bottomBar.frame.width - buttonWidth - 20, y: (barHeight - buttonHeight) / 2, width: buttonWidth, height: buttonHeight) // Rechtsbündig in der Leiste
        cancelButton.addTarget(context.coordinator, action: #selector(Coordinator.cancelScanning), for: .touchUpInside)
        bottomBar.addSubview(cancelButton)
        
        captureSession.startRunning()
        
        return viewController
    }
    
    
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

}


class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var bottomBar: UIView!
    var cancelButton: UIButton!
    
    // Closure to handle scanned code
    var onCodeScanned: ((QRCodeData) -> Void)?
    var onCancel: (() -> Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDeviceOrientationChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.connection?.videoOrientation = .landscapeRight
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
        
        // Leiste am unteren Bildschirmrand
        let screenHeight = view.frame.size.height
        let barHeight: CGFloat = 60
        bottomBar = UIView(frame: CGRect(x: 0, y: screenHeight - barHeight, width: view.frame.width, height: barHeight))
        bottomBar.backgroundColor = UIColor.black.withAlphaComponent(0.6) // Halbtransparent
        view.addSubview(bottomBar)
        
        // Abbrechen-Button
        let buttonWidth: CGFloat = 100
        let buttonHeight: CGFloat = 40
        cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Abbrechen", for: .normal)
        cancelButton.setTitleColor(.red, for: .normal)
        cancelButton.frame = CGRect(x: bottomBar.frame.width - buttonWidth - 20, y: (barHeight - buttonHeight) / 2, width: buttonWidth, height: buttonHeight) // Rechtsbündig in der Leiste
        cancelButton.addTarget(self, action: #selector(cancelTapped) , for: .touchUpInside)
        bottomBar.addSubview(cancelButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds // Update the preview layer to fill the view
        
        // Update the bottom bar's frame
        let barHeight: CGFloat = 60
        bottomBar.frame = CGRect(x: 0, y: view.frame.height - barHeight, width: view.frame.width, height: barHeight)

        // Update the cancel button's frame
        let buttonWidth: CGFloat = 100
        let buttonHeight: CGFloat = 40
        cancelButton.frame = CGRect(x: bottomBar.frame.width - buttonWidth - 20, y: (barHeight - buttonHeight) / 2, width: buttonWidth, height: buttonHeight)

    }
    
    @objc func handleDeviceOrientationChange() {
        let orientation = UIDevice.current.orientation
        guard let connection = previewLayer.connection, connection.isVideoOrientationSupported else { return }

        switch orientation {
        case .portrait:
            connection.videoOrientation = .portrait
        case .landscapeRight:
            connection.videoOrientation = .landscapeLeft // Note the inversion
        case .landscapeLeft:
            connection.videoOrientation = .landscapeRight // Note the inversion
        case .portraitUpsideDown:
            connection.videoOrientation = .portraitUpsideDown
        default:
            break // Ignore other orientations (e.g., face up, face down)
        }
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
        
        dismiss(animated: true)
    }
    
    func found(code: String) {
        if let decodedData = decodeQRCodeString(code) {
            onCodeScanned?(decodedData)
        } else {
            // Handle the case where decoding fails, if necessary
            print("Decoding QR code failed.")
        }
    }
    
    @objc func cancelTapped() {
        onCancel?()  // Calls the onCancel closure if it's set
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

struct ScannerView: UIViewControllerRepresentable {
    var onCodeScanned: (QRCodeData) -> Void
    var onCancel: () -> Void  // Add this line

    func makeUIViewController(context: Context) -> ScannerViewController {
        let controller = ScannerViewController()
        controller.onCodeScanned = onCodeScanned
        controller.onCancel = onCancel  // Set the closure
        return controller
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {
        // The closure is already set, nothing needed here for now.
    }
}
