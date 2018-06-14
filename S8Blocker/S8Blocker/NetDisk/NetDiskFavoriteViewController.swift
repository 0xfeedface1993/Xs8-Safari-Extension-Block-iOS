//
//  NetDiskFavoriteViewController.swift
//  S8Blocker
//
//  Created by virus1994 on 2018/6/10.
//  Copyright © 2018年 ascp. All rights reserved.
//

import UIKit

class NetDiskFavoriteViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        updatePreferredContentSize(withTraitCollection: traitCollection)

        // Do any additional setup after loading the view.
        let collect = UIBarButtonItem(image: #imageLiteral(resourceName: "NetDisk"), style: .done, target: self, action: #selector(switchDataSource(sender:)))
        navigationItem.rightBarButtonItem = collect
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func updatePreferredContentSize(withTraitCollection traitCollection: UITraitCollection) {
        preferredContentSize = view.bounds.size
    }

    @objc func switchDataSource(sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        updatePreferredContentSize(withTraitCollection: traitCollection)
    }
}
