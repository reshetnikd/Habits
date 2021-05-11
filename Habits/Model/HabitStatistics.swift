//
//  HabitStatistics.swift
//  Habits
//
//  Created by Dmitry Reshetnik on 11.05.2021.
//

import Foundation

struct HabitStatistics {
    let habit: Habit
    let userCounts: [UserCount]
}

extension HabitStatistics: Codable { }
