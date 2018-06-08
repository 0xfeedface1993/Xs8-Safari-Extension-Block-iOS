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

enum DownloadState {
    case wait
    case downloading
    case downloaded
    case error
}

struct ImageItem {
    var url: URL?
    var state: DownloadState
    var size: CGSize
    var radio: CGFloat {
        return size.height / size.width
    }
    func realHeight(fitWidth: CGFloat) -> CGFloat {
        return radio * fitWidth
    }
}

class NetDiskDetailViewController: UITableViewController {
    var netdisk : NetDiskModal?
    var images = [ImageItem]()
    
    let image = UIImageView()
    let centerImageView = UIImageView()
    let cover = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "详情"
        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: "NetDiskTitleTableViewCell", bundle: nil), forCellReuseIdentifier: NetDiskTitleTableViewCellIdentitfier)
        tableView.register(UINib(nibName: "NetDiskImageTableViewCell", bundle: nil), forCellReuseIdentifier: NetDiskImageTableViewCellIdentitfier)
        tableView.separatorStyle = .none
        
        guard let imageLinks = netdisk?.images else {
            return
        }
        
        images = imageLinks.map({ ImageItem(url: URL(string: $0), state: .wait, size: #imageLiteral(resourceName: "NetDisk").size) })
        
        let saveItem = UIBarButtonItem(title: "收藏", style: .plain, target: self, action: #selector(saver))
        navigationItem.rightBarButtonItem = saveItem
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
                NSLayoutConstraint.activate([constraint])
            }
            
            let linkIndex = indexPath.row - 3
            let item = self.images[linkIndex]
            let url = item.url
            
            switch item.state {
            case .wait:
                self.images[linkIndex].state = .downloading
                cell.img.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "NetDisk"), options: nil, progressBlock: nil, completionHandler: { (img, err, cache, urlx) in
                    if let _ = err {
                        DispatchQueue.main.async {
                            self.images[linkIndex].state = .error
                            self.images[linkIndex].size = #imageLiteral(resourceName: "Failed").size
                            layoutMaker(radio: self.images[linkIndex].radio)
                            tableView.reloadData()
                        }
                        return
                    }
                    
                    if let img = img {
                        DispatchQueue.main.async {
                            self.images[linkIndex].state = .downloaded
                            self.images[linkIndex].size = img.size
                            layoutMaker(radio: self.images[linkIndex].radio)
                            tableView.reloadData()
                        }
                    }
                })
            case .downloading:
                cell.img.image = #imageLiteral(resourceName: "NetDisk")
            case .downloaded:
                cell.img.kf.setImage(with: url)
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
//        if let cell = tableView.cellForRow(at: indexPath) as? NetDiskImageTableViewCell, let img = cell.img.image {
//            return self.view.frame.size.width * (img.size.height / img.size.width)
//        }
//        return 300
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Favorite
extension NetDiskDetailViewController: CloudSaver {
    @objc func saver() {
//        save(netDisk: netdisk!) { (rec, err) in
//            if let e = err {
//                DispatchQueue.main.async {
//                    let alert = UIAlertController(title: "保存失败", message: e.localizedDescription, preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//                    self.present(alert, animated: true, completion: nil)
//                }
//                return
//            }
//
//            if let record = rec {
//                print("Save to cloud Ok: \(record.recordID)")
//                DispatchQueue.main.async {
//                    let alert = UIAlertController(title: "保存成功", message: "请在收藏夹里面查看", preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//                    self.present(alert, animated: true, completion: nil)
//                }
//            }
//        }
    }
}

struct LikeImage {
    var image : UIImage
    static let like = LikeImage(image: #imageLiteral(resourceName: "Like"))
    static let unlike = LikeImage(image: #imageLiteral(resourceName: "Unlike"))
}

extension NetDiskDetailViewController: CAAnimationDelegate {
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
            self.cover.alpha = 0.0
            self.centerImageView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            UIView.animate(withDuration: 0.35, animations: {
                self.centerImageView.alpha = 1.0
                self.cover.alpha = 0.2
                self.centerImageView.transform = CGAffineTransform(scaleX: 3.0, y: 3.0)
            }) { (finished) in
                if finished {
                    self.animationGroup()
                }
            }
        }
    }
    
    func animationGroup() {
        let animation = CAKeyframeAnimation(keyPath: "position")
        let startCenterPoint = centerImageView.layer.position
        let endCenterPoint = image.layer.position
        let controlPoint = CGPoint(x: endCenterPoint.x, y: startCenterPoint.y)
        
        print("start: \(startCenterPoint),end: \(endCenterPoint), control: \(controlPoint)")
        
        let path = CGMutablePath()
        path.move(to: startCenterPoint)
        path.addQuadCurve(to: endCenterPoint, control: controlPoint)
        
        animation.path = path
        animation.rotationMode = kCAAnimationLinear
        
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.toValue = 1.0
        
        let alpha = CABasicAnimation(keyPath: "transform.alpha")
        alpha.toValue = 0.0
        
        let group = CAAnimationGroup()
        
        group.animations = [animation, scale, alpha]
        group.duration = 0.35
        group.delegate = self
        group.isRemovedOnCompletion = false
        group.fillMode = kCAFillModeForwards
        group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        self.centerImageView.layer.add(group, forKey: "popAnimate")
        self.view.window?.isUserInteractionEnabled = false
    }
    
    func coverFade() {
        let coverAlpha = CABasicAnimation(keyPath: "opacity")
        coverAlpha.fromValue = 0.2
        coverAlpha.toValue = 0.0
        coverAlpha.duration = 0.35
        coverAlpha.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        coverAlpha.fillMode = kCAFillModeForwards
        coverAlpha.delegate = self
        coverAlpha.isRemovedOnCompletion = false
        self.cover.layer.add(coverAlpha, forKey: "fadeCover")
    }
}
