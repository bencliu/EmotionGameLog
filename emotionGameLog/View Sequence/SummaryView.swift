//
//  SummaryView.swift
//  emotionGameLog
//
//  Created by Benjamin Liu on 6/7/20.
//  Copyright © 2020 Benjamin Liu. All rights reserved.
//
//  Description: EmotiSummary View,, provides user's personalized app highlights

import SwiftUI

struct SummaryView: View {
    @EnvironmentObject var EmotionGameLogModel: EmotionGameLog
    @Environment(\.colorScheme) var displayLightingMode
    
    //State used for view navigation and view scaling
    @State var popScale: CGFloat = 0.0
    @State var selection: Int? = nil
    
    var body: some View {
        VStack {
            self.title
            self.amalgamationSummaryView
                .scaleEffect(self.popScale)
                .onAppear(perform: {self.popScale = 1})
                .animation(.easeInOut(duration: 1.0))
        }
    }
    
    //Combins summary highlight views into aesthetic format
    var amalgamationSummaryView: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    self.summaryHighlight(category: "Your Quote:", text: self.EmotionGameLogModel.userBundle.favoriteMotivationalQuote, width: geometry.size.width / self.highlightFrameWidthScale, height: geometry.size.height / self.highlightFrameHeighScale)
                    self.summaryHighlight(category: "Best Memory:", text: self.EmotionGameLogModel.userBundle.bestChildhoodMemory, width: geometry.size.width / self.highlightFrameWidthScale, height: geometry.size.height / self.highlightFrameHeighScale)
                }
                HStack {
                    self.summaryHighlight(category: "Moment of the Day", text: self.momentOfTheDay, width: geometry.size.width / self.highlightFrameWidthScale, height: geometry.size.height / self.highlightFrameHeighScale)
                    self.summaryHighlight(category: "Gratitude of the Day", text: self.gratefulPointOfTheDay, width: geometry.size.width / self.highlightFrameWidthScale, height: geometry.size.height / self.highlightFrameHeighScale)
                }
                HStack {
                    self.summaryHighlight(category: "Your emoji today", text: "\(ChartRateView.obtainEmojiFromRating(rating: self.currentEmotionRating))", width: geometry.size.width / self.highlightFrameWidthScale, height: geometry.size.height / self.highlightFrameHeighScale)
                    self.summaryHighlight(category: "Log Streak", text: "\(self.logStreak)", width: geometry.size.width / self.highlightFrameWidthScale, height: geometry.size.height / self.highlightFrameHeighScale)
                }
                self.nextButtonView(title: "End EmotiCycle")
            }
            .animation(.easeInOut(duration: 0.3))
        }
    }
    
    //Navigation button view
    func nextButtonView(title: String) -> some View {
        NavigationLink(destination: EndCycleView().environmentObject(EmotionGameLogModel), tag: 1, selection: self.$selection) {
            Button(action: {
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
            .frame(width: self.nextButtonWidth, height: self.nextButtonHeight)
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
    
    //View for individual summary highlight,, applies custom view modifier with custom shape overlay
    func summaryHighlight(category: String, text: String, width: CGFloat, height: CGFloat) -> some View {
        VStack {
            Text(category)
                .font(.system(size: self.summaryTitleFont))
                .frame(width: width, height: height / self.summaryFrameScale)
            Text(text)
                .font(.system(size: self.summaryTitleBodyFont))
                .frame(width: width, height: height / self.summaryFrameScale)
        }
        .summaryHighlighted(width: width, height: height)
    }
    
    //Title subview
    var title: some View {
        Text("Your Healthy EmotiReminders")
            .padding()
            .font(.system(size: self.titleFont, weight: .light, design: .rounded))
            .foregroundColor(self.displayLightingMode == .dark ? Color.white : Color.black)
            .frame(width: self.titleFrame)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(self.displayLightingMode == .dark ? Color.white : Color.black, lineWidth: 4)
            )
            .multilineTextAlignment(TextAlignment.center)
    }
    
    // MARK: - Summary Highlight Content
    var gratefulPointOfTheDay: String {
        return self.EmotionGameLogModel.gratitudeList[Int.random(in: 0...(self.EmotionGameLogModel.gratitudeList.count - 1))]
    }
    
    var momentOfTheDay: String {
        return self.EmotionGameLogModel.momentList[Int.random(in: 0...(self.EmotionGameLogModel.momentList.count - 1))]
    }
    
    var currentEmotionRating: Int {
        let lastPos: Int = self.EmotionGameLogModel.recordedEmotionList.count - 1
        return self.EmotionGameLogModel.recordedEmotionList[lastPos].rating
    }
    
    var logStreak: Int {
        return self.EmotionGameLogModel.logStreak
    }
    
    // MARK: - Drawing and Transition Constants
    let titleFont: CGFloat = 25
    let titleFrame: CGFloat = 350
    let summaryTitleFont: CGFloat = 15
    let summaryTitleBodyFont: CGFloat = 11
    let summaryFrameScale: CGFloat = 4
    let nextButtonWidth: CGFloat = 200
    let nextButtonHeight: CGFloat = 75
    let highlightFrameWidthScale: CGFloat = 2.7
    let highlightFrameHeighScale: CGFloat = 3.5
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView().environmentObject(EmotionGameLog())
    }
}

