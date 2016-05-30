//
//  GCD.swift
//  Virtual Travel
//
//  Created by Unathi Chonco on 2016/05/30.
//  Copyright © 2016 Unathi Chonco. All rights reserved.
//

import Foundation

func performUpdateOnMain(updates: () -> Void){
    dispatch_async(dispatch_get_main_queue()){
        updates()
    }
}

