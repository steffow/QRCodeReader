//
//  QRCodeViewController.swift
//  QRCodeReader
//
//  Created by Simon Ng on 13/10/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit

class QRCodeViewController: UIViewController {
    @IBOutlet weak var SetCashierBtn: UIButton!
    
    @IBOutlet weak var startScanBtn: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        startScanBtn.isHidden = true
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func hideStartScanBtn(result: Bool) {
        if result {
            startScanBtn.isHidden = false
        } else {
            startScanBtn.isHidden = true
        }
        
    }

    
    // MARK: - Navigation

    @IBAction func unwindToHomeScreen(segue: UIStoryboardSegue) {
        //dismiss(animated: true, completion: nil)
    }
    
    @IBAction func LoginCashier(_ sender: Any) {
        login()
    }


    func login() {

        let alertController = UIAlertController(title: "Login", message: "Login is via ForgeRock push. Make sure you registered your device.", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Login Name"
            }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: {
                (action : UIAlertAction!) -> Void in
            })

        let loginAction = UIAlertAction(title: "Login", style: UIAlertActionStyle.default, handler: {
                alert -> Void in
                    let loginTextField = alertController.textFields![0] as UITextField
                    Identity.pushLogin(login: loginTextField.text!, completion: self.hideStartScanBtn)
                    print("Login: " + loginTextField.text!)
                })

        alertController.addAction(loginAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
