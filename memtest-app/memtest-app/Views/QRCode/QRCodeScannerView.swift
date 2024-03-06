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
