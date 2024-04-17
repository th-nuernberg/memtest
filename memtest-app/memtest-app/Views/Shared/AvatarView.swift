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
        loadFirstFrame(imageView: imageView)  // Load the first frame initially
        return imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {
        if animate {
            startAnimation(uiView: uiView)
        }
    }

    private func loadFirstFrame(imageView: UIImageView) {
        let path = Bundle.main.path(forResource: resourceName, ofType: "gif")!
        let url = URL(fileURLWithPath: path)
        let gifData = try! Data(contentsOf: url)
        let source = CGImageSourceCreateWithData(gifData as CFData, nil)!
        let firstImage = CGImageSourceCreateImageAtIndex(source, 0, nil)!
        imageView.image = UIImage(cgImage: firstImage)
    }
    
    private func startAnimation(uiView: UIImageView) {
        let path = Bundle.main.path(forResource: resourceName, ofType: "gif")!
        let url = URL(fileURLWithPath: path)
        let gifData = try! Data(contentsOf: url)
        let source = CGImageSourceCreateWithData(gifData as CFData, nil)!
        
        var images = [UIImage]()
        let imageCount = CGImageSourceGetCount(source)
        for i in 0..<imageCount {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(UIImage(cgImage: image))
            }
        }
        
        uiView.animationImages = images
        uiView.animationDuration = Double(images.count) * 0.06
        uiView.animationRepeatCount = 1
        uiView.startAnimating()
        animate = false
    }
}
