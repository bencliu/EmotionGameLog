//
//  EmotionLog.swift
//  emotionGameLog
//
//  Created by Benjamin Liu on 5/29/20.
//  Copyright © 2020 Benjamin Liu. All rights reserved.
//
//  Description:
//  Model for tracking 1) Points of gratitude; 2) Emotion Ratings; 3) User Preferences

import Foundation

struct EmotionLog: Codable {
    var emotionRating: emotionUnit = emotionUnit(rating: -1)
    var gratitudePointList: Array<String> = Array<String>()
    var momentPointList: Array<String> = Array<String>()
    var emotionRatinglist: Array<emotionUnit> = Array<emotionUnit>()
    var uniqueUserInfoBundle: userInfoBundle = EmotionLog.defaultUserBundle
    var userNotificationsBundle: userNotificationsBundle = EmotionLog.defaultNotificationsBundle
    var topEmotiGameScore: Int = 0
    var logStreak: Int = 0
    
    //User preference information
    struct userInfoBundle: Encodable, Decodable, Identifiable {
        var id = UUID()
        var firstName: String
        var lastName: String
        var favoriteFood: String
        var bestChildhoodMemory: String
        var spiritAnimal: String
        var favoriteMotivationalQuote: String
    }
    
    //Notification scheduling information
    struct userNotificationsBundle: Codable {
        var dateLastAccessed: Date
        var notificationsOn: Bool
        var happinessPoints: Int
        var notificationDate: Date 
    }
    
    struct emotionUnit: Encodable, Decodable, Identifiable {
        var id = UUID()
        var rating: Int
    }
    
    static var defaultUserBundle: userInfoBundle {
        let defaultBundle = self.userInfoBundle(
            firstName: "",
            lastName: "",
            favoriteFood: "",
            bestChildhoodMemory: "",
            spiritAnimal: "",
            favoriteMotivationalQuote: ""
        )
        return defaultBundle
    }
    
    static var defaultNotificationsBundle: userNotificationsBundle {
        let defaultBundle = self.userNotificationsBundle(
            dateLastAccessed: Date(timeIntervalSince1970: 1),
            notificationsOn: false,
            happinessPoints: 1,
            notificationDate: Date(timeIntervalSince1970: 1)
        )
        return defaultBundle
    }
}
