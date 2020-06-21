//
//  gratitudeLoggerView.swift
//  emotionGameLog
//
//  Created by Benjamin Liu on 5/29/20.
//  Copyright © 2020 Benjamin Liu. All rights reserved.
//
//  Description: View for logging gratitude and moment points

import SwiftUI

struct GratitudeLoggerView: View {
    @EnvironmentObject var EmotionGameLogModel: EmotionGameLog
    @Environment(\.colorScheme) var displayLightingMode
    
    //Track grateful and moment input text
    @State private var gratefulPoint: String = ""
    @State private var momentPoint: String = ""
    
    //Track button display and keyboard offset interaction
    @State private var selection: Int? = nil
    @State private var keyboardOffset: CGFloat = 0
    @State private var displayNext: Bool = false
    @State private var nextButtonTopPadding: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                self.questionView(width: geometry.size.width)
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: geometry.size.width / self.rectangleFrameWidthScale, height: geometry.size.height / self.rectangleFrameHeightScale)
                        .padding(.leading).padding(.trailing)
                    VStack {
                        self.gratefulRecorderView(width: geometry.size.width / self.gratefulFrameScale, height: geometry.size.height / 10, text: "Grateful for...")
                        self.momentRecorderView(width: geometry.size.width / self.gratefulFrameScale, height: geometry.size.height / 10, text: "Favorite moment...")
                    }
                }
                if self.displayNext {
                    self.nextButtonView(title: "Next")
                        .padding(.top, self.buttonPadding)
                }
            }
                .padding(.top, self.nextButtonTopPadding)
                .offset(x: 0, y: self.keyboardOffset)
                .animation(.easeInOut(duration: 0.3))
        }
    }
    
    func nextButtonView(title: String) -> some View {
        NavigationLink(destination: GratitudeSummarizeView().environmentObject(self.EmotionGameLogModel), tag: 1, selection: self.$selection) {
            Button(action: {
                self.selection = 1
                self.EmotionGameLogModel.addGratitudePoint(for: self.gratefulPoint)
                self.EmotionGameLogModel.addMomentPoint(for: self.momentPoint)
                self.gratefulPoint = ""
                self.momentPoint = ""
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
    
    func questionView(width: CGFloat) -> some View {
        Text("What are you grateful for today?")
            .padding()
            .font(.system(size: 25, weight: .light, design: .rounded))
            .foregroundColor(self.displayLightingMode == .dark ? Color.white : Color.black)
            .frame(width: width)
    }
    
    func gratefulRecorderView(width: CGFloat, height: CGFloat, text: String) -> some View {
        TextField(text, text: $gratefulPoint, onEditingChanged:
            { began in
                if !began {
                    withAnimation(.easeIn(duration: 1)) {
                        self.keyboardOffset = 0
                    }
                    if (self.gratefulPoint.count > 0 && self.momentPoint.count > 0) {
                        withAnimation(.linear(duration: 0.2)) {
                            self.displayNext = true
                            self.nextButtonTopPadding = self.buttonPadding
                        }
                    }
                } else {
                    withAnimation(.easeIn(duration: 0.2)) {
                        self.keyboardOffset = (-1) * self.buttonPadding
                    }
                }
        })
            .multilineTextAlignment(TextAlignment.center)
            .frame(width: width, height: height, alignment: .leading)
            .padding()
            .border(self.displayLightingMode == .dark ? Color.white : Color.black)
    }
    
    func momentRecorderView(width: CGFloat, height: CGFloat, text: String) -> some View {
        TextField(text, text: $momentPoint, onEditingChanged:
            { began in
                if !began {
                    withAnimation(.easeIn(duration: 0.2)) {
                        self.keyboardOffset = 0
                    }
                    if (self.gratefulPoint.count > 0 && self.momentPoint.count > 0) {
                        withAnimation(.linear(duration: 0.2)) {
                            self.displayNext = true
                            self.nextButtonTopPadding = self.buttonPadding
                        }
                    }
                } else {
                    withAnimation(.easeIn(duration: 0.2)) {
                        self.keyboardOffset = self.keyboardOffsetConstant
                    }
                }
        })
            .multilineTextAlignment(TextAlignment.center)
            .frame(width: width, height: height, alignment: .leading)
            .padding()
            .border(self.displayLightingMode == .dark ? Color.white : Color.black)
    }
    
    // MARK: - Drawing and Transition Constants
    let buttonPadding: CGFloat = 100
    let keyboardOffsetConstant: CGFloat = -150
    let nextButtonFrameWidth: CGFloat = 150
    let nextButtonFrameHeight: CGFloat = 75
    let rectangleFrameWidthScale: CGFloat = 1.05
    let rectangleFrameHeightScale: CGFloat = 2.5
    let gratefulFrameScale: CGFloat = 1.2
}

