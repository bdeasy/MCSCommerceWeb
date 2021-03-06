//
//  Configuration.swift
//  Merchant Checkout App
//
//  Created by MasterCard on 10/12/17.
//  Copyright © 2018 MasterCard. All rights reserved.
//

import Foundation
import MCSCommerceWeb

/// SDK Configuration, handles all the changes made in the setting screens
class SDKConfiguration: NSObject, NSCoding{
    // MARK: Variables
    
    /// CardConfiguration array
    var cards: [CardConfiguration]
    
    /// Selected Language
    var language: String
    
    /// Selected Currency
    var currency: String
    
    /// Suppress shippping flag
    var suppressShipping: Bool
    
    /// Suppress 3DS flag
    var suppress3DS: Bool
    
    /// Enable express checkout flag
    var enableExpressCheckout: Bool
    
    /// Enable web express checkout flag
    var enablePairingWithCheckout: Bool
    
    /// DSRP Array (Tokenization)
    var DSRPs: [DSRP]
    
    /// Enable Checkout With PaymentMethod flag.(If Disabled then checkout with Masterpass Button)
    var enablePaymentMethodCheckout: Bool
    
    /// Singleton instance of SDKConfiguration
    static let sharedInstance : SDKConfiguration = {
        if let instance = DataPersisterManager.sharedInstance.getConfiguration() {
            return instance
        }
        return SDKConfiguration()
    }()
    
    // MARK: Initializers
    /// Private intitializer
    private override init() {
        self.cards = []
        // Cards
        for name in Constants.cardsEnum.allValues {
            let tempCard = CardConfiguration.init(withName: name)
            self.cards.append(tempCard)
        }
        //Language
        self.language = Constants.languages.English_UK
        //Currency
        self.currency = Constants.currencies.USD
        //Supress Shipping
        self.suppressShipping = false
        //Supress 3DS
        self.suppress3DS = true
        //Enable Express Checkout
        self.enableExpressCheckout = false
        //Init Web Express Checkout
        self.enablePairingWithCheckout = false
        //Enable Payment Method Checkout
        self.enablePaymentMethodCheckout = false
        //DSRP's
        self.DSRPs = []
        for dsrp in Constants.DSRPEnum.allValues {
            let tempDSRP = DSRP.init(withName: dsrp)
            self.DSRPs.append(tempDSRP)
        }
        super.init()
    }
    
    // MARK: Methods
    /// Saves the configuration
    func saveConfiguration(){
        DataPersisterManager.sharedInstance.saveConfiguration()
    }
    
    /// Sets the new language as selected
    ///
    /// - Parameter language: Selected language
    func setLanguage(language: String) {
        self.language = language
        self.saveConfiguration()
    }
    
    /// Saves the selected currency as the current one
    ///
    /// - Parameter currency: Selected currency
    func setCurrency(currency: String) {
        self.currency = currency
        self.saveConfiguration()
    }
    
    /// Returns the currency code, based on the selected currency
    ///
    /// - Returns: String Currency code
    func getCurrencyCode() -> String {
        switch self.currency {
        case Constants.currencies.USD:
            return "USD"
        case Constants.currencies.INR:
            return "INR"
        case Constants.currencies.UKPound:
            return "GBP"
        case Constants.currencies.CAD:
            return "CAD"
        default:
            return""
        }
    }
    
    /// Returns the currency number, based on the selected currency
    ///
    /// - Returns: String Currency number
    func getCurrencyNumber() -> String {
        switch self.currency {
        case Constants.currencies.USD:
            return "840"
        case Constants.currencies.INR:
            return "356"
        case Constants.currencies.UKPound:
            return "826"
        case Constants.currencies.CAD:
            return "124"
        default:
            return""
        }
    }
    
    /// Returns the currency code, based on the selected currency
    ///
    /// - Returns: String Currency code
    func getCurrencySymbol() -> String {
        switch self.currency {
        case Constants.currencies.USD:
            return Constants.currenciesSymbols.DOLLAR
        case Constants.currencies.INR:
            return Constants.currenciesSymbols.RUPEE
        case Constants.currencies.UKPound:
            return Constants.currenciesSymbols.POUND
        case Constants.currencies.CAD:
            return Constants.currenciesSymbols.DOLLAR
        default:
            return""
        }
    }
    
    /// Returns a set of cards allowed to configure the SDK
    ///
    /// - Returns: MCCCardType set
    func getAllowedCardsSet() -> Set<MCCCardType>{
        var allowedCardsSet = Set<MCCCardType>()
        for card:CardConfiguration in self.cards {
            if card.isSelected{
                switch card.name{
                case Constants.cardsEnum.American:
                    allowedCardsSet.insert(MCCCardType(type: MCCCard.AMEX)!)
                case Constants.cardsEnum.Discover:
                    allowedCardsSet.insert(MCCCardType(type: MCCCard.DISCOVER)!)
                case Constants.cardsEnum.MasterCard:
                    allowedCardsSet.insert(MCCCardType(type: MCCCard.MASTER)!)
                case Constants.cardsEnum.VISA:
                    allowedCardsSet.insert(MCCCardType(type: MCCCard.VISA)!)
                case Constants.cardsEnum.Maestro:
                    allowedCardsSet.insert(MCCCardType(type: MCCCard.MAESTRO)!)
                case Constants.cardsEnum.DinersClub:
                    allowedCardsSet.insert(MCCCardType(type: MCCCard.DINERS)!)
                }
            }
        }
        return allowedCardsSet
    }
    
    // NOTE: Revisit the code according to the following.
    // In the SDK, Locale is used for two purposes:
    // (1) Identifies the locale (language) in which the Merchant application is running & instructs SDK to use the same language if supported by SDK.
    // (2) Identifies the region in which the user is using the application which will decide if the MEX flow will trigger or not when Masterpass button is clicked.
    
    /// Returns a locale based in the selected language
    ///
    /// - Returns: Locale instance to configure the SDK
    func getLocaleFromSelectedLanguage() -> Locale{
        var locale: Locale
        switch self.language {
        case Constants.languages.English_UK:
            locale =  Locale.init(identifier: "en_UK")
        case Constants.languages.Portuguese_BR:
            locale =  Locale.init(identifier: "pt_BR")
        case Constants.languages.Spanish_MX:
            locale =  Locale.init(identifier: "es_MX")
        case Constants.languages.English_CA:
            locale =  Locale.init(identifier: "en_CA")
        case Constants.languages.English_IN:
            locale =  Locale.init(identifier: "en_IN")
        case Constants.languages.English_TH:
            locale =  Locale.init(identifier: "en_TH")
        case Constants.languages.French_CA:
            locale =  Locale.init(identifier: "fr_CA")
        case Constants.languages.Spanish_AR:
            locale =  Locale.init(identifier: "es_AR")
        case Constants.languages.Spanish_CO:
            locale =  Locale.init(identifier: "es_CO")
        case Constants.languages.English_HK:
            locale =  Locale.init(identifier: "en_HK")
        case Constants.languages.English_SG:
            locale =  Locale.init(identifier: "en_SG")
        case Constants.languages.English_PH:
            locale =  Locale.init(identifier: "en_PH")
        case Constants.languages.English_MY:
            locale =  Locale.init(identifier: "en_MY")
        case Constants.languages.English_AU:
            locale =  Locale.init(identifier: "en_AU")
        case Constants.languages.English_NZ:
            locale =  Locale.init(identifier: "en_NZ")
        default:
            locale =  Locale.init(identifier: "en_US")
        }
        return locale
    }
    
    
    /// Validates if at least one card is selected
    ///
    /// - Returns: Boolean, indicating if at least one card is selected
    func isCardSelected() -> Bool{
        for card in self.cards {
            if card.isSelected{
                return true
            }
        }
        return false
    }
    
    //MARK: NSCoding
    
    /// NSCoding Initializer
    ///
    /// - Parameters:
    ///   - coder: NSCoder instance
    internal required init?(coder aDecoder: NSCoder) {
        self.cards = aDecoder.decodeObject(forKey: "cards") as! [CardConfiguration]
        self.language = aDecoder.decodeObject(forKey:"language") as! String
        self.currency = aDecoder.decodeObject(forKey: "currency") as! String
        self.suppressShipping = aDecoder.decodeBool(forKey: "supressShipping")
        self.suppress3DS = aDecoder.decodeBool(forKey: "suppress3DS")
        self.enableExpressCheckout = aDecoder.decodeBool(forKey: "enableExpressCheckout")
        self.enablePairingWithCheckout = aDecoder.decodeBool(forKey: "enablePairingWithCheckout")
        self.enablePaymentMethodCheckout = aDecoder.decodeBool(forKey: "enablePaymentMethodCheckout")
        self.DSRPs = aDecoder.decodeObject(forKey: "DSRPs") as! [DSRP]
        super.init()
    }
    
    
    /// NSCoding Method
    ///
    /// - Parameter aCoder: NSCoder instance
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.cards, forKey:"cards")
        aCoder.encode(self.language, forKey:"language")
        aCoder.encode(self.currency, forKey:"currency")
        aCoder.encode(self.suppressShipping, forKey:"supressShipping")
        aCoder.encode(self.suppress3DS, forKey:"suppress3DS")
        aCoder.encode(self.enableExpressCheckout, forKey: "enableExpressCheckout")
        aCoder.encode(self.enablePairingWithCheckout, forKey: "enablePairingWithCheckout")
        aCoder.encode(self.enablePaymentMethodCheckout, forKey: "enablePaymentMethodCheckout")
        aCoder.encode(self.DSRPs, forKey: "DSRPs")
    }
}
