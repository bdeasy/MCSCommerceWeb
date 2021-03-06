//
//  OrderSummaryView.swift
//  MerchantCheckoutApp
//
//  Created by MasterCard on 10/08/2017.
//  Copyright © 2018 MasterCard. All rights reserved.
//

import Foundation
import UIKit
import MCSCommerceWeb
/// Shows the resume of the order, products, total, subtotal and taxes
class OrderSummaryViewController: BaseViewController, OrderSummaryViewProtocol, UITableViewDataSource, UITableViewDelegate{
    
    
    // MARK: variables
    var presenter: OrderSummaryPresenterProtocol?
    var masterPassButton : MCCMasterpassButton?;
    @IBOutlet weak var itemsTableView: UITableView!
    @IBOutlet weak var shoppingCartButton: ShoppingCartButton!
    @IBOutlet weak var taxesLabel: UILabel!
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var buttonContainer: UIView!
    @IBOutlet weak var shippingView: UIView!
    @IBOutlet weak var shippingViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var checkoutButton: UIButton!
    @IBOutlet weak var paymentMethodButton: UIButton!
    @IBOutlet weak var paymentMethodLabel: UILabel!
    @IBOutlet weak var checkoutButtonContainerHeightConstraint: NSLayoutConstraint!
    
    fileprivate var items: [ShoppingCartItem] = []
    fileprivate let reuseIdentifier = "shoppingCartItemCell"
    fileprivate let minimunHeight:Int = 200
    fileprivate let minimunTablewViewHeight:Int = 80
    fileprivate let checkoutButtonContainerMinHeight:Int = 80
    fileprivate let checkoutButtonContainerMaxHeight:Int = 150
    
    /// Static method will initialize the view
    ///
    /// - Returns: ConfirmOrderViewController instance to be presented
    static func instantiate() -> Any{
        return UIStoryboard(name: "OrderSummary", bundle: nil).instantiateViewController(withIdentifier: "OrderSummaryViewController") as! OrderSummaryViewController
    }
    /// Overwritten method from UIVIewController, sets the constraints for the required views
    override func viewDidLoad() {
        super.viewDidLoad()
        self.itemsTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.itemsTableView.frame.size.width, height: 1))
    }
    
    /// Overwritten method from UIVIewController, calls the presenter to get the required data
    ///
    /// - Parameter animated: animation flag
    override func viewWillAppear(_ animated: Bool) {
        self.set(shippingStatus: true)
        super.viewWillAppear(animated)
        self.presenter?.requestShoppingCartViewConfiguration()
        self.presenter?.fetchItemsFromShoppingCart()
        self.presenter?.getCheckoutButton()
    }
    /// Ask the presenter to go back
    ///
    /// - Parameter sender: Any object
    @IBAction func goBackAction(_ sender: Any) {
        self.presenter?.goBackToProductList(animated: true)
    }
    
    /// Sets the number of products on the cart
    ///
    /// - Parameter quantity: number of products
    func showQuantityOfProductsInCartButton(quantity: Int) {
        self.shoppingCartButton.setBadgeText(numberOfItems: quantity)
    }
    
    /// Reloads the data of the view
    override func reloadData() {
        self.itemsTableView.reloadData()
    }
    
    ///setup checkout Button container view
    func updateContainerUI(isPaymentMethodCheckout: Bool) {
        checkoutButtonContainerHeightConstraint.constant = isPaymentMethodCheckout ? CGFloat(checkoutButtonContainerMaxHeight) : CGFloat(checkoutButtonContainerMinHeight)
    }
    
    /// Returns the ShoppingCartItem and the given index
    ///
    /// - Parameter index: index to get the ShoppingCartItem
    /// - Returns: ShoppingCartItem object
    fileprivate func getShoppingCartItemFromListUsingIndex(index: Int) -> ShoppingCartItem{
        return self.items[index]
    }
    
    // MARK: Action Methods
    /// Decreases the number of a product in the item
    ///
    /// - Parameter sender: UIButton
    @IBAction func lessItemsOfProductAction(_ sender: UIButton) {
        super.animateView(view: self.shoppingCartButton, duration: 0.5)
        let index: Int = self.getIndexPathFromCellUsingButton(sender, 3)
        self.presenter?.lessProductQuantityAction(product: self.getShoppingCartItemFromListUsingIndex(index: index).product)
    }
    
    /// Increases the number of a product in the item
    ///
    /// - Parameter sender: UIButton
    @IBAction func moreItemsOfProductAction(_ sender: UIButton) {
        super.animateView(view: self.shoppingCartButton, duration: 0.5)
        let index: Int = self.getIndexPathFromCellUsingButton(sender, 3)
        self.presenter?.moreProductQuantityAction(product: self.getShoppingCartItemFromListUsingIndex(index: index).product)
    }
    
    /// Removes all the products and the item of the cart
    ///
    /// - Parameter sender: UIButton
    @IBAction func removeProductFromShoppingCartAction(_ sender: UIButton) {
        super.animateView(view: self.shoppingCartButton, duration: 0.5)
        let index: Int = self.getIndexPathFromCellUsingButton(sender, 2)
        self.presenter?.removeProductAction(product: self.getShoppingCartItemFromListUsingIndex(index: index).product)
    }
    
    /// Calls the presenter to do a express checkout
    ///
    /// - Parameter sender: Any view
    @IBAction func expressCheckoutAction(_ sender: Any) {
        self.presenter?.expressCheckoutButtonAction()
    }
    
    /// Calls the presenter to trigger payment Method view
    ///
    /// - Parameter sender: Any view
    @IBAction func paymetMethodSelectionAction(_ sender: Any) {
        self.presenter?.paymentMethodSelectionButtonAction()
    }
    
    
    /// Gets the index from a given button
    ///
    /// - Parameters:
    ///   - sender: UIButton
    ///   - levels: Levels to do the search
    /// - Returns: Index
    fileprivate func getIndexPathFromCellUsingButton(_ sender: UIButton, _ levels: Int) -> Int{
        var i = 0
        var superview: UIView = sender.superview!
        while i < levels-1 {
            superview = superview.superview!
            i += 1
        }
        let cell: ItemViewCell = superview as! ItemViewCell
        if let indexPath: NSIndexPath = self.itemsTableView.indexPath(for: cell) as NSIndexPath? {
            return indexPath.row
        }
        return -1;
    }
    // MARK: OrderSummaryViewProtocol
    
    /// Shows the items in the cart
    ///
    /// - Parameter items: ShoppingCartItem array
    func showItemsInCart(items: [ShoppingCartItem]) {
        self.items = items
        self.reloadData()
    }
    
    /// Shows an error in an alert
    ///
    /// - Parameter error: String with the error
    func showError(error: String) {
        super.showErrorInAlert(message: error, title: "") { (void) in
            self.presenter?.goBackToProductList(animated: true)
        }
    }
    
    /// Shows an alert if no paymentMethod is added
    ///
    /// - Parameter error: String with the alertMsg
    func showAddPaymentMethodAlert(alertMsg: String) {
        super.showErrorInAlert(message: alertMsg, title: "")
    }
    
    /// Shows the taxes
    ///
    /// - Parameter taxes: String with the taxes value
    func set(taxes: String) {
        self.taxesLabel.text = taxes
    }
    /// Shows the subtotal
    ///
    /// - Parameter subtotal: String with the subtotal value
    func set(subtotal: String) {
        self.subtotalLabel.text = subtotal
    }
    /// Shows the total
    ///
    /// - Parameter total: String with the total value
    func set(total: String) {
        self.totalLabel.text = total
    }
    
    /// Adds the Masterpass button in the view
    func showMCCButton() {
        self.updateContainerUI(isPaymentMethodCheckout: false)
        if self.checkoutButton != nil {
            self.checkoutButton.removeFromSuperview()
        }
        if self.paymentMethodButton != nil {
            self.paymentMethodButton.removeFromSuperview()
        }
        self.masterPassButton?.removeFromSuperview()
        self.masterPassButton = nil
        self.masterPassButton = MasterpassSDKManager.sharedInstance.getMasterPassButton()
        
        if self.masterPassButton != nil {
            self.masterPassButton?.add(to: self.buttonContainer)
        }
    }
    
    /// Shows a spinner in the view
    func startAnimating() {
//        super.startAnimating()
    }
    
    /// Dimisses the spinner from the view
    func stopAnimating() {
//        super.stopAnimating()
    }
    
    /// Sets the shipping status and adjust the view according to it
    ///
    /// - Parameter shippingStatus: Boolean
    func set(shippingStatus: Bool) {
        self.shippingView.isHidden = shippingStatus
        if shippingStatus {
            self.shippingViewHeightConstraint.constant = 0
        }else{
            self.shippingViewHeightConstraint.constant = 50
        }
    }
    
    /// Removes the Masterpass button and shows the normal button for a express checkout
    func showExpressCheckoutButton() {
        self.updateContainerUI(isPaymentMethodCheckout: false)
        
        if self.paymentMethodButton != nil {
            self.paymentMethodButton.removeFromSuperview()
        }
        self.masterPassButton?.removeFromSuperview()
    }
    
    /// Removes the Masterpass button and shows the normal button for a payment checkout
    func showPaymentMethodCheckoutButton() {
        self.masterPassButton?.removeFromSuperview()
        self.paymentMethodButton.isHidden = false;
        if let paymentMethodObject = PaymentMethod.sharedInstance.paymentMethodObject {
           self.paymentMethodButton.titleLabel?.textAlignment = .center
            if let paymentMethodLastFourDigits = paymentMethodObject.paymentMethodLastFourDigits {
                self.paymentMethodButton.setTitle((paymentMethodObject.paymentMethodName + paymentMethodLastFourDigits), for: .normal)
            }
            //TODO: We are using MasterPass as PaymentMethod, So Logo should be dynamic as per paymentMethod selected.
           let mpassLogo = UIImage(named: "masterpasLogo")
           self.paymentMethodButton.setImage(mpassLogo, for: .normal)
           self.paymentMethodLabel.isHidden =  false;
        } else {
            self.paymentMethodButton.titleLabel?.textAlignment = .center
            self.paymentMethodButton.setTitle("Payment Method >", for: .normal)
            self.paymentMethodButton.setImage(nil, for: .normal)
            self.paymentMethodLabel.isHidden = true;
        }
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ItemViewCell
        let shoppingCartItem: ShoppingCartItem = self.getShoppingCartItemFromListUsingIndex(index: indexPath.row)
        let theProduct: Product = shoppingCartItem.product
        cell.productImage.image = UIImage.init(named: (theProduct.imagePath as NSString).lastPathComponent, in: nil, compatibleWith: nil)
        cell.productName.text = theProduct.name
        cell.productQuantity.text = String(shoppingCartItem.quantity)
        cell.productSalePrice.text = SDKConfiguration.sharedInstance.getCurrencySymbol() + String(format: "%.02f", theProduct.salePrice * Double(shoppingCartItem.quantity))

        return cell
    }
}
