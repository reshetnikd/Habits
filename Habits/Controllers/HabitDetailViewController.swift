//
//  HabitDetailViewController.swift
//  Habits
//
//  Created by Dmitry Reshetnik on 04.05.2021.
//

import UIKit

class HabitDetailViewController: UIViewController {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    enum ViewModel {
        enum Section: Hashable {
            case leaders(count: Int)
            case remaining
        }
        
        enum Item: Hashable, Comparable {
            case single(_ stat: UserCount)
            case multiple(_ stats: [UserCount])
            
            static func < (lhs: Item, rhs: Item) -> Bool {
                switch (lhs, rhs) {
                    case (.single(let lCount), .single(let rCount)):
                        return lCount.count < rCount.count
                    case (.multiple(let lCounts), .multiple(let rCounts)):
                        return lCounts.first!.count < rCounts.first!.count
                    case (.single, .multiple):
                        return false
                    case (.multiple, .single):
                        return true
                }
            }
        }
    }
    
    struct Model {
        var habitStatistics: HabitStatistics?
        var userCounts: [UserCount] {
            habitStatistics?.userCounts ?? []
        }
    }
    
    var dataSource: DataSourceType!
    var model = Model()
    var habit: Habit!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = habit.name
        categoryLabel.text = habit.category.name
        infoLabel.text = habit.info
    }
    
    init?(coder: NSCoder, habit: Habit) {
        self.habit = habit
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update() {
        HabitStatisticsRequest(habitNames: [habit.name]).send { result in
            if case .success(let statistics) = result, statistics.count > 0 {
                self.model.habitStatistics = statistics[0]
            } else {
                self.model.habitStatistics = nil
            }
            
            DispatchQueue.main.async {
                self.updateCollectionView()
            }
        }
    }
    
    func updateCollectionView() {
        let items = (self.model.habitStatistics?.userCounts.map { ViewModel.Item.single($0) } ?? []).sorted(by: >)
        
        dataSource.applySnapshotUsing(sectionIDs: [.remaining], itemsBySection: [.remaining: items])
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
