//
//  HabitCount.swift
//  Habits
//
//  Created by Dmitry Reshetnik on 11.05.2021.
//

import Foundation

struct HabitCount {
    let habit: Habit
    let count: Int
}

extension HabitCount: Codable { }

extension HabitCount: Hashable { }
