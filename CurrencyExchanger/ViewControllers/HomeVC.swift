//
//  ViewController.swift
//  CurrencyExchangeExample
//
//  Created by Shahid Rogers on 16/04/2018.
//  Copyright © 2018 Shahid Rogers. All rights reserved.
//

import UIKit

class HomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UISearchBarDelegate {
    
    // MARK: - interface
    @IBOutlet var currencyListTVC: UITableView!
    @IBOutlet var currencySearchBar: UISearchBar!
    
    // MARK: - variable
    //currency list
    var currencyArray = [Currency]()
    var displayCurrencyArray = [Currency]()
    
    //country list
    var countryArray = [String]()
    var displayCountryArray = [String]()
    
    //current country code (base)
    var countryCode = "MYR"
    
    //pull to refresh
    let refreshControl = UIRefreshControl()
    
    /////////
    //popup
    /////////
    //searchbar in popup
    var popupSearchBar = UISearchBar()
    //picker in popup
    var popupPickerView = UIPickerView()
    
    // MARK: - VC
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //step 1: init tableview
        TVCinit()
        
        //step 2: get currency list
        getCurrencyList()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //go to currency detail VC
        if segue.identifier == "currencyDetail_segue" {
            if let currencyDetailVC = segue.destination as? CurrencyDetailVC {
                let currencyInfo = sender as! Currency
                currencyDetailVC.currencyInfo = currencyInfo
                currencyDetailVC.baseCountryCode = countryCode
            }
        }
    }
    
    //dismiss keyboard when other areas are touched
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currencySearchBar.endEditing(true)
    }
    
    // MARK: - method
    func getCurrencyList() {
        
        //request list of currencies
        RequestManager.requestCurrencyList(baseCountry: countryCode, completion: { (currencyList, countryList) in
            
            //if success
            self.currencyArray = currencyList
            self.countryArray = countryList
            
            self.refreshControl.endRefreshing()
            
            self.displayCurrencyArray = currencyList
            self.displayCountryArray = countryList
            
            self.currencyListTVC.reloadData()
            
        }) { (error) in
            
            //if fail show error
            self.refreshControl.endRefreshing()
            
            let alert = UIAlertController(
                title: "Opps!",
                message: error,
                preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    //pull tableview down to refresh list
    @objc func refreshCurrencyData(_ sender: Any) {
        getCurrencyList()
    }
    
    //search filter for currency (search bar)
    func searchCurrency(searchText: String) -> [Currency] {
        
        let fliteredArray = currencyArray.filter() { $0.countryName.contains(searchText) }
        
        return fliteredArray
    }
    
    //search filter for country(search bar popup)
    func searchCountry(searchText: String) -> [String] {
        
        let fliteredArray = countryArray.filter() { $0.contains(searchText) }
        
        return fliteredArray
    }
    
    // MARK: - search bar delegation
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar == currencySearchBar {
            
            print("search text: " + searchText)
            
            guard !searchText.isEmpty else {
                
                displayCurrencyArray = currencyArray
                currencyListTVC.reloadData()
                
                return
            }
            
            displayCurrencyArray = searchCurrency(searchText: searchText)
            currencyListTVC.reloadData()
            
        } else if searchBar == popupSearchBar {
            
            print("search text: " + searchText)
            
            guard !searchText.isEmpty else {
                
                displayCountryArray = countryArray
                popupPickerView.reloadAllComponents()
                
                return
            }
            
            displayCountryArray = searchCountry(searchText: searchText)
            popupPickerView.reloadAllComponents()
            
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)  {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - pickerview delegation
    // The number of columns of data
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return displayCountryArray.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return displayCountryArray[row]
    }
    
    //if selected
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        countryCode = displayCountryArray[row]
    }
    
    // MARK: - tableview delegation
    func TVCinit() {
        self.currencyListTVC.delegate = self
        self.currencyListTVC.dataSource = self
        
        if #available(iOS 10.0, *) {
            currencyListTVC.refreshControl = refreshControl
        } else {
            currencyListTVC.addSubview(refreshControl)
        }
        
        currencySearchBar.delegate = self;
        currencySearchBar.autocapitalizationType = .allCharacters
        
        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshCurrencyData(_:)), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching currency ...", attributes: nil)
        
        //animate manually to show loading
        currencyListTVC.setContentOffset(CGPoint(x:0, y:currencyListTVC.contentOffset.y - (refreshControl.frame.size.height)), animated: true)
        
        refreshControl.beginRefreshing()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayCurrencyArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //display cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_currency", for: indexPath)
        
        let listItem = displayCurrencyArray[indexPath.row]
        
        cell.textLabel?.text = listItem.countryName
        cell.detailTextLabel?.text = String(listItem.rates)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        //go next page after selected currency
        performSegue(withIdentifier: "currencyDetail_segue", sender: displayCurrencyArray[indexPath.row])
    }
    
    // MARK: - button
    @IBAction func editBaseCurrencyBtnC(_ sender: Any) {
        
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250,height: 300)
        
        //show searchbar view in popup
        popupSearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 250, height: 44))
        
        popupSearchBar.delegate = self
        
        vc.view.addSubview(popupSearchBar)
        
        //show picker view in popup
        popupPickerView = UIPickerView(frame: CGRect(x: 0, y: popupSearchBar.frame.height, width: 250, height: 256))
        
        popupPickerView.delegate = self
        popupPickerView.dataSource = self
        
        vc.view.addSubview(popupPickerView)
        
        //init popup
        let alert = UIAlertController(
            title: "Change base currency code",
            message: "",
            preferredStyle: .alert)
        
        alert.setValue(vc, forKey: "contentViewController")
        
        //autolayout constraint for searchbar
        let cons4: NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.greaterThanOrEqual, toItem: popupSearchBar, attribute: NSLayoutAttribute.height, multiplier: 1.00, constant: 130)
        
        let cons3: NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.greaterThanOrEqual, toItem: popupSearchBar, attribute: NSLayoutAttribute.width, multiplier: 1.00, constant: 20)
        
        alert.view.addConstraint(cons4)
        alert.view.addConstraint(cons3)
        
        //autolayout constraint for pickerview
        let cons:NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.greaterThanOrEqual, toItem: popupPickerView, attribute: NSLayoutAttribute.height, multiplier: 1.00, constant: 130)
        
        let cons2:NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.greaterThanOrEqual, toItem: popupPickerView, attribute: NSLayoutAttribute.width, multiplier: 1.00, constant: 20)
        
        alert.view.addConstraint(cons)
        alert.view.addConstraint(cons2)
        
        //popup btn
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (_) in
            
            if (self.countryCode.characters.count) > 0 {
                
                self.getCurrencyList()
                self.title = self.countryCode
                
                //animate manually to show loading
                self.currencyListTVC.setContentOffset(CGPoint(x:0, y:self.currencyListTVC.contentOffset.y - (self.refreshControl.frame.size.height)), animated: true)
                
                self.refreshControl.beginRefreshing()
                
            }
            
        }))
        
        //show popup
        self.present(alert, animated: true, completion: nil)
    }
    
}

