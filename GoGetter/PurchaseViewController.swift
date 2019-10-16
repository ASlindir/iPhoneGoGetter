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
    func didSuccessPurchase(userId: String?, convoId: Int, screenAction: Int, prompt: String?)
}

class PurchaseViewController: UIViewController {
    @IBOutlet weak var logoImageVIew: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var purchaseStackView: UIStackView!
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var bottomTitle1Label: UILabel!
    @IBOutlet weak var bottomTitle2Label: UILabel!
    
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

        // stack view
        self.purchaseStackView.axis = .vertical
        self.purchaseStackView.distribution = .fillEqually
        self.purchaseStackView.translatesAutoresizingMaskIntoConstraints = false
        self.purchaseStackView.alignment = .center
        self.purchaseStackView.spacing = 4.0
        
        // hide title
        self.bottomTitle1Label.alpha = 0.0
        self.bottomTitle2Label.alpha = 0.0
        
        // title
//        self.titleLabel.text = self.prompt
        
        // taps
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapNoThanks))
        self.bottomTitle2Label.isUserInteractionEnabled = true
        self.bottomTitle2Label.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // init views
        self.loadPurchases()
        self.createGradientLayer(self.gradientView)
    }

    // MARK: - User functions
    
    func initViews(products: [Purchase]){
        let count = products.count
        let space: CGFloat = 4.0
        let width = (self.purchaseStackView.frame.width - (space * CGFloat(count - 1))) / CGFloat(count)
        let height = self.purchaseStackView.frame.height
        
        var viewItems: [UIPurchase] = []
        var maxCoins = 0
        var maxItems = 0
        
        for index in  0..<count {
            let view = UIPurchase(frame: CGRect(x: CGFloat(index) * (width + CGFloat(index <= count - 1 ? space : 0)), y: 0, width: width, height: height))
            viewItems.append(view)
            
            view.title1Label.isHidden = true
            view.title2Label.isHidden = true
            view.title4Label.isHidden = true
            view.buyButton.isHidden = true
            
            view.alpha = 0
            
            self.purchaseStackView.addSubview(view)
            var countCoins = 0
            
            if products[index].item.CoinsPurchased != nil {
                countCoins = Int(products[index].item.CoinsPurchased!) ?? 0
            }
            
            if maxCoins < countCoins {
                maxCoins = countCoins
                maxItems = index
            }
            
            view.set(
                id: products[index].item.AppleStoreID ?? "",
                title1: products[index].item.CoinsPurchased,
                title2: "$ \(Int(Double(products[index].item.Price!)! / Double(products[index].item.CoinsPurchased!)!)) per convo",
                title3: "$ \(String(describing: products[index].item.Price!))",
                title4: "\(products[index].item.CoinsPurchased!) conversation",
                touch: { id in
                    // test
//                    self.dismiss(animated: true, completion: {
//                        self.delegate?.didSuccessPurchase(userId: self.userId, convoId: self.convoId, screenAction: 2, prompt: self.prompt)
//                    })

                    // original
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
                                            self.delegate?.didSuccessPurchase(userId: self.userId, convoId: convoId, screenAction: screenAction, prompt: prompt)
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
        
        func animateItems(counter: Int, maxItem: Int = 0) {
            if counter < viewItems.count {
                self.showPurchaseAnimation(viewItems[counter], completedHandler: {
                    
                    let duration: Double = 0.4
                    
                    // rotate image
                    func rotateView(duration: Double = 0.4, isLast: Bool = false) {
                        UIView.animate(withDuration: duration, delay: 0.0, options: [
                            //                        .repeat, .autoreverse
                            ], animations: {
                                //                        UIView.setAnimationRepeatCount(4)
                                viewItems[counter].imageView.layer.transform = CATransform3DMakeRotation(.pi, 0, 1, 0)
                        }, completion: { completed in
                            UIView.animate(withDuration: duration, delay: 0.0, animations: {
                                viewItems[counter].imageView.layer.transform = CATransform3DMakeRotation(2 * .pi, 0, 1, 0)
                            }, completion: { completed in
                                if !isLast {
                                    rotateView(duration: duration, isLast: true)
                                }
                            })
                        })
                    }
                    
                    rotateView(duration: duration)
                    
                    if counter == maxItem {
                        DispatchQueue.main.asyncAfter(deadline: .now() + duration * 2 * Double(count)) {
                            viewItems[counter].bestValueImageView.isHidden = false
                            self.bestValueAnimation(viewItems[counter].bestValueImageView, completedHandler: {
                                self.showPurchaseAnimation(self.bottomTitle1Label, completedHandler: {
                                    UIView.animate(withDuration: 0.8, animations: {
                                        self.bottomTitle2Label.alpha = 1.0
                                    }, completion: { (completed: Bool) in
                                        //
                                    })
                                }, duration: 0.5)
                            })
                        }
                    }
                    
                    self.showPurchaseAnimation(viewItems[counter].title1Label, duration: 0.3)
                    self.showPurchaseAnimation(viewItems[counter].title2Label, duration: 0.3)
                    self.showPurchaseAnimation(viewItems[counter].title4Label, duration: 0.3)
                    self.showPurchaseAnimation(viewItems[counter].buyButton, duration: 0.3)
                    
                    // next view
                    animateItems(counter: counter + 1, maxItem: maxItem)
                })
            }
        }
        
        animateItems(counter: 0, maxItem: maxItems)
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
    
    func loadTestPurchase() {
        Loader.startLoader(true)
        
        var parameters = Dictionary<String, Any>()
        parameters["userId"] = LocalStore.store.getFacebookID()
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
                            AppleStoreID: product["iTunesProductID"] as? String,
                            GoogleStoreID: product["googleProductID"] as? String)
                        )
                    }
                }
                
                self.loadPurchases()
                
            } else {
                Loader.stopLoader()
                self.outAlertError(message: "Error: Convo Id is null")
                UserDefaults.standard.set(false, forKey: "matchedNotification")
            }
        }) { (error) in
            Loader.stopLoader()
            self.outAlertError(message: "Error: \(error.debugDescription)")
            UserDefaults.standard.set(false, forKey: "matchedNotification")
        }
    }
    
    // MARK: - Animations
    func bestValueAnimation(_ view: UIView, completedHandler: (() -> Void)? = nil) {
        view.rotate(10, 0.05, finished: { (completed: Bool) in
            view.rotate(-10, 0.05, finished: { (completed: Bool) in
                view.rotate(10, 0.05, finished: { (completed: Bool) in
                    view.rotate(-10, 0.05, finished: { (completed: Bool) in
                        view.rotate(10, 0.05, finished: { (completed:Bool) in
                            view.rotate(-10, 0.05, finished: { (completed: Bool) in
                                view.rotate(8, 0.05, finished: { (completed: Bool) in
                                    view.rotate(-8, 0.05, finished: { (completed: Bool) in
                                        view.rotate(6, 0.1, finished: { (completed:Bool) in
                                            view.rotate(-6, 0.1, finished: { (completed:Bool) in
                                                view.rotate(2, 0.2, finished: { (completed:Bool) in
                                                    view.rotate(-2, 0.1, finished: { (completed:Bool) in
                                                        view.rotate(0, 0.1, finished: { (completed:Bool) in
                                                            completedHandler?()
                                                        })
                                                    })
                                                })
                                            })
                                        })
                                    })
                                })
                            })
                        })
                    })
                })
            })
        })
    }
    
    func showPurchaseAnimation(_ view: UIView, completedHandler: (() -> Void)? = nil, duration: Double = 0.5) {
        view.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        view.alpha = 0
        view.isHidden = false
        
        UIView.animate(withDuration: duration, animations: {
            view.transform = CGAffineTransform(scaleX: 1, y: 1)
            view.alpha = 1
        }, completion: { (completed: Bool) in
            completedHandler?()
        })
    }
    
    
    // MARK: - Events

    @IBAction func touchBackButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func tapNoThanks(sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
}
