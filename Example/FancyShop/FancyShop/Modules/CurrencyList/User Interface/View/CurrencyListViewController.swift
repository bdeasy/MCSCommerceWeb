/* Copyright © 2019 Mastercard. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 =============================================================================*/

import Foundation
import UIKit

/// Shows the currency list
class CurrencyListViewController: BaseViewController, CurrencyListViewProtocol, UITableViewDataSource, UITableViewDelegate {
    
    
    /// MARK: Variables
    var presenter: CurrencyListPresenterProtocol?
    @IBOutlet weak var itemsTableView: UITableView!
    fileprivate let reuseIdentifier = "CurrencyTableViewCell"
    fileprivate var currencysArray: [String] = Constants.currencies.allValues
    var selectedCurrency: String!
    @IBOutlet weak var backButton: UIButton!
    
    /// Static method will initialize the view
    ///
    /// - Returns: CurrencyListViewController instance to be presented
    static func instantiate() -> Any{
        return UIStoryboard(name: "CurrencyList", bundle: nil).instantiateViewController(withIdentifier: "CurrencyListViewController") as! CurrencyListViewController
    }
    /// Overwritten method from UIVIewController, calls the presenter to get the required data
    ///
    /// - Parameter animated: animation flag
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter?.getCurrentCurrency()
        self.enableAccessibility()
    }
    
    /// Sets Identifiers
    private func enableAccessibility() {
        /* NOTE: Accessibility Identifier are going to remain same irrespective of the localization. Hence not accessing it using .strings file. It will be performance overhead at runtime. */
        //Set Identifiers
        self.backButton?.accessibilityIdentifier     = objectLocator.currencyListScreenStruct.backButton_Identifier
    }
    
    /// Ask the presenter to go back
    ///
    /// - Parameter sender: Any object
    @IBAction func goBackAction(_ sender: Any) {
        self.presenter?.goBack(true)
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currencysArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! CurrencyTableViewCell
        cell.accessoryType = UITableViewCell.AccessoryType.none
        let theCurrency: String = self.currencysArray[indexPath.row]
        if theCurrency == self.selectedCurrency{
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
        cell.currencyName.text = theCurrency
        cell.accessibilityIdentifier = objectLocator.currencyListScreenStruct.currency_Identifier + String(indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedCurrency = self.currencysArray[indexPath.row]
        self.presenter?.currencySelected(currency: self.selectedCurrency)
        tableView.reloadData()
    }
    
    // MARK: CurrencyListViewProtocol
    
    /// Sets the current currency and show it
    ///
    /// - Parameter currency: String with the currency
    func setCurrent(currency: String) {
        self.selectedCurrency = currency
    }
    
    
    
}
