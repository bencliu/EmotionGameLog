//
//  View+SummaryElementModifier.swift
//  emotionGameLog
//
//  Created by Benjamin Liu on 6/7/20.
//  Copyright © 2020 Benjamin Liu. All rights reserved.
//
//  Description: Custom view modifier for summary elemnts in the summary view.
//  Incorporates the ShazamCustomView to aesthetically encapsulate summary points

import SwiftUI
import Foundation

struct SummaryElement: ViewModifier {
    var width: CGFloat
    var height: CGFloat
    
    func body(content: Content) -> some View {
        content
            .font(.caption)
            .frame(width: width, height: height)
            .multilineTextAlignment(.center)
            .background(
                ZStack {
                    ShazamCustomView()
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.green.opacity(0.8))
                    .frame(width: width, height: height)
                }
            )
            .padding(5)
    }
}

extension View {
    func summaryHighlighted(width: CGFloat, height: CGFloat) -> some View {
        self.modifier(SummaryElement(width: width, height: height))
    }
}
