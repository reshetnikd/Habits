//
//  Category.swift
//  Habits
//
//  Created by Dmitry Reshetnik on 05.05.2021.
//

import Foundation

struct Category {
    let name: String
    let color: Color
}

extension Category: Codable { }

extension Category: Hashable {
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
