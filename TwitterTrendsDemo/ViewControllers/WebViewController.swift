//
//  WebViewController.swift
//  TwitterTrendsDemo
//
//  Created by Bader BEN ZRIBIA on 23.01.18.
//  Copyright © 2018 Bader Ben Zribia. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    @IBOutlet weak var webView : UIWebView!
    var urlString : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let urlString = urlString {
            let url = URL(string: urlString)
            let request = URLRequest(url: url!)
            webView.loadRequest(request)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
