//
//  NetDiskDetailViewController.swift
//  S8Blocker
//
//  Created by virus1994 on 2017/8/17.
//  Copyright © 2017年 ascp. All rights reserved.
//

import UIKit
import WebKit

class NetDiskDetailViewController: UITableViewController {
    var netdisk : NetDiskModal?
    var detail : NetDiskDetalModal?
    let webview = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "详情"
        // Do any additional setup after loading the view.
        view.insertSubview(webview, belowSubview: tableView)
        webview.isHidden = true
        webview.frame = view.frame
        webview.navigationDelegate = self
        if let url = netdisk?.href, let netUrl = URL(string: url) {
            webview.load(URLRequest(url: netUrl))
        }
        tableView.register(UINib.init(nibName: "NetDiskTitleTableViewCell", bundle: nil), forCellReuseIdentifier: NetDiskTitleTableViewCellIdentitfier)
        tableView.register(UINib.init(nibName: "NetDiskImageTableViewCell", bundle: nil), forCellReuseIdentifier: NetDiskImageTableViewCellIdentitfier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension NetDiskDetailViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detail?.count ?? 0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: NetDiskTitleTableViewCellIdentitfier, for: indexPath) as! NetDiskTitleTableViewCell
            cell.title.text = detail?.title
            cell.title.textColor = .black
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: NetDiskTitleTableViewCellIdentitfier, for: indexPath) as! NetDiskTitleTableViewCell
            cell.title.text = detail?.pageurl
            cell.title.textColor = .lightGray
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: NetDiskTitleTableViewCellIdentitfier, for: indexPath) as! NetDiskTitleTableViewCell
            cell.title.text = detail?.passwod
            cell.title.textColor = .lightGray
            return cell
        default:
            guard let detailx = detail else {
                break
            }
            guard detailx.links.count > 0, indexPath.row < 3 + detailx.links.count  else {
                guard detailx.images.count > 0 else {
                    break
                }
                let cell = tableView.dequeueReusableCell(withIdentifier: NetDiskImageTableViewCellIdentitfier, for: indexPath) as! NetDiskImageTableViewCell
                cell.loadData(detailx.links[indexPath.row - 3 - detailx.links.count])
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: NetDiskTitleTableViewCellIdentitfier, for: indexPath) as! NetDiskTitleTableViewCell
            cell.title.text = detail?.links[indexPath.row - 3]
            cell.title.textColor = .lightGray
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - WKNavigationDelegate
extension NetDiskDetailViewController : WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let url = Bundle.main.path(forResource: "netDetail", ofType: "js") else {
            return
        }
        do {
            let js = try String(contentsOfFile: url)
            webview.evaluateJavaScript(js, completionHandler: { (result, err) in
                if let e = err {
                    print(e)
                    return
                }
                guard let array = result as? [String:Any] else {
                    return
                }
                self.detail = NetDiskDetalModal(data: array)
                print(self.detail ?? "bad")
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
        } catch {
            print(error.localizedDescription)
        }
    }
}

