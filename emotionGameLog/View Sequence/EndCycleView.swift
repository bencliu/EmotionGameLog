//
//  EndCycleView.swift
//  emotionGameLog
//
//  Created by Benjamin Liu on 6/9/20.
//  Copyright © 2020 Benjamin Liu. All rights reserved.
//
//  Description: Last view in view sequence,, end of cycle

import SwiftUI

struct EndCycleView: View {
    @EnvironmentObject var EmotionGameLogModel: EmotionGameLog
    @State var selection: Int? = nil
    @State var beginStarTransition: Bool = false
    var decorationArray: Array<String> = ["🌟","✨","✨","🌟","⭐️","🌟","⭐️","✨","💫","🌟"]
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Thank you for using EmotiLog!")
                    .foregroundColor(Color.black)
                    .font(.system(size: 20))
                    .padding(.bottom)
                Text("See you soon!")
                    .foregroundColor(Color.black)
                    .font(.system(size: 15))
                    .padding(.bottom)
                self.nextButtonView(title: "Home Page")
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(ZStack {
                Image("Cartoon-Cloud-Fit").aspectRatio(contentMode: .fill)
                self.decorationDisplay(width: geometry.size.width, height: geometry.size.height)
            })
            .onAppear {
                withAnimation(.linear(duration: 1)) { //Cards fly into position
                    self.beginStarTransition = true
                }
            }
        }
    }
    
    func nextButtonView(title: String) -> some View {
        NavigationLink(destination: EmotionGameLogView().environmentObject(EmotionGameLogModel), tag: 1, selection: self.$selection) {
            Button(action: {
                self.EmotionGameLogModel.updateLogStreak() //Log completion
                self.selection = 1
            }) {
                HStack {
                    Spacer()
                    Text(title).foregroundColor(Color.white).bold()
                    Spacer()
                }
            }
            .padding()
            .background(Color(UIColor.blue))
            .cornerRadius(4.0)
            .frame(width: self.nextButtonFrameWidth, height: self.nextButtonFrameHeight)
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
    
    //Displays star decorations with custom animatable modifier for fly effect
    func decorationDisplay(width: CGFloat, height: CGFloat) -> some View {
        Group {
            ForEach(0..<(self.decorationArray.count)) { index in
                Text(self.decorationArray[index])
                    .position(x: self.randomFloat() * width, y: self.randomFloat() * height)
                    .modifier(flyFadeModifier(finishedState: self.beginStarTransition))
            }
        }
    }
    
    //Reference: Stack Overflow "Generate SwiftUi Random Number", random float between 0 and 1 (https://stackoverflow.com/questions/25050309/swift-random-float-between-0-and-1)
    func randomFloat() -> CGFloat {
        CGFloat(Float(arc4random()) / Float(UINT32_MAX))
    }
    
    // MARK: - Drawing and Transition Constants
    let nextButtonFrameWidth: CGFloat = 150
    let nextButtonFrameHeight: CGFloat = 75
}
