//
//  GameInstructionsView.swift
//  emotionGameLog
//
//  Created by Benjamin Liu on 6/10/20.
//  Copyright © 2020 Benjamin Liu. All rights reserved.
//
//  Description: Display of game instructions

import SwiftUI

struct GameInstructionsView: View {
    @Binding var showSheet: Bool
    
    var body: some View {
        NavigationView {
            self.instructionsView
                .navigationBarTitle(Text("Game Instructions"), displayMode: .inline)
                .navigationBarItems(trailing: Button(action: {
                    self.showSheet = false
                }) {
                    Text("Done").bold()
                })
        }
    }
    
    var instructionsView: some View {
        GeometryReader { geometry in
            VStack {
                self.instructionHeader(title: "Goal")
                self.instructionBody(body: "Collect all of the falling emoji with your basket and the help of heart helpers.", width: geometry.size.width / self.bodyWidthScaleFactor)
                Divider()
                self.instructionHeader(title: "Purpose")
                self.instructionBody(body: "This game will help you visualize your emotions in the last seven days. The falling emojis which you will focus on catching correspond to your most recent ratings. The background color of the game will change in parallel to reflect your emotions as well. This game will teach you the importance of tending to your emotions, being honest with yourself, and asking for help along the way <3 ", width: geometry.size.width / self.bodyWidthScaleFactor)
                Divider()
                self.instructionHeader(title: "Rules")
                self.instructionBody(body: "Slide the basket by touching, pressing, and dragging either left or right to catch the falling emoji. Double tap to commission heart helpers that can boost you on your journey. Scoring 100 points will win you the game, while losing 10 emoji will lose you the game. You have 10 heart helper requests per game. Good luck!", width: geometry.size.width / self.bodyWidthScaleFactor)
            }
        }
    }
    
    func instructionHeader(title: String) -> some View {
        Text(title)
            .font(.headline)
            .bold()
            .padding(.bottom)
            .multilineTextAlignment(.center)
    }
    
    func instructionBody(body: String, width: CGFloat) -> some View {
        Text(body)
            .font(.system(size: 15))
            .frame(width: width)
    }
    
    // MARK: - Drawing and Transition Constants
    let bodyWidthScaleFactor: CGFloat = 1.3
}
