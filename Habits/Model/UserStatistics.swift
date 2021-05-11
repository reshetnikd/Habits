//
//  UserStatistics.swift
//  Habits
//
//  Created by Dmitry Reshetnik on 11.05.2021.
//

import Foundation

struct UserStatistics {
    let user: User
    let habitCounts: [HabitCount]
}

extension UserStatistics: Codable { }
