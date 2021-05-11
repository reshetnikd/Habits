//
//  LoggedHabit.swift
//  Habits
//
//  Created by Dmitry Reshetnik on 11.05.2021.
//

import Foundation

struct LoggedHabit {
    let userID: String
    let habitName: String
    let timestamp: Date
}

extension LoggedHabit: Codable { }
