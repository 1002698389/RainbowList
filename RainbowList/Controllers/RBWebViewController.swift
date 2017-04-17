//
//  RBWebViewController.swift
//  RainbowList
//
//  Created by admin on 2017/3/31.
//  Copyright © 2017年 aLazyCoder. All rights reserved.
//

import UIKit
import WebKit

class RBWebViewController: UIViewController {

    var url: URL
    
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var progressView: UIProgressView = {
        var progress = UIProgressView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 1))
        progress.progress = 0
        progress.tintColor = UIColor.green
        progress.trackTintColor = UIColor.clear
        return progress
    }()
    
    lazy var webView: WKWebView = {
        var webView = WKWebView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        webView.navigationDelegate = self
        let request = URLRequest(url: self.url)
        webView.load(request)
        return webView
    }()
    
    lazy var gobackItem: UIBarButtonItem = {
        var gobackItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.rewind, target: self, action: #selector(goBack))
        gobackItem.isEnabled = false
        return gobackItem
    }()
    
    lazy var goForwardItem: UIBarButtonItem = {
        var goForwardItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fastForward, target: self, action: #selector(goForward))
        goForwardItem.isEnabled = false
        return goForwardItem
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItems = [goForwardItem,gobackItem]
        
        view.addSubview(webView)
        view.addSubview(progressView)
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
    }
    deinit {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "estimatedProgress") {
            progressView.isHidden = webView.estimatedProgress == 1
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
    }
    
    func goBack() {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    func goForward() {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
    func refreshNavItemState() {
        gobackItem.isEnabled = webView.canGoBack
        goForwardItem.isEnabled = webView.canGoForward
    }
}

extension RBWebViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressView.setProgress(0.0, animated: false)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        refreshNavItemState()
        progressView.setProgress(0.0, animated: false)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        refreshNavItemState()
        progressView.setProgress(0.0, animated: false)
    }
}
