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
    
    func loadData(_ data: NetCell) {
        customTitle.text = data.modal.title
        for (index, item) in previewImages.enumerated() {
            func layoutMaker(radio: CGFloat) {
                let constraint = NSLayoutConstraint(item: item, attribute: .height, relatedBy: .equal, toItem: item, attribute: .width, multiplier: radio, constant: 0)
                constraint.priority = UILayoutPriority(rawValue: 999)
                if let index = item.constraints.index(where: { $0.firstAttribute == NSLayoutAttribute.height && $0.secondAttribute == NSLayoutAttribute.width }) {
                    if item.constraints[index] != constraint {
                        item.constraints[index].isActive = false
                        constraint.isActive = true
                    }
                }   else    {
                    constraint.isActive = true
                }
                
                item.layoutIfNeeded()
            }
            guard data.modal.images.count > index, let url = URL(string: data.modal.images[index]) else {
                item.kf.setImage(with: nil, placeholder: #imageLiteral(resourceName: "Failed"), options: nil, progressBlock: nil)
                continue
            }
            item.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "NetDisk"), options: nil, progressBlock: nil) { (img, err, type, urll) in
                if let e = err {
                    print(e)
                    item.image = #imageLiteral(resourceName: "Failed")
                }
                if let image = img, data.previewImages.count > index {
                    var value = data.previewImages[index]
                    value.size = image.size
                    layoutMaker(radio: value.radio)
                }
            }
            var value = data.previewImages[index]
            value.size = #imageLiteral(resourceName: "NetDisk").size
            layoutMaker(radio: value.radio)
        }
    }
}
