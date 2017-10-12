//
//  NewMovieTableViewCell.swift
//  S8Blocker
//
//  Created by virus1993 on 2017/10/9.
//  Copyright © 2017年 ascp. All rights reserved.
//

import UIKit
import Kingfisher

let NewMovieTableViewCellIdentifier = "com.ascp.nmtvci"

class NewMovieTableViewCell: UITableViewCell {
    @IBOutlet weak var cover: UIImageView!
    @IBOutlet weak var bigTitle: UILabel!
    @IBOutlet weak var discription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadData(image: String, title: String, dsc: String) {
//        cover.kf.setImage(with: URL.init(string: image), placeholder: UIImage(named: "Movie"), options: nil, progressBlock: nil, completionHandler: nil)
        cover.image = UIImage(named: "Movie")
        bigTitle.text = title
        discription.text = dsc
    }
}
