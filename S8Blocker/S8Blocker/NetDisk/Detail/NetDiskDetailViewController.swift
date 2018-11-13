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
import WebShell_iOS

enum DownloadState {
    case wait
    case downloading
    case downloaded
    case error
}

struct ImageItem {
    var url: URL?
    var image: UIImage?
    var state: DownloadState
    var size: CGSize
    var radio: CGFloat {
        return size.height / size.width
    }
    func realHeight(fitWidth: CGFloat) -> CGFloat {
        return radio * fitWidth
    }
}

let CacheOptions : KingfisherOptionsInfo = [.downloader(ImageDownloader.default)]

class NetDiskDetailViewController: UITableViewController {
    var netdisk : NetDiskModal?
    var images = [ImageItem]()
    
    let image = UIImageView()
    let centerImageView = UIImageView()
    let cover = UIView()
    
    let downloadButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 44))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "详情"
        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: "NetDiskTitleTableViewCell", bundle: nil), forCellReuseIdentifier: NetDiskTitleTableViewCellIdentitfier)
        tableView.register(UINib(nibName: "NetDiskImageTableViewCell", bundle: nil), forCellReuseIdentifier: NetDiskImageTableViewCellIdentitfier)
        tableView.separatorStyle = .none
        tableView.prefetchDataSource = self
        
        guard let imageLinks = netdisk?.images else {
            return
        }
        
        if netdisk?.downloads.count ?? 0 > 0 {
            let collect = UIBarButtonItem(title: "下载", style: .plain, target: self, action: #selector(download))
            navigationItem.rightBarButtonItem = collect
        }
        
        images = imageLinks.map({ ImageItem(url: URL(string: $0), image: nil, state: .wait, size: #imageLiteral(resourceName: "NetDisk").size) })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadMemoView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        image.removeFromSuperview()
        centerImageView.removeFromSuperview()
        cover.removeFromSuperview()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func download() {
        guard let urls = netdisk?.downloads.map({ URL(string: $0) }) else {
            return
        }
        
        let popver = URLListTableViewController()
        popver.urls = urls.filter({ $0 != nil }).map({ $0! })
        popver.preferredContentSize = CGSize(width: 300, height: popver.urls.count > 6 ? 6 * 44:popver.urls.count * 44 )
        popver.modalPresentationStyle = .popover
        popver.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        popver.popoverPresentationController?.permittedArrowDirections = .up
        let defaultDelegate = popver.popoverPresentationController?.delegate
        popver.popoverPresentationController?.delegate = self
        popver.downloadAction = { [unowned self] url in
            if let riffle = PCPipeline.share.add(url: url.absoluteString, password: self.netdisk?.password ?? "") {
                DownloaderController.share.add(riffle: riffle)
            }
            
            popver.dismiss(animated: true, completion: {
                popver.popoverPresentationController?.delegate = defaultDelegate
                self.performSegue(withIdentifier: "com.ascp.downloader.push", sender: nil)
            })
        }
        present(popver, animated: true, completion: nil)
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
            
            func layoutMaker(radio: CGFloat) {
                let constraint = NSLayoutConstraint(item: cell.img, attribute: .height, relatedBy: .equal, toItem: cell.img, attribute: .width, multiplier: radio, constant: 0)
                constraint.priority = UILayoutPriority(rawValue: 999)
                if let index = cell.img.constraints.index(where: { $0.firstAttribute == NSLayoutConstraint.Attribute.height && $0.secondAttribute == NSLayoutConstraint.Attribute.width }) {
                    if cell.img.constraints[index] != constraint {
                        cell.img.constraints[index].isActive = false
                        constraint.isActive = true
                    }
                }   else    {
                    constraint.isActive = true
                }
                
                cell.layoutIfNeeded()
            }
            
            let linkIndex = indexPath.row - 3
            let item = self.images[linkIndex]
            switch item.state {
            case .wait:
                self.images[linkIndex].state = .downloading
                guard let url = item.url else {
                    cell.img.image = #imageLiteral(resourceName: "Failed")
                    self.images[linkIndex].state = .error
                    break
                }
                if let cache = ImageCache.default.retrieveImageInMemoryCache(forKey: url.absoluteString) ?? ImageCache.default.retrieveImageInDiskCache(forKey: url.absoluteString) {
                    self.images[linkIndex].state = .downloaded
                    self.images[linkIndex].image = cache
                    self.images[linkIndex].size = cache.size
                    if tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
                        cell.img.image = cache
                        tableView.reloadData()
                    }
                    break
                }
                ImageDownloader.default.downloadImage(with: url, completionHandler: { (image, error, urlx, data) in
                    if let _ = error {
                        DispatchQueue.main.async {
                            self.images[linkIndex].state = .error
                            self.images[linkIndex].size = #imageLiteral(resourceName: "Failed").size
                            if tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
                                cell.img.image = #imageLiteral(resourceName: "Failed")
                                tableView.reloadData()
                            }
                        }
                        return
                    }
                    if let img = image {
                        DispatchQueue.main.async {
                            ImageCache.default.store(img, forKey: url.absoluteString)
                            self.images[linkIndex].image = image
                            self.images[linkIndex].state = .downloaded
                            self.images[linkIndex].size = img.size
                            if tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
                                cell.img.image = image
                                tableView.reloadData()
                            }
                        }
                    }
                })
                cell.img.image = #imageLiteral(resourceName: "NetDisk")
            case .downloading:
                cell.img.image = #imageLiteral(resourceName: "NetDisk")
            case .downloaded:
                cell.img.image = self.images[linkIndex].image
            case .error:
                cell.img.image = #imageLiteral(resourceName: "Failed")
            }
            
            layoutMaker(radio: self.images[linkIndex].radio)
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if let cell = tableView.cellForRow(at: indexPath) as? NetDiskImageTableViewCell {
//            return self.view.frame.size.width * (img.size.height / img.size.width)
//        }
//        return 300
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    

}

extension NetDiskDetailViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { (indexPath) in
            guard indexPath.row >= 3 else {
                return
            }
            let linkIndex = indexPath.row - 3
            let item = self.images[linkIndex]
            guard let url = item.url else {
                self.images[linkIndex].state = .error
                return
            }
            
            switch item.state {
            case .wait:
                self.images[linkIndex].state = .downloading
                if let cache = ImageCache.default.retrieveImageInMemoryCache(forKey: url.absoluteString) ?? ImageCache.default.retrieveImageInDiskCache(forKey: url.absoluteString) {
                    self.images[linkIndex].state = .downloaded
                    self.images[linkIndex].image = cache
                    self.images[linkIndex].size = cache.size
                    if tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
                        tableView.reloadData()
                    }
                    break
                }
                ImageDownloader.default.downloadImage(with: url, completionHandler: { (image, error, urlx, data) in
                    if let _ = error {
                        DispatchQueue.main.async {
                            self.images[linkIndex].state = .error
                            self.images[linkIndex].size = #imageLiteral(resourceName: "Failed").size
                            if tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
                                tableView.reloadData()
                            }
                        }
                        return
                    }
                    if let img = image {
                        DispatchQueue.main.async {
                            ImageCache.default.store(img, forKey: url.absoluteString)
                            self.images[linkIndex].image = image
                            self.images[linkIndex].state = .downloaded
                            self.images[linkIndex].size = img.size
                            if tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
                                tableView.reloadData()
                            }
                        }
                    }
                })
            default:
                break
            }
        }
    }
}

// MARK: - Favorite

struct LikeImage {
    var image : UIImage
    static let like = LikeImage(image: UIImage(named: "Like")!)
    static let unlike = LikeImage(image: UIImage(named: "Unlike")!)
}

extension NetDiskDetailViewController: CAAnimationDelegate, CloudSaver {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            print(anim)
            if anim.isKind(of: CAAnimationGroup.self) {
                self.centerImageView.alpha = 0.0
                self.centerImageView.layer.removeAllAnimations()
                self.image.image = self.image === LikeImage.like.image ? LikeImage.unlike.image:LikeImage.like.image
                coverFade()
            }   else {
                self.cover.alpha = 0.0
                self.cover.layer.removeAllAnimations()
                self.view.window?.isUserInteractionEnabled = true
            }
            
        }
    }
}

extension NetDiskDetailViewController {
    func loadMemoView() {
        let v = self.view.window!
        
        image.image = LikeImage.unlike.image
        self.image.isHidden = true
        image.translatesAutoresizingMaskIntoConstraints = false
        
        loadFavoriteFlag()
        
        centerImageView.image = LikeImage.like.image
        centerImageView.translatesAutoresizingMaskIntoConstraints = false
        centerImageView.alpha = 0
        
        cover.translatesAutoresizingMaskIntoConstraints = false
        cover.backgroundColor = .black
        cover.alpha = 0.0
        
        v.addSubview(cover)
        v.addSubview(image)
        v.addSubview(centerImageView)
        
        var views : [String : Any] = ["img":image]
        v.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[img(40)]-|", options: [], metrics: nil, views: views))
        v.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[img(40)]-|", options: [], metrics: nil, views: views))
        
        views = ["img":centerImageView]
        v.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[img(40)]", options: [], metrics: nil, views: views))
        v.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[img(40)]", options: [], metrics: nil, views: views))
        v.addConstraint(NSLayoutConstraint(item: centerImageView, attribute: .centerX, relatedBy: .equal, toItem: v, attribute: .centerX, multiplier: 1, constant: 0))
        v.addConstraint(NSLayoutConstraint(item: centerImageView, attribute: .centerY, relatedBy: .equal, toItem: v, attribute: .centerY, multiplier: 1, constant: 0))
        
        views = ["img":cover]
        v.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[img]|", options: [], metrics: nil, views: views))
        v.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[img]|", options: [], metrics: nil, views: views))
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(favoriteAction(tap:)))
        tap.numberOfTapsRequired = 2
        tap.numberOfTouchesRequired = 1
        v.isUserInteractionEnabled = true
        v.addGestureRecognizer(tap)
    }
    
    func loadFavoriteFlag() {
        guard let nd = netdisk else {
            return
        }
        
        check(favoriteModal: nd, fetchBlock: { (modal) in
            DispatchQueue.main.async {            
                self.image.image = modal.favorite > 0 ? LikeImage.like.image:LikeImage.unlike.image
            }
        }, completion: {
            DispatchQueue.main.async {            
                self.image.isHidden = false
            }
        })
    }
    
    @objc func favoriteAction(tap: UITapGestureRecognizer) {
        let startPoint = tap.location(in: self.cover)
        let destinationImage : UIImage!
        let flag = (self.netdisk?.favorite ?? 0) > 0 ? 0:1
        self.netdisk?.favorite = flag
        if let nd = self.netdisk {
            flep(favoriteModal: nd)
        }
        if image.image! === LikeImage.like.image {
            print("unlike it!")
            destinationImage = LikeImage.unlike.image
            UIView.animate(withDuration: 0.35, animations: {
                self.image.alpha = 0.5
                self.image.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            }) { (finished) in
                if finished {
                    self.image.image = destinationImage
                    UIView.animate(withDuration: 0.20, animations: {
                        self.image.alpha = 1.0
                        self.image.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    }) { (finished) in
                        if finished {
                            
                        }
                    }
                }
            }
        }   else    {
            print("like it!")
            destinationImage = LikeImage.like.image
            self.centerImageView.alpha = 0.0
            
            self.view.window?.constraints.first(where: { $0.firstAttribute == .centerX && $0.secondAttribute == .centerX && ($0.firstItem as? UIView == self.centerImageView) })?.constant = startPoint.x - self.view.window!.frame.size.width / 2
            self.view.window?.constraints.first(where: { $0.firstAttribute == .centerY && $0.secondAttribute == .centerY && ($0.firstItem as? UIView == self.centerImageView) })?.constant = startPoint.y - self.view.window!.frame.size.height / 2
            
            self.view.window?.layoutIfNeeded()
            self.cover.alpha = 0.0
            self.centerImageView.alpha = 1.0
            self.centerImageView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            UIView.animate(withDuration: 0.35, animations: {
                self.centerImageView.alpha = 1.0
                self.centerImageView.layoutIfNeeded()
                self.cover.alpha = 0.2
                self.centerImageView.transform = CGAffineTransform(scaleX: 4.0, y: 4.0)
            }) { (finished) in
                if finished {
                    self.animationGroup(startCenterPoint: startPoint)
                }
            }
        }
    }
    
    func animationGroup(startCenterPoint: CGPoint) {
        let animation = CAKeyframeAnimation(keyPath: "position")
        let endCenterPoint = image.layer.position
        let controlPoint = CGPoint(x: endCenterPoint.x, y: startCenterPoint.y)
        
        print("start: \(startCenterPoint),end: \(endCenterPoint), control: \(controlPoint)")
        
        let path = CGMutablePath()
        path.move(to: startCenterPoint)
        path.addQuadCurve(to: endCenterPoint, control: controlPoint)
        
        animation.path = path
        animation.rotationMode = nil
        
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.toValue = 1.0
        
        let alpha = CABasicAnimation(keyPath: "transform.alpha")
        alpha.toValue = 0.0
        
        let group = CAAnimationGroup()
        group.animations = [animation, scale, alpha]
        group.duration = 0.40
        group.delegate = self
        group.isRemovedOnCompletion = false
        group.fillMode = CAMediaTimingFillMode.forwards
        group.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        
        self.centerImageView.layer.add(group, forKey: "popAnimate")
        self.view.window?.isUserInteractionEnabled = false
    }
    
    func coverFade() {
        let coverAlpha = CABasicAnimation(keyPath: "opacity")
        coverAlpha.fromValue = 0.2
        coverAlpha.toValue = 0.0
        coverAlpha.duration = 0.35
        coverAlpha.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        coverAlpha.fillMode = CAMediaTimingFillMode.forwards
        coverAlpha.delegate = self
        coverAlpha.isRemovedOnCompletion = false
        self.cover.layer.add(coverAlpha, forKey: "fadeCover")
    }
}

extension NetDiskDetailViewController : UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
