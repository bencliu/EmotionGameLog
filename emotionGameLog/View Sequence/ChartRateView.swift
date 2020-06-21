//
//  ChartRateView.swift
//  emotionGameLog
//
//  Created by Benjamin Liu on 5/29/20.
//  Copyright © 2020 Benjamin Liu. All rights reserved.
//
//  Description: View for emotion chart visualizer

import SwiftUI

struct ChartRateView: View {
    @EnvironmentObject var EmotionGameLogModel: EmotionGameLog
    @Environment(\.colorScheme) var displayLightingMode
    @State var selection: Int? = nil
    
    //Passed to EmotiGame
    @State var gameEmojis: Array<String> = Array<String>()
    @State var gameColors: Array<UIColor> = Array<UIColor>()
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                VStack {
                    self.headerView(width: geometry.size.width, height: geometry.size.height, text: "Your Last 30 Visits")
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.blue.opacity(0.3))
                            .frame(width: geometry.size.width / 1.05, height: geometry.size.height / 1.8)
                            .padding(.leading).padding(.trailing)
                        self.emotionChartView(width: geometry.size.width, height: geometry.size.height)
                            .frame(width: geometry.size.width / 1.1, height: geometry.size.height / 2).padding(.bottom).padding(.top)
                    }
                    self.nextButtonView(title: "Next")
                            .padding(.top, 50)
                }
                .padding(.top, 50)
                .animation(.easeInOut(duration: 0.3))
            }
            .onAppear(perform: {self.initGameColorsAndEmojis()})
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
    
    func nextButtonView(title: String) -> some View {
        NavigationLink(destination: EmotiGameMasterView(emotiGameScene: EmotiGameScene(playingGame: false, gameColors: self.gameColors, gameEmojis: self.gameEmojis, size: UIScreen.main.bounds.size)).environmentObject(self.EmotionGameLogModel), tag: 1, selection: self.$selection) {
            Button(action: {
                self.selection = 1
                self.EmotionGameLogModel.updateCurrentEmotionRating(rating: -1) //Reset emotion rating
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
            .frame(width: 150, height: 75)
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
    
    func headerView(width: CGFloat, height: CGFloat, text: String) -> some View {
        Text(text)
            .padding()
            .font(.system(size: 25, weight: .light, design: .rounded))
            .foregroundColor(self.displayLightingMode == .dark ? Color.white : Color.black)
            .frame(width: width)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(self.displayLightingMode == .dark ? Color.white : Color.black, lineWidth: 4)
            )
            .multilineTextAlignment(TextAlignment.center)
    }
    
    //Ful rating chart view
    func emotionChartView(width: CGFloat, height: CGFloat) -> some View {
        Grid(self.blankEmotionDisplayTemplate) { emotionUnit in
            self.emotionCharUnitview(rating: emotionUnit.rating)
                .transition(AnyTransition.opacity.animation(.easeIn(duration: 0.3)))
        }
    }
    
    //Single square (emotion unit) view
    func emotionCharUnitview(rating: Int) -> some View {
        Rectangle()
            .stroke(Color.black)
            .aspectRatio(1.0, contentMode: .fit)
            .overlay(Color(ChartRateView.obtainColorFromRating(rating: rating)))
            .padding(.bottom)
    }
    
    // MARK: - Setup and Variable Processing for EmotiGame
    
    //Use recorded emotions to init gameEmoji and gameColors passed to EmotiGame
    func initGameColorsAndEmojis() {
        let recordedEmotions: Array<EmotionLog.emotionUnit> = self.EmotionGameLogModel.recordedEmotionList
        let bound: Int = recordedEmotions.count < 7 ? recordedEmotions.count : 7
        var emotionColors = Array<UIColor>()
        var gameEmojisTemp = Array<String>()
        for index in (recordedEmotions.count-bound)..<recordedEmotions.count {
            let rating: Int = recordedEmotions[index].rating
            emotionColors.append(ChartRateView.obtainColorFromRating(rating: rating))
            gameEmojisTemp.append(ChartRateView.obtainEmojiFromRating(rating: rating))
        }
        self.gameEmojis = gameEmojisTemp
        self.gameColors = emotionColors
    }
    
    //Obtain emoji corresponding to emotion rating
    static func obtainEmojiFromRating(rating: Int) -> String {
        var emoji: String
        switch rating {
        case 0:
            emoji = "🥳"
        case 1:
            emoji = "😆"
        case 3:
            emoji = "😀"
        case 4:
            emoji = "🙂"
        case 5:
            emoji = "😔"
        case 6:
            emoji = "😖"
        default:
            emoji = "😰"
        }
        return emoji
    }
    
    //Obtain UIColor corresponding to emotion rating
    static func obtainColorFromRating(rating: Int) -> UIColor {
        var matchingColor: UIColor
        switch rating {
        case 0:
            matchingColor = UIColor(displayP3Red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
        case 1:
            matchingColor = UIColor(displayP3Red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0)
        case 2:
            matchingColor = UIColor(displayP3Red: 0.0, green: 0.6, blue: 0.2, alpha: 0.8)
        case 3:
            matchingColor = UIColor(displayP3Red: 0.0, green: 0.5, blue: 0.4, alpha: 0.7)
        case 4:
            matchingColor = UIColor(displayP3Red: 0.0, green: 0.2, blue: 0.6, alpha: 0.6)
        case 5:
            matchingColor = UIColor(displayP3Red: 0.0, green: 0.0, blue: 0.4, alpha: 0.5)
        case 6:
            matchingColor = UIColor(displayP3Red: 0.0, green: 0.0, blue: 0.2, alpha: 0.4)
        default:
            matchingColor = UIColor(white: 1.0, alpha: 1.0)
        }
        return matchingColor
    }
    
    //Display for non-recorded visits (<31)
    var blankEmotionDisplayTemplate: Array<EmotionLog.emotionUnit> {
        var returnList: Array<EmotionLog.emotionUnit> = Array<EmotionLog.emotionUnit>()
        if EmotionGameLogModel.recordedEmotionList.count > 30 { //At least 31 logged ratings, take 31 most recent
            for index in (EmotionGameLogModel.recordedEmotionList.count - 31)..<EmotionGameLogModel.recordedEmotionList.count {
                returnList.append(EmotionGameLogModel.recordedEmotionList[index])
            }
        } else {
            for index in 0..<31 { //Less than 31 ratings, append blank ratings
                if EmotionGameLogModel.recordedEmotionList.count > index {
                    returnList.append(EmotionGameLogModel.recordedEmotionList[index])
                } else {
                    returnList.append(EmotionLog.emotionUnit(rating: -1))
                }
            }
        }
        return returnList
    }
}
