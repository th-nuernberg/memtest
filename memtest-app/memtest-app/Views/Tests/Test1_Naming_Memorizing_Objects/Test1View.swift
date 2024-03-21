//
//  Test1View.swift
//  memtest-app
//
//  Created by Maximilian Werzinger - TH on 02.03.24.
//

import SwiftUI

struct Test1View: View {
    
    var columns: [GridItem] = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    var body: some View {
        
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(1...12, id: \.self) { imageID in
                    ZStack {
                        Rectangle()
                            .fill(Color.gray)
                            .frame(height: 200)
                            .frame(width: 200)
                            .cornerRadius(20)
                            .padding(.bottom, 20)
                        
                        let imageName = "Test1Icons/test1_" + String(imageID)
                        
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 150, height: 150)
                            .offset(x: 5, y: -5)
                    }
                }
            }
            .padding(.vertical)
            .padding(.top, 70)
        }
        
        
        /*
         BaseTestView(destination: Test2View(), content: {
         
         }, explanationContent: {
         Text("Hier sind einige Erklärungen.")
         })
         */
        
    }
    
    private func startStopRecording() {
        if isRecording {
            AudioService.shared.stopRecording {
                listRecordedFiles()
            }
        } else {
            do {
                try AudioService.shared.startRecording(to: "test1")
            } catch {
                print("Failed to start recording: \(error)")
            }
        }
        isRecording.toggle()
    }

    private func listRecordedFiles() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            // Filter for specific file types if needed, e.g., .m4a
            let audioFiles = fileURLs.filter { $0.pathExtension == "m4a" }
            print("Recorded files:")
            for file in audioFiles {
                print(file.lastPathComponent)
            }
        } catch {
            print("Error while enumerating files \(documentsDirectory.path): \(error.localizedDescription)")
        }
    }
    
}





#Preview {
    Test1View()
}
