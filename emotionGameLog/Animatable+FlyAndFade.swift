//
//  AnyTransition+FlyAndFade.swift
//  emotionGameLog
//
//  Created by Benjamin Liu on 6/10/20.
//  Copyright © 2020 Benjamin Liu. All rights reserved.
//
//  Description: AnimatableModifier FlyAndFade implementation used to animate
//  flying stars in the endCycleView

import Foundation
import SwiftUI

struct flyFadeModifier: AnimatableModifier {
    private var finishedState: Bool
    private var horizontalOffset: CGFloat
    private var opacity: Double
    var animatableData: AnimatablePair<CGFloat, Double> {
        get { AnimatablePair(horizontalOffset, opacity) }
        set { horizontalOffset = newValue.first
            opacity = newValue.second }
    }
    
    init(finishedState: Bool) {
        self.finishedState = finishedState
        self.opacity = finishedState ? 1.0 : 0.0
        self.horizontalOffset = finishedState ? 0 : 500
    }
    
    func body(content: Content) -> some View {
        content
            .offset(y: animatableData.first)
            .opacity(finishedState ? animatableData.second : 1.0 - animatableData.second)
    }
}
