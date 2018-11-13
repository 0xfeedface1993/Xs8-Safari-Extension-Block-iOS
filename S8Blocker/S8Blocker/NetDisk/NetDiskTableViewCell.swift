//
//  NetDiskTableViewCell.swift
//  Sex8BlockExtension-iOS
//
//  Created by virus1993 on 2017/8/17.
//  Copyright © 2017年 ascp. All rights reserved.
//

import UIKit
import Kingfisher

let NetDiskTableViewCellIdentifier = "ndtv"

class NetDiskTableViewCell: UITableViewCell {
    @IBOutlet weak var customTitle: UILabel!
    @IBOutlet var previewImages: [UIImageView]!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadData(_ data: NetDiskModal) {
        customTitle.text = data.title
    }
}
