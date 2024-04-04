//
//  WelcomeView.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 21.03.24.
//

import SwiftUI

struct WelcomeView: View {
    @State var showNextView: Bool = false
    @State private var qrCodeData: QRCodeData?
    @State private var isScanning = false
    
    var body: some View {
        NavigationStack {
                
            if !isScanning {
                VStack{
                    Text("Test beginnen")
                        .font(.custom("SFProText-SemiBold", size: 60))
                        .padding(.bottom,60)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    
                    Text("Bitte geben Sie das Gerät jetzt an die Testperson weiter.")
                        .font(.custom("SFProText-SemiBold", size: 25))
                        .foregroundStyle(Color(hex: "#958787"))
                        .padding(.top)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Nach Abschluss des Tests werden die erfassten Daten automatisch hochgeladen.")
                        .font(.custom("SFProText-SemiBold", size: 25))
                        .foregroundStyle(Color(hex: "#958787"))
                        .padding(.top)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Stellen Sie dafür sicher, dass das Gerät am Stromnetz angeschlossen ist.")
                        .font(.custom("SFProText-SemiBold", size: 25))
                        .foregroundStyle(Color(hex: "#958787"))
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Nachdem die Daten hochgeladen sind, müssen Sie die App für den nächsten User neu starten.")
                        .font(.custom("SFProText-SemiBold", size: 25))
                        .foregroundStyle(Color(hex: "#958787"))
                        .padding(.top)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Wenn Sie jetzt auf den Button QR-Code scannen drücken, wird die Kamera des Geräts geöffnet")
                        .font(.custom("SFProText-SemiBold", size: 25))
                        .foregroundStyle(Color(hex: "#958787"))
                        .padding(.top)
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    
                    Text("Halten Sie bitte die Kamera über den Ihnen gegebenen QR-Code damit das Gerät diesen erkennen kann.")
                        .font(.custom("SFProText-SemiBold", size: 25))
                        .foregroundStyle(Color(hex: "#958787"))
                        .padding(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Button(action: {
                        // For disabling for testCases --> change to !=
                        if qrCodeData == nil {
                            isScanning = true
                        } else {
                            showNextView = true
                        }
                    }) {
                        Text(qrCodeData != nil ? "Weiter": "QR-Code scannen")
                            .font(.custom("SFProText-SemiBold", size: 25))
                            .foregroundStyle(.white)
                    }
                    .padding(20)
                    .background(.blue)
                    .cornerRadius(10)
                    .padding(.top,70)
                    .padding(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .navigationBarBackButtonHidden(true)
                    .navigationDestination(isPresented: $showNextView) {
                        WelcomeStudyView()
                    }
                }
            } else {
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

#Preview {
    WelcomeView()
}
