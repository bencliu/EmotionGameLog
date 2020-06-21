//
//  EmotiGameSceneView.swift
//  emotionGameLog
//
//  Created by Benjamin Liu on 6/9/20.
//  Copyright © 2020 Benjamin Liu. All rights reserved.
//
//  Description: View to present game scene
//  Reference: Stackoverflow for inspiration in showing SKScene within SwiftUI view
//  Post Title: "Using SpriteKit inside SwiftUI"
//  Cite: https://stackoverflow.com/questions/56615183/using-spritekit-inside-swiftui

import Foundation
import SwiftUI
import SpriteKit

struct EmotiGameSceneView: UIViewRepresentable {
    let scene: SKScene
    let frame: CGRect
    
    func makeUIView(context: Context) -> SKView {
        SKView(frame: .zero)
    }
    
    func updateUIView(_ skView: SKView, context: Context) {
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .fill //fill size of screen
        scene.size = self.frame.size
        skView.presentScene(scene)
    }
}
