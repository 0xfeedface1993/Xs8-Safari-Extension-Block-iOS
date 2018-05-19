//
//  NetDiskDetailViewController.swift
//  S8Blocker
//
//  Created by virus1994 on 2017/8/17.
//  Copyright © 2017年 ascp. All rights reserved.
//

import UIKit
import WebKit
import Kingfisher

struct ImageItem {
    var image: Image
    var height: CGFloat
}

class NetDiskDetailViewController: UITableViewController {
    var netdisk : NetDiskModal?
    var images = [ImageItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "详情"
        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: "NetDiskTitleTableViewCell", bundle: nil), forCellReuseIdentifier: NetDiskTitleTableViewCellIdentitfier)
        tableView.register(UINib(nibName: "NetDiskImageTableViewCell", bundle: nil), forCellReuseIdentifier: NetDiskImageTableViewCellIdentitfier)
        tableView.separatorStyle = .none
        
        downloadImages()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func downloadImages() {
        guard let imageLinks = netdisk?.images else {
            return
        }
        
        let downloader = ImageDownloader.default
        for img in imageLinks {
            guard let url = URL(string: img) else {
                continue
            }
            downloader.downloadImage(with: url, retrieveImageTask: nil, options: nil, progressBlock: nil) { (image, err, url, data) in
                if let e = err {
                    print(e)
                    return
                }
                self.images.append(ImageItem(image: image!, height: image!.size.height / image!.size.width))
                
                if Thread.isMainThread {
                    self.tableView.reloadData()
                }   else    {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
}

extension NetDiskDetailViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3 + images.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: NetDiskTitleTableViewCellIdentitfier, for: indexPath) as! NetDiskTitleTableViewCell
            cell.title.text = netdisk?.title
            cell.title.textColor = .black
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: NetDiskTitleTableViewCellIdentitfier, for: indexPath) as! NetDiskTitleTableViewCell
            cell.title.text = netdisk?.fileSize
            cell.title.textColor = .lightGray
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: NetDiskTitleTableViewCellIdentitfier, for: indexPath) as! NetDiskTitleTableViewCell
            cell.title.text = netdisk?.password
            cell.title.textColor = .lightGray
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: NetDiskImageTableViewCellIdentitfier, for: indexPath) as! NetDiskImageTableViewCell
            cell.img.image = images[indexPath.row - 3].image
            let constraint = NSLayoutConstraint(item: cell.img, attribute: .height, relatedBy: .equal, toItem: cell.img, attribute: .width, multiplier: images[indexPath.row - 3].height, constant: 0)
            constraint.priority = UILayoutPriority(rawValue: 999)
            NSLayoutConstraint.activate([constraint])
            cell.layoutIfNeeded()
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if let cell = tableView.cellForRow(at: indexPath) as? NetDiskImageTableViewCell, let img = cell.img.image {
//            return self.view.frame.size.width * (img.size.height / img.size.width)
//        }
//        return 300
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

