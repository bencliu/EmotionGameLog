//
//  BiHeartShape.swift
//  emotionGameLog
//
//  Created by Benjamin Liu on 6/7/20.
//  Copyright © 2020 Benjamin Liu. All rights reserved.
//
//  Description: Implementation of the popshape, component of the "Shazam" custom view
//  used in the emotiSummary display

import SwiftUI
import Foundation

struct PopShape: Shape {
    func path(in rect: CGRect) -> Path {
        let width: CGFloat = rect.width
        let height: CGFloat = rect.height
        let startX: CGFloat = width / 3 //Vertex at halfway point of quad side
        let startY: CGFloat = height / 3
        return Path { path in
            path.move(to: CGPoint(x: startX, y: startY))
            path.addLine(to: CGPoint(x: startX + width / 6, y: startY - width / 3))
            path.addLine(to: CGPoint(x: startX + width / 3, y: startY))
            path.addLine(to: CGPoint(x: width, y: startY + width / 6))
            path.addLine(to: CGPoint(x: startX + width / 3, y: startY + width / 3))
            path.addLine(to: CGPoint(x: startX + width / 6, y: startY + width * (2 / 3)))
            path.addLine(to: CGPoint(x: startX, y: startY + width / 3))
            path.addLine(to: CGPoint(x: startX - width / 3, y: startY + width / 6))
            path.addLine(to: CGPoint(x: startX, y: startY))
        }
    }
}

struct ShazamCustomView: View {
    var body: some View {
        ZStack {
            PopShape()
            PopShape().rotation(.degrees(45))
        }
    }
}

struct PopShape_Previews: PreviewProvider {
    static var previews: some View {
        ShazamCustomView()
    }
}


