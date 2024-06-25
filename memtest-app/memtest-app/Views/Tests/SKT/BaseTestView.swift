import SwiftUI

typealias ContinueHandler = () -> Void


/// A generic SwiftUI view for managing the presentation of different stages of a test.
///
/// This view dynamically switches between content, explanation, and completed states based on the
/// user interaction and completion of test conditions.
///
/// - Parameters:
///   - showCompletedView: A binding to a Boolean value that determines whether the completed content should be displayed.
///   - showExplanationView: A binding to a Boolean value that determines whether the explanation content should be displayed.
///   - indexOfCircle: An index for a progress circle indicating the current test's progress.
///   - textOfCircle: A label for the progress circle, typically showing the current step or phase.
///   - content: A closure returning the primary content of the test when neither the explanation nor completion conditions are met. Here the actual Test View is written in the Tests
///   - explanationContent: A closure returning an optional explanation view that provides additional information or instructions for the test. It accepts a continuation handler to trigger the next step.
///   - completedContent: A closure returning an optional view displayed upon test completion. It also accepts a continuation handler for further actions.
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
            // Dynamically display content based on the state of `showExplanationView` and `showCompletedView`
            if showExplanationView == true {
                explanationContent({
                })
            } else {
                if showCompletedView == false {
                    content()
                } else {
                    completedContent({})
                }
            }
        }
    }
}

/// A SwiftUI view that presents explanatory content along with an optional set of progress indicators.
///
/// This view is typically used to provide users with guidelines or instructions before they start or continue with a process.
///
/// - Parameters:
///   - onNext: A closure executed when the user taps the "Next" button, intended to advance the user through the app's flow.
///   - circleIndex: The current index in the progress circle, representing the user's progress in a series of steps.
///   - circleText: The text displayed inside the progress circle.
///   - showProgressCircles: A Boolean value indicating whether progress circles should be displayed.
///   - content: A closure providing the content to be displayed within the explanation view.
///
/// - Remarks:
///   This view dynamically adjusts to include progress circles if required and ensures all instructional content is displayed alongside navigational controls.
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
    // The third view in the SKT Tests is the LearningPhaseView, therefore L
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

/// This view is used at the end of a test
///
/// - Parameters:
///   - numberOfTasks: The total number of tasks in the series.
///   - completedTasks: The number of tasks that have been completed successfully.
///   - onContinue: A closure that is executed when the user taps the continue button.
///   - customButtonText: An optional string that can be used to customize the text on the continue button.
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
