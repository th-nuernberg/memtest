//
//  HomeView.swift
//  memtest-app
//
//  Created by Christopher Witzl on 13.05.24.
//

import SwiftUI

struct HomeView: View {
    @State private var isAdminMode = false
    @State private var zippedFiles: [String] = []

    var nextView: ((_ nextView: VisibleView) -> Void)
    
    public var isAdminModeActive: Bool {
        return isAdminMode
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Button(action: {
                    isAdminMode.toggle()
                    DataService.shared.toggleDebugMode()
                }) {
                    HStack {
                        Image(systemName: "ladybug.fill")
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
            
            Spacer()
            
            HStack(spacing: 20) {
                navigationButton(title: "SKT", color: .blue, action: {
                    nextView(.skt)
                })
                navigationButton(title: "VFT", color: .blue, action: {
                    nextView(.vft)
                })
            }
            .padding(.bottom, 20)
            
            HStack(spacing: 20) {
                navigationButton(title: "BNT", color: .blue, action: {
                    nextView(.bnt)
                })
                navigationButton(title: "PDT", color: .blue, action: {
                    nextView(.pdt)
                })
            }
            
            Spacer()
            
            HStack {
                Button(action: {
                    // TODO: add uploading functionality
                }) {
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title)
                        Text("Upload")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(.blue)
                    .cornerRadius(10)
                }
                .padding()
                
                Button(action: {
                    isAdminMode.toggle()
                    if isAdminMode {
                        zippedFiles = fetchZippedFiles() // Fetch files when Admin mode is turned on
                    }
                }) {
                    HStack {
                        Image(systemName: "ladybug.fill")
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
            
            Spacer()
            
            HStack {
                VStack {
                    HStack(spacing: 20) {
                        navigationButton(title: "SKT", color: .blue, action: {
                            nextView(.skt)
                        })
                        navigationButton(title: "VFT", color: .blue, action: {
                            nextView(.vft)
                        })
                    }
                    .padding(.bottom, 20)
                    
                    HStack(spacing: 20) {
                        navigationButton(title: "BNT", color: .blue, action: {
                            nextView(.bnt)
                        })
                        navigationButton(title: "PDT", color: .blue, action: {
                            nextView(.pdt)
                        })
                    }
                    
                    Spacer()
                    
                    HStack {
                        Button(action: {
                            // TODO: add uploading functionality
                        }) {
                            HStack {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.title)
                                Text("Upload")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(.blue)
                            .cornerRadius(10)
                        }
                        .padding()
                        
                        Button(action: {
                            // TODO: add functionality to end the test
                        }) {
                            HStack {
                                Image(systemName: "stop.fill")
                                    .font(.title)
                                Text("Test Beenden")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(.blue)
                            .cornerRadius(10)
                        }
                        .padding()
                    }
                }
                if isAdminMode {
                    VStack {
                        Text("Verschlüsselte Testergebnisse")
                            .font(.title)
                        List(zippedFiles, id: \.self) { file in
                            Text(file)
                        }
                    }
                   
               }
            }
            
            
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
    
    func fetchZippedFiles() -> [String] {
        let fileManager = FileManager.default
        var documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            //return fileURLs.filter { $0.pathExtension == "zip" }.map { $0.lastPathComponent }
            return fileURLs.map { $0.lastPathComponent }
        } catch {
            print("Error while enumerating files: \(error.localizedDescription)")
        }
        
        return []
    }

}

#Preview {
    HomeView() {nextView in }
}
