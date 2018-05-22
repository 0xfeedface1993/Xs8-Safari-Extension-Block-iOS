//
//  NewMovieTableViewController.swift
//  S8Blocker
//
//  Created by virus1993 on 2017/10/9.
//  Copyright © 2017年 ascp. All rights reserved.
//

import UIKit

class NewMovieTableViewController: UITableViewController {
    static var movieContents = [ContentInfo]()
    static var mainMovieContents = [ContentInfo]()
    
    var movies : [ContentInfo] {
        get {
            if searchController.isActive {
                return NewMovieTableViewController.movieContents
            }
            return NewMovieTableViewController.mainMovieContents
        }
        set {
            if searchController.isActive {
                NewMovieTableViewController.movieContents = newValue
            }
            NewMovieTableViewController.mainMovieContents = newValue
        }
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    private var snapCount = 10
    
    private var shapshotIndexPath : IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "电影名称、导演、演员"
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        
//        view.addSubview(searchController.searchBar)
//        let views = ["bar":searchController.searchBar] as [String:Any]
//        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[bar]|", options: [], metrics: nil, views: views))
//        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[bar]", options: [], metrics: nil, views: views))
//        
        tableView.estimatedRowHeight = 160
        tableView.tableHeaderView = searchController.searchBar
        tableView.register(UINib(nibName: "NewMovieTableViewCell", bundle: nil), forCellReuseIdentifier: "com.ascp.moviecell")

        let bot = FetchBot.shareBot
        bot.startPage = 1
        bot.pageOffset = 1
        bot.delegate = self
        DispatchQueue.global().async {
            bot.start(withSite: Site.dytt)
        }
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
        return movies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "com.ascp.moviecell", for: indexPath) as! NewMovieTableViewCell

        // Configure the cell...
        let movie = movies[indexPath.row]
        cell.loadData(image: movie.imageLink.first ?? "", title: movie.title, dsc: movie.note)
        cell.contentView.layoutIfNeeded()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = movies[indexPath.row]
        let detail = MovieBrowerTableViewController()
        detail.content = movie
        self.navigationController?.pushViewController(detail, animated: true)
    }

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
    
    //MARK: - UISearchControllerDelegate
    
    func appendContent(_ element: ContentInfo) {
        if NewMovieTableViewController.mainMovieContents.filter({ $0 == element }).count <= 0 {
            NewMovieTableViewController.mainMovieContents.append(element)
        }
    }
}

extension NewMovieTableViewController : FetchBotDelegate {
    func bot(didStartBot bot: FetchBot) {
        
    }
    
    func bot(_ bot: FetchBot, didLoardContent content: ContentInfo, atIndexPath index: Int) {
        snapCount -= 1
        appendContent(content)
        if snapCount <= 0 {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            snapCount = 10
        }
    }
    
    func bot(_ bot: FetchBot, didFinishedContents contents: [ContentInfo], failedLink: [FetchURL]) {
        snapCount = 10
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension NewMovieTableViewController : UISearchControllerDelegate, UISearchResultsUpdating {
    func willPresentSearchController(_ searchController: UISearchController) {
        shapshotIndexPath = tableView.indexPathsForVisibleRows?.first
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        tableView.reloadData()
        if let paths = shapshotIndexPath {
            tableView.scrollToRow(at: paths, at: .top, animated: true)
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        print("update search!")
        NewMovieTableViewController.movieContents = NewMovieTableViewController.mainMovieContents.filter({
            guard let keyword = searchController.searchBar.text else {
                return false
            }
            return $0.contain(keyword: keyword)
        })
        tableView.reloadData()
    }
}
