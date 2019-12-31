//
//  GCDDetailViewController.swift
//  GCDDemoMobile
//
//  Created by roger.wang[王濬淇] on 2019/12/31.
//  Copyright © 2019 roger.wang[王濬淇]. All rights reserved.
//

import UIKit

class GCDDetailViewController: UIViewController {

    let gcdDetail = GCDDetail()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    

    @IBAction func tapDetail(_ sender: UIButton) {
        gcdDetail.run(mode: DetailMode(rawValue: sender.tag)!)
    }
    
    @IBAction func tapDismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }


}
