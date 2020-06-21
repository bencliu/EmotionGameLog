//
//  ContentView.swift
//  emotionGameLog
//
//  Created by Benjamin Liu on 5/29/20.
//  Copyright © 2020 Benjamin Liu. All rights reserved.
//
//  Description: Starter page of game with options to start cycle or edit preferences

import SwiftUI

struct EmotionGameLogView: View {
    @EnvironmentObject var EmotionGameLogModel: EmotionGameLog
    @State var showPreferencesEditor: Bool = false
    @State var selection: Int? = nil
    @State var showHourAlert: Bool = false
    @State var preferencesFilled: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            NavigationView {
                VStack {
                    Group {
                        if (self.preferencesFilled || self.EmotionGameLogModel.firstName.count > 0) {
                            self.consistentView(width: geometry.size.width, height: geometry.size.height)
                        } else {
                            self.starterView(width: geometry.size.width, height: geometry.size.height)
                        }
                    }
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
    }
    
    //Button to navigate to next view, implements date logic to ensure 24 hour usage interval
    func nextButtonView(title: String) -> some View {
        NavigationLink(destination: DayRateView().environmentObject(self.EmotionGameLogModel), tag: 1, selection: self.$selection) {
            Button(action: {
                let lastDate = self.EmotionGameLogModel.userNotificationsBundle.dateLastAccessed
                let timeBetweenAccess = Date().timeIntervalSinceReferenceDate - lastDate.timeIntervalSinceReferenceDate
                let validAccess: Bool = timeBetweenAccess > 86400 //Seconds per day
                if validAccess {
                    self.EmotionGameLogModel.updateNotificationsBundle(date: Date(), notificationsOn: nil, points: nil, notificationsDate: nil)
                    self.selection = 1
                } else {
                    self.showHourAlert = true
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
            .frame(width: 200, height: 75)
            .alert(isPresented: self.$showHourAlert) {
                return Alert(title: Text("Log Overusage!"),
                         message: Text("You may only use the log once per day, check back tomorrow!"),
                         dismissButton: .default(Text("OK"))
                )
            }
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
    
    //View for new users who have not entered any info
    func starterView(width: CGFloat, height: CGFloat) -> some View {
        VStack {
            Text("Welcome!")
                .font(.title)
            self.preferencesButton(title: "Get Started")
                .popover(isPresented: self.$showPreferencesEditor) {
                    PreferencesEditor(isShowing: self.$showPreferencesEditor,
                                      preferencesFilled: self.$preferencesFilled)
                        .environmentObject(self.EmotionGameLogModel)
                        .frame(minWidth: width - 50, minHeight: height)
                }
        }
    }
    
    //View for users who ahve used the app before
    func consistentView(width: CGFloat, height: CGFloat) -> some View {
        VStack {
            Text("Welcome, \(self.EmotionGameLogModel.firstName)")
                .font(.title)
                .padding(.bottom)
            VStack {
                self.preferencesButton(title: "Edit Preferences")
                    .popover(isPresented: self.$showPreferencesEditor) {
                        PreferencesEditor(isShowing: self.$showPreferencesEditor,
                                          preferencesFilled: self.$preferencesFilled)
                        .environmentObject(self.EmotionGameLogModel)
                    }
                self.nextButtonView(title: "Begin EmotiCycle")
            }
        }
    }
    
    //Button used to show the preferences pop-up
    func preferencesButton(title: String) -> some View {
        Button(action: {
            self.showPreferencesEditor = true
        }) {
            HStack {
                Spacer()
                Text("Edit Preferences").foregroundColor(Color.white).bold()
                Spacer()
            }
        }
        .padding()
        .background(Color(UIColor.purple))
        .cornerRadius(4.0)
        .frame(width: 190, height: 75)
    }
}

