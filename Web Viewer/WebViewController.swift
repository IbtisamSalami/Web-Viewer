//
//  WebViewController.swift
//  Web Viewer
//
//  Created by Ibtisam on 15/10/2022.
//

import UIKit
import WebKit

class WebViewController: UIViewController  , WKNavigationDelegate {

    @IBOutlet weak var openInSafariBtn: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var backBtn: UIBarButtonItem!
    @IBOutlet weak var forwordBtn: UIBarButtonItem!
    @IBOutlet weak var goUrlBtn: UIBarButtonItem!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var webView: WKWebView!
    
    private var estimatedProgressObserver: NSKeyValueObservation?
    var refreshControl: UIRefreshControl = UIRefreshControl()
    var urlString = "https://apple.com/"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        webView.navigationDelegate = self
        self.refreshControl = creatRefresherWith(target: self, action: #selector(self.reload), toControl: self.webView.scrollView)
        self.webView.scrollView.alwaysBounceVertical = true
        self.webView.scrollView.decelerationRate = UIScrollView.DecelerationRate.normal
        webView.allowsBackForwardNavigationGestures = true
        self.loadWebView()
        setupEstimatedProgressObserver()
        
    }
    @objc func reload()
    {
        webView.reload()
    }
    
    func loadWebView()
    {
        if let url = URL(string: urlString)
        {
            self.title = "Loading .."
            webView.load(URLRequest(url: url))
        }
        else
        {
            makeToast(message: "Sorry, there is something wrong!")
        }
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if progressView.isHidden {
            // Make sure our animation is visible.
            progressView.isHidden = false
        }

        UIView.animate(withDuration: 0.33,
                       animations: {
                           self.progressView.alpha = 1.0
        })
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.title = self.webView.title
        
        self.refreshControl.endRefreshing()
        UIView.animate(withDuration: 0.33,
                       animations: {
                           self.progressView.alpha = 0.0
                       },
                       completion: { isFinished in
                           // Update `isHidden` flag accordingly:
                           //  - set to `true` in case animation was completly finished.
                           //  - set to `false` in case animation was interrupted, e.g. due to starting of another animation.
                           self.progressView.isHidden = isFinished
        })
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.refreshControl.endRefreshing()
        self.title = "Fail to load"
        makeToast(message: "Sorry, there is something wrong!")
        UIView.animate(withDuration: 0.33,
                       animations: {
                           self.progressView.alpha = 0.0
                       },
                       completion: { isFinished in
                           // Update `isHidden` flag accordingly:
                           //  - set to `true` in case animation was completly finished.
                           //  - set to `false` in case animation was interrupted, e.g. due to starting of another animation.
                           self.progressView.isHidden = isFinished
        })
    }


    private func setupEstimatedProgressObserver() {
        estimatedProgressObserver = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
            self?.progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    @IBAction func backForwordBtnPrsd(_ sender: UIBarButtonItem) {
        switch sender.tag {
        case 0:
            if self.webView.canGoBack
            {
                self.webView.goBack()
            }
            else
            {
                makeToast(message: "You are at first page")
            }
        case 1:
            if self.webView.canGoForward
            {
                self.webView.goForward()
            }
            else
            {
                makeToast(message: "You are at last page")
            }
            
        default:
            break
        }
    }
    
    @IBAction func openInSafariBtnPtnPrsd(_ sender: Any) {
        if let url = URL(string: urlString)
        {
            openURL(url: url)
        }
        else
        {
            makeToast(message: "Sorry, there is something wrong!")
        }
    }
}


func creatRefresherWith(target: UIViewController, action: Selector, toControl: UIScrollView) -> UIRefreshControl
{
    var refreshControl = UIRefreshControl()
    let attrString = NSMutableAttributedString(string: "اسحب للتحديث")
    attrString.addAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16) , NSAttributedString.Key.foregroundColor : UIColor.darkGray], range: NSMakeRange(0, attrString.length))
    refreshControl = UIRefreshControl()
    refreshControl.attributedTitle = attrString
    refreshControl.addTarget(target, action: action, for: UIControl.Event.valueChanged)
    if #available(iOS 10.0, *) {
        toControl.refreshControl = refreshControl
    } else {
        toControl.addSubview(refreshControl)
    }
    return refreshControl
}
func openURL(url: URL)
{
    if #available(iOS 10.0, *) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    } else {
        UIApplication.shared.openURL(url)
    }
}
func makeToast(message: String)
{
    var style = ToastStyle()
    style.cornerRadius = 5
    style.messageFont = UIFont.systemFont(ofSize: 16)
    style.messageAlignment = .center
    style.titleFont = UIFont.systemFont(ofSize: 14)
    style.titleAlignment = .center
    
    if UIWindow.visibleWindow()?.rootViewController?.navigationController != nil
    {
        UIWindow.visibleWindow()?.rootViewController?.navigationController?.view.makeToast(message, duration: 3.0, position: .bottom, style: style)
    }
    else
    {
        rootViewController().view.makeToast(message, duration: 3.0, position: .bottom, style: style)
    }
}
extension UIWindow {
    static func visibleWindow() -> UIWindow? {
        var currentWindow:UIWindow?
        if #available(iOS 13.0, *) {
            currentWindow =  UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .compactMap({$0 as? UIWindowScene})
                .first?.windows
                .filter({$0.isKeyWindow}).first
        } else {
            currentWindow = UIApplication.shared.keyWindow
        }
        if currentWindow == nil {
            let frontToBackWindows = Array(UIApplication.shared.windows.reversed())
            
            for window in frontToBackWindows {
                if window.windowLevel == UIWindow.Level.normal {
                    currentWindow = window
                    break
                }
            }
        }
        
        return currentWindow
    }
    
}
func rootViewController() -> UIViewController
{
    var hostVC = UIWindow.visibleWindow()?.rootViewController
    
    while let next = hostVC?.presentedViewController {
        hostVC = next
    }
    return hostVC!
}
