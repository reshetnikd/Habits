//
//  UserCollectionViewController.swift
//  Habits
//
//  Created by Dmitry Reshetnik on 04.05.2021.
//

import UIKit

private let reuseIdentifier = "Cell"

class UserCollectionViewController: UICollectionViewController {
    typealias DataSourceType = UICollectionViewDiffableDataSource<ViewModel.Section, ViewModel.Item>
    
    enum ViewModel {
        typealias Section = Int
        
        struct Item: Hashable {
            let user: User
            let isFollowed: Bool
        }
    }
    
    struct Model {
        var userByID = [String: User]()
        var followedUsers: [User] {
            return Array(userByID.filter { Settings.shared.followedUserIDs.contains($0.key) }.values)
        }
    }
    
    var dataSource: DataSourceType!
    var model = Model()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func update() {
        UserRequest().send { result in
            switch result {
                case .success(let users):
                    self.model.userByID = users
                case .failure:
                    self.model.userByID = [:]
            }
            
            DispatchQueue.main.async {
                self.updateCollectionView()
            }
        }
    }
    
    func updateCollectionView() {
        let users = model.userByID.values.sorted().reduce(into: [ViewModel.Item]()) { partial, user in
            partial.append(ViewModel.Item(user: user, isFollowed: model.followedUsers.contains(user)))
        }
        
        let itemsBySection = [0: users]
        
        dataSource.applySnapshotUsing(sectionIDs: [0], itemsBySection: itemsBySection)
    }

}
