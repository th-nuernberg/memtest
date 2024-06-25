import SwiftUI

/// `AudioIndicatorView` displays a visual representation of the audio input level
///
/// This view utilizes the `SpeechRecognitionManager` to observe and react to changes in audio input levels.
///
/// The component adjusts its size based on the available space and maintains a consistent height.
struct AudioIndicatorView: View {
    @ObservedObject var speechRecognitionManager: SpeechRecognitionManager = SpeechRecognitionManager.shared
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Spacer()
                
                Image(systemName: "mic.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .padding(.trailing, 8)
                
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: geometry.size.width * 0.25, height: 20)
                        .cornerRadius(10)
                    
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: min(geometry.size.width * 0.25, geometry.size.width * 0.25 * CGFloat(speechRecognitionManager.inputLevel)), height: 20)
                    
                        .cornerRadius(10)
                }
                
                Spacer()
            }
        }
        .frame(height: 24)
    }
}
