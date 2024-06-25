//
//  HomeView.swift
//  memtest-app
//
//  Created by Christopher Witzl on 13.05.24.
//
import SwiftUI
import memtest_server_client

/// `HomeView` serves as the main View of the memtest-app, allowing navigation to various test modules and administrative settings.
///
/// Features:
/// - Displays connection status to the server.
/// - Provides access to different test views based on the calibration status and test completion state.
/// - Allows administrators to toggle administrative mode and manage app settings.
/// - Supports navigation to a detailed settings view.
///
/// Actions:
/// - Toggle admin mode to access advanced settings.
/// - Check server connection on appearance and dynamically display network status.
/// - Navigate to different testing modules like SKT, VFT, BNT, and PDT.
/// - Perform data uploads and manage session endings.
struct HomeView: View {
    @State private var isAdminMode = false
    @State private var isServerConnected: Bool = false
    @State private var isCalibrated: Bool = DataService.shared.hasCalibrated()
    
    @State private var sktFinished: Bool = DataService.shared.hasSKTFinished()
    @State private var vftFinished: Bool = DataService.shared.hasVFTFinished()
    @State private var bntFinished: Bool = DataService.shared.hasBNTFinished()
    @State private var pdtFinished: Bool = DataService.shared.hasPDTFinished()
    
    @State private var errorMessage: String?
    
    var nextView: ((_ nextView: VisibleView) -> Void)
    
    var body: some View {
        VStack {
            HStack {
                // Displays if there is a connection to the backend
                Image(systemName: isServerConnected ? "network" : "network.slash")
                    .foregroundColor(isServerConnected ? .green : .red)
                    .padding(8)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
                
                /// Button for navigation to the AdminSettingsView if in AdminMode
                if isAdminMode {
                    Button(action: {
                        nextView(.settings)
                    }) {
                        Image(systemName: "gear")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .transition(.scale)
                }
                
                Spacer()
                
                // Admin Mode toggle button
                Button(action: {
                    isAdminMode.toggle()
                    SettingsService.shared.toggleAdminMode()
                    
                    
                    // TODO: Remove
                    if let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path {
                        let basePath = documentsPath.components(separatedBy: "/Documents").first ?? documentsPath
                        printDirectoryContents(path: documentsPath, basePath: basePath)
                    }
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
            
            // Button to start calibration if not yet calibrated
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
                .background(isCalibrated ? Color.gray : Color.green)
                .cornerRadius(10)
            }
            .disabled(isCalibrated)
            .padding()
            
            
            // The Buttons for the tests
            // They are disabled if, the test has been finished and/or if not yet calibrated
            HStack(spacing: 20) {
                navigationButton(title: "SKT", color: sktFinished || !isCalibrated ? .gray : .blue, action: {
                    nextView(.skt)
                }).disabled(sktFinished || !isCalibrated)
                
                navigationButton(title: "VFT", color: vftFinished || !isCalibrated ? .gray : .blue, action: {
                    nextView(.vft)
                }).disabled(vftFinished || !isCalibrated)
            }
            .padding(.bottom, 20)
            
            HStack(spacing: 20) {
                navigationButton(title: "BNT", color: bntFinished || !isCalibrated ? .gray : .blue, action: {
                    nextView(.bnt)
                }).disabled(bntFinished || !isCalibrated)
                
                navigationButton(title: "PDT", color: pdtFinished || !isCalibrated ? .gray : .blue, action: {
                    nextView(.pdt)
                }).disabled(pdtFinished || !isCalibrated)
            }
            Spacer()
            
            // Button for uploading the test results, if it fails, an alert is shown
            // Tries also to upload not yet uploaded testresults (e.g. if server was not reachable)
            HStack {
                Button(action: {
                    Task {
                        errorMessage = await DataService.shared.uploadAllZipFiles()
                        updateViewStates()
                    }
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
                .alert("Fehler beim Hochladen", isPresented: Binding<Bool>.constant(errorMessage != nil), presenting: errorMessage) { _ in
                    Button("OK") {
                        errorMessage = nil
                    }
                } message: { detail in
                    Text(detail)
                }
                
                // Button for complete session, therefore zipping and encrypting the testresult and deleting the tempory saved testresults
                // => then tries to upload the testresult
                Button(action: {
                    Task {
                        await DataService.shared.uploadAllZipFiles()
                        updateViewStates()
                    }
                    
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
        .onAppear() {
            checkServerConnection()
        }
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
    
    private func updateViewStates() {
        isCalibrated = DataService.shared.hasCalibrated()
        sktFinished = DataService.shared.hasSKTFinished()
        vftFinished = DataService.shared.hasVFTFinished()
        bntFinished = DataService.shared.hasBNTFinished()
        pdtFinished = DataService.shared.hasPDTFinished()
        checkServerConnection()
    }
    
    func checkServerConnection() {
        Task {
            isServerConnected = await DataService.shared.isServerConnectionHealthy()
        }
    }
    
}

// Helper method for displaying the folder structure in app Space
func printDirectoryContents(path: String, basePath: String? = nil, level: Int = 0) {
    let fileManager = FileManager.default
    let basePath = basePath ?? path // Set the base path only once to remove it from all paths
    
    do {
        let items = try fileManager.contentsOfDirectory(atPath: path)
        for item in items {
            let fullPath = (path as NSString).appendingPathComponent(item)
            var isDir: ObjCBool = false
            
            if fileManager.fileExists(atPath: fullPath, isDirectory: &isDir) {
                let relativePath = fullPath.replacingOccurrences(of: basePath, with: "")
                let indent = String(repeating: "    ", count: level) // Create an indent string of 4 spaces per level
                
                if isDir.boolValue {
                    // If it's a directory, print it and recurse
                    print("\(indent)- \(relativePath)/")
                    printDirectoryContents(path: fullPath, basePath: basePath, level: level + 1)
                } else {
                    // If it's a file, just print it
                    print("\(indent)- \(relativePath)")
                }
            }
        }
    } catch {
        print("Error reading contents of directory: \(error)")
    }
}


#Preview {
    HomeView() {nextView in }
}
