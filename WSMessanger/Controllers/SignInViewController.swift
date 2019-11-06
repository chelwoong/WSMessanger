//
//  LoginViewController.swift
//  WSMessanger
//
//  Created by TTgo on 05/11/2019.
//  Copyright © 2019 TTgo. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController {
    
    var activeField: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .black
        
        setupViews()
        setupTextField()
        setupKeyboard()
        
        
    }
    
    
    // MARK: Functions
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func registerForKeyboardTapRecognizer() {
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.isEnabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(singleTapGestureRecognizer)

    }
    
    // MARK: Add Target
    
    @objc func didTapSignIn() {
        print("sign in tapped")
        
        if let email = idTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                guard let strongSelf = self else { return }
                
                if let error = error {
                    return print("Email or Password is Wrong!")
                }
                
                let defaults = UserDefaults.standard
                defaults.set(email, forKey: "Account")
                defaults.set(password, forKey: "Password")
              
                let vc = ChannelTC()
                vc.modalPresentationStyle = .fullScreen
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
    
    @objc func didTapSignUp() {
        print("cancel tapped")
    }
    
    @objc func scrollViewTapped() {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardFrame.height, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets

        // 활성화된 텍스트 필드가 키보드에 의해 가려진다면 가려지지 않도록 스크롤한다.
        // 이 부분은 상황에 따라 불필요할 수 있다.
        var rect = self.view.frame
        rect.size.height -= keyboardFrame.height
        if let activeField = activeField, rect.contains(activeField.frame.origin) {
            scrollView.scrollRectToVisible(activeField.frame, animated: true)
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        scrollView.endEditing(true)
    }
    
    // MARK: Setups
    
    func setupKeyboard() {
        registerForKeyboardNotifications()
        registerForKeyboardTapRecognizer()
    }
    
    func setupTextField() {
        idTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    func setupViews() {
        self.view.addSubview(scrollView)
//        self.view.addSubview(idTextField)
//        self.view.addSubview(passwordTextField)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(idTextField)
        scrollView.addSubview(passwordTextField)
        scrollView.addSubview(buttonStack)
        
        scrollView.anchor(top: self.view.safeAreaLayoutGuide.topAnchor, leading: self.view.safeAreaLayoutGuide.leadingAnchor, bottom: self.view.safeAreaLayoutGuide.bottomAnchor, trailing: self.view.safeAreaLayoutGuide.trailingAnchor)
        
        titleLabel.anchor(top: nil, leading: self.view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: self.view.safeAreaLayoutGuide.trailingAnchor, padding: UIEdgeInsets.init(top: 0, left: 50, bottom: 0, right: 50))
        titleLabel.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor, constant: -200).isActive = true
        
        idTextField.anchor(top: titleLabel.bottomAnchor, leading: self.view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: self.view.safeAreaLayoutGuide.trailingAnchor, padding: UIEdgeInsets.init(top: 50, left: 50, bottom: 0, right: 50))
//        idTextField.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor, constant: -100).isActive = true
        
        passwordTextField.anchor(top: idTextField.bottomAnchor, leading: self.view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: self.view.safeAreaLayoutGuide.trailingAnchor, padding: UIEdgeInsets.init(top: 30, left: 50, bottom: 0, right: 50))
        
        
        buttonStack.addArrangedSubview(signInButton)
        buttonStack.addArrangedSubview(CancelButton)
        
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        CancelButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
        
        buttonStack.anchor(top: passwordTextField.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0), size: CGSize(width: 200, height: 50))
        buttonStack.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
    }
    
    // MARK: Views
    
    let scrollView: UIScrollView = {
        let screensize: CGRect = UIScreen.main.bounds
        let screenWidth = screensize.width
        let screenHeight = screensize.height

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentSize = CGSize(width: screenWidth, height: screenHeight)
        return scrollView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "WSSMessanger"
        label.font = .boldSystemFont(ofSize: 30)
        label.textColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        label.textAlignment = .center
        return label
    }()
    
    let idTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "ID"
        textField.borderStyle = .roundedRect
        
        return textField
    }()
    
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Password"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    let buttonStack: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        stackView.backgroundColor = .green
        return stackView
    }()
    
    let signInButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Sign In", for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .heavy)
        button.backgroundColor = .orange
        return button
    }()
    
    let CancelButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Cancel", for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .heavy)
        button.backgroundColor = .orange
        
    
        return button
    }()
}

extension SignInViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }
        
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // textField가 더이상 first view가 아닐 때 사라짐
        textField.resignFirstResponder()
        return true
    }
}
