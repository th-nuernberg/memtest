//
//  HomeView.swift
//  memtest-app
//
//  Created by Christopher Witzl on 13.05.24.
//
import SwiftUI

struct HomeView: View {
    @State private var isAdminMode = false
    @State private var isCalibrated: Bool = DataService.shared.hasCalibrated()
    
    var nextView: ((_ nextView: VisibleView) -> Void)
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Button(action: {
                    isAdminMode.toggle()
                    SettingsService.shared.toggleAdminMode()
                }) {
                    HStack {
                        Image(systemName: "person.fill")
                            .font(.title)
                        Text(isAdminMode ? "Admin On" : "Admin Off")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(isAdminMode ? Color.red : Color.gray)
                    .cornerRadius(10)
                }
                .padding()
            }
            
            Spacer(minLength: 20)
            
            Button(action: {
                nextView(.calibration)
            }) {
                HStack {
                    Image(systemName: "gear")
                        .font(.title)
                    Text("Kalibrieren")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.green)
                .cornerRadius(10)
            }
            .padding()

            // Test Buttons
            HStack(spacing: 20) {
                navigationButton(title: "SKT", color: isCalibrated ? .blue : .gray, action: {
                    nextView(.skt)
                }).disabled(!isCalibrated)
                
                navigationButton(title: "VFT", color: isCalibrated ? .blue : .gray, action: {
                    nextView(.vft)
                }).disabled(!isCalibrated)
            }
            .padding(.bottom, 20)
            
            HStack(spacing: 20) {
                navigationButton(title: "BNT", color: isCalibrated ? .blue : .gray, action: {
                    nextView(.bnt)
                }).disabled(!isCalibrated)
                
                navigationButton(title: "PDT", color: isCalibrated ? .blue : .gray, action: {
                    nextView(.pdt)
                }).disabled(!isCalibrated)
            }

            Spacer()
            
            HStack {
                Button(action: {
                    // Upload functionality goes here
                }) {
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title)
                        Text("Upload")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .padding()
                
                Button(action: {
                    // End session functionality goes here
                }) {
                    HStack {
                        Image(systemName: "stop.fill")
                            .font(.title)
                        Text("Sitzung beenden")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                .padding()
            }
            
            Spacer()
            
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func navigationButton(title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 150, height: 150)
                .background(color)
                .cornerRadius(10)
        }
    }
}

#Preview {
    HomeView() {nextView in }
}
