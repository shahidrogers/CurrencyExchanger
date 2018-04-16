//
//  Currency.swift
//  CurrencyExchangeExample
//
//  Created by Shahid Rogers on 16/04/2018.
//  Copyright © 2018 Shahid Rogers. All rights reserved.
//

import Foundation

//currency object
class Currency {
    
    var countryName: String
    var rates: Float
    
    public init(countryName: String, rates: Float) {
        self.countryName = countryName
        self.rates = rates
    }
}

