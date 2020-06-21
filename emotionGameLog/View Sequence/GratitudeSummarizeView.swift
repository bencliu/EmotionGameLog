//
//  gratitudeSummarizeView.swift
//  emotionGameLog
//
//  Created by Benjamin Liu on 5/29/20.
//  Copyright © 2020 Benjamin Liu. All rights reserved.
//
//  Description: View for summarizing recent gratitude points

import SwiftUI

struct GratitudeSummarizeView: View {
    @EnvironmentObject var EmotionGameLogModel: EmotionGameLog
    @Environment(\.colorScheme) var displayLightingMode
    @State var selection: Int? = nil
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                VStack {
                    self.headerView(width: geometry.size.width, text: "Your Daily Gratitude Points")
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.blue.opacity(0.3))
                            .frame(width: geometry.size.width / self.frameWidthScale, height: geometry.size.height / self.frameHeightScale)
                            .padding(.leading).padding(.trailing)
                        self.gratitudePointsView(width: geometry.size.width)
                            .padding(.top)
                    }
                }
                self.nextButtonView(title: "Next")
                    .padding(.top, self.viewPadding)
            }
            .padding(.top, self.viewPadding)
            .animation(.easeInOut(duration: 0.3))
        }
    }
    
    //View for "Next" button
    func nextButtonView(title: String) -> some View {
        NavigationLink(destination: ChartRateView().environmentObject(self.EmotionGameLogModel), tag: 1, selection: self.$selection) {
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
            .frame(width: self.nextFrameWidth, height: self.nextFrameWidth)
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
    
    //View for header
    func headerView(width: CGFloat, text: String) -> some View {
        Text(text)
            .padding()
            .font(.system(size: 25, weight: .light, design: .rounded))
            .foregroundColor(self.displayLightingMode == .dark ? Color.white : Color.black)
            .frame(width: width)
            .multilineTextAlignment(TextAlignment.center)
    }
    
    //View for gratitude points display
    func gratitudePointsView(width: CGFloat) -> some View {
        VStack { //First few points (Less than 7)
            if self.EmotionGameLogModel.gratitudeList.count < 7 {
                ForEach(0..<self.EmotionGameLogModel.gratitudeList.count) { index in
                    Text(self.EmotionGameLogModel.gratitudeList[index])
                        .padding(.bottom)
                }
            } else { //Last 7 Points
                ForEach(self.EmotionGameLogModel.gratitudeList.count - 7..<self.EmotionGameLogModel.gratitudeList.count) { index in
                    Text(self.EmotionGameLogModel.gratitudeList[index])
                        .padding(.bottom)
                }
            }
        }
    }
    
    // MARK: - Drawing and Transition Constants
    let nextFrameWidth: CGFloat = 150
    let nextFrameHeight: CGFloat = 75
    let viewPadding: CGFloat = 100
    let frameWidthScale: CGFloat = 1.05
    let frameHeightScale: CGFloat = 2.5
}

