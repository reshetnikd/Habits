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
    
    static let formatter: NumberFormatter = {
        var formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter
    }()
    
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
        
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createLayout()
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
    
    func ordinalString(from number: Int) -> String {
        return Self.formatter.string(from: NSNumber(integerLiteral: number + 1))!
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
        
        let leaderboardItems = model.habitStatistics.filter { statistic in
            return model.favoriteHabits.contains { $0.name == statistic.habit.name }
        }
        .sorted { $0.habit.name < $1.habit.name }
        .reduce(into: [ViewModel.Item]()) { partial, statistic in
            // Rank the user counts from highest to lowest.
            let rankedUserCounts = statistic.userCounts.sorted { $0.count > $1.count }
            
            // Find the index of the current user's count, keeping in mind that it won't exist if the user hasn't logged that habit yet.
            let myCountIndex = rankedUserCounts.firstIndex { $0.user.id == self.model.currentUser.id }
            
            func userRankingString(from userCount: UserCount) -> String {
                var name = userCount.user.name
                var ranking = ""
                
                if userCount.user.id == self.model.currentUser.id {
                    name = "You"
                    ranking = " (\(ordinalString(from: myCountIndex!)))"
                }
                
                return "\(name) \(userCount.count)" + ranking
            }
            
            var leadingRanking: String?
            var secondaryRanking: String?
            
            // Examine the number of user counts for the statistic:
            switch rankedUserCounts.count {
                case 0:
                // If 0, set the leader label to "Nobody Yet!" and leave the secondary label `nil`.
                    leadingRanking = "Nobody yet!"
                case 1:
                // If 1, set the leader label to the only user and count.
                    let onlyCount = rankedUserCounts.first!
                    leadingRanking = userRankingString(from: onlyCount)
                default:
                // Otherwise, do the following:
                    // Set the leader label to the user count at index 0.
                    leadingRanking = userRankingString(from: rankedUserCounts[0])
                    
                    // Check whether the index of the current user's count exists and is not 0.
                    if let myCountIndex = myCountIndex,
                       myCountIndex != rankedUserCounts.startIndex {
                        // If true, the user's count and ranking should be displayed in the secondary label.
                        secondaryRanking = userRankingString(from: rankedUserCounts[myCountIndex])
                    } else {
                        // If false, the second-place user count should be displayed
                        secondaryRanking = userRankingString(from: rankedUserCounts[1])
                    }
            }
            
            let leaderboardItem = ViewModel.Item.leaderboardHabit(name: statistic.habit.name, leadingUserRanking: leadingRanking, secondaryUserRanking: secondaryRanking)
            
            partial.append(leaderboardItem)
        }
        
        sectionIDs.append(.leaderboard)
        
        let itemsBySection = [ViewModel.Section.leaderboard: leaderboardItems]
        
        dataSource.applySnapshotUsing(sectionIDs: sectionIDs, itemsBySection: itemsBySection)
    }
    
    func createDataSource() -> DataSourceType {
        let dataSource = DataSourceType(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
                case .leaderboardHabit(let name, let leadingUserRanking, let secondaryUserRanking):
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LeaderboardHabit", for: indexPath) as! LeaderboardHabitCollectionViewCell
                    
                    cell.habitNameLabel.text = name
                    cell.leaderLabel.text = leadingUserRanking
                    cell.secondaryLabel.text = secondaryUserRanking
                    
                    return cell
                default:
                    return nil
            }
        }
        
        return dataSource
    }
    
    func createLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
            switch self.dataSource.snapshot().sectionIdentifiers[sectionIndex] {
                case .leaderboard:
                    let leaderboardItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.3))
                    let leaderboardItem = NSCollectionLayoutItem(layoutSize: leaderboardItemSize)
                    
                    let verticalTrioSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.75), heightDimension: .fractionalWidth(0.75))
                    let leaderboardVerticalTrio = NSCollectionLayoutGroup.vertical(layoutSize: verticalTrioSize, subitem: leaderboardItem, count: 3)
                    
                    let leaderboardSection = NSCollectionLayoutSection(group: leaderboardVerticalTrio)
                    leaderboardSection.interGroupSpacing = 20
                    leaderboardSection.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0)
                    leaderboardSection.orthogonalScrollingBehavior = .groupPagingCentered
                    leaderboardSection.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 0, bottom: 20, trailing: 0)
                    
                    return leaderboardSection
                default:
                    return nil
            }
        }
        
        return layout
    }

}
