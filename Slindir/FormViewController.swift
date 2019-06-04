//
//  FormViewController.swift
//  Slindir
//
//  Created by admin on 08/05/2019.
//  Copyright © 2019 Batth. All rights reserved.
//

import UIKit
import KeyboardMan

class FormViewController: UIViewController, UITextFieldDelegate {
    var isActiveForm: Bool = false
    var isChangeView: Bool = false
    var heightContentDefault: CGFloat = 0
    
    var tapFormScrollView: UITapGestureRecognizer?
    var viewTap: UIView?
    
    let keyboardMan = KeyboardMan()
    var keyboardHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //default view tap
        self.viewTap = self.view
        
        // init keyboard
        self.keyboardMan.animateWhenKeyboardAppear = { [weak self] appearPostIndex, keyboardHeight, keyboardHeightIncrement in
            self?.keyboardHeight = keyboardHeight
            
            if (self?.isActiveForm)! {
                print("appear \(appearPostIndex), \(keyboardHeight), \(keyboardHeightIncrement)\n")
                self?.didOpenKeyboard(keyboardHeight: keyboardHeight)
            }
        }
        
        keyboardMan.animateWhenKeyboardDisappear = { [weak self] keyboardHeight in
            if (self?.isActiveForm)! {
                self?.isChangeView = false
                print("disappear \(keyboardHeight)\n")
                self?.didHideKeyboard(keyboardHeight: keyboardHeight)
            }
            
            self?.keyboardMan.postKeyboardInfo = { keyboardMan, keyboardInfo in
                switch keyboardInfo.action {
                case .show:
                    print("show \(keyboardMan.appearPostIndex), \(keyboardInfo.height), \(keyboardInfo.heightIncrement)\n")
                case .hide:
                    print("hide \(keyboardInfo.height)\n")
                }
            }
        }
    }
    
    func didOpenKeyboard(keyboardHeight: CGFloat) {
        self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.heightContentDefault - keyboardHeight)
        
        if !self.isChangeView {
            self.isChangeView = true
            self.setTapForHideKeyboard()
        }
    }
    
    func didHideKeyboard(keyboardHeight: CGFloat) {
        self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.heightContentDefault)
        self.removeTapForHideKeyboard()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.isActiveForm = true
        self.heightContentDefault = self.view.frame.height
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.isActiveForm = false
    }
    
    // MARK: - Users function
    
    
    
    // MARK: - Keyboard
    
    func hideKeyboard() {
        self.isChangeView = false
        self.view.endEditing(true)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        self.hideKeyboard()
    }
    
    func setTapForHideKeyboard(_ view: UIView) {
        self.viewTap = view
    }
    
    func setTapForHideKeyboard() {
        if self.tapFormScrollView == nil {
            self.tapFormScrollView = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        }
        
        if self.viewTap?.gestureRecognizers == nil || !(self.viewTap?.gestureRecognizers?.contains(self.tapFormScrollView!))! {
            self.viewTap?.addGestureRecognizer(self.tapFormScrollView!)
            self.viewTap?.isUserInteractionEnabled = true
        }
        
    }
    
    func removeTapForHideKeyboard() {
        if self.tapFormScrollView != nil && (self.viewTap?.gestureRecognizers?.contains(self.tapFormScrollView!)) != nil &&
            (self.viewTap?.gestureRecognizers?.contains(self.tapFormScrollView!))! {
            self.viewTap?.removeGestureRecognizer(self.tapFormScrollView!)
        }
    }
    
    // MARK: - Text view delegates
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.hideKeyboard()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if self.isChangeView {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.heightContentDefault - self.keyboardHeight + 30)
        }
    }
    
    // MARK: - Delegates
    @objc func textFieldDidChange(_ textField: UITextField) {
        
    }
    
    @objc func touchSendButton(sender: UITapGestureRecognizer) {
        self.hideKeyboard()
    }
}

extension FormViewController {
    func initTextFields(fields: [UITextField]) {
        for item in fields {
            item.delegate = self
            item.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }
}

