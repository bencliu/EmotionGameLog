//
//  BiHeartShape.swift
//  emotionGameLog
//
//  Created by Benjamin Liu on 6/7/20.
//  Copyright © 2020 Benjamin Liu. All rights reserved.
//

import SwiftUI
import Foundation

struct PopShape: Shape {
    func path(in rect: CGRect) -> Path {
        let width: CGFloat = rect.width
        let height: CGFloat = rect.height
        let startX: CGFloat = width / 2 //Vertex at halfway point of quad side
        let startY: CGFloat = height / 2
        return Path { path in
            path.move(to: CGPoint(x: startX, y: startY))
            path.addLine(to: CGPoint(x: width - 10, y: 70))
            path.addArc(center: CGPoint(x: (width * (7 / 8)) - 10, y: 70), radius: 80, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: true)
        }
    }
}

struct BiHeartShape_Previews: PreviewProvider {
    static var previews: some View {
        PopShape()
    }
}


