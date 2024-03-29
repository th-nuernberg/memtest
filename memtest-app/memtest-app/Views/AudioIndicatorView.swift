import SwiftUI

struct AudioIndicatorView: View {
    @ObservedObject var speechRecognitionManager: SpeechRecognitionManager = SpeechRecognitionManager()
    
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
