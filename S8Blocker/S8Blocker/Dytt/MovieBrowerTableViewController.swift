//
//  MovieBrowerTableViewController.swift
//  S8Blocker
//
//  Created by virus1993 on 2018/1/17.
//  Copyright © 2018年 ascp. All rights reserved.
//

import UIKit
import Kingfisher

class MovieBrowerTableViewController: UITableViewController {
    let ImageCellIdentifier = "com.ascp.movie.image"
    var content : ContentInfo?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        title = content?.title
        tableView.register(UINib(nibName: "MovieBrowerTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: ImageCellIdentifier)
        
        let rightBarItem = UIBarButtonItem(title: "下载地址", style: .plain, target: self, action: #selector(showDownloadsOption))
        navigationItem.rightBarButtonItem = rightBarItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return content?.imageLink.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImageCellIdentifier, for: indexPath) as! MovieBrowerTableViewCell

        // Configure the cell...
        
        if let url = URL(string: content?.imageLink[indexPath.row] ?? "") {
            cell.movieImage?.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "Movie"), options: nil, progressBlock: nil, completionHandler: {
                (_, _, _, _) in
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            })
        }
 
        return cell
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if let cell = tableView.dequeueReusableCell(withIdentifier: ImageCellIdentifier, for: indexPath) as? MovieBrowerTableViewCell, let img = cell.movieImage.image {
//             return self.view.frame.size.width * (img.size.height / img.size.width)
//        }
//        return 100
//    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    @objc func showDownloadsOption() {
        let alert = UIAlertController(title: "下载地址", message: "请选择你的下载地址, 点击后会复制", preferredStyle: .actionSheet)
        for link in content?.downloafLink ?? [] {
            let action = UIAlertAction(title: link, style: .default, handler: { (act) in
                alert.dismiss(animated: true, completion: nil)
                let sharePasteboard = UIPasteboard.general
                sharePasteboard.string = link
            })
            alert.addAction(action)
        }
        let cancel = UIAlertAction(title: "取消", style: .cancel, handler: { (_) in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(cancel)
        
        alert.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(alert, animated: true, completion: nil)
    }
}

