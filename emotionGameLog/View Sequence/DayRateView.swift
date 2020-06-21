//
//  dayRateView.swift
//  emotionGameLog
//
//  Created by Benjamin Liu on 5/29/20.
//  Copyright © 2020 Benjamin Liu. All rights reserved.
//
//  Description: View for logging user's current emotion

import SwiftUI

struct DayRateView: View {
    @EnvironmentObject var EmotionGameLogModel: EmotionGameLog
    @Environment(\.colorScheme) var displayLightingMode
    @State var toggleNextOption: Bool = false //Display next button
    @State var selection: Int? = nil
    @State var ratingTracker: Int = -1
    
    var body: some View {
        VStack {
            Group {
                self.questionView()
                GeometryReader { geometry in
                    self.ratingView(width: geometry.size.width, height: geometry.size.height / self.ratingViewHeightScale, ratingNumber: 2)
                }
                if self.toggleNextOption {
                    self.nextButtonView
                }
            }
        }
        .background(LinearGradient(gradient: Gradient(colors: [.green, .purple, .white, .blue]), startPoint: .top, endPoint: .bottom))
        .animation(.easeInOut(duration: self.keyboardAnimationDuration))
    }
    
    //View for the "Next" button
    var nextButtonView: some View {
        NavigationLink(destination: GratitudeLoggerView().environmentObject(self.EmotionGameLogModel), tag: 1, selection: self.$selection) {
            Button(action: {
                self.selection = 1
                self.EmotionGameLogModel.logEmotionRating(rating: self.ratingTracker) //log emotion
            }) {
                HStack {
                    Spacer()
                    Text("Next").foregroundColor(Color.white).bold()
                    Spacer()
                }
            }
            .padding()
            .background(Color(UIColor.blue))
            .cornerRadius(2.0)
            .frame(width: self.nextButtonFrameWidth, height: self.nextButtonFrameHeight)
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
    
    //View for main title question
    func questionView() -> some View {
        Text("How are you feeling today?")
            .padding()
            .font(.system(size: self.questionFont, weight: .light, design: .rounded))
            .foregroundColor(.black)
    }
    
    //View to display emotion ratings
    func ratingView(width: CGFloat, height: CGFloat, ratingNumber: Int) -> some View {
        VStack {
            ForEach(0..<7) { index in
                ZStack {
                    RoundedRectangle(cornerRadius: self.frameCornerRadius) //Outline
                        .stroke(Color.black, lineWidth: 3)
                    Text(self.ratingDescriptionArray[index]) //Emotion
                        .foregroundColor(self.displayLightingMode == .dark ? Color(UIColor.darkGray) : Color(UIColor.black))
                }
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: self.keyboardAnimationDuration)) {
                            self.EmotionGameLogModel.updateCurrentEmotionRating(rating: index)
                            self.ratingTracker = index
                            self.toggleNextOption = true //Show "Next" Button
                        }
                    }
                    .overlay( //Indicate selection with overlay
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: self.EmotionGameLogModel.currentEmotionRating.rating == index ? self.selectionStrokeWidth : 0)
                    )
            }
        }
        .frame(width: width / 1.1, height: height)
        .padding(.leading, self.ratingViewPadding)
    }
    
    //Contains descriptions of the emotions to select
    var ratingDescriptionArray: Array<String> {
        let firstRating: String =  "Sky-High Joyous!"
        let secondRating: String = "Very Happy"
        let thirdRating: String = "Happy"
        let fourthRating: String = "Okay"
        let fifthRating: String = "Sad"
        let sixthRating: String = "Extremely Sad"
        let seventhRating: String = "Depressed"
        return [firstRating, secondRating, thirdRating, fourthRating, fifthRating, sixthRating, seventhRating]
    }
    
    // MARK: - Drawing and Transition Constants
    let frameCornerRadius: CGFloat = 10
    let ratingViewPadding: CGFloat = 15
    let selectionStrokeWidth: CGFloat = 4
    let questionFont: CGFloat = 25
    let ratingViewHeightScale: CGFloat = 1.05
    let nextButtonFrameWidth: CGFloat = 150
    let nextButtonFrameHeight: CGFloat = 75
    let keyboardAnimationDuration: Double = 0.2
}
