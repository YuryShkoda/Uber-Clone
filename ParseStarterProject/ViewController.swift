/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class ViewController: UIViewController {
    
    var signupMode = true
    
    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var driverOrRiderSwitcher: UISwitch!
    @IBOutlet weak var riderLabel: UILabel!
    @IBOutlet weak var driverLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginOrSignupButton: UIButton!
    
    func displayAlert(title: String, message: String) {
    
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    
    }
    
    @IBAction func loginOrSignup(_ sender: Any) {
        
        if usernameTextfield.text! == "" || passwordTextfield.text! == "" {
            
            displayAlert(title: "Error in form", message: "Username and password are required")
        
        } else {
        
            if signupMode {
                
                let user = PFUser()
                
                user.username = usernameTextfield.text
                user.password = passwordTextfield.text
                
                user["isDriver"] = driverOrRiderSwitcher.isOn
                
                user.signUpInBackground(block: { (success, error) in
                    
                    if error != nil {
                        
                        var errorMessage = "Please try again latter."
                        
                        let error = error as? NSError
                        
                        if let parseError = error?.userInfo["error"] as? String {
                            
                            errorMessage = parseError
                            
                        }
                        
                        self.displayAlert(title: "Sign Up Failed", message: errorMessage)
                        
                    } else {
                        
                        print("User Signed Up!")
                        
                        if let isDriver = PFUser.current()?["isDriver"] as? Bool {
                        
                            if isDriver {
                                
                                self.performSegue(withIdentifier: "showDriverViewController", sender: self)
                            
                            } else {
                            
                                self.performSegue(withIdentifier: "showRiderViewController", sender: self)
                            
                            }
                        
                        }
                        
                    }
                    
                })
                
            } else {
                
                PFUser.logInWithUsername(inBackground: usernameTextfield.text!, password: passwordTextfield.text!, block: { (user, error) in
                    
                    if error != nil {
                        
                        var errorMessage = "Please try again latter."
                        
                        let error = error as? NSError
                        
                        if let parseError = error?.userInfo["error"] as? String {
                            
                            errorMessage = parseError
                            
                        }
                        
                        self.displayAlert(title: "Log In Failed", message: errorMessage)
                        
                    } else {
                        
                        print("User logged In!")
                        
                        if let isDriver = PFUser.current()?["isDriver"] as? Bool {
                            
                            if isDriver {
                                
                                self.performSegue(withIdentifier: "showDriverViewController", sender: self)
                                
                            } else {
                                
                                self.performSegue(withIdentifier: "showRiderViewController", sender: self)
                                
                            }
                            
                        }
                        
                    }
                    
                })
                
            }
        
        }
        
    }
    
    @IBAction func changeLoginOrSignup(_ sender: Any) {
        
        if signupMode {
            
            loginButton.setTitle("log In", for: [])
            
            loginOrSignupButton.setTitle("Switch to Sign Up", for: [])
            
            signupMode = false
            
            driverOrRiderSwitcher.isHidden = true
            driverLabel.isHidden           = true
            riderLabel.isHidden            = true
        
        } else {
        
            loginButton.setTitle("Sign Up", for: [])
            
            loginOrSignupButton.setTitle("Switch to Log In", for: [])
            
            signupMode = true
            
            driverOrRiderSwitcher.isHidden = false
            driverLabel.isHidden           = false
            riderLabel.isHidden            = false
        
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let isDriver = PFUser.current()?["isDriver"] as? Bool {
            
            if isDriver {
                
                self.performSegue(withIdentifier: "showDriverViewController", sender: self)
                
            } else {
                
                self.performSegue(withIdentifier: "showRiderViewController", sender: self)
                
            }
            
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
