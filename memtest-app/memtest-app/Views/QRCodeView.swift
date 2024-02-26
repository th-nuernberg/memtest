//
//  QRCodeView.swift
//  memtest-app
//
//  Created by Christopher Witzl on 22.02.24.
//

import SwiftUI
import AVFoundation

struct QRCodeScannerView: UIViewControllerRepresentable {
    @Binding var scannedCode: String?
        @Binding var isScanning: Bool // Hinzufügen eines Bindings für isScanning
        @Environment(\.presentationMode) var presentationMode
        
        class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
            var parent: QRCodeScannerView
            
            init(parent: QRCodeScannerView) {
                self.parent = parent
            }
            
            func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
                if let metadataObject = metadataObjects.first {
                    guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                    guard let stringValue = readableObject.stringValue else { return }
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                    parent.scannedCode = stringValue
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
        
        captureSession.startRunning()
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct QRCodeView: View {
    @State private var scannedCode: String? = "TEST"
    @State private var isScanning = false // Zustand, um das Scannen zu steuern
    
    var body: some View {
        if !isScanning {
            ZStack {
                VStack {
                    VStack {
                        Text("Bitte Scannen Sie den QR-Code")
                            .font(.title)
                            .bold()
                            .padding()
                            .foregroundColor(.black)
                            
                        if let scannedCode = scannedCode, !scannedCode.isEmpty {
                            Text(scannedCode)
                                .font(.title)
                                .foregroundColor(.black)
                                .padding()
                        }
                    }
                    .background(Color("l_gray"))
                    .cornerRadius(10)
                    
                    Spacer()
                }
                
                
                VStack {
                    Spacer()
                    Button("Scan") {
                        isScanning = true
                    }
                    .padding()
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .background(Color("t_blue"))
                    .cornerRadius(30)
                    .padding()
                
                }
            } 
            .background(Color.white)
            .navigationBarTitle("Scan QR Code", displayMode: .inline)
        }
       
            
        if isScanning {
            QRCodeScannerView(scannedCode: $scannedCode, isScanning: $isScanning) // Binden des isScanning-Zustands
            .edgesIgnoringSafeArea(.all)
            .transition(.move(edge: .bottom))
            .onDisappear {
                isScanning = false // Setzt den Zustand zurück, wenn die Ansicht verschwindet
            }
        }
        
    }
}
struct QRCodeView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeView()
    }
}
