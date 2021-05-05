//
//  HabitCollectionViewController.swift
//  Habits
//
//  Created by Dmitry Reshetnik on 04.05.2021.
//

import UIKit

private let reuseIdentifier = "Cell"

class HabitCollectionViewController: UICollectionViewController {
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    enum ViewModel {
        enum Section: Hashable, Equatable, Comparable {
            case favorites
            case category(_ category: Category)
            
            static func < (lhs: Section, rhs: Section) -> Bool {
                switch (lhs, rhs) {
                    case (.category(let l), .category(let r)):
                        return l.name < r.name
                    case (.favorites, _):
                        return true
                    case (_, .favorites):
                        return false
                }
            }
        }
        
        struct Item: Hashable, Equatable {
            let habit: Habit
            let isFavorite: Bool
        }
    }
    
    struct Model {
        var habitsByName = [String: Habit]()
        var favoriteHabits: [Habit] {
            return Settings.shared.favoriteHabits
        }
    }
    
    var dataSource: DataSourceType!
    var model = Model()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func update() {
        HabitRequest().send { result in
            switch result {
                case .success(let habits):
                    self.model.habitsByName = habits
                case .failure:
                    self.model.habitsByName = [:]
            }
            
            DispatchQueue.main.async {
                self.updateCollectionView()
            }
        }
    }
    
    func updateCollectionView() {
        let itemsBySection = model.habitsByName.values.reduce(into: [ViewModel.Section: [ViewModel.Item]]()) { partial, habit in
            let section: ViewModel.Section
            let item: ViewModel.Item
            
            if model.favoriteHabits.contains(habit) {
                section = .favorites
                item = ViewModel.Item(habit: habit, isFavorite: true)
            } else {
                section = .category(habit.category)
                item = ViewModel.Item(habit: habit, isFavorite: false)
            }
            
            partial[section, default: []].append(item)
        }
        
        let sectionIDs = itemsBySection.keys.sorted()
    }

}
