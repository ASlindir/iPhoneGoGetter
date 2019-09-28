//
//  PurchaseManagerViewController.swift
//  GoGetter
//
//  Created by admin on 28/09/2019.
//  Copyright © 2019 Batth. All rights reserved.
//

import UIKit
import StoreKit
import SwiftyStoreKit

protocol PurchaseManagerViewControllerDelegate {
    func didBackToMathes()
}

class PurchaseManagerViewController: UIViewController, PurchaseStatisticViewControllerDelegate, PurchaseManagerViewControllerDelegate {
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    
    @IBOutlet weak var purchaseStackView: UIStackView!
    
    var prompt: String? = nil
    var convoId: Int = 0
    var products: [PurchaseViewController.PurchaseItem] = []
    var items: [PurchaseViewController.Purchase] = []
    var currentProduct: PurchaseViewController.Purchase?
    
    var delegate: PurchaseViewControllerDelegate? = nil
    var delegateManager: PurchaseManagerViewControllerDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // buttons
        self.backButton.setImage(UIImage(named: "back")!.withRenderingMode(.alwaysTemplate), for: .normal)
        self.backButton.tintColor = UIColor(red:0.00, green:0.65, blue:0.69, alpha:1.0)
        
        // labels
        self.bottomLabel.textColor = UIColor.white
        
        // taps
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapStatistics))
        self.bottomLabel.isUserInteractionEnabled = true
        self.bottomLabel.addGestureRecognizer(tap)
        
        //
        self.loadUserConvoStats(compliteHandler: {
            self.loadPurchaseFromServer()
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.createGradientLayer(self.gradientView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Users function
    
    func loadPurchaseFromServer() {
        Loader.startLoader(true)
        
        var parameters = Dictionary<String, Any>()
        parameters["userId"] = LocalStore.store.getFacebookID()
        
        // hook
        parameters["otherUserId"] = "NVqSplSj9QUQrgcmn4Mdwn3f1ao2"
        
        WebServices.service.webServicePostRequest(.post, .conversation, .doQueryConversation, parameters, successHandler: { (response) in
            Loader.stopLoader()
            let jsonDict = response
            
            if let convoId = jsonDict!["convoId"] as? Int {
                self.convoId = convoId
                self.prompt = jsonDict!["prompt"] as? String
                
                if let _products = jsonDict!["products"] as? [Dictionary<String, Any?>] {
                    for product in _products {
                        self.products.append(PurchaseViewController.PurchaseItem(
                            Productid: product["id"] as? String,
                            ProductName: product["productName"] as? String,
                            Description: product["description"] as? String,
                            Price: product["price"] as? String,
                            CoinsPurchased: product["coinsPurchased"] as? String,
                            NumberConvos: convoId,
                            AppleStoreID: product["iTunesProductID"] as? String,
                            GoogleStoreID: product["googleProductID"] as? String)
                        )
                    }
                }
                
                self.loadPurchases()
                
            } else {
                Loader.stopLoader()
                self.outAlertError(message: "Error: Convo Id is null")
            }
        }) { (error) in
            Loader.stopLoader()
            self.outAlertError(message: "Error: \(error.debugDescription)")
        }
    }
    
    func loadUserConvoStats(compliteHandler: (() -> Void)? = nil) {
        Loader.startLoader(true)
        
        var parameters = Dictionary<String, Any>()
        parameters["userId"] = LocalStore.store.getFacebookID()
        
        WebServices.service.webServicePostRequest(.post, .conversation, .doQueryConvoStats, parameters, successHandler: { (response) in
            Loader.stopLoader()
            
            let jsonDict = response
            
            if let userCoinRecord = jsonDict!["userCoinRecord"] as? [String:Any?] {
                if let coinsNotReserved = userCoinRecord["coinsNotReserved"] as? String {
                    let string = NSMutableAttributedString(string: "You have \(coinsNotReserved) coins left")
                    let range: NSRange = string.mutableString.range(of: coinsNotReserved, options: .caseInsensitive)
                   
                    string.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red:0.00, green:0.65, blue:0.69, alpha:1.0), range: range)
                    string.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Barmeno-Bold", size: 35.0)!, range: range)
                    
                    self.titleLabel.attributedText = string
                }
            }
            
            compliteHandler?()
        }) { (error) in
            Loader.stopLoader()
            self.outAlertError(message: "Error: \(error.debugDescription)")
            compliteHandler?()
        }
    }
    
    
    func loadPurchases() {
        var productIDs: Set<String> = []
        
        for product in self.products {
            productIDs.insert(product.AppleStoreID!)
        }
        
        if productIDs.count > 0 {
            Loader.startLoader(true)
            
            SwiftyStoreKit.retrieveProductsInfo(productIDs) { result in
                Loader.stopLoader()
                
                if result.retrievedProducts.first != nil {
                    for purchase in self.products {
                        for product in result.retrievedProducts {
                            if purchase.AppleStoreID == product.productIdentifier {
                                self.items.append(PurchaseViewController.Purchase(item: purchase, details: product))
                                break
                            }
                        }
                    }
                    
                    self.initViews(products: self.items)
                }
                else if let invalidProductId = result.invalidProductIDs.first {
                    self.outAlertError(message: "Invalid product identifier: \(invalidProductId)")
                }
                else {
                    self.outAlertError(message: "Error: \(result.error?.localizedDescription ?? "")")
                }
            }
        }
    }
    
    func initViews(products: [PurchaseViewController.Purchase]){
        let count = products.count
        let space: CGFloat = 4.0
        let width = (self.purchaseStackView.frame.width - (space * CGFloat(count - 1))) / CGFloat(count)
        let height = self.purchaseStackView.frame.height
        
        var viewItems: [UIPurchase] = []
        var maxCoins = 0
        var maxItem = 0
        
        for index in  0..<count {
            let view = UIPurchase(frame: CGRect(x: CGFloat(index) * (width + CGFloat(index <= count - 1 ? space : 0)), y: 0, width: width, height: height))
            viewItems.append(view)
            
            self.purchaseStackView.addSubview(view)
            var countCoins = 0
            
            if products[index].item.CoinsPurchased != nil {
                countCoins = Int(products[index].item.CoinsPurchased!) ?? 0
            }
            
            if maxCoins < countCoins {
                maxCoins = countCoins
                maxItem = index
            }
            
            view.set(
                id: products[index].item.AppleStoreID ?? "",
                title1: products[index].item.CoinsPurchased,
                title2: "$ \(Int(Double(products[index].item.Price!)! / Double(products[index].item.CoinsPurchased!)!)) per convo",
                title3: "$ \(String(describing: products[index].item.Price!))",
                title4: "\(products[index].item.CoinsPurchased!) conversation",
                touch: { id in
                    Loader.startLoader(true)

                    SwiftyStoreKit.purchaseProduct(id!, quantity: 1, atomically: false) { result in
                        Loader.stopLoader()

                        switch result {
                        case .success(let product):
                            // fetch content from your server, then:
                            if product.needsFinishTransaction {
                                SwiftyStoreKit.finishTransaction(product.transaction)
                            }

                            print("Purchase Success: \(product.productId)")

                            Loader.startLoader(true)

                            var formattedDate: String = ""

                            if let date = product.transaction.transactionDate {
                                let format = DateFormatter()
                                format.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                formattedDate = format.string(from: date)
                            }

                            var parameters = Dictionary<String, Any>()
                            parameters["convoId"] = self.convoId
                            parameters["userId"] = LocalStore.store.getFacebookID()

                            let productInfo = [
                                "purchaseStatus": PurchasesConst.PurchaseStatus.PURCHASE_SUCCESS.rawValue,
                                "appstore": "G",
                                "amount": Double(products[index].item.Price!)!,
                                "transctionID": product.transaction.transactionIdentifier != nil ? (product.transaction.transactionIdentifier)! : "",
                                "dateTime": formattedDate,
                                "productId": Int(products[index].item.Productid ?? "0")!
                                ] as [String : Any]
                            parameters["purchaseInfo"] = productInfo

                            WebServices.service.webServicePostRequest(.post, .conversation, .inAppPurchaseComplete, parameters, successHandler: { (response) in
                                Loader.stopLoader()

                                let jsonDict = response
                                var isSuccess = false

                                if let convoId = jsonDict!["convoId"] as? Int {
                                    let prompt = jsonDict!["prompt"] as? String

                                    if let screenAction = jsonDict!["screenAction"] as? Int {
                                        isSuccess = true

                                        self.dismiss(animated: true, completion: {
                                            self.delegate?.didSuccessPurchase(convoId: convoId, screenAction: screenAction, prompt: prompt)
                                        })
                                    }
                                }

                                if !isSuccess {
                                    self.outAlertError(message: "Error: Convo Id is null")
                                }
                            }) { (error) in
                                Loader.stopLoader()
                                self.outAlertError(message: "Error: \(error.debugDescription)")
                            }
                        case .error(let error):
                            switch error.code {
                            case .unknown: print("Unknown error. Please contact support")
                            case .clientInvalid: print("Not allowed to make the payment")
                            case .paymentCancelled: break
                            case .paymentInvalid: print("The purchase identifier was invalid")
                            case .paymentNotAllowed: print("The device is not allowed to make the payment")
                            case .storeProductNotAvailable: print("The product is not available in the current storefront")
                            case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                            case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                            case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                            default:
                                print((error as NSError).localizedDescription)
                            }

                            self.outAlertError(message: "Error: \((error as NSError).localizedDescription)")
                        }
                    }
            }
            )
            
            view.bestValueImageView.isHidden = true
        }
        
        viewItems[maxItem].bestValueImageView.isHidden = false
        
    }
    
    // MARK: - PurchaseStatisticViewControllerDelegate
    
    func didBackToMathes() {
        self.dismiss(animated: false, completion: {
            self.delegateManager?.didBackToMathes()
        })
    }


    // MARK: - Events

    @IBAction func touchBackButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func tapStatistics(sender: UITapGestureRecognizer) {
        let controller = PurchaseStatisticViewController.loadFromNib()
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
}
