//
//  CategroryCollectionViewCell.swift
//  S8Blocker
//
//  Created by virus1993 on 2018/1/15.
//  Copyright © 2018年 ascp. All rights reserved.
//

import UIKit

class CategroryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var title: UILabel!
    func load(image imageData: UIImage?, title titleText : String) {
        self.image.image = imageData
        self.title.text = titleText
    }
}
