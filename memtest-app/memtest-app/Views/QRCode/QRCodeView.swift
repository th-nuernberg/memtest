//
//  QRCodeView.swift
//  memtest-app
//
//  Created by Christopher Witzl on 22.02.24.
//

import SwiftUI
import AVFoundation

struct QRCodeView: View {
    @State private var qrCodeData: QRCodeData?
    @State private var isScanning = false // Zustand, um das Scannen zu steuern
    
    @State var showNextView: Bool = false
    var body: some View {
        NavigationStack {
            VStack{
                if !isScanning {
                    ZStack {
                        VStack {
                            VStack {
                                
                                if (qrCodeData == nil) {
                                    Text("Bitte Scannen Sie den QR-Code")
                                        .font(.title)
                                        .bold()
                                        .padding()
                                        .foregroundColor(.black)
                                }
                                
                                if let qrCodeData = $qrCodeData.wrappedValue { // Zugriff auf den Wert des Bindings
                                    if !qrCodeData.id.isEmpty { // Überprüfen, ob die ID leer ist
                                        
                                        Text("Studien-ID: "+qrCodeData.study_id)
                                            .font(.title)
                                            .foregroundColor(.black)
                                            .padding()
                                        
                                        Text(qrCodeData.id).foregroundColor(.black)
                                        Text(qrCodeData.key).foregroundColor(.black)
                                    }
                                }
                            }
                            .background(.lGray)
                            .cornerRadius(10)
                            
                            Spacer()
                            
                            
                        }
                        
                        VStack {
                            Spacer()
                            
                            HStack {
                                Button(action: {
                                    isScanning = true
                                }) {
                                    Text(qrCodeData != nil ? "Erneut Scannen" : "Scan")
                                        .padding()
                                        .font(.title)
                                        
                                }
                                .frame(maxWidth: .infinity)
                                .background(qrCodeData != nil ? .lGray : .tBlue)
                                .foregroundColor(qrCodeData != nil ? .black : .white)
                                .cornerRadius(10)
                                
                                if qrCodeData != nil {
                                    Button(action: {
                                        showNextView.toggle()
                                    }) {
                                        Text("Weiter")
                                            .padding()
                                            .font(.title)
                                        
                                    }
                                    .frame(maxWidth: .infinity)
                                    .foregroundColor(.white)
                                    .background(.tBlue)
                                    .cornerRadius(10)
                                    .navigationDestination(isPresented: $showNextView) {
                                        DataInputView()
                                    }
                                    .navigationBarBackButtonHidden(true)
                                    
                                }
                            }
                            .padding()
                        
                        }
                    }
                    
                }
               
                    
                if isScanning {
                    QRCodeScannerView(onCodeScanned: { code in
                        print(code)
                        qrCodeData = code
                        isScanning = false
                    }, onCancel: {
                        isScanning = false
                    })
                }
                
            }
        }
    }
}
struct QRCodeView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeView()
    }
}
