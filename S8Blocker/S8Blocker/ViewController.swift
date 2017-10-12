//
//  ViewController.swift
//  S8Blocker
//
//  Created by virus1994 on 2017/8/17.
//  Copyright © 2017年 ascp. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "杏吧有你"
        let web = Webservice.share
        let caller = WebserviceCaller<LoginResopnse>(baseURL: .aliyun, way: .post, method: "login", paras: ["account":"admin", "password":"71B4655FA0CB2753BF533D478CBAF5F20A91BEE127132AFD45668FA9B38383F4"], rawData: nil) { (data, err, serverErr) in
            if let e = err {
                print(e)
                return
            }
            
            if let e = serverErr {
                print(e)
                return
            }
            
            if let user = data {
                print("id: \(user.id), name: \(user.name)")
            }
        }
        do {
            try web.read(caller: caller)
        } catch {
            print("login failed: \(error)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func jump(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Sex8", bundle: Bundle.main)
        let v = storyboard.instantiateViewController(withIdentifier: "NetDiskList")
        navigationController?.pushViewController(v, animated: true)
    }
    
    @IBAction func jumpMovieList(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Dytt", bundle: Bundle.main)
        let v = storyboard.instantiateViewController(withIdentifier: "dytt")
        navigationController?.pushViewController(v, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
