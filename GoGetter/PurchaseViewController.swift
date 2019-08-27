//
//  PurchaseViewController.swift
//  GoGetter
//
//  Created by admin on 21/08/2019.
//  Copyright © 2019 Batth. All rights reserved.
//

import UIKit
import StoreKit
import SwiftyStoreKit

protocol PurchaseViewControllerDelegate {
    func didSuccessPurchase(convoId: Int, screenAction: Int, prompt: String?)
}

class PurchaseViewController: UIViewController {
    @IBOutlet weak var logoImageVIew: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var purchaseStackView: UIStackView!
    
    var prompt: String? = nil
    var convoId: Int = 0
    var products: [PurchaseItem] = []
    var items: [Purchase] = []
    var userId: String = ""
    var currentProduct: Purchase?
    
    struct PurchaseItem {
        let Productid: String?
        let ProductName: String?
        let Description: String?
        let Price: String?
        let CoinsPurchased: String?
        let NumberConvos: Int?
        let AppleStoreID: String?
        let GoogleStoreID: String?
    }
    
    struct Purchase {
        let item: PurchaseItem
        let details: SKProduct
    }
    
    var delegate: PurchaseViewControllerDelegate? = nil
    var isRootController: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.purchaseStackView.axis = .vertical
        self.purchaseStackView.distribution = .fillEqually
        self.purchaseStackView.translatesAutoresizingMaskIntoConstraints = false
        self.purchaseStackView.alignment = .center
        self.purchaseStackView.spacing = 4.0
        
        // title
        self.titleLabel.text = self.prompt
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // init views
        self.loadPurchases()
    }

    // MARK: - User functions
    
    func initViews(products: [Purchase]){
        let count = products.count
        let space: CGFloat = 4.0
        let width = (self.purchaseStackView.frame.width - (space * CGFloat(count - 1))) / CGFloat(count)
        let height = self.purchaseStackView.frame.height
        
        for index in  0..<count {
            let view = UIPurchase(frame: CGRect(x: CGFloat(index) * (width + CGFloat(index <= count - 1 ? space : 0)), y: 0, width: width, height: height))
            self.purchaseStackView.addSubview(view)
            view.set(
                id: products[index].item.AppleStoreID ?? "",
                title1: products[index].item.ProductName,
                title2: "$ \(Int(Double(products[index].item.Price!)! / Double(products[index].item.CoinsPurchased!)!)) per convo",
                title3: "$ \(String(describing: products[index].item.Price!))",
                title4: "\(products[index].item.CoinsPurchased!) conversation",
                touch: {id in
//                    self.outAlertSuccess(message: String(describing: id!))
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
                            parameters["userId"] = self.userId
                            
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
                                self.items.append(Purchase(item: purchase, details: product))
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
    
    // MARK: - Events

    @IBAction func touchBackButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
