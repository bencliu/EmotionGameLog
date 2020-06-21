//
//  EmotionGameLog.swift
//  emotionGameLog
//
//  Created by Benjamin Liu on 5/29/20.
//  Copyright © 2020 Benjamin Liu. All rights reserved.
//
//  Description:
//
//  View Model that communicates with all views in the view sequence providing access to
//  emotion rating information, gratitude/moment points, and user preferences

import SwiftUI
import Combine

class EmotionGameLog: ObservableObject {
    
    @Published private var model: EmotionLog
    private var autosave: AnyCancellable?
    let name: String
    
    //Initialize with user defaults
    init(named name: String = "Emotion Game Log") {
        self.name = name
        let defaultEmotionLog: Data = try! JSONEncoder().encode(EmotionLog())
        let userDefaultsKey = "EmotionLog.\(name)"
        let emotionLog: Data = UserDefaults.standard.object(forKey: userDefaultsKey) as? Data ?? defaultEmotionLog
        self.model = try! JSONDecoder().decode(EmotionLog.self, from: emotionLog)
        autosave = $model.sink { emotionLogFinal in //Value of variable that is published
            let encodedLog = try! JSONEncoder().encode(emotionLogFinal)
            UserDefaults.standard.set(encodedLog, forKey: userDefaultsKey)
        }
    }
    
    // MARK: - Acces to the Model
    var currentEmotionRating: EmotionLog.emotionUnit {
        model.emotionRating
    }
    
    var gratitudeList: Array<String> {
        model.gratitudePointList
    }
    
    var momentList: Array<String> {
        model.momentPointList
    }
    
    var recordedEmotionList: Array<EmotionLog.emotionUnit> {
        model.emotionRatinglist
    }
    
    var firstName: String {
        model.uniqueUserInfoBundle.firstName
    }
    
    var lastName: String {
        model.uniqueUserInfoBundle.lastName
    }
    
    var spiritAnimal: String {
        model.uniqueUserInfoBundle.spiritAnimal
    }
    
    var quote: String {
        model.uniqueUserInfoBundle.favoriteMotivationalQuote
    }
    
    var memory: String {
        model.uniqueUserInfoBundle.bestChildhoodMemory
    }
    
    var food: String {
        model.uniqueUserInfoBundle.favoriteFood
    }
    
    var topScore: Int {
        model.topEmotiGameScore
    }
    
    var userNotificationsBundle: EmotionLog.userNotificationsBundle {
        model.userNotificationsBundle
    }
    
    var logStreak: Int {
        model.logStreak
    }
    
    var userBundle: EmotionLog.userInfoBundle {
        model.uniqueUserInfoBundle
    }
    
    // MARK: - User Intents
    func logEmotionRating(rating: Int) {
        objectWillChange.send()
        let newEmotionUnit: EmotionLog.emotionUnit = EmotionLog.emotionUnit(rating: rating)
        model.emotionRatinglist.append(newEmotionUnit)
    }
    
    func updateCurrentEmotionRating(rating: Int) {
        objectWillChange.send()
        let newEmotionUnit: EmotionLog.emotionUnit = EmotionLog.emotionUnit(rating: rating)
        model.emotionRating = newEmotionUnit
    }
    
    func addGratitudePoint(for point: String) {
        objectWillChange.send()
        model.gratitudePointList.append(point)
    }
    
    func addMomentPoint(for point: String) {
        objectWillChange.send()
        model.momentPointList.append(point)
    }
    
    func updateTopScore(_ score: Int) {
        objectWillChange.send()
        model.topEmotiGameScore = score
    }
    
    func updateLogStreak() {
        objectWillChange.send()
        model.logStreak += 1
    }
    
    func updateNotificationsBundle(date: Date?, notificationsOn: Bool?, points: Int?, notificationsDate: Date?) {
        if let date = date {
            self.model.userNotificationsBundle.dateLastAccessed = date
        }
        if let notificationsOn = notificationsOn {
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            if notificationsOn == true {
                self.scheduleNotification()
            } 
            self.model.userNotificationsBundle.notificationsOn = notificationsOn
        }
        if let points = points {
            self.model.userNotificationsBundle.happinessPoints = points
        }
        if let notificationsDate = notificationsDate {
            self.model.userNotificationsBundle.notificationDate = notificationsDate
        }
    }
    
    func updateUserBundle(firstName: String?, lastName: String?, food: String?, memory: String?, quote: String?, spiritAnimal: String?) {
        if let userName = firstName {
            self.model.uniqueUserInfoBundle.firstName = userName
        }
        if let lastName = lastName {
             self.model.uniqueUserInfoBundle.lastName = lastName
        }
        if let favoriteFood = food {
            self.model.uniqueUserInfoBundle.favoriteFood = favoriteFood
        }
        if let favoriteMemory = memory {
            self.model.uniqueUserInfoBundle.bestChildhoodMemory = favoriteMemory
        }
        if let favoriteQuote = quote {
            self.model.uniqueUserInfoBundle.favoriteMotivationalQuote = favoriteQuote
        }
        if let animal = spiritAnimal {
            self.model.uniqueUserInfoBundle.spiritAnimal = animal
        }
    }
    
    //Helper function called with notification status is updated
    //Note: Referenced Apple's local notification guide and Date API guide
    func scheduleNotification() {
        let notificationCenter = UNUserNotificationCenter.current()
        let notificationOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        notificationCenter.requestAuthorization(options: notificationOptions) {
            (granted, error) in
            if !granted {
                print("Failure to request authorization")
            }
        }
        let notificationBody = UNMutableNotificationContent()
        notificationBody.title = "EmotiLog Reminder!"
        notificationBody.subtitle = "It's time to log your emotions for the day!"
        notificationBody.sound = UNNotificationSound.default
        notificationBody.badge = 1
        let dateComponentBundle = Calendar.current.dateComponents([.hour, .minute], from: self.userNotificationsBundle.notificationDate)
        let notificationTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponentBundle, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: notificationBody, trigger: notificationTrigger)
        notificationCenter.add(request)
        print("Hello")
    }
    
}

//Helper for resetting user defaults (Development Purposes Only)
//Reference: Code from Stack Overflow
func resetDefaults() {
    let defaults = UserDefaults.standard
    let dictionary = defaults.dictionaryRepresentation()
    dictionary.keys.forEach { key in
        defaults.removeObject(forKey: key)
    }
}
