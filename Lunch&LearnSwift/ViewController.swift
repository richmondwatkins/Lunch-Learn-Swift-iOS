//
//  ViewController.swift
//  Lunch&LearnSwift
//
//  Created by Richmond Watkins on 6/3/15.
//  Copyright (c) 2015 Richmond Watkins. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        APIManger.requestNewData({ (locations) -> Void in
            println(locations)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}