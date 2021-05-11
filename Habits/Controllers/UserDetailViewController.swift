//
//  UserDetailViewController.swift
//  Habits
//
//  Created by Dmitry Reshetnik on 04.05.2021.
//

import UIKit

class UserDetailViewController: UIViewController {
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var bioLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    enum ViewModel {
        enum Section: Hashable, Comparable {
            case leading
            case category(_ category: Category)
            
            static func < (lhs: Section, rhs: Section) -> Bool {
                switch (lhs, rhs) {
                    case (.leading, .category), (.leading, .leading):
                        return true
                    case (.category, .leading):
                        return false
                    case (category(let category1), category(let category2)):
                        return category1.name > category2.name
                }
            }
        }
        
        typealias Item = HabitCount
    }
    
    struct Model {
        var userStats: UserStatistics?
        var leadingStats: UserStatistics?
    }
    
    var dataSource: DataSourceType!
    var model = Model()
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userNameLabel.text = user.name
        bioLabel.text = user.bio
    }
    
    init?(coder: NSCoder, user: User) {
        self.user = user
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update() {
        UserStatisticsRequest(userIDs: [user.id]).send { result in
            switch result {
                case .success(let userStats):
                    self.model.userStats = userStats[0]
                case .failure:
                    self.model.userStats = nil
            }
            
            DispatchQueue.main.async {
                self.updateCollectionView()
            }
        }
        
        HabitLeadStatisticsRequest(userID: user.id).send { result in
            switch result {
                case .success(let userStats):
                    self.model.leadingStats = userStats
                case .failure:
                    self.model.leadingStats = nil
            }
            
            DispatchQueue.main.async {
                self.updateCollectionView()
            }
        }
    }
    
    func updateCollectionView() {
        guard let userStatistics = model.userStats,
              let leadingStatistics = model.leadingStats else {
            return
        }
        
        var itemsBySection = userStatistics.habitCounts.reduce(into: [ViewModel.Section: [ViewModel.Item]]()) { partial, habitCount in
            let section: ViewModel.Section
            
            if leadingStatistics.habitCounts.contains(habitCount) {
                section = .leading
            } else {
                section = .category(habitCount.habit.category)
            }
            
            partial[section, default: []].append(habitCount)
        }
        
        itemsBySection = itemsBySection.mapValues { $0.sorted() }
        
        let sectionIDs = itemsBySection.keys.sorted()
        
        dataSource.applySnapshotUsing(sectionIDs: sectionIDs, itemsBySection: itemsBySection)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
