//
//  QRCodeViewController.swift
//  QRCodeReader
//
//  Created by Simon Ng on 13/10/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit

class QRCodeViewController: UIViewController {

    override func viewDidLoad() {
        self.popupWarning(title: "Warning", msg: "Message")
        super.viewDidLoad()
        //login()
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    @IBAction func unwindToHomeScreen(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
    }

    func login() {
        let alertController = UIAlertController(title: "Login", message: "Login is via ForgeRock push. Make sure you registered your device.", preferredStyle: .alert)
        let loginAction = UIAlertAction(title: "Login", style: UIAlertActionStyle.default) { [weak alertController] _ in
            if let alertController = alertController {
                let loginTextField = alertController.textFields![0] as UITextField
                Identity.pushLogin(username: loginTextField.text!)
            }
        }
        alertController.addAction(loginAction)
        self.present(alertController, animated: true, completion: nil)
        
        loginAction.isEnabled = false
    }
    
    func popupWarning(title: String, msg: String) {
        print("popup warning ************")
        let alertController = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            print("OK")
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
