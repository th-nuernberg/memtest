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
                                    Text(qrCodeData != nil ? "Erneut Scannen" : "Scan") // Dynamischer Button-Text
                                }
                                .padding()
                                .font(.title)
                                .foregroundColor(qrCodeData == nil ? .white : .black)
                                .frame(maxWidth: .infinity)
                                .background(qrCodeData == nil ? .tBlue : .lGray)
                                .cornerRadius(30)
                                .padding()
                                
                                if qrCodeData != nil {
                                    Button("Weiter") {
                                        showNextView.toggle()
                                    }
                                    .padding()
                                    .font(.title)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .background(.tBlue)
                                    .cornerRadius(30)
                                    .padding()
                                    .navigationDestination(isPresented: $showNextView) {
                                        DataInputView()
                                    }
                                    .navigationBarBackButtonHidden(true)
                                }
                            }
                        
                        }
                    }
                    .navigationBarTitle("Scan QR Code", displayMode: .inline)
                }
               
                    
                if isScanning {
                    QRCodeScannerView(qrCodeData: $qrCodeData, isScanning: $isScanning) // Binden des isScanning-Zustands
                    .edgesIgnoringSafeArea(.all)
                    .transition(.move(edge: .bottom))
                    .onDisappear {
                        isScanning = false // Setzt den Zustand zurück, wenn die Ansicht verschwindet
                    }
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
