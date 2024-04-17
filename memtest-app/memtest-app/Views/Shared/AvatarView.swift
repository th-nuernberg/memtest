//
//  AvatarView.swift
//  memtest-app
//
//  Created by Christopher Witzl on 17.04.24.
//

import SwiftUI

// Should listen to SpeechRecognitionManager callback for nouns
struct AvatarView: View {
    let gifName: String
    @State private var animate: Bool = false

    var body: some View {
        VStack {
            GifImage(resourceName: gifName, frame: CGRect(x: 0, y: 0, width: 100, height: 100), animate: $animate)
                .frame(width: 700, height: 525, alignment: .center)
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: .triggerAvatarAnimation, object: nil, queue: .main) { _ in
                animate.toggle()
                animate = true
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self)
        }
    }
}


#Preview {
    AvatarView(gifName: "Avatar_Nicken")
}


struct GifImage: UIViewRepresentable {
    var resourceName: String
    var frame: CGRect
    @Binding var animate: Bool

    func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView(frame: frame)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .white
        loadFirstFrame(into: imageView)
        return imageView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {
        print("update")
        if animate {
            startAnimation(uiView: uiView)
        } else {
            uiView.stopAnimating()
            uiView.animationImages = nil
        }
    }

    private func loadFirstFrame(into imageView: UIImageView) {
        let path = Bundle.main.path(forResource: resourceName, ofType: "gif")!
        let url = URL(fileURLWithPath: path)
        let gifData = try! Data(contentsOf: url)
        let source = CGImageSourceCreateWithData(gifData as CFData, nil)!
        if let firstImage = CGImageSourceCreateImageAtIndex(source, 0, nil) {
            imageView.image = UIImage(cgImage: firstImage)
        }
    }
    
    private func startAnimation(uiView: UIImageView) {
        print("start Animating")
        uiView.stopAnimating()  // Ensure to stop any previous animations
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
        uiView.animationDuration = Double(images.count) * 0.02
        uiView.animationRepeatCount = 1
        uiView.startAnimating()
    }
}
