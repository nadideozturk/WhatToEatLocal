//
//  EurekaFormExtension.swift
//  WhatToEatLocal
//
//  Created by Engin Ozturk on 2018-08-25.
//  Copyright © 2018 NadideOzturk. All rights reserved.
//

import Foundation
import Eureka

extension Form {
    
    @discardableResult
    public func isValid(includeHidden: Bool = false) -> Bool {
        let rowsToValidate = includeHidden ? allRows : rows
        return rowsToValidate.reduce(true) { res, row in
            var res = res
            res = res && row.isValid;
            return res
        }
    }
}
