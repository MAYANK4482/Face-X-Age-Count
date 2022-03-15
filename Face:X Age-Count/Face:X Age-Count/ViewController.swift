//
//  ViewController.swift
//  Face:X Age-Count
//
//  Created by Mayank Vadaliya on 07/08/19.
//  Copyright © 2019 Mayank Vadaliya. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var lblname: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblname.text = "-->This app is used to count members or people.\n\n-->The age of people can be traced using real cameras or photos."
        // Do any additional setup after loading the view.
    }

    @IBAction func Age(_ sender: UIButton)
    {
        let foo = self.storyboard?.instantiateViewController(withIdentifier: "AgeVC") as! AgeVC
        
        self.navigationController?.pushViewController(foo, animated: true)
        
    }
    @IBAction func count(_ sender: UIButton)
    {
        let foo = self.storyboard?.instantiateViewController(withIdentifier: "MembercountVC") as! MembercountVC
        
        self.navigationController?.pushViewController(foo, animated: true)
        
    }
    
}

