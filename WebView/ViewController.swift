//
//  ViewController.swift
//  WebView
//
//  Created by DebianArch on 6/30/21.
//

import UIKit
import WebKit

extension UIColor {
    
    public class var main: UIColor {
        return UIColor(named: "main") ?? .purple
    }
    
    public class var statusColor: UIColor {
        return UIColor(named: "statusBar") ?? .purple
    }
    
}

extension UIView {

  var safeTopAnchor: NSLayoutYAxisAnchor {
    if #available(iOS 11.0, *) {
      return safeAreaLayoutGuide.topAnchor
    }
    return topAnchor
  }

  var safeLeftAnchor: NSLayoutXAxisAnchor {
    if #available(iOS 11.0, *){
      return safeAreaLayoutGuide.leftAnchor
    }
    return leftAnchor
  }

  var safeRightAnchor: NSLayoutXAxisAnchor {
    if #available(iOS 11.0, *){
      return safeAreaLayoutGuide.rightAnchor
    }
    return rightAnchor
  }

  var safeBottomAnchor: NSLayoutYAxisAnchor {
    if #available(iOS 11.0, *) {
      return safeAreaLayoutGuide.bottomAnchor
    }
    return bottomAnchor
  }
}

class ViewController: UIViewController, WKUIDelegate {

    /* Allowing the class as a whole to access the buttonView.... */
    var buttonView: UIView = .init()
    var webView: WKWebView = .init()
    var previousPos: Double = 0.0
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        view.insetsLayoutMarginsFromSafeArea = true
        view.backgroundColor = UIColor.statusColor
        
        buttonView.isHidden = true

        webView = WKWebView(frame: view.frame)
            
        webView.uiDelegate = self
        self.view.addSubview(webView)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.safeTopAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 100)
        ])
        
        // Load web content to webview...
        let url = URL(string: "https://appinstallerios.com")
        let urlRequest: URLRequest = URLRequest(url: url!)
        
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        webView.isOpaque = false
        webView.backgroundColor = UIColor.main
        
        webView.load(urlRequest)
     
        /* Add a button to go directly to home.... */
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        webView.addSubview(buttonView)
        
        webView.bringSubviewToFront(buttonView)
        
        /* Adding constraints... */
        NSLayoutConstraint.activate([
            buttonView.widthAnchor.constraint(equalToConstant: 50),
            buttonView.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        let xContraints = NSLayoutConstraint(item: buttonView, attribute: NSLayoutConstraint.Attribute.bottomMargin, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.bottomMargin, multiplier: 1, constant: -20)
            
            let yContraints = NSLayoutConstraint(item: buttonView, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: -20)
        NSLayoutConstraint.activate([xContraints,yContraints])
        
        /* Add Blur effect then add an icon ontop.... */
        let blurView = UIVisualEffectView()
        let blurEffect = UIBlurEffect(style: .regular)
        blurView.effect = blurEffect
        
        buttonView.addSubview(blurView)
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        if #available(iOS 13.0, *) {
            let icon = UIImageView(image: UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .bold, scale: .medium))?.withRenderingMode(.alwaysTemplate))
            
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.tintColor = UIColor.main
            
            buttonView.addSubview(icon)
            
            NSLayoutConstraint.activate([
                icon.centerXAnchor.constraint(equalTo: buttonView.centerXAnchor),
                icon.centerYAnchor.constraint(equalTo: buttonView.centerYAnchor),
            ])
            
        } else {
            // Fallback on earlier versions
        }
        
        
        buttonView.layer.cornerRadius = 20
        buttonView.layer.masksToBounds = true
        
        /* Handle touch of button... */
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleBackTap(sender:)))
        buttonView.addGestureRecognizer(tap)

    }
    
    @objc func handleBackTap(sender: UITapGestureRecognizer) {
        webView.goBack()
        }
}

/* Extension to make things less cluttered lol */
extension ViewController: UIWebViewDelegate, WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) { // triggers when loading is complete
        
        if(webView.canGoBack) {
//            print("[Alert] Button should show!")
        }
        
        if(webView.canGoBack) {
            self.buttonView.isHidden = false
        }
        
        UIView.animate(withDuration: 0.3, delay: 0.1, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.2, options: .curveEaseOut) {
            
            if(!webView.canGoBack) {
                
                self.previousPos = self.buttonView.frame.origin.x
                self.buttonView.frame = CGRect(x: self.view.frame.size.width, y: self.buttonView.frame.origin.y, width: self.buttonView.frame.size.width, height: self.buttonView.frame.size.height)
            } else {
                self.buttonView.frame = CGRect(x: self.previousPos, y: self.buttonView.frame.origin.y, width: self.buttonView.frame.size.width, height: self.buttonView.frame.size.height)
            }
            
        } completion: { didSucceed in
            self.buttonView.isHidden = !webView.canGoBack
        }

            
        }
    
    /* Extension to install apps and fix other hyperlink related issues... */
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.url, let scheme = url.scheme, scheme.contains("http") else {
            
            /* Assuming non-https hyperlinks are schemes meant to be open in 3rd party apps / installed onto the device... */
            decisionHandler(.cancel)
            
            if(navigationAction.request.url == nil) {
                return
            }
            
            UIApplication.shared.open(navigationAction.request.url!)
            print("[Alert] Hyperlink was open externally form WebView....")
            
               return
           }
        
        if(url.lastPathComponent.contains("mobileconfig")) {
            /* Mobileconfig bruh */
            print("mobileconfig")
            UIApplication.shared.open(url)
        }
        
        // This is a HTTP link
        decisionHandler(.allow)
        
   }
    
}
