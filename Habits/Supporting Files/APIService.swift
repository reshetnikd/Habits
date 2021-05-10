//
//  APIService.swift
//  Habits
//
//  Created by Dmitry Reshetnik on 05.05.2021.
//

import Foundation

struct HabitRequest: APIRequest {
    typealias Response = [String: Habit]
    
    var habitName: String?
    var path: String { "/habits" }
}
