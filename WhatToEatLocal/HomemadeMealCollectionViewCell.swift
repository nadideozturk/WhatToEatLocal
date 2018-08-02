//
//  MealTableViewCell.swift
//  WhatToEatLocal
//
//  Created by Engin Oruc Ozturk on 6.02.2018.
//  Copyright © 2018 NadideOzturk. All rights reserved.
//

import UIKit

class HomemadeMealCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var hmMealImageView: UIImageView!
    
    @IBOutlet weak var hmMealDurInMinLabel: UILabel!
    
    @IBOutlet weak var hmMealNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
