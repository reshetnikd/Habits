//
//  HomeCollectionViewController.swift
//  Habits
//
//  Created by Dmitry Reshetnik on 04.05.2021.
//

import UIKit

class HomeCollectionViewController: UICollectionViewController {
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    enum ViewModel {
        enum Section: Equatable, Hashable {
            case leaderboard
            case followedUsers
        }
        
        enum Item: Equatable, Hashable {
            case leaderboardHabit(name: String, leadingUserRanking: String?, secondaryUserRanking: String?)
            case followedUser(_ user: User, message: String)
        }
    }
    
    struct Model {
        var usersByID = [String: User]()
        var habitsByName = [String: Habit]()
        var habitStatistics = [HabitStatistics]()
        var userStatistics = [UserStatistics]()
        
        var currentUser: User {
            return Settings.shared.currentUser
        }
        
        var users: [User] {
            return Array(usersByID.values)
        }
        
        var habits: [Habit] {
            return Array(habitsByName.values)
        }
        
        var followedUsers: [User] {
            return Array(usersByID.filter { Settings.shared.followedUserIDs.contains($0.key) }.values)
        }
        
        var favoriteHabits: [Habit] {
            return Settings.shared.favoriteHabits
        }
        
        var nonFavoriteHabits: [Habit] {
            return habits.filter { !favoriteHabits.contains($0) }
        }
    }
    
    var dataSource: DataSourceType!
    var model = Model()
    var updateTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserRequest().send { result in
            switch result {
                case .success(let users):
                    self.model.usersByID = users
                case .failure:
                    break
            }
            
            DispatchQueue.main.async {
                self.updateCollectionView()
            }
        }
        
        HabitRequest().send { result in
            switch result {
                case .success(let habits):
                    self.model.habitsByName = habits
                case .failure:
                    break
            }
            
            DispatchQueue.main.async {
                self.updateCollectionView()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        update()
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.update()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    func update() {
        CombinedStatisticsRequest().send { result in
            switch result {
                case .success(let combinedStatistics):
                    self.model.userStatistics = combinedStatistics.userStatistics
                    self.model.habitStatistics = combinedStatistics.habitStatistics
                case .failure:
                    self.model.userStatistics = []
                    self.model.habitStatistics = []
            }
            
            DispatchQueue.main.async {
                self.updateCollectionView()
            }
        }
    }
    
    func updateCollectionView() {
        var sectionIDs = [ViewModel.Section]()
    }

}
