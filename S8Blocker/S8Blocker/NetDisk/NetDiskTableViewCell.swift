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
//        for (index, item) in previewImages.enumerated() {
//            guard data.images.count > index, let url = URL(string: data.images[index]) else {
//                item.kf.setImage(with: nil, placeholder: #imageLiteral(resourceName: "Failed"), options: nil, progressBlock: nil)
//                continue
//            }
//            item.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "NetDisk"), options: nil, progressBlock: nil) { (img, err, type, urll) in
//                if let e = err {
//                    print(e)
//                    item.image = #imageLiteral(resourceName: "Failed")
//                }
//            }
//        }
    }
}
