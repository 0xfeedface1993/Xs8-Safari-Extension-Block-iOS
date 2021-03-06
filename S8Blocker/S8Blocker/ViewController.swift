//
//  ViewController.swift
//  S8Blocker
//
//  Created by virus1994 on 2017/8/17.
//  Copyright © 2017年 ascp. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    lazy var menus : [ListCategrory] = {
        guard let fileURL = Bundle.main.url(forResource: "categrory", withExtension: "plist") else {
            return [ListCategrory]()
        }
        
        do {
            let file = try Data(contentsOf: fileURL)
            let decoder = PropertyListDecoder()
            let plist = try decoder.decode([ListCategrory].self, from: file)
            return plist
        }   catch {
            print(error)
            return [ListCategrory]()
        }
    }()
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "杏吧有你"
        
        let download = UIBarButtonItem(title: "下载记录", style: .done, target: self, action: #selector(downloader))
        navigationItem.rightBarButtonItem = download
    }
    
    @objc func downloader() {
        // more work
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        guard let item = sender as? ListCategrory else { return }
        
        if let destination = segue.destination as? NetDiskListViewController {
            var site = Site.netdisk
            site.categrory = item
            destination.site = site
        }
    }
}


// MARK: - Collection View Delegate
extension ViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menus.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "com.ascp.main.cell", for: indexPath) as! CategroryCollectionViewCell
        let item = menus[indexPath.row]
//        cell.backgroundColor = .red
        cell.load(image:UIImage(named: item.image), title: item.name)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = menus[indexPath.row]
        performSegue(withIdentifier: item.segue, sender: item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.size.width / 2, height: 277)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension ViewController {
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return identifier != ""
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        coordinator.animate(alongsideTransition: { (context) in
////            let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
////            layout.itemSize = CGSize(width: size.width / 2, height: 227)
////            self.collectionView.collectionViewLayout = layout
//            
////            self.collectionView.visibleCells.forEach({ cell in
////                cell.frame.size = CGSize(width: size.width / 2, height: 227)
//            })
//        }) { (context) in
////            let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
////            layout.itemSize = CGSize(width: size.width / 2, height: 227)
////            self.collectionView.collectionViewLayout = layout
////            self.collectionView.reloadData()
//        }
        super.viewWillTransition(to: size, with: coordinator)
        self.collectionView.reloadData()
        print("opps!")
    }
}
