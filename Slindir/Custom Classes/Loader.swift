//
//  Loader.swift
//  Slindir
//
//  Created by Gurinder Batth on 17/10/17.
//  Copyright © 2017 Batth. All rights reserved.
//

//UIColor(red: 0, green: 166/255, blue: 175/255, alpha: 1)

import UIKit
import NVActivityIndicatorView

class Loader: NSObject {
    
//MARK:-  Init Methods
    static let sharedLoader = Loader()
    
    private override init(){
        super.init()
        if let rootView = UIApplication.shared.keyWindow {
            rootView.addSubview(blackView)
            blackView.addSubview(loaderView)
            settingTheConstraints(rootView)
        }
    }
    
//MARK:-  Private Properties
    private let loaderView: NVActivityIndicatorView = {
        let view = NVActivityIndicatorView(frame: .zero, type: .lineScale, color: .white, padding: 0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate let blackView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        return view
    }()
    
//MARK:-  Private Methods
    private func settingTheConstraints(_ rootView: UIWindow){
        rootView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[v0]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: [:], views: ["v0":blackView]))
        rootView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[v0]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: [:], views: ["v0":blackView]))
        loaderView.centerXAnchor.constraint(equalTo: blackView.centerXAnchor).isActive = true
        loaderView.centerYAnchor.constraint(equalTo: blackView.centerYAnchor).isActive = true
        loaderView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        loaderView.widthAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
//MARK:-  Start And Stop Loader Functions
    
    /// This Methods is used for show Custom Loader. It is Class methods so you can call this method  directly with Class name. This method is called on main thread you donot need to call this method on Main Thread.
    ///
    /// - Parameter animated: This paramter is for animation. To enable animation return true else false, Default value is false
    class func startLoader(_ animated: Bool){
        DispatchQueue.main.async {
            var duration = 0.3
            if animated{
                duration = 0.3
            }else{
                duration = 0
            }
            if let rootView = UIApplication.shared.keyWindow {
                Loader.sharedLoader.blackView.alpha = 0
                rootView.bringSubview(toFront: Loader.sharedLoader.loaderView)
                UIView.animate(withDuration: duration, animations: {
                    Loader.sharedLoader.blackView.alpha = 1
                }, completion: { (completed) in
                    Loader.sharedLoader.loaderView.startAnimating()
                })
            }
        }
    }
    
    
    func statLoader(_ animated: Bool){
        DispatchQueue.main.async {
            var duration = 0.3
            if animated{
                duration = 0.3
            }else{
                duration = 0
            }
            if let rootView = UIApplication.shared.keyWindow {
                Loader.sharedLoader.blackView.alpha = 0
                rootView.bringSubview(toFront: Loader.sharedLoader.loaderView)
                UIView.animate(withDuration: duration, animations: {
                    Loader.sharedLoader.blackView.alpha = 1
                }, completion: { (completed) in
                    Loader.sharedLoader.loaderView.startAnimating()
                })
            }
        }
    }
    
    ///  This Methods is used for stop Custom Loader. It is Class methods so you can call this method  directly with Class name. This method is called on main thread you donot need to call this method on Main Thread.
    class func stopLoader() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: {
                Loader.sharedLoader.blackView.alpha = 0
            }, completion: { (completed) in
                Loader.sharedLoader.loaderView.stopAnimating()
            })
        }
    }
}
