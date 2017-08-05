//
//  FacebookManager.swift
//  ProSpinner
//
//  Created by AlexP on 31.7.2017.
//  Copyright © 2017 Alex Pinhasov. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import FirebaseAuth
import FirebaseStorage

class FacebookManager: UIView,
                       FBSDKLoginButtonDelegate
{
    @IBOutlet weak var Loading: UIActivityIndicatorView!
    
    var loginButton: FBSDKLoginButton = FBSDKLoginButton()
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        // Hide the log in button if a user is already logged in
        Auth.auth().addStateDidChangeListener
            { auth, user in
                if let user = user {
                    // User is signed in.
                    
                    
                } else {
                    // No user is signed in.
                    
                    self.loginButton.center = self.center
                    self.loginButton.readPermissions = ["public_profile"]
                    
                    
                    self.addSubview(self.loginButton)
                    self.loginButton.delegate = self
                    
                    // show log in button
                    self.loginButton.isHidden = false
                }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        
        loginButton.isHidden = true
        
        if let error = error {
            print(error.localizedDescription)
            loginButton.isHidden = false
        
            return
        }
            
        else if result.isCancelled{
            
            loginButton.isHidden = false
        
            
        }
            
            
        else {
            
            print("successfullyAuthenticated")
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            Auth.auth().signIn(with: credential) { (user, error) in
                print("User loged in Firebase")
                
            }
            
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("did log out")
    }
}

