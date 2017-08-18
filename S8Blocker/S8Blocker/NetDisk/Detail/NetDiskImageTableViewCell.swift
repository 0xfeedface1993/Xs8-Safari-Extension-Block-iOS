//
//  NetDiskImageTableViewCell.swift
//  S8Blocker
//
//  Created by virus1994 on 2017/8/18.
//  Copyright © 2017年 ascp. All rights reserved.
//

import UIKit
import Kingfisher

let NetDiskImageTableViewCellIdentitfier = "nditvci"

class NetDiskImageTableViewCell: UITableViewCell {
    @IBOutlet weak var img: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadData(_ str: String) {
        if let url = URL(string: str) {
            img.kf.setImage(with: url)
        }
    }
}
