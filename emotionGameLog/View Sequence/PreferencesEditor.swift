//
//  preferencesEditor.swift
//  emotionGameLog
//
//  Created by Benjamin Liu on 5/29/20.
//  Copyright © 2020 Benjamin Liu. All rights reserved.
//
//  Description: View for user preferences editor

import SwiftUI
import UserNotifications

struct PreferencesEditor: View {
    @EnvironmentObject var EmotionGameLogModel: EmotionGameLog
    
    //Manage display of popovers and keyboard interactions
    @Binding var isShowing: Bool
    @Binding var preferencesFilled: Bool
    @State var invalidPreferenceStatus: Bool = false
    @State private var keyboardOffset: CGFloat = 0
    
    //User info bundle states
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var spiritAnimal: String = ""
    @State var quote: String = ""
    @State var memory: String = ""
    @State var food: String = ""
    
    //User notification bundle states
    @State private var notificationDate = Date()
    @State var happinessRating: Float = 1
    @State var notificationsOn: Bool = false
    
    var body: some View {
        VStack {
            self.preferencesEditorFrame
            Divider()
            Form {
                self.firstNameEditorView
                self.lastNameEditorView
                self.foodEditorView
                self.memoryEditorView
                self.quoteEditorView
                self.animalEditorView
                self.notificationsPickerView
                self.happinessSlider
                self.notificationToggle
            }
        }
        .offset(x: 0, y: self.keyboardOffset)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    //Frame for popover: Includes button with logic for properly filled fields
    var preferencesEditorFrame: some View {
        ZStack {
            Text("Preferences Editor")
                .font(.title)
                .padding()
            HStack {
                Spacer()
                Button(action: {
                    if self.preferencesFilledCorrectly() {
                        self.EmotionGameLogModel.updateNotificationsBundle(date: nil, notificationsOn: self.notificationsOn, points: Int(self.happinessRating), notificationsDate: self.notificationDate)
                        self.isShowing = false
                        self.preferencesFilled = true
                    } else {
                        self.invalidPreferenceStatus = true
                    }
                }, label: { Text("Done") })
                .padding()
            }
            .alert(isPresented: self.$invalidPreferenceStatus) {
                return Alert(
                    title: Text("Preference Error"),
                    message: Text("All preference fields must be filled out!"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    // MARK: - Text Editor Fields
    
    var firstNameEditorView: some View {
        Section(header: Text("Enter First Name")) {
            TextField("First Name", text: $firstName, onEditingChanged:
                { began in
                    if !began {
                        self.EmotionGameLogModel.updateUserBundle(firstName: self.firstName, lastName: nil, food: nil, memory: nil, quote: nil, spiritAnimal: nil)
                    }
            })
                .onAppear(perform: {self.firstName = self.EmotionGameLogModel.firstName})
        }
    }
    
    var lastNameEditorView: some View {
        Section(header: Text("Enter Last Name")) {
            TextField("Last Name", text: $lastName, onEditingChanged:
                { began in
                    if !began {
                        self.EmotionGameLogModel.updateUserBundle(firstName: nil, lastName: self.lastName, food: nil, memory: nil, quote: nil, spiritAnimal: nil)
                    }
            })
                .onAppear(perform: {self.lastName = self.EmotionGameLogModel.lastName})
        }
    }
    
    var animalEditorView: some View {
        Section(header: Text("Spirit Animal")) {
            TextField("Animal", text: $spiritAnimal, onEditingChanged:
                { began in
                    if !began {
                        self.EmotionGameLogModel.updateUserBundle(firstName: nil, lastName: nil, food: nil, memory: nil, quote: nil, spiritAnimal: self.spiritAnimal)
                        withAnimation(.easeIn(duration: self.keyboardSlideDuration)) {
                                    self.keyboardOffset = 0
                        }
                    } else {
                        withAnimation(.easeIn(duration: self.keyboardSlideDuration)) {
                            self.keyboardOffset = self.largeKeyboardOffest
                        }
                    }
            })
                .onAppear(perform: {self.spiritAnimal = self.EmotionGameLogModel.spiritAnimal})
        }
    }
    
    var quoteEditorView: some View {
        Section(header: Text("Motivational Quote")) {
            TextField("Quote", text: $quote, onEditingChanged:
                { began in
                    if !began {
                        self.EmotionGameLogModel.updateUserBundle(firstName: nil, lastName: nil, food: nil, memory: nil, quote: self.quote, spiritAnimal: nil)
                        withAnimation(.easeIn(duration: self.keyboardSlideDuration)) {
                            self.keyboardOffset = 0
                        }
                    } else {
                        withAnimation(.easeIn(duration: self.keyboardSlideDuration)) {
                            self.keyboardOffset = self.mediumKeyboardOffest
                        }
                    }
            })
                .onAppear(perform: {self.quote = self.EmotionGameLogModel.quote})
        }
    }
    
    var foodEditorView: some View {
        Section(header: Text("Favorite Food")) {
            TextField("Food", text: $food, onEditingChanged:
                { began in
                    if !began {
                        self.EmotionGameLogModel.updateUserBundle(firstName: nil, lastName: nil, food: self.food, memory: nil, quote: nil, spiritAnimal: nil)
                        withAnimation(.easeIn(duration: self.keyboardSlideDuration)) {
                            self.keyboardOffset = 0
                        }
                    } else {
                        withAnimation(.easeIn(duration: self.keyboardSlideDuration)) {
                            self.keyboardOffset = self.smallKeyboardOffest
                        }
                    }
            })
                .onAppear(perform: {self.food = self.EmotionGameLogModel.food})
        }
    }
    
    var memoryEditorView: some View {
        Section(header: Text("Cherished Memory")) {
            TextField("Memory", text: $memory, onEditingChanged:
                { began in
                    if !began {
                        self.EmotionGameLogModel.updateUserBundle(firstName: nil, lastName: nil, food: nil, memory: self.memory, quote: nil, spiritAnimal: nil)
                        withAnimation(.easeIn(duration: self.keyboardSlideDuration)) {
                            self.keyboardOffset = 0
                        }
                    } else {
                        withAnimation(.easeIn(duration: self.keyboardSlideDuration)) {
                            self.keyboardOffset = self.smallKeyboardOffest
                        }
                    }
            })
                .onAppear(perform: {self.memory = self.EmotionGameLogModel.memory})
        }
    }
    
    
    // MARK: - Notification Editor Fields
    
    var notificationToggle: some View {
        Section {
            Toggle(isOn: self.$notificationsOn) {
                Text("Turn on Notifications")
            }.padding()
        }
        .onAppear(perform: {self.notificationsOn = self.EmotionGameLogModel.userNotificationsBundle.notificationsOn} )
    }
    
    var notificationsPickerView: some View {
        Section(header: Text("Schedule Notifications")) {
            DatePicker("Notification Time", selection:
            self.$notificationDate, displayedComponents: .hourAndMinute)
            .labelsHidden()
        }
        .onAppear(perform: {self.notificationDate = self.EmotionGameLogModel.userNotificationsBundle.notificationDate})
    }
    
    var happinessSlider: some View {
        Section(header: Text("General Happines Rating")) {
            VStack {
                HStack {
                    Text("Sad")
                    Slider(value: self.$happinessRating, in: 1...10, step: 1)
                        .frame(width: self.sliderFrameWidth, height: self.sliderFrameHeight)
                    Text("Joyous")
                }
                Text("\(Int(self.happinessRating)) Happiness Points")
            }
        }
        .onAppear(perform: {self.happinessRating = Float(self.EmotionGameLogModel.userNotificationsBundle.happinessPoints)})
    }
    
    //Helper function used to determine if preferences filled properly
    func preferencesFilledCorrectly() -> Bool {
        let preferencesArray = [self.firstName, self.lastName, self.spiritAnimal, self.quote, self.memory, self.food]
        for index in 0..<preferencesArray.count {
            if preferencesArray[index].count == 0 {
                return false
            }
        }
        return true
    }
    
    // MARK: - Drawing and Transition Constants
    let smallKeyboardOffest: CGFloat = -100
    let mediumKeyboardOffest: CGFloat = -200
    let largeKeyboardOffest: CGFloat = -300
    let sliderFrameWidth: CGFloat = 200
    let sliderFrameHeight: CGFloat = 20
    let keyboardSlideDuration: Double = 0.2
}

