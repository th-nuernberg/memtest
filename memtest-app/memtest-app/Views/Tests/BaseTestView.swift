import SwiftUI

typealias ContinueHandler = () -> Void

struct BaseTestView<Content: View, ExplanationContent: View, CompletedContent: View>: View {
    let content: () -> Content
    var explanationContent: (@escaping ContinueHandler) -> ExplanationContent?
    var completedContent: (@escaping ContinueHandler) -> CompletedContent?
    @Binding private var showCompletedView: Bool
    @Binding private var showExplanationView: Bool
    private var circleText: String
    private var circleIndex: Int

    init(showCompletedView: Binding<Bool>, showExplanationView: Binding<Bool>,
         indexOfCircle: Int,
         textOfCircle: String, @ViewBuilder content: @escaping () -> Content,
         @ViewBuilder explanationContent: @escaping (@escaping ContinueHandler) -> ExplanationContent? = { _ in nil }, @ViewBuilder completedContent: @escaping (@escaping ContinueHandler) -> CompletedContent? = { _ in nil }) {
        self.content = content
        self.explanationContent = explanationContent
        self.completedContent = completedContent
        self._showCompletedView = showCompletedView
        self._showExplanationView = showExplanationView
        self.circleText = textOfCircle
        self.circleIndex = indexOfCircle
    }

    var body: some View {
        VStack {
            if showExplanationView == true {
                explanationContent({
                })
            } else {
                if showCompletedView == false {
                    content()
                } else {
                    completedContent({
                        // Handle what happens when continue is pressed in completed view
                    })
                }
            }
        }
    }
}

struct ExplanationView<Content: View>: View {
    var onNext: (() -> Void)
    
    let content: Content
    var circleIndex: Int = 1
    var circleText: String = "1"
    var showProgressCircles: Bool

    init(onNext: @escaping (() -> Void), circleIndex: Int,
         circleText: String, showProgressCircles: Bool, @ViewBuilder content: () -> Content) {
        self.onNext = onNext
        self.content = content()
        self.circleIndex = circleIndex
        self.circleText = circleText
        self.showProgressCircles = showProgressCircles
    }
    
    init(onNext: @escaping (() -> Void), showProgressCircles: Bool, @ViewBuilder content: () -> Content) {
        self.onNext = onNext
        self.content = content()
        self.showProgressCircles = showProgressCircles
    }

    var body: some View {
        if showProgressCircles {
            HStack {
                HStack {
                    ForEach(0..<10) { index in
                        ZStack {
                            if index <= circleIndex {
                                Circle()
                                    .foregroundColor(.blue)
                                    .frame(width: 30, height: 30)
                                Text(getTextForIndex(index: index + 1))
                                    .font(.title)
                                    .foregroundColor(.white)
                            } else {
                                Circle()
                                    .foregroundColor(.gray)
                                    .frame(width: 30, height: 30)
                            }
                        }
                        .padding(.trailing, 5)
                    }
                }
            }
        }

        VStack {
            content
            Spacer()
            VStack {
                Spacer()
                Button(action: {
                    onNext()
                }) {
                    Text("Weiter ➔")
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                }
                .padding(.horizontal, 50)
                .background(Color.blue)
                .cornerRadius(10)
                .navigationBarBackButtonHidden(true)
            }
            .padding()
        }
    }

    func getTextForIndex(index: Int) -> String {
        switch index {
        case 1:
            return "1"
        case 2:
            return "2"
        case 3:
            return "L"
        case 4:
            return "3"
        case 5:
            return "4"
        case 6:
            return "5"
        case 7:
            return "6"
        case 8:
            return "7"
        case 9:
            return "8"
        case 10:
            return "9"
        case 11:
            return "10"
        case 12:
            return "11"
        default:
            return ""
        }
    }
}

struct CompletedView: View {
    var numberOfTasks: Int = 10 // Total number of tasks
    var completedTasks: Int = 1 // Number of tasks completed
    var onContinue: ContinueHandler
    var customButtonText: String? // Optional custom button text

    var buttonText: String {
        if let customText = customButtonText {
            return customText
        } else if completedTasks == 2 {
            return "Zur Lernphase ➔"
        } else if completedTasks < 9 {
            return "Zur nächsten Aufgabe ➔"
        } else {
            return "Beenden ➔"
        }
    }

    var body: some View {
        VStack {
            Spacer()

            Text("Die Aufgabe ist abgeschlossen.\nMachen Sie eine kurze Pause.")
                .font(.custom("SFProText-SemiBold", size: 40))
                .foregroundStyle(Color(hex: "#958787"))
                .padding(.top)
                .padding(.leading)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)

            HStack(spacing: 50) {
                ForEach(0..<numberOfTasks) { index in
                    Image(systemName: completedTasks > index ? "checkmark.circle.fill" : "circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .foregroundColor(completedTasks > index ? .green : .gray)
                }
            }
            .padding()

            Spacer()

            Button(action: {
                onContinue()
            }, label: {
                Text("\(buttonText)")
                    .bold()
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            })

            Spacer()
        }
        .padding()
    }
}

#Preview {
    BaseTestView(showCompletedView: .constant(false), showExplanationView: .constant(true),
                 indexOfCircle: 7,
                 textOfCircle: "6", content: {
        Text("Das ist die Test1View")
    }, explanationContent: { onContinue in
        ExplanationView(onNext: {}, circleIndex: 7, circleText: "6", showProgressCircles: true, content: {
            Text("Hier sind einige Erklärungen.")
        })
    }, completedContent: { onContinue in
        CompletedView(numberOfTasks: 7, completedTasks: 3, onContinue: onContinue, customButtonText: "Weiter zur nächsten Aufgabe ➔")
    })
}
