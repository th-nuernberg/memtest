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
                   
                   Button(action: {
                       isAdminMode.toggle()
                       SettingsService.shared.toggleAdminMode()
                       
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

               HStack(spacing: 20) {
                   navigationButton(title: "SKT", color: DataService.shared.hasSKTFinished() ? .gray : .blue, action: {
                       nextView(.skt)
                   }).disabled(DataService.shared.hasSKTFinished())
                   
                   navigationButton(title: "VFT", color: DataService.shared.hasVFTFinished() ? .gray : .blue, action: {
                       nextView(.vft)
                   }).disabled(DataService.shared.hasVFTFinished())
               }
               .padding(.bottom, 20)
               
               HStack(spacing: 20) {
                   navigationButton(title: "BNT", color: DataService.shared.hasBNTFinished() ? .gray : .blue, action: {
                       nextView(.bnt)
                   }).disabled(DataService.shared.hasBNTFinished())
                   
                   navigationButton(title: "PDT", color: DataService.shared.hasPDTFinished() ? .gray : .blue, action: {
                       nextView(.pdt)
                   }).disabled(DataService.shared.hasPDTFinished())
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
