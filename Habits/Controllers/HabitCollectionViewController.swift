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
        enum Section: Hashable, Equatable {
            case favorites
            case category(_ category: Category)
        }
        
        struct Item: Hashable, Equatable {
            let habit: Habit
            let isFavorite: Bool
        }
    }
    
    struct Model {
        var habitsByName = [String: Habit]()
    }
    
    var dataSource: DataSourceType!
    var model = Model()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
