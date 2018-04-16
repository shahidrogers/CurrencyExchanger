//
//  CurrencyDetailVC.swift
//  CurrencyExchangeExample
//
//  Created by Shahid Rogers on 16/04/2018.
//  Copyright © 2018 Shahid Rogers. All rights reserved.
//

import UIKit

class CurrencyDetailVC: UIViewController, UITextFieldDelegate {
    
    // MARK: - interface
    @IBOutlet var baseCurrencyNameLbl: UILabel!
    @IBOutlet var baseCurrencyRatesTF: UITextField!
    
    @IBOutlet var oppoCurrencyNameLbl: UILabel!
    @IBOutlet var oppoCurrencyRatesTF: UITextField!
    //to show 'loading' when fetching rates
    @IBOutlet var loadingLbl: UILabel!
    
    // MARK: - variable
    var currencyInfo: Currency!
    var baseCountryCode: String!
    var baseRates = "0"
    
    // MARK: - VC control
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set delegate for TF
        baseCurrencyRatesTF.delegate = self
        oppoCurrencyRatesTF.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //load info when view appear
        loadInfo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - method
    //preload data from previous VC
    func loadInfo() {
        
        baseCurrencyNameLbl.text = baseCountryCode
        baseCurrencyRatesTF.text = "1.00"
        
        oppoCurrencyNameLbl.text = currencyInfo.countryName
        oppoCurrencyRatesTF.text = String(currencyInfo.rates)
        
        //show loading text
        loadingLbl.text = "Loading \(currencyInfo.countryName) to \(baseCountryCode.description)"
        
        //Get the rates for base currency as well; to calc from opposite rates > base rates
        RequestManager.getOppositeCurrencyRate(oppositeCurrencyName: currencyInfo.countryName, baseCurrencyName: baseCountryCode, completion: { (rates) in
            
            //set rates
            self.baseRates = rates
            
            //hide loading lbl when donw
            self.loadingLbl.isHidden = true
            self.oppoCurrencyRatesTF.isEnabled = true
            
        }) { (error) in
            
            //show error if error
            let alert = UIAlertController(
                title: "Oops!",
                message: error,
                preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    
    //calc rates based on quantity - base > opposite
    func calcBaseToOppoCurrency(quantity: String) -> String {
        
        let calculated = Float(quantity)! * currencyInfo.rates
        
        return String(calculated)
    }
    
    //calc rates based on quantity - opposite > base
    func calcOppoToBaseCurrency(quantity: String) -> String {
        
        let calculated = Float(quantity)! * Float(baseRates)!
        
        return String(calculated)
    }
    
    // MARK: - TF delegation
    //dismiss keyboard when other ares are touched
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //when something is type in the Textfield
    @IBAction func editedTF(_ sender: Any) {
        
        let textField = sender as! UITextField
        
        //if its the base currency TF or opposite currency TF
        if textField == baseCurrencyRatesTF && !(textField.text?.isEmpty)! {
            oppoCurrencyRatesTF.text = calcBaseToOppoCurrency(quantity: textField.text!)
        } else if textField == oppoCurrencyRatesTF && !(textField.text?.isEmpty)! {
            baseCurrencyRatesTF.text = calcOppoToBaseCurrency(quantity: textField.text!)
        }
    }
}

