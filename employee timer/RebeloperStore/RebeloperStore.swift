//
//  RebeloperStore.swift
//
//  Created by Alex Nagy on 22/09/2016.
//  Copyright © 2016 Rebeloper. All rights reserved.
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import StoreKit
import SwiftyStoreKit
import KeychainAccess

let AppBundleId = Bundle.main.bundleIdentifier!
let mydateFormat = DateFormatter()

let iAPStatusChanged = "iAPStatusChanged"
let virtualPurchaseStatusChanged = "virtualPurchaseStatusChanged"

let keychain = Keychain(service: AppBundleId)
enum KeychainValue : String {
    
    case keychainAlreadyCreated = "keychainAlreadyCreated"
    case purchased = "purchased"
    case notPurchased = "notPurchased"
    case trueValue = "trueValue"
    case falseValue = "falseValue"
    case noValue = "noValue"
}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

@objc final class RebeloperStore: NSObject {
    @objc static let shared = RebeloperStore()
    private override init() {} //This prevents others from using the default '()' initializer for this class.
    
    enum InfoType : String {
        
        case title = "title"
        case description = "description"
        case price = "price"
        
    }
    
    
    
    @objc func start() {
        
        // swifty store
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                if purchase.transaction.transactionState == .purchased || purchase.transaction.transactionState == .restored {
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    print("purchased: \(purchase)")
                }
            }
        }
        
        SwiftyStoreKit.shouldAddStorePaymentHandler = { payment, product in
            return true //if the content can be delivered by your app
            // return false otherwise
        }
        
        // keychain
        setupRebeloperStoreKeychainAccount()
        
        if shouldLogRebeloperStoreKeychainAccount {
            logRebeloperStoreKeychainAccount()
        }
        
    }
    
    func setupRebeloperStoreKeychainAccount() {
        
        if resetKeychainToDefaultValues {
            removeRebeloperStoreKeychainAccount()
        }
        
        // non-renewable purchases
        var g = 0
        repeat {
            
            if getRebeloperStoreKeychainAccountValue(NonRenewablePurchases[g].rawValue) == KeychainValue.noValue.rawValue {
                print("Key '\(NonRenewablePurchases[g].rawValue)' does not exist or is 'nil'. Setting it up now.")
                setRebeloperStoreKeychainAccount(KeychainValue.notPurchased.rawValue, key: NonRenewablePurchases[g].rawValue)
            }
            
            g = g + 1
        } while g < NonRenewablePurchases.count
        
        // renewable purchases
        var h = 0
        repeat {
            
            if getRebeloperStoreKeychainAccountValue(RenewablePurchases[h].rawValue) == KeychainValue.noValue.rawValue {
                print("Key '\(RenewablePurchases[h].rawValue)' does not exist or is 'nil'. Setting it up now.")
                setRebeloperStoreKeychainAccount(KeychainValue.notPurchased.rawValue, key: RenewablePurchases[h].rawValue)
            }
            
            h = h + 1
        } while h < RenewablePurchases.count
        
        // regular purchases
        var i = 0
        repeat {
            
            if getRebeloperStoreKeychainAccountValue(RegularPurchases[i].rawValue) == KeychainValue.noValue.rawValue {
                print("Key '\(RegularPurchases[i].rawValue)' does not exist or is 'nil'. Setting it up now.")
                setRebeloperStoreKeychainAccount(KeychainValue.notPurchased.rawValue, key: RegularPurchases[i].rawValue)
            }
            
            i = i + 1
        } while i < RegularPurchases.count
        
        // virtual purchases
        var j = 0
        repeat {
            
            if getRebeloperStoreKeychainAccountValue(VirtualPurchases[j].rawValue) == KeychainValue.noValue.rawValue {
                print("Key '\(VirtualPurchases[j].rawValue)' does not exist or is 'nil'. Setting it up now.")
                setRebeloperStoreKeychainAccount(VirtualPurchasesAmountToGiveOnFirstLaunch[j], key: VirtualPurchases[j].rawValue)
            }
            
            j = j + 1
        } while j < VirtualPurchases.count
        
        // virtual currencies
        var k = 0
        repeat {
            
            if getRebeloperStoreKeychainAccountValue(VirtualCurrencies[k].rawValue) == KeychainValue.noValue.rawValue {
                print("Key '\(VirtualCurrencies[k].rawValue)' does not exist or is 'nil'. Setting it up now.")
                setRebeloperStoreKeychainAccount(VirtualCurrenciesAmountToGiveOnFirstLaunch[k], key: VirtualCurrencies[k].rawValue)
            }
            
            k = k + 1
        } while k < VirtualCurrencies.count
        
    }
    
    func logRebeloperStoreKeychainAccount() {
        print("-------- Logging Rebeloper Store Keychain Account --------")
        
        print("-------- Non-Renewable Purchases --------")
        // renewable purchases
        var g = 0
        repeat {
            
            if getRebeloperStoreKeychainAccountValue(NonRenewablePurchases[g].rawValue) == KeychainValue.noValue.rawValue {
                print("Key '\(NonRenewablePurchases[g].rawValue)' does not exist or is 'nil'.")
            } else {
                print("[\(NonRenewablePurchases[g].rawValue) : \(getRebeloperStoreKeychainAccountValue(NonRenewablePurchases[g].rawValue))]")
            }
            
            g = g + 1
        } while g < NonRenewablePurchases.count
        
        print("-------- Renewable Purchases --------")
        // renewable purchases
        var h = 0
        repeat {
            
            if getRebeloperStoreKeychainAccountValue(RenewablePurchases[h].rawValue) == KeychainValue.noValue.rawValue {
                print("Key '\(RenewablePurchases[h].rawValue)' does not exist or is 'nil'.")
            } else {
                print("[\(RenewablePurchases[h].rawValue) : \(getRebeloperStoreKeychainAccountValue(RenewablePurchases[h].rawValue))]")
            }
            
            h = h + 1
        } while h < RenewablePurchases.count
        
        print("-------- Regular Purchases --------")
        // regular purchases
        var i = 0
        repeat {
            
            if getRebeloperStoreKeychainAccountValue(RegularPurchases[i].rawValue) == KeychainValue.noValue.rawValue {
                print("Key '\(RegularPurchases[i].rawValue)' does not exist or is 'nil'.")
            } else {
                print("[\(RegularPurchases[i].rawValue) : \(getRebeloperStoreKeychainAccountValue(RegularPurchases[i].rawValue))]")
            }
            
            i = i + 1
        } while i < RegularPurchases.count
        
        print("-------- Virtual Purchases --------")
        // virtual purchases
        var j = 0
        repeat {
            
            if getRebeloperStoreKeychainAccountValue(VirtualPurchases[j].rawValue) == KeychainValue.noValue.rawValue {
                print("Key '\(VirtualPurchases[j].rawValue)' does not exist or is 'nil'.")
            } else {
                print("[\(VirtualPurchases[j].rawValue) : \(getRebeloperStoreKeychainAccountValue(VirtualPurchases[j].rawValue))]")
            }
            
            j = j + 1
        } while j < VirtualPurchases.count
        
        print("-------- Virtual Currencies --------")
        // virtual currencies
        var k = 0
        repeat {
            
            if getRebeloperStoreKeychainAccountValue(VirtualCurrencies[k].rawValue) == KeychainValue.noValue.rawValue {
                print("Key '\(VirtualCurrencies[k].rawValue)' does not exist or is 'nil'.")
            } else {
                print("[\(VirtualCurrencies[k].rawValue) : \(getRebeloperStoreKeychainAccountValue(VirtualCurrencies[k].rawValue))]")
            }
            
            k = k + 1
        } while k < VirtualCurrencies.count
        
        print("-------- End of Rebeloper Store Keychain Account Log --------")
    }
    
    func getRebeloperStoreKeychainAccountValue(_ key: String) -> String {
        let value = try! keychain.getString(key)
        print("Getting data from key '\(key)' : \(String(describing: value))")
        
        if value != nil {
            return value!
        } else {
            return KeychainValue.noValue.rawValue
        }
        
        
    }
    
    func setRebeloperStoreKeychainAccount(_ value: String, key: String) {
        if let _ = try? keychain.getString(key) != nil {
            do {
                try keychain.set(value, key: key)
                //print("Setting data for key '\(key)' : \(value)")
            }
            catch let error {
                print(error)
            }
        } else {
            print("Couldn't create keychain token for '\(key)'")
        }
    }
    
    func removeRebeloperStoreKeychain(_ key: String) {
        if let _ = try? keychain.getString(key) {
            if let token = try? keychain.getString(key) != nil {
                
                do {
                    try keychain.remove(key)
                    print("Removing data at key '\(key)' : \(token)")
                } catch let error {
                    print("error: \(error)")
                }
                
            } else {
                print("No data found to delete at key '\(key)'")
            }
        } else {
            print("No such key found to delete: '\(key)'")
        }
    }
    
    func removeRebeloperStoreKeychainAccount() {
        
        var g = 0
        repeat {
            removeRebeloperStoreKeychain(NonRenewablePurchases[g].rawValue)
            g = g + 1
        } while g < NonRenewablePurchases.count
        
        var h = 0
        repeat {
            removeRebeloperStoreKeychain(RenewablePurchases[h].rawValue)
            h = h + 1
        } while h < RenewablePurchases.count
        
        var i = 0
        repeat {
            removeRebeloperStoreKeychain(RegularPurchases[i].rawValue)
            i = i + 1
        } while i < RegularPurchases.count
        
        var j = 0
        repeat {
            removeRebeloperStoreKeychain(VirtualPurchases[j].rawValue)
            j = j + 1
        } while j < VirtualPurchases.count
        
        var k = 0
        repeat {
            removeRebeloperStoreKeychain(VirtualCurrencies[k].rawValue)
            k = k + 1
        } while k < VirtualCurrencies.count
        
    }
    
    @objc func isRegularPurchaseBought(_ regularPurchaseType: Int) -> Bool {
        let regularPurchaseType: RegularPurchaseName = RegularPurchases[regularPurchaseType]
        if getRebeloperStoreKeychainAccountValue(regularPurchaseType.rawValue) == KeychainValue.purchased.rawValue {
            return true
        } else {
            return false
        }
    }
    
    @objc func isVirtualNonConsumablePurchaseBought(_ virtualPurchaseType: Int) -> Bool {
        let virtualPurchaseType: VirtualPurchasesName = VirtualPurchases[virtualPurchaseType]
        if getRebeloperStoreKeychainAccountValue(virtualPurchaseType.rawValue) != "0" {
            return true
        } else {
            return false
        }
    }
    
    func purchaseVirtualGood(_ amount: Int, ofVirtualGoodType: Int, forVirtualCurrencyAmount: Int, ofVirtualCurrencyType: Int) {
        //let ofVirtualGoodType: VirtualPurchasesName = VirtualPurchases[ofVirtualGoodType]
        //let ofVirtualCurrencyType: VirtualCurrenciesName = VirtualCurrencies[ofVirtualCurrencyType]
        // pay
        changeVirtualCurrency(-forVirtualCurrencyAmount, ofVirtualCurrencyType: ofVirtualCurrencyType) { (result, theAmount) in
            if result == true {
                // receive the goods
                self.changeVirtualGood(amount, ofVirtualGoodType: ofVirtualGoodType, completion: { (resut, theAmount) in
                    print("Added \(theAmount)")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: virtualPurchaseStatusChanged), object: nil)
                })
                
            }
            
        }
        
    }
    
    @objc func purchaseVirtualCurrency(_ amount: Int, ofVirtualCurrencyType: Int, forPayableVirtualCurrencyAmount: Int, ofPayableVirtualCurrencyType: Int) {
        //let ofVirtualCurrencyType: VirtualCurrenciesName = VirtualCurrencies[ofVirtualCurrencyType]
        //let ofPayableVirtualCurrencyType: VirtualCurrenciesName = VirtualCurrencies[ofPayableVirtualCurrencyType]
        // pay
        changeVirtualCurrency(-forPayableVirtualCurrencyAmount, ofVirtualCurrencyType: ofPayableVirtualCurrencyType) { (result, theAmount) in
            if result == true {
                // receive the virtual currency
                self.changeVirtualCurrency(amount, ofVirtualCurrencyType: ofVirtualCurrencyType, completion: { (result, theAmount) in
                    print("Added \(theAmount)")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: virtualPurchaseStatusChanged), object: nil)
                })
                
            }
            
        }
        
    }
    
    @objc func changeVirtualGood(_ amount: Int, ofVirtualGoodType: Int, completion: @escaping (_ result: Bool, _ amount: Int) -> Void) {
        //let ofVirtualGoodType: VirtualPurchasesName = VirtualPurchases[ofVirtualGoodType]
        
        if amount < 0 {
            
            let currentVirtualGoodAmount = getVirtualGoodAmount(ofVirtualGoodType)
            if currentVirtualGoodAmount >= -amount {
                let virtualGoodAmountToSave = currentVirtualGoodAmount + amount
                setRebeloperStoreKeychainAccount(String(virtualGoodAmountToSave), key: "VirtualGoodType\(ofVirtualGoodType)")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: virtualPurchaseStatusChanged), object: nil)
                completion(true, amount)
            } else {
                // not enough VG
                self.showAlert(self.alertWithTitle("Insufficient funds", message: "You don't have enough funds to make this action."))
                completion(false, amount)
            }
            
        } else {
            
            let currentVirtualGoodAmount = getVirtualGoodAmount(ofVirtualGoodType)
            let virtualGoodAmountToSave = currentVirtualGoodAmount + amount
            setRebeloperStoreKeychainAccount(String(virtualGoodAmountToSave), key: "VirtualGoodType\(ofVirtualGoodType)")
            completion(true, amount)
            
        }
        
        
        
        
    }
    
    func changeVirtualCurrency(_ amount: Int, ofVirtualCurrencyType: Int, completion: @escaping (_ result: Bool, _ amount: Int) -> Void) {
        //let ofVirtualCurrencyType: VirtualCurrenciesName = VirtualCurrencies[ofVirtualCurrencyType];
        
        if amount < 0 {
            
            let currentVirtualCurrencyAmount = getVirtualCurrencyAmount(ofVirtualCurrencyType)
            if currentVirtualCurrencyAmount >= -amount {
                let virtualCurrencyToSave = currentVirtualCurrencyAmount + amount
                setRebeloperStoreKeychainAccount(String(virtualCurrencyToSave), key: "VirtualCurrencyType\(ofVirtualCurrencyType)")
                completion(true, amount)
            } else {
                // not enough VC
                self.showAlert(self.alertWithTitle("Insufficient funds", message: "You don't have enough funds to make this action."))
                completion(false, amount)
            }
            
        } else {
            
            let currentVirtualCurrencyAmount = getVirtualCurrencyAmount(ofVirtualCurrencyType)
            let virtualCurrencyToSave = currentVirtualCurrencyAmount + amount
            setRebeloperStoreKeychainAccount(String(virtualCurrencyToSave), key: "VirtualCurrencyType\(ofVirtualCurrencyType)")
            completion(true, amount)
            
        }
        
        
        
        
    }
    
    @objc func getVirtualGoodAmount(_ ofVirtualGoodType: Int) -> Int {
        let ofVirtualGoodType: VirtualPurchasesName = VirtualPurchases[ofVirtualGoodType]
        return Int(getRebeloperStoreKeychainAccountValue(ofVirtualGoodType.rawValue))!
    }
    
    @objc func getVirtualCurrencyAmount(_ ofVirtualCurrency: Int) -> Int {
        let ofVirtualCurrency: VirtualCurrenciesName = VirtualCurrencies[ofVirtualCurrency]
        return Int(getRebeloperStoreKeychainAccountValue(ofVirtualCurrency.rawValue))!
    }
    
    
    @objc func getInfo(_ purchase: Int, completion: @escaping (_ result: SKProduct) -> Void) {
        let purchase: RegularPurchaseName = RegularPurchases[purchase]
        
        NetworkActivityIndicatorManager.networkOperationStarted()
        
        SwiftyStoreKit.retrieveProductsInfo([AppBundleId + "." + purchase.rawValue]) { result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            if let product = result.retrievedProducts.first {
                
                completion(product)
                
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                self.showAlert(self.alertWithTitle("Could not retrieve product info", message: "Invalid product identifier: \(invalidProductId)"))
            }
            else {
                let errorString = result.error?.localizedDescription ?? "Unknown error. Please contact support"
                self.showAlert(self.alertWithTitle("Could not retrieve product info", message: errorString))
            }
            
        }
    }
    
    @objc func purchase(_ purchase: Int) {
        let purchase: RegularPurchaseName = RegularPurchases[purchase]
        
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.purchaseProduct(AppBundleId + "." + purchase.rawValue) { result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            //self.showAlert(self.alertForPurchaseResult(result))
            self.alertForPurchaseResult(result)
        }
    }
    
    func getNonRenewableInfo(_ purchase: NonRenewablePurchaseName, completion: @escaping (_ result: SKProduct) -> Void) {
        
        NetworkActivityIndicatorManager.networkOperationStarted()
        
        SwiftyStoreKit.retrieveProductsInfo([AppBundleId + "." + purchase.rawValue]) { result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            if let product = result.retrievedProducts.first {
                
                completion(product)
                
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                self.showAlert(self.alertWithTitle("Could not retrieve product info", message: "Invalid product identifier: \(invalidProductId)"))
            }
            else {
                let errorString = result.error?.localizedDescription ?? "Unknown error. Please contact support"
                self.showAlert(self.alertWithTitle("Could not retrieve product info", message: errorString))
            }
            
        }
    }
    
    @objc func purchaseNonRenewable(_ purchase: Int) {
        let purchase: NonRenewablePurchaseName = NonRenewablePurchases[purchase]
        
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.purchaseProduct(AppBundleId + "." + purchase.rawValue) { result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            //self.showAlert(self.alertForPurchaseResult(result))
            self.alertForPurchaseResult(result)
        }
    }
    
    @objc func getRenewableInfo(_ purchase: Int, completion: @escaping (_ result: SKProduct) -> Void) {
        
        let purchase: RenewablePurchaseName = RenewablePurchases[purchase]
        
        NetworkActivityIndicatorManager.networkOperationStarted()
        print (AppBundleId + "." + purchase.rawValue)
        
        SwiftyStoreKit.retrieveProductsInfo([AppBundleId + "." + purchase.rawValue]) { result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            if let product = result.retrievedProducts.first {
                
                completion(product)
                
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                self.showAlert(self.alertWithTitle("Could not retrieve product info", message: "Invalid product identifier: \(invalidProductId)"))
            }
            else {
                let errorString = result.error?.localizedDescription ?? "Unknown error. Please contact support"
                self.showAlert(self.alertWithTitle("Could not retrieve product info", message: errorString))
            }
            
        }
    }
    
    @objc func purchaseRenewable(_ purchase: Int) {
        let purchase: RenewablePurchaseName = RenewablePurchases[purchase]
        
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.purchaseProduct(AppBundleId + "." + purchase.rawValue) { result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            //self.showAlert(self.alertForPurchaseResult(result))
            self.alertForPurchaseResult(result)
        }
    }
    
    @objc func purchaseVirtualCurrency(_ purchase: Int) {
        let purchase: VirtualCurrencyPurchaseName = VirtualCurrencyPurchases[purchase]
        
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.purchaseProduct(AppBundleId + "." + purchase.rawValue) { result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            //self.showAlert(self.alertForPurchaseResult(result))
            self.alertForPurchaseResult(result)
        }
    }
    
    @objc func getVirtualCurrencyPurchaseInfo(_ purchase: Int, completion: @escaping (_ result: SKProduct) -> Void) {
        let purchase: VirtualCurrencyPurchaseName = VirtualCurrencyPurchases[purchase]
        
        NetworkActivityIndicatorManager.networkOperationStarted()
        
        SwiftyStoreKit.retrieveProductsInfo([AppBundleId + "." + purchase.rawValue]) { result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            if let product = result.retrievedProducts.first {
                
                completion(product)
                
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                self.showAlert(self.alertWithTitle("Could not retrieve product info", message: "Invalid product identifier: \(invalidProductId)"))
            }
            else {
                let errorString = result.error?.localizedDescription ?? "Unknown error. Please contact support"
                self.showAlert(self.alertWithTitle("Could not retrieve product info", message: errorString))
            }
            
        }
    }
    
    @objc func restorePurchases() {
        
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.restorePurchases() { results in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            self.showAlert(self.alertForRestorePurchases(results))
        }
    }
    
    func verifyReceipt() {
        
        NetworkActivityIndicatorManager.networkOperationStarted()
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: SharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: false) { (result) in
            NetworkActivityIndicatorManager.networkOperationFinished()
            
            switch result {
            case .success(let receipt):
                print("Verify receipt success: \(receipt)")
            case .error(let error):
                print("Verify receipt failed: \(error)")
                self.alertForVerifyReceipt(result)
                if case .noReceiptData = error {
                    self.refreshReceipt()
                }
            }
            
        }
        
    }
    
    @objc func verifyNonRenewablePurchase(_ purchase: Int, completion: @escaping (_ result: Bool, _ resutlString: String) -> Void) {
        
        let purchase: NonRenewablePurchaseName = NonRenewablePurchases[purchase]
        
        NetworkActivityIndicatorManager.networkOperationStarted()
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: SharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: false) { (result) in
            NetworkActivityIndicatorManager.networkOperationFinished()
            switch result {
            case .success(let receipt):
                
                let productId = AppBundleId + "." + purchase.rawValue
                
                var i = 0
                repeat {
                    
                    if purchase == NonRenewablePurchases[i] {
                        
                        let purchaseResult = SwiftyStoreKit.verifySubscription(
                            type: .nonRenewing(validDuration: TimeInterval(NonRenewablePurchasesSubscritionAmount[i])),
                            productId: productId,
                            inReceipt: receipt)
                        
                        switch purchaseResult {
                        case .purchased(let expiresDate):
                            print("Product '\(AppBundleId).\(purchase)' is valid until \(expiresDate)")
                            completion(true, "Product is valid until \(expiresDate)")
                        case .expired(let expiresDate):
                            print("Product '\(AppBundleId).\(purchase)' is expired since \(expiresDate)")
                            completion(false, "Product is expired since \(expiresDate)")
                        case .notPurchased:
                            print("Product '\(AppBundleId).\(purchase)' has never been purchased")
                            completion(false, "Product has never been purchased")
                        }
                    }
                    
                    i = i + 1
                } while i < NonRenewablePurchases.count
                
                
                
            case .error(let error):
                //self.showAlert(self.alertForVerifyReceipt(result))
                self.alertForVerifyReceipt(result)
                if case .noReceiptData = error {
                    self.refreshReceipt()
                }
            }
        }
        
    }
    
    
    @objc func verifyRenewablePurchase(_ purchase: Int, completion: @escaping (_ result: Bool, _ resutlString: String) -> Void) {
        
        let purchase: RenewablePurchaseName = RenewablePurchases[purchase]
        
        NetworkActivityIndicatorManager.networkOperationStarted()
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: SharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: false) { (result) in
            NetworkActivityIndicatorManager.networkOperationFinished()
             mydateFormat.dateFormat = DateFormatter.dateFormat(fromTemplate: " MMM d, yyyy", options: 0, locale: Locale.autoupdatingCurrent)!
            switch result {
            case .success(let receipt):
                
                let productId = AppBundleId + "." + purchase.rawValue
                
                var i = 0
                repeat {
                    
                    if purchase == RenewablePurchases[i] {
                        
                        let purchaseResult = SwiftyStoreKit.verifySubscription(
                            type: .autoRenewable,
                            productId: productId,
                            inReceipt: receipt,
                            validUntil: Date()
                        
                        )
                    
                        switch purchaseResult {
                        case .purchased(let expiresDate):
                            print("Product is valid until \(mydateFormat.string(from: expiresDate.expiryDate))")
                            completion(true, "Valid until: \(mydateFormat.string(from: expiresDate.expiryDate))")
                        case .expired(let expiresDate):
                            print("Product Expired since \(mydateFormat.string(from: expiresDate.expiryDate))")
                            completion(false, "Expired since \(mydateFormat.string(from: expiresDate.expiryDate))")
                        case .notPurchased:
                            print("Product never been purchased")
                            completion(false, "Never purchased")
                        }
                    }
                    
                    i = i + 1
                } while i < RenewablePurchases.count
                
                
                
            case .error(let error):
                //self.showAlert(self.alertForVerifyReceipt(result))
                self.alertForVerifyReceipt(result)
                if case .noReceiptData = error {
                    self.refreshReceipt()
                  
                }
            }
        }
        
    }
    
    func verifyPurchase(_ purchase: RegularPurchaseName, completion: @escaping (_ result: Bool, _ resutlString: String) -> Void) {
        
        NetworkActivityIndicatorManager.networkOperationStarted()
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: SharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: false) { (result) in
            NetworkActivityIndicatorManager.networkOperationFinished()
            switch result {
            case .success(let receipt):
                
                let productId = AppBundleId + "." + purchase.rawValue
                
                var i = 0
                repeat {
                    
                    if purchase == RegularPurchases[i] {
                        let purchaseResult = SwiftyStoreKit.verifyPurchase(
                            productId: productId,
                            inReceipt: receipt
                        )
                        
                        switch purchaseResult {
                        case .purchased:
                            print("Product '\(AppBundleId).\(purchase)' is purchased")
                            completion(true, "Product is purchased")
                        case .notPurchased:
                            print("Product '\(AppBundleId).\(purchase)' has never been purchased")
                            completion(false, "Product has never been purchased")
                        }
                    }
                    
                    i = i + 1
                } while i < RegularPurchases.count
                
            case .error(let error):
                //self.showAlert(self.alertForVerifyReceipt(result))
                self.alertForVerifyReceipt(result)
                if case .noReceiptData = error {
                    self.refreshReceipt()
                }
            }
        }
        
    }
    
    func verifyVirtualCurrencyPurchase(_ purchase: VirtualCurrencyPurchaseName, completion: @escaping (_ result: Bool, _ resutlString: String) -> Void) {
        
        // check if there is a network connection
        // if not than we're updating from keychain
        
        NetworkActivityIndicatorManager.networkOperationStarted()
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: SharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: false) { (result) in
            NetworkActivityIndicatorManager.networkOperationFinished()
            switch result {
            case .success(let receipt):
                
                let productId = AppBundleId + "." + purchase.rawValue
                
                var i = 0
                repeat {
                    
                    if purchase == VirtualCurrencyPurchases[i] {
                        let purchaseResult = SwiftyStoreKit.verifyPurchase(
                            productId: productId,
                            inReceipt: receipt
                        )
                        
                        switch purchaseResult {
                        case .purchased:
                            print("Product '\(AppBundleId).\(purchase)' is purchased")
                            completion(true, "Product is purchased")
                        case .notPurchased:
                            print("Product '\(AppBundleId).\(purchase)' has never been purchased")
                            completion(false, "Product has never been purchased")
                        }
                    }
                    
                    i = i + 1
                } while i < RegularPurchases.count
                
            case .error(let error):
                //self.showAlert(self.alertForVerifyReceipt(result))
                self.alertForVerifyReceipt(result)
                if case .noReceiptData = error {
                    self.refreshReceipt()
                }
            }
        }
        
    }
    
    func refreshReceipt() {
        
        SwiftyStoreKit.fetchReceipt(forceRefresh: true) { (result) in
            self.alertForRefreshReceipt(result)
        }
        
    }
    
    func alertWithTitle(_ title: String, message: String) -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alert
    }
    
    func showAlert(_ alert: UIAlertController) {
        
        if let topController = UIApplication.topViewController() {
            topController.present(alert, animated: true, completion: nil)
        }
        
        /*
         if let rootView = UIApplication.shared.keyWindow?.rootViewController {
         rootView.present(alert, animated: true, completion: nil)
         }*/
        
        /*
         guard let _ = self.presentedViewController else {
         self.present(alert, animated: true, completion: nil)
         return
         }*/
        
        
    }
    
    func showCancelAutoRenewableSubscriptionsAlert() {
        let alert = UIAlertController(title: "How to cancel auto-renewable subscriptions",
                                      message: "As of Apple Guidelines you can cancel any of your auto-renewable subscriptions in the Settings app. Open the Settings app, scroll down and select 'iTunes & App Store', Sign in if already not signed in, tap on your Apple ID, tap on 'View Apple ID' in the alert, tap on 'Manage' and finally Cancel your auto-renewable-subcription.",
                                      preferredStyle: UIAlertControllerStyle.alert)
        /*
         let goAction = UIAlertAction(title: "Go To Settings", style: .default) { (self) in
         if #available(iOS 10.0, *) {
         guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
         return
         }
         
         if UIApplication.shared.canOpenURL(settingsUrl) {
         UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
         }
         
         } else {
         // Fallback on earlier versions
         UIApplication.shared.openURL(NSURL(string:UIApplicationOpenSettingsURLString)! as URL)
         }
         }*/
        
        let cancelAction = UIAlertAction(title: "Ok", style: .default) { (nil) in
            
        }
        
        //alert.addAction(goAction)
        alert.addAction(cancelAction)
        showAlert(alert)
    }
    
    /*
     func alertForProductRetrievalInfo(_ result: SwiftyStoreKit.RetrieveResults) -> UIAlertController {
     
     if let product = result.retrievedProducts.first {
     let numberFormatter = NumberFormatter()
     numberFormatter.locale = product.priceLocale
     numberFormatter.numberStyle = .currency
     let priceString = numberFormatter.string(from: product.price)
     return alertWithTitle(product.localizedTitle, message: "\(product.localizedDescription) - \(priceString)")
     }
     else if let invalidProductId = result.invalidProductIDs.first {
     return alertWithTitle("Could not retrieve product info", message: "Invalid product identifier: \(invalidProductId)")
     }
     else {
     let errorString = result.error?.localizedDescription ?? "Unknown error. Please contact support"
     return alertWithTitle("Could not retrieve product info", message: errorString)
     }
     }*/
    
    func saveRealPurchaseIntoRebeloperStoreKeychain(_ productId: String) {
        // save to keychain
        let bundleIDString = productId.range(of: "\(AppBundleId).")
        let key = productId[(bundleIDString?.upperBound)!..<productId.endIndex]
        
        // regular / non-consumable purchases
        var i = 0
        repeat {
            
            if key == RegularPurchases[i].rawValue {
                setRebeloperStoreKeychainAccount(KeychainValue.purchased.rawValue, key: String(key))
            }
            
            i = i + 1
        } while i < RegularPurchases.count
        
        // virtual currency purchases
        var j = 0
        repeat {
            
            if key == VirtualCurrencyPurchases[j].rawValue {
                changeVirtualCurrency(Int(VirtualCurrencyPurchasesAmount[j])!, ofVirtualCurrencyType: 0, completion: { (result, amount) in
                    print("Changed virtual currency")
                })
            }
            
            j = j + 1
        } while j < VirtualCurrencyPurchases.count
        
    }
    
    func alertForPurchaseResult(_ result: PurchaseResult) /*-> UIAlertController*/ {
        switch result {
        case .success(let purchaseResult):
            let productId = purchaseResult.productId
            print("Purchase Success: \(productId)")
            
            saveRealPurchaseIntoRebeloperStoreKeychain(productId)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: iAPStatusChanged), object: nil)
            
            self.showAlert(alertWithTitle("Thank You", message: "Purchase completed"))
        case .error(let error):
            print("Purchase Failed: \(error.code)")
            switch error.code {
            case .unknown:
                print("Unknown error. Please contact support")
                self.showAlert(alertWithTitle("Purchase failed", message: "Unknown error. Please contact support"))
            case .clientInvalid:
                print("Not allowed to make the payment")
                self.showAlert(alertWithTitle("Purchase failed", message: "Not allowed to make the payment"))
            case .paymentCancelled:
                self.showAlert(alertWithTitle("Purchase failed", message: "Purchase was canceled"))
                break
            case .paymentInvalid:
                print("The purchase identifier was invalid")
                self.showAlert(alertWithTitle("Purchase failed", message: "The purchase identifier was invalid"))
            case .paymentNotAllowed:
                print("The device is not allowed to make the payment")
                self.showAlert(alertWithTitle("Purchase failed", message: "The device is not allowed to make the payment"))
            case .storeProductNotAvailable:
                print("The product is not available in the current storefront")
                self.showAlert(alertWithTitle("Purchase failed", message: "The product is not available in the current storefront"))
            case .cloudServicePermissionDenied:
                print("Access to cloud service information is not allowed")
                self.showAlert(alertWithTitle("Purchase failed", message: "Access to cloud service information is not allowed"))
            case .cloudServiceNetworkConnectionFailed:
                print("Could not connect to the network")
                self.showAlert(alertWithTitle("Purchase failed", message: "Could not connect to the network"))
            case .cloudServiceRevoked:
                print("User has revoked permission to use this cloud service")
                self.showAlert(alertWithTitle("Purchase failed", message: "User has revoked permission to use this cloud service"))
            }
        }
    }
    
    func alertForRestorePurchases(_ results: RestoreResults) -> UIAlertController {
        
        if results.restoreFailedPurchases.count > 0 {
            print("Restore Failed: \(results.restoreFailedPurchases)")
            return alertWithTitle("Restore failed", message: "Unknown error. Please contact support")
        }
        else if results.restoredPurchases.count > 0 {
            print("Restore Success: \(results.restoredPurchases)")
            
            for i in 0 ... results.restoredPurchases.count - 1 {
                saveRealPurchaseIntoRebeloperStoreKeychain(results.restoredPurchases[i].productId)
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: iAPStatusChanged), object: nil)
            return alertWithTitle("Purchases Restored", message: "All purchases have been restored")
        }
        else {
            print("Nothing to Restore")
            return alertWithTitle("Nothing to restore", message: "No previous purchases were found")
        }
    }
    
    
    func alertForVerifyReceipt(_ result: VerifyReceiptResult) /*-> UIAlertController*/ {
        
        switch result {
        case .success(let receipt):
            print("Verify receipt Success: \(receipt)")
        //return alertWithTitle("Receipt verified", message: "Receipt verified remotly")
        case .error(let error):
            print("Verify receipt Failed: \(error)")
            
            switch (error) {
            case .noReceiptData :
                print("Receipt verification - No receipt data, application will try to get a new one. Try again.")
            //return alertWithTitle("Receipt verification", message: "No receipt data, application will try to get a new one. Try again.")
            default:
                print("Receipt verification - Receipt verification failed")
                //return alertWithTitle("Receipt verification", message: "Receipt verification failed")
            }
        }
    }
    /*
     func alertForVerifySubscription(_ result: SwiftyStoreKit.VerifySubscriptionResult) -> UIAlertController {
     
     switch result {
     case .purchased(let expiresDate):
     print("Product is valid until \(expiresDate)")
     return alertWithTitle("Product is purchased", message: "Product is valid until \(expiresDate)")
     case .expired(let expiresDate):
     print("Product is expired since \(expiresDate)")
     return alertWithTitle("Product expired", message: "Product is expired since \(expiresDate)")
     case .notPurchased:
     print("This product has never been purchased")
     return alertWithTitle("Not purchased", message: "This product has never been purchased")
     }
     }
     
     func alertForVerifyPurchase(_ result: SwiftyStoreKit.VerifyPurchaseResult) -> UIAlertController {
     
     switch result {
     case .purchased:
     print("Product is purchased")
     return alertWithTitle("Product is purchased", message: "Product will not expire")
     case .notPurchased:
     print("This product has never been purchased")
     return alertWithTitle("Not purchased", message: "This product has never been purchased")
     }
     }*/
    
    func alertForRefreshReceipt(_ result: FetchReceiptResult) /*-> UIAlertController*/ {
        switch result {
        case .success:
            print("Receipt refresh Success")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: iAPStatusChanged), object: nil)
        //return self.alertWithTitle("Receipt refreshed", message: "Receipt refreshed successfully")
        case .error(let error):
            print("Receipt refresh Failed: \(error)")
            //return self.alertWithTitle("Receipt refresh failed", message: "Receipt refresh failed")
        }
    }
    
    
}

class NetworkActivityIndicatorManager: NSObject {
    
    fileprivate static var loadingCount = 0
    
    class func networkOperationStarted() {
        
        if loadingCount == 0 {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        loadingCount += 1
    }
    
    class func networkOperationFinished() {
        if loadingCount > 0 {
            loadingCount -= 1
        }
        if loadingCount == 0 {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
}




/*
//
//  RebeloperStore.swift
//
//  Created by Alex Nagy on 22/09/2016.
//  Copyright © 2016 Rebeloper. All rights reserved.
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import StoreKit
import SwiftyStoreKit
import KeychainAccess


let AppBundleId = "HomePloyer.perSession"// Bundle.main.bundleIdentifier!
let mydateFormat = DateFormatter()

let iAPStatusChanged = "iAPStatusChanged"
let virtualPurchaseStatusChanged = "virtualPurchaseStatusChanged"

let keychain = Keychain(service: AppBundleId)
enum KeychainValue : String {
  
  case keychainAlreadyCreated = "keychainAlreadyCreated"
  case purchased = "purchased"
  case notPurchased = "notPurchased"
  case trueValue = "trueValue"
  case falseValue = "falseValue"
  case noValue = "noValue"
}

extension UIApplication {
  class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
    print(Bundle.main.bundleIdentifier!)
    print(AppBundleId)
    
    if let nav = base as? UINavigationController {
      return topViewController(base: nav.visibleViewController)
    }
    if let tab = base as? UITabBarController {
      if let selected = tab.selectedViewController {
        return topViewController(base: selected)
      }
    }
    if let presented = base?.presentedViewController {
      return topViewController(base: presented)
    }
    return base
  }
}

class RebeloperStore: UIViewController {
    

  static let shared = RebeloperStore()
   
 
    
    ///private init() {} //This prevents others from using the default '()' initializer for this class.
 ///comented this to add UIViewcontroller
    
    
  enum InfoType : String {
    case title = "title"
    case description = "description"
    case price = "price"
    
  }
  
  
  
  func start() {
    
    // swifty store
    SwiftyStoreKit.completeTransactions() { completedTransactions in
      
      for completedTransaction in completedTransactions {
        
        if completedTransaction.transactionState == .purchased || completedTransaction.transactionState == .restored {
          
          print("purchased: \(completedTransaction.productId)")
        }
      }
    }
    
    // keychain
    setupRebeloperStoreKeychainAccount()
    
    if shouldLogRebeloperStoreKeychainAccount {
      logRebeloperStoreKeychainAccount()
    }
    
  }
  
  func setupRebeloperStoreKeychainAccount() {
    
    if resetKeychainToDefaultValues {
      removeRebeloperStoreKeychainAccount()
    }
    
    
    // renewable purchases
   // var h = 0
    //repeat {
      
      if getRebeloperStoreKeychainAccountValue(RenewablePurchases[0].rawValue) == KeychainValue.noValue.rawValue {
        print("Key '\(RenewablePurchases[0].rawValue)' does not exist or is 'nil'. Setting it up now.")
        
        setRebeloperStoreKeychainAccount(KeychainValue.notPurchased.rawValue, key: RenewablePurchases[0].rawValue)
        
      }
      
     // h = h + 1
    //} while h < RenewablePurchases.count
    
    
  }
  
  func logRebeloperStoreKeychainAccount() {
    print("-------- Logging Rebeloper Store Keychain Account --------")
    
    print("-------- Non-Renewable Purchases --------")
    // renewable purchases
    //var g = 0
   // repeat {
      
      if getRebeloperStoreKeychainAccountValue(NonRenewablePurchases[0].rawValue) == KeychainValue.noValue.rawValue {
        print("Key '\(NonRenewablePurchases[0].rawValue)' does not exist or is 'nil'.")
      } else {
        print("[\(NonRenewablePurchases[0].rawValue) : \(getRebeloperStoreKeychainAccountValue(NonRenewablePurchases[0].rawValue))]")
      }
      
    //  g = g + 1
   // } while g < NonRenewablePurchases.count
    
    print("-------- Renewable Purchases --------")
    // renewable purchases
  //  var h = 0
   // repeat {
      
      if getRebeloperStoreKeychainAccountValue(RenewablePurchases[0].rawValue) == KeychainValue.noValue.rawValue {
        print("Key '\(RenewablePurchases[0].rawValue)' does not exist or is 'nil'.")
      } else {
        print("[\(RenewablePurchases[0].rawValue) : \(getRebeloperStoreKeychainAccountValue(RenewablePurchases[0].rawValue))]")
      }
      
    // h = h + 1
  //  } while h < RenewablePurchases.count
    
    
    print("-------- End of Rebeloper Store Keychain Account Log --------")
  }
  
  func getRebeloperStoreKeychainAccountValue(_ key: String) -> String {
    let value = try! keychain.getString(key)
    print("Getting data from key '\(key)' : \(String(describing: value))")
    
    if value != nil {
      return value!
    } else {
      return KeychainValue.noValue.rawValue
    }
    
    
  }
  
  func setRebeloperStoreKeychainAccount(_ value: String, key: String) {
    if let _ = try? keychain.getString(key) != nil {
      do {
        try keychain.set(value, key: key)
        //print("Setting data for key '\(key)' : \(value)")
      }
      catch let error {
        print(error)
      }
    } else {
      print("Couldn't create keychain token for '\(key)'")
    }
  }
  
  func removeRebeloperStoreKeychain(_ key: String) {
    if let _ = try? keychain.getString(key) {
      if let token = try? keychain.getString(key) != nil {
        
        do {
          try keychain.remove(key)
          print("Removing data at key '\(key)' : \(token)")
        } catch let error {
          print("error: \(error)")
        }
        
      } else {
        print("No data found to delete at key '\(key)'")
      }
    } else {
      print("No such key found to delete: '\(key)'")
    }
  }
  
  func removeRebeloperStoreKeychainAccount() {
    
    
    var h = 0
    repeat {
      removeRebeloperStoreKeychain(RenewablePurchases[h].rawValue)
      h = h + 1
    } while h < RenewablePurchases.count
    
    
    
  }
  
  
  
  
  func getRenewableInfo(_ purchase: RenewablePurchaseName, completion: @escaping (_ result: SKProduct) -> Void) {
    mydateFormat.dateFormat = DateFormatter.dateFormat(fromTemplate: " MMM d, yyyy", options: 0, locale: Locale.autoupdatingCurrent)!
   // mydateFormat.dateFormat = DateFormatter.dateFormat(fromTemplate: "MM/dd/yy"
     //   ,options: 0, locale: nil)!
    NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.retrieveProductsInfo([AppBundleId + "." + purchase.rawValue]) { result in
     NetworkActivityIndicatorManager.networkOperationFinished()
      
      if let product = result.retrievedProducts.first {
        
        completion(product)
        
      }
      else if let invalidProductId = result.invalidProductIDs.first {
        self.showAlert(self.alertWithTitle("Could not retrieve product info", message: "Invalid product identifier: \(invalidProductId)"))
      }
      else {
        let errorString = result.error?.localizedDescription ?? "Unknown error. Please contact support"
        self.showAlert(self.alertWithTitle("Could not retrieve product info", message: errorString))
      }
      
    }
  }
  
  func purchaseRenewable(_ purchase: RenewablePurchaseName) {
    
    NetworkActivityIndicatorManager.networkOperationStarted()
     print ("aa")
    SwiftyStoreKit.purchaseProduct("\(AppBundleId).\(purchase.rawValue)") { result in
    NetworkActivityIndicatorManager.networkOperationFinished()
   print ("bb")
      //self.showAlert(self.alertForPurchaseResult(result))
      self.alertForPurchaseResult(result)
    }
  }
  
  
  
  func restorePurchases() {
    
    NetworkActivityIndicatorManager.networkOperationStarted()
    SwiftyStoreKit.restorePurchases() { results in
      NetworkActivityIndicatorManager.networkOperationFinished()
      
      self.showAlert(self.alertForRestorePurchases(results))
    }
  }
  
  func verifyReceipt() {
    
    NetworkActivityIndicatorManager.networkOperationStarted()
    SwiftyStoreKit.verifyReceipt() { result in
      NetworkActivityIndicatorManager.networkOperationFinished()
      
      //self.showAlert(self.alertForVerifyReceipt(result))
      self.alertForVerifyReceipt(result)
      
      if case .error(let error) = result {
        if case .noReceiptData = error {
          self.refreshReceipt()
        }
      }
    }
  }
  
  
 //////////////check from add account/////////////////////////////////////////////
func verifyRenewablePurchase(_ purchase: RenewablePurchaseName, completion: @escaping (_ result: Bool, _ resutlString: String) -> Void) {
mydateFormat.dateFormat = DateFormatter.dateFormat(fromTemplate: " MMM d, yyyy", options: 0, locale: Locale.autoupdatingCurrent)!
NetworkActivityIndicatorManager.networkOperationStarted()
SwiftyStoreKit.verifyReceipt(password: SharedSecret, session: URLSession.shared) { (result) in
NetworkActivityIndicatorManager.networkOperationFinished()
    
switch result {
case .success(let receipt):

let productId = AppBundleId + "." + purchase.rawValue
print (productId)

///   var i = 0
///    repeat {

///if purchase == RenewablePurchases[0] {
print (purchase)
    
let purchaseResult = SwiftyStoreKit.verifySubscription(
productId: productId,
inReceipt: receipt,
validUntil: Date()
)
print (purchaseResult)

switch purchaseResult {
case .purchased(let expiresDate):
print("Product till'\(AppBundleId).\(expiresDate)")
completion(true, "Valid:\(mydateFormat.string(from: expiresDate))")

case .expired(let expiresDate):
print("Product expired '\(AppBundleId).\(expiresDate))")
completion(false, "Expired:\(mydateFormat.string(from: expiresDate))")
    
case .notPurchased:
print("Product '\(AppBundleId).\(purchase)' has never been purchased")
completion(false, "Not purchased")
}// end of switch purchaseResult
///}//end of if purchase
    
// /   i = i + 1
// /   } while i < RenewablePurchases.count

case .error(let error):
//self.showAlert(self.alertForVerifyReceipt(result))
self.alertForVerifyReceipt(result)
if case .noReceiptData = error {
self.refreshReceipt()
}
}//end of switch
}

}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  
  func refreshReceipt() {
    
    SwiftyStoreKit.refreshReceipt { (result) -> () in
      
      //self.showAlert(self.alertForRefreshReceipt(result))
      self.alertForRefreshReceipt(result)
    }
  }
    
    
    func pop(alert: UIAlertAction!){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view = storyboard.instantiateViewController(withIdentifier: "homeScreen") as UIViewController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        //show window
        appDelegate.window?.rootViewController = view
        
    }
  func alertWithTitle(_ title: String, message: String) -> UIAlertController {
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler:  self.pop))
    return alert
  }
    
    
  
  func showAlert(_ alert: UIAlertController) {
    
    if let topController = UIApplication.topViewController() {
    topController.present(alert, animated: true, completion: nil)
    }
    
   
    
    
    /*
    if let rootView = UIApplication.shared.keyWindow?.rootViewController {
      rootView.present(alert, animated: true, completion: nil)
    }*/
    
    /*
     guard let _ = self.presentedViewController else {
     self.present(alert, animated: true, completion: nil)
     return
     }*/
    
    
  }
  
  func showCancelAutoRenewableSubscriptionsAlert() {
    let alert = UIAlertController(title: "How to cancel auto-renewable subscriptions",
                                  message: "As of Apple Guidelines you can cancel any of your auto-renewable subscriptions in the Settings app. Open the Settings app, scroll down and select 'iTunes & App Store', Sign in if already not signed in, tap on your Apple ID, tap on 'View Apple ID' in the alert, tap on 'Manage' and finally Cancel your auto-renewable-subcription.",
                                  preferredStyle: UIAlertControllerStyle.alert)
    /*
    let goAction = UIAlertAction(title: "Go To Settings", style: .default) { (self) in
      if #available(iOS 10.0, *) {
        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
          return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
          UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
        }
      
      } else {
        // Fallback on earlier versions
        UIApplication.shared.openURL(NSURL(string:UIApplicationOpenSettingsURLString)! as URL)
      }
    }*/
    
    let cancelAction = UIAlertAction(title: "Ok", style: .default) { (nil) in
      
    }
    
    //alert.addAction(goAction)
    alert.addAction(cancelAction)
    showAlert(alert)
  }
  
  /*
   func alertForProductRetrievalInfo(_ result: SwiftyStoreKit.RetrieveResults) -> UIAlertController {
   
   if let product = result.retrievedProducts.first {
   let numberFormatter = NumberFormatter()
   numberFormatter.locale = product.priceLocale
   numberFormatter.numberStyle = .currency
   let priceString = numberFormatter.string(from: product.price)
   return alertWithTitle(product.localizedTitle, message: "\(product.localizedDescription) - \(priceString)")
   }
   else if let invalidProductId = result.invalidProductIDs.first {
   return alertWithTitle("Could not retrieve product info", message: "Invalid product identifier: \(invalidProductId)")
   }
   else {
   let errorString = result.error?.localizedDescription ?? "Unknown error. Please contact support"
   return alertWithTitle("Could not retrieve product info", message: errorString)
   }
   }*/
  
  
  
    func alertForPurchaseResult(_ result: SwiftyStoreKit.PurchaseResult) /*-> UIAlertController*/ {
    
    switch result {
    case .success(let productId):
      print("Purchase Success: \(productId)")
      NotificationCenter.default.post(name: NSNotification.Name(rawValue: iAPStatusChanged), object: nil)
      self.showAlert(alertWithTitle("Thank You", message: "Purchase completed"))
      
    case .error(let error):
      print("Purchase Failed: \(error)")
      
      switch error {
      case .failed(let error):
        
        if (error as NSError).domain == SKErrorDomain {
          self.showAlert(alertWithTitle("Purchase failed", message: "Please check your Internet connection or try again later"))
        }
        self.showAlert(alertWithTitle("Purchase failed", message: "Unknown error. Please contact support"))
      case .invalidProductId(let productId):
        self.showAlert(alertWithTitle("Purchase failed", message: "\(productId) is not a valid product identifier"))
      case .noProductIdentifier:
        self.showAlert(alertWithTitle("Purchase failed", message: "Product not found"))
      case .paymentNotAllowed:
        self.showAlert(alertWithTitle("Payments not enabled", message: "You are not allowed to make payments"))
      }
    }
  }
  
  func alertForRestorePurchases(_ results: SwiftyStoreKit.RestoreResults) -> UIAlertController {
    
    if results.restoreFailedProducts.count > 0 {
      print("Restore Failed: \(results.restoreFailedProducts)")
      return alertWithTitle("Restore failed", message: "Unknown error. Please contact support")
    }
    else if results.restoredProductIds.count > 0 {
      print("Restore Success: \(results.restoredProductIds)")
      
    ///  for i in 0 ... results.restoredProductIds.count - 1 {
   ///   }
      
      NotificationCenter.default.post(name: NSNotification.Name(rawValue: iAPStatusChanged), object: nil)
      return alertWithTitle("Purchases Restored", message: "All purchases have been restored")
    }
    else {
      print("Nothing to Restore")
      return alertWithTitle("Nothing to restore", message: "No previous purchases were found")
    }
  }
  
  
  func alertForVerifyReceipt(_ result: SwiftyStoreKit.VerifyReceiptResult) /*-> UIAlertController*/ {
    
    switch result {
    case .success(let receipt):
      print("Verify receipt Success: \(receipt)")
    //return alertWithTitle("Receipt verified", message: "Receipt verified remotly")
    case .error(let error):
      print("Verify receipt Failed: \(error)")
      
      switch (error) {
      case .noReceiptData :
        print("Receipt verification - No receipt data, application will try to get a new one. Try again.")
      //return alertWithTitle("Receipt verification", message: "No receipt data, application will try to get a new one. Try again.")
      default:
        print("Receipt verification - Receipt verification failed")
        //return alertWithTitle("Receipt verification", message: "Receipt verification failed")
      }
    }
  }
  /*
   func alertForVerifySubscription(_ result: SwiftyStoreKit.VerifySubscriptionResult) -> UIAlertController {
   
   switch result {
   case .purchased(let expiresDate):
   print("Product is valid until \(expiresDate)")
   return alertWithTitle("Product is purchased", message: "Product is valid until \(expiresDate)")
   case .expired(let expiresDate):
   print("Product is expired since \(expiresDate)")
   return alertWithTitle("Product expired", message: "Product is expired since \(expiresDate)")
   case .notPurchased:
   print("This product has never been purchased")
   return alertWithTitle("Not purchased", message: "This product has never been purchased")
   }
   }
   
   func alertForVerifyPurchase(_ result: SwiftyStoreKit.VerifyPurchaseResult) -> UIAlertController {
   
   switch result {
   case .purchased:
   print("Product is purchased")
   return alertWithTitle("Product is purchased", message: "Product will not expire")
   case .notPurchased:
   print("This product has never been purchased")
   return alertWithTitle("Not purchased", message: "This product has never been purchased")
   }
   }*/
  
  func alertForRefreshReceipt(_ result: SwiftyStoreKit.RefreshReceiptResult) /*-> UIAlertController*/ {
    switch result {
    case .success:
      print("Receipt refresh Success")
      NotificationCenter.default.post(name: NSNotification.Name(rawValue: iAPStatusChanged), object: nil)
      //return self.alertWithTitle("Receipt refreshed", message: "Receipt refreshed successfully")
    case .error(let error):
      print("Receipt refresh Failed: \(error)")
      //return self.alertWithTitle("Receipt refresh failed", message: "Receipt refresh failed")
    }
  }
  
  
}

class NetworkActivityIndicatorManager: NSObject {
  
  fileprivate static var loadingCount = 0
  
  class func networkOperationStarted() {
    
    if loadingCount == 0 {
      UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    loadingCount += 1
  }
  
  class func networkOperationFinished() {
    if loadingCount > 0 {
      loadingCount -= 1
    }
    if loadingCount == 0 {
      UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
  }
}
*/

