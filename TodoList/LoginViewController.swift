//
//  LoginViewController.swift
//  TodoList
//
//  Created by Yelay Song on 1/3/2567 BE.
//  Copyright © 2567 BE meech-ward. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextfield: UITextField!
    
    @IBOutlet weak var passwordTextfield: UITextField!
    
    var handle: AuthStateDidChangeListenerHandle?
    
    
    override func viewWillAppear(_ animated: Bool) {
        // 1
        handle = Auth.auth().addStateDidChangeListener { _, user in
          // 2
          if user == nil {
            self.navigationController?.popToRootViewController(animated: true)
          } else {
            // 3
            self.performSegue(withIdentifier: "LoginToTodoList", sender: nil)
            self.emailTextfield.text = "lay@gmail.com"
            self.passwordTextfield.text = "123456"
          }
        }

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        guard let handle = handle else { return }
        Auth.auth().removeStateDidChangeListener(handle)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextfield.text = "lay@gmail.com"
        passwordTextfield.text = "123456"
    }
    
    
    
    @IBAction func AboutBtn(_ sender: Any) {
        let alert = UIAlertController(title: "About Us", message: "Kasitinard Song 6514110023\nKrittamet Srijaroon 6514110031", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    

    @IBAction func loginPressed(_ sender: Any) {
        if let email = emailTextfield.text, let password = passwordTextfield.text {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    let alert = UIAlertController(
                      title: "Sign In Failed",
                      message: e.localizedDescription,
                      preferredStyle: .alert)

                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true, completion: nil)
                
                } else{
                    self.performSegue(withIdentifier: "LoginToTodoList", sender: self)
                }
                
            }
        }
    }
    
    

}
