//
//  EmotiGameMasterView.swift
//  emotionGameLog
//
//  Created by Benjamin Liu on 6/9/20.
//  Copyright © 2020 Benjamin Liu. All rights reserved.
//
//  View file for the base of EmotiGame: incudes gameplay and instruction views

import SwiftUI

struct EmotiGameMasterView: View {
    @EnvironmentObject var EmotionGameLogModel: EmotionGameLog
    
    //Used to coordinate gameplay with standard view
    @ObservedObject var emotiGameScene: EmotiGameScene
    
    //States to track subviews and game status
    @State var showGameInstructions: Bool = false
    @State var showGamePlay: Bool = false
    @State var selection: Int? = nil
    @State var gameStarted: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            Group {
                if self.emotiGameScene.playingGame { //Playing game
                    ZStack {
                        EmotiGameSceneView(scene: self.emotiGameScene, frame: UIScreen.main.bounds).environmentObject(self.EmotionGameLogModel)
                            .animation(.easeInOut(duration: 3))
                            .edgesIgnoringSafeArea(.all)
                            .navigationBarTitle("")
                            .navigationBarHidden(true)
                    }
                } else { //Not playing game
                    VStack {
                        self.headerView()
                        HStack {
                            self.gameInstructionsButton
                            //self.gamePreferencesEditorView
                        }
                        self.startGamePlayView
                        self.nextButtonView(title: "Next")
                            .padding(.top, self.buttonPadding)
                    }
                        .padding(.top, self.buttonPadding)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .background(LinearGradient(gradient: Gradient(colors: [.green, .purple, .white, .blue]), startPoint: .top, endPoint: .bottom))
                        .animation(.easeInOut(duration: 0.2))
                }
            }
        }
    }
    
    //View for the "Next" Button: Implement model updates
    func nextButtonView(title: String) -> some View {
        NavigationLink(destination: SummaryView().environmentObject(self.EmotionGameLogModel), tag: 1, selection: self.$selection) {
            Button(action: {
                self.selection = 1
                self.EmotionGameLogModel.updateCurrentEmotionRating(rating: -1) //Reset emotion rating
                if self.emotiGameScene.score > self.EmotionGameLogModel.topScore { //Update top score
                    self.EmotionGameLogModel.updateTopScore(self.emotiGameScene.score)
                }
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
            .frame(width: self.nextButtonFrameWidth, height: self.nextButtonFrameWidth / 2)
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
    
    //View of view header
    func headerView() -> some View {
        Text("EmotiGame: Visualize Your Feelings")
            .padding()
            .font(.system(size: 25, weight: .light, design: .rounded))
            .foregroundColor(.black)
            .multilineTextAlignment(.center)
    }
    
    //Button view to begin game
    var startGamePlayView: some View {
        Button(action: {
            self.emotiGameScene.playingGame = true
        }) {
            HStack {
                Spacer()
                Text("Play Game!").foregroundColor(Color.white).bold()
                Spacer()
            }
        }
        .padding()
        .background(Color(UIColor.purple))
        .cornerRadius(4.0)
        .frame(width: self.buttonFrameWidth, height: self.buttonFrameHeight)
        
    }
    
    var gameInstructionsButton: some View {
        Button(action: {
            self.showGameInstructions = true
        }) {
            HStack {
                Spacer()
                Text("Instructions").foregroundColor(Color.white).bold()
                Spacer()
            }
        }
        .padding()
        .background(Color(UIColor.purple))
        .cornerRadius(4.0)
        .frame(width: self.buttonFrameWidth, height: self.buttonFrameHeight)
        .sheet(isPresented: self.$showGameInstructions) {
            GameInstructionsView(showSheet: self.$showGameInstructions)
        }
    }
    
    // MARK: - Drawing and Transition Constants
    let buttonFrameWidth: CGFloat = 190
    let buttonFrameHeight: CGFloat = 75
    let nextButtonFrameWidth: CGFloat = 150
    let buttonPadding: CGFloat = 50
}


