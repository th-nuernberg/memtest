//
//  TimerModifier.swift
//  memtest-app
//
//  Created by Christopher Witzl on 21.03.24.
//

import Foundation
import SwiftUI

/// modifier used for easy tracking of time for the tests
/// it uses a callback to notify the view, that the timer has been completed
struct TimerModifier: ViewModifier {
    let duration: Int
    var onComplete: () -> Void
    
    @State private var timeRemaining: Int
    @State private var timerIsActive = false
    
    init(duration: Int, onComplete: @escaping () -> Void) {
        self.duration = duration
        self.onComplete = onComplete
        _timeRemaining = State(initialValue: duration)
    }
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                self.startTimer()
            }
            .onDisappear {
                self.timerIsActive = false
            }
    }
    
    private func startTimer() {
        self.timeRemaining = duration
        self.timerIsActive = true
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                timer.invalidate()
                self.timerIsActive = false
                self.onComplete()
            }
        }
    }
}

extension View {
    func onTimerComplete(duration: Int, onComplete: @escaping () -> Void) -> some View {
        self.modifier(TimerModifier(duration: duration, onComplete: onComplete))
    }
}


