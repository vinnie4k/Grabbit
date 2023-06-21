//
//  HapticTouch.swift
//  Grabbit
//
//  Created by Vin Bui on 6/18/23.
//

import UIKit

/// `Haptics` provides haptic feedback as a response to tap gestures
class Haptics {

    static let shared = Haptics()

    private init() { }

    func play(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred()
    }
    
    func doubleTap() {
        self.play(.light)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.play(.medium)
        }
    }

}
