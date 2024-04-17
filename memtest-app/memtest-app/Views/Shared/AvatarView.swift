//
//  AvatarView.swift
//  memtest-app
//
//  Created by Christopher Witzl on 17.04.24.
//

import SwiftUI

struct AvatarView: View {
    let gifName: String
    @State private var animate: Bool = false

    var body: some View {
        VStack {
            GifImage(resourceName: gifName, frame: CGRect(x: 0, y: 0, width: 200, height: 200), animate: $animate)
                        .frame(width: 200, height: 200, alignment: .center)
           
            Button("Start GIF") {
                startAnimation()
            }
        }
    }
    
    private func startAnimation() {
        animate = true
    }
}

#Preview {
    AvatarView(gifName: "Avatar_Nicken")
}

import SwiftUI
import UIKit
import ImageIO

struct GifImage: UIViewRepresentable {
    var resourceName: String
    var frame: CGRect
    @Binding var animate: Bool
    
    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView(frame: frame)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {
        if animate {
            guard let path = Bundle.main.path(forResource: resourceName, ofType: "gif") else {
                print("Could not find the GIF resource")
                return
            }

            let url = URL(fileURLWithPath: path)

            do {
                let gifData = try Data(contentsOf: url)
                guard let source = CGImageSourceCreateWithData(gifData as CFData, nil) else {
                    print("Failed to create CGImageSource")
                    return
                }
                
                var images = [UIImage]()
                let imageCount = CGImageSourceGetCount(source)
                for i in 0..<imageCount {
                    if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                        images.append(UIImage(cgImage: image))
                    }
                }
                
                uiView.animationImages = images
                uiView.animationDuration = Double(images.count) * 0.1 // Assuming 0.1 second per frame.
                uiView.animationRepeatCount = 1 // Set this to run the animation only once.
                uiView.startAnimating()
                animate = false // Reset the animate state
            } catch {
                print("Error loading GIF data: \(error)")
            }
        }
    }
}

