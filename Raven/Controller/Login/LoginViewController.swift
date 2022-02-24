//
//  ViewController.swift
//  Raven
//
//  Created by Gök Gün Çağatay Koç on 12.02.2022.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTxt: UITextField!
    
    @IBOutlet weak var passwordTxt: UITextField!
    
    @IBOutlet weak var loginButtonOutlet: UIButton!
    
    @IBOutlet weak var signUpButtonOutlet: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeToKeyboardNotifications()
    }

    @IBAction func loginButton(_ sender: UIButton) {
        
        activityIndicator.startAnimating()
        let loginManager = FirebaseAuthManager()
        guard let email = emailTxt.text, let password = passwordTxt.text else { return }
        
        if isValidEmail(email)
        {
            loginManager.signIn(email: email, pass: password) {[weak self] (success, error)  in
                guard let `self` = self else { return }
                var message: String = ""
                self.activityIndicator.stopAnimating()
                if (success) {
                    
                    //user defaults
                    let userDefaults:UserDefaults = UserDefaults.standard
                    userDefaults.set(email, forKey: "email")
                    userDefaults.set(password, forKey: "password")
                    
                    self.dismiss(animated: true, completion: nil)
                } else {
                    message = error // localizedDescription
                    let alertController = UIAlertController(title: "Attention", message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        else
        {
            activityIndicator.stopAnimating()
            let alertController = UIAlertController(title: "Attention", message: "Invalid email.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: Notification){
        var currentEditingTextField: UITextField!
        
        for view in self.view.subviews as [UIView] {
            if let tf = view as? UITextField {
                if tf.isEditing {
                    currentEditingTextField = tf
                    break
                }
            }
        }
        
        if emailTxt == currentEditingTextField {
            self.view.frame.origin.y = 0
        }
        else if passwordTxt == currentEditingTextField {
            self.view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(notification: Notification){
        self.view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height/2
    }
    
    func showSignupViewController()
    {
        var signupViewController:SignupViewController = SignupViewController()
        signupViewController = self.storyboard?.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
        signupViewController.modalPresentationStyle = .fullScreen
        self.present(signupViewController, animated: true, completion: nil)
    }
    
    @IBAction func signupButton(_ sender: UIButton) {
        
        showSignupViewController()
    }
    
}

