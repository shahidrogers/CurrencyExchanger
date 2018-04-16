//
//  RequestManager.swift
//  CurrencyExchangeExample
//
//  Created by Shahid Rogers on 16/04/2018.
//  Copyright © 2018 Shahid Rogers. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

let link = "https://api.fixer.io/latest"

class RequestManager {
    
    //get currency list from api
    class func requestCurrencyList(baseCountry: String, completion: @escaping (_ currencylist: [Currency], _ countrylist: [String]) -> Void, error: @escaping (_ error: String) -> Void) {
        
        //set para
        let parameters: Parameters = [
            "base" : baseCountry
        ]
        
        //set link
        let url = link
        
        //use alamo wrapper to get json data
        Alamofire.request(url, method:.get, parameters:parameters).responseJSON { response in
            switch response.result {
                
            //if sucess
            case .success:
                
                print(response)
                
                //swiftyjson to decode data to json
                let json = JSON(data: response.data!)
                
                //if json object exist, and return success with correct json object
                if (json["error"].string == nil) {
                    
                    var currencyArray = [Currency]()
                    var countryArray = [String]()
                    
                    //open json rates child
                    let temp = json["rates"].dictionary
                    for tempItem in temp! {
                        let currencyInfo = tempItem
                        
                        //save to object
                        let currencyItem = Currency(countryName: currencyInfo.key, rates: currencyInfo.value.float!)
                        
                        currencyArray.append(currencyItem)
                        countryArray.append(currencyInfo.key)
                    }
                    
                    //return proccessed array
                    completion(currencyArray, countryArray)
                    
                } else {
                    //return error from sucessful json object
                    error(json["error"].string!)
                }
                
            //if error
            case .failure(let Error):
                //return error
                error(Error.localizedDescription)
            }
        }
    }
    
    //get opposite rates as base for converting at the currency detail page
    class func getOppositeCurrencyRate(oppositeCurrencyName: String, baseCurrencyName: String, completion: @escaping (_ rates: String) -> Void, error: @escaping (_ error: String) -> Void) {
        
        //set para
        let parameters: Parameters = [
            "base" : oppositeCurrencyName,
            "symbols" : baseCurrencyName
        ]
        
        //set link
        let url = link
        
        //use alamo wrapper to get json data
        Alamofire.request(url, method:.get, parameters:parameters).responseJSON { response in
            switch response.result {
                
            //if sucess
            case .success:
                
                print(response)
                
                //swiftyjson to decode data to json
                let json = JSON(data: response.data!)
                
                //if json object exist, and return success with correct json object
                if (json["error"].string == nil) {
                    
                    //open json rates child
                    let temp = json["rates"][baseCurrencyName].stringValue
                    
                    //return proccessed
                    completion(temp)
                    
                } else {
                    //return error from sucessful json object
                    error(json["error"].string!)
                }
                
            //if error
            case .failure(let Error):
                //return error
                error(Error.localizedDescription)
            }
        }
    }
}

