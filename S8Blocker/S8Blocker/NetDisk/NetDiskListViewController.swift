//
//  NetDiskListViewController.swift
//  Sex8BlockExtension-iOS
//
//  Created by virus1993 on 2017/8/17.
//  Copyright © 2017年 ascp. All rights reserved.
//

import UIKit
import WebKit

enum SitePlace {
    case login
    case main
    case netdisk
    case page
}

class NetDiskListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    fileprivate var data = [NetDiskModal]()
    let webview = WKWebView()
    var isRefreshing = false
    var place : SitePlace = .netdisk
    var page = 1
    var netUrl : URL {
        get {
            let str = "http://xbluntan.net/forum-103-\(page).html"//xbluntan.net
            page += 1
            return URL(string: str)!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "网盘下载"
        // Do any additional setup after loading the view.
        tableviewLoad()
        view.insertSubview(webview, at: 0)
        webview.frame = view.frame
        webview.navigationDelegate = self
        webview.load(URLRequest(url: netUrl))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 &&  isRefreshing == false {
            print("load next page tableview!")
            place = .netdisk
            isRefreshing = true
            webview.load(URLRequest(url: netUrl))
        }
    }
}


// MARK: - UITableViewDataSource, UITableViewDelegate
extension NetDiskListViewController : UITableViewDataSource, UITableViewDelegate {
    func tableviewLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: "NetDiskTableViewCell", bundle: nil), forCellReuseIdentifier: NetDiskTableViewCellIdentifier)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NetDiskTableViewCellIdentifier, for: indexPath) as! NetDiskTableViewCell
        cell.loadData(data[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Sex8", bundle: nil)
        let v = storyboard.instantiateViewController(withIdentifier: "NetDiskDetail") as! NetDiskDetailViewController
        v.netdisk = data[indexPath.row]
        navigationController?.pushViewController(v, animated: true)
    }
}

// MARK: - WKNavigationDelegate
extension NetDiskListViewController : WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        switch place {
        case .login:
            place = .main
            print("login now!")
            webview.evaluateJavaScript("document.getElementById('ls_username').value = '318715498';document.getElementById('ls_password').value = 'xts@19931022';document.getElementsByClassName('mem_login')[0].click();", completionHandler: { (result, err) in
                if let e = err {
                    print(e.localizedDescription)
                }
            })
            break
        case .main:
            place = .netdisk
            print("main page now!")
            webview.evaluateJavaScript("window.location.href = 'http://xbluntan.net/forum-103-1.html';", completionHandler: { (result, err) in
                if let e = err {
                    print(e.localizedDescription)
                }
            })
            break
        case .netdisk:
            place = .page
            print("netdisk list now!")
            webview.evaluateJavaScript("function readList() {var table = document.getElementById('threadlisttableid');var chillds = table.children;var list = [];for (var i = chillds.length - 1; i >= 0; i--) {var item = chillds[i];var id = item.id;if (id.indexOf('normalthread') >= 0) {var titlex = item.getElementsByClassName('s xst');var title = '';var hf = '';if (titlex != null && titlex.length > 0) {title = titlex[0].innerText;hf = titlex[0].href;}var images = item.getElementsByClassName('thread-img');var imgSrcs = [];if (images != null && images.length > 0) {for (var j = images.length - 1; j >= 0; j--) {var img = images[j];var src = img.src;imgSrcs.push(src);};}list.push({'title':title, 'images':imgSrcs, 'href':hf});}};return list;}readList();", completionHandler: { (result, err) in
                if let e = err {
                    print(e)
                    return
                }
//                print(result as? [[String:Any]] ?? "抓取数据失败！")
                if let array = result as? [[String:Any]] {
                    self.data += array.map({
                        return NetDiskModal(data: $0)
                    })
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }   else    {
                    DispatchQueue.main.async {
                        self.page -= 1
                    }
                }
                self.isRefreshing = false
            })
            break
        default:
            break
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
}
