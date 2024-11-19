//
//  RegisterViewController.swift
//  TodoList
//
//  Created by Yelay Song on 1/3/2567 BE.
//  Copyright © 2567 BE meech-ward. All rights reserved.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!

    

    @IBAction func registerPressed(_ sender: UIButton) {
        if let email = emailTextfield.text, let password = passwordTextfield.text {
            Auth.auth().createUser(withEmail: email, password: password) {
                authResult, error in
                if let e = error {
                    print(e)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
}
