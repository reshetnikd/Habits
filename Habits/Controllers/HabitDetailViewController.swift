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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
