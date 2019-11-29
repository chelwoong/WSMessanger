//
//  SMSViewController.swift
//  WSMessanger
//
//  Created by TTgo on 14/11/2019.
//  Copyright © 2019 TTgo. All rights reserved.
//

import UIKit
import ContactsUI

protocol SMSVCDelegate {
    var phone: String? {get set}
    var message: String? {get set}
    
    func unwindToViewController()
}


class SMSViewController: UIViewController, CNContactPickerDelegate {
    
    var delegate: SMSVCDelegate?
    var channelVC: ChannelViewController?
    
    // MARK: Properties
    let searchController = UISearchController(searchResultsController: nil)

    let cnPicker = CNContactPickerViewController()
    
    var originRect:CGRect?
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
//        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.tabBarController?.tabBar.isHidden = true
        title = "SMS"
        
        //Contact
        cnPicker.delegate = self
        cnPicker.predicateForSelectionOfContact = NSPredicate(value: true)
        
        setupViews()
//        setupSearchController()
        setupViewResizerOnKeyboardShown()
        recipientTextField.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.isHidden = false
        self.delegate?.unwindToViewController()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        view.endEditing(true)
    }

    // MARK: Setups
    
    private func setupViews() {
        view.addSubview(recipientView)
        recipientView.addSubview(recipientTextField)
        recipientView.addSubview(recipientButton)
        view.addSubview(smsTextView)
        view.addSubview(sendButton)

        recipientView.anchor(top: self.view.safeAreaLayoutGuide.topAnchor, leading: self.view.safeAreaLayoutGuide.leadingAnchor, bottom: nil, trailing: self.view.safeAreaLayoutGuide.trailingAnchor, padding: .zero , size: .init(width: 0, height: 50))
        
        recipientTextField.anchor(top: recipientView.safeAreaLayoutGuide.topAnchor, leading: recipientView.safeAreaLayoutGuide.leadingAnchor, bottom: recipientView.safeAreaLayoutGuide.bottomAnchor, trailing: recipientButton.leadingAnchor, padding: .init(top: 0, left: 30, bottom: 0, right: 0))
       
        recipientButton.anchor(top: recipientView.safeAreaLayoutGuide.topAnchor, leading: nil, bottom: recipientView.safeAreaLayoutGuide.bottomAnchor, trailing: recipientView.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 30), size: .init(width: 50, height: 50))
        recipientButton.addTarget(self, action: #selector(onAddButton(_:)), for: .touchUpInside)
        
        smsTextView.anchor(top: recipientView.bottomAnchor, leading: self.view.safeAreaLayoutGuide.leadingAnchor, bottom: sendButton.topAnchor, trailing: self.view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: 30, left: 30, bottom: 0, right: 30))
        
        sendButton.anchor(top: smsTextView.bottomAnchor, leading: self.view.safeAreaLayoutGuide.leadingAnchor, bottom: self.view.safeAreaLayoutGuide.bottomAnchor, trailing: self.view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: 30, left: 30, bottom: 10, right: 30))
        sendButton.addTarget(self, action: #selector(onSendButton(_:)), for: .touchUpInside)
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = ""
        searchController.searchBar.tintColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
//        let image = UIImage(named: "imgText")
//        navigationItem.searchController?.searchBar.showsBookmarkButton = true
//        navigationItem.searchController?.searchBar.setImage(image, for: .bookmark, state: .normal)
        
//        recipientView.addSubview(searchController.searchBar)
        
    }
    
    // MARK: Methods
    
    @objc func onSendButton(_ sender: UIButton) {
        print("send")
        
        guard let phone = recipientTextField.text , phone.count > 8 else {
//            view.makeToast("Please, check phone number!")
            print("Please, check phone number!")
            return
        }
        guard let message = smsTextView.text, message.count > 0  else {
//            view.makeToast("Please, input sms message!")
            print("Please, input sms message!")
            return
        }
        
        delegate?.phone = phone
        delegate?.message = message
        
        
        
//        self.dismiss(animated: true) {
//            self.delegate?.unwindToViewController()
//        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func onAddButton(_ sender: Any) {
        print("add button")
        //SB_SEGUE_CONTACTS
        //tabBarController?.performSegue(withIdentifier: "SB_SEGUE_CONTACTS", sender: nil)
        self.present(cnPicker, animated: true, completion: nil)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        //let phoneNumber = contact.phoneNumbers
        //print("number is = \(phoneNumber)")
        let validNumbers = contact.phoneNumbers.compactMap { phoneNumber -> String? in
            if let label = phoneNumber.label  {
                print("phoneNumber.label \(label)")
                return phoneNumber.value.stringValue
            }
            return nil
        }
        var phoneNumber = validNumbers[0]
        phoneNumber = phoneNumber.replacingOccurrences(of: "-", with: "")
        phoneNumber = phoneNumber.replacingOccurrences(of: "+", with: "")
        phoneNumber = phoneNumber.replacingOccurrences(of: " ", with: "")
        phoneNumber = phoneNumber.replacingOccurrences(of: "(", with: "")
        phoneNumber = phoneNumber.replacingOccurrences(of: ")", with: "")
        recipientTextField.text = phoneNumber
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
           print("Cancel Contact Picker")
       }

    
    func filterContentForSearch(_ searchText: String) {
//        filteredLectures = lectures.filter({ (lecture: Lecture) -> Bool in
//            lecture.lecture.lowercased().contains(searchText.lowercased())
//        })
//        collectionView.reloadData()
    }
    
    
    // MARK: Views
    private let recipientView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
//        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    private let recipientTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "recipient"
        
        return textField
    }()
    
    private let recipientButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "iconAdd")
        button.setImage(image, for: .normal)
        
        return button
    }()
    
    private let smsTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        return textView
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Send", for: .normal)
        button.setTitleColor(.orange, for: .normal)
        
        return button
    }()

}

// MARK: - UISearchResultsUpdating Delegate
extension SMSViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar

        filterContentForSearch(searchBar.text ?? "")
        
    }
}

// MARK: - UISearchBar Delegate
extension SMSViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.filterContentForSearch(searchBar.text ?? "")
    }
}

// MARK: - TextField Delegate
extension SMSViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        recipientTextField.resignFirstResponder()
        return true
    }
}

extension SMSViewController {
    // MARK: Keyboard Helpers
    
    func setupViewResizerOnKeyboardShown() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShowForResizing),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHideForResizing),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc func keyboardWillShowForResizing(notification: Notification) {
        
        //viewHeight 를 비교해서 키보드가 나타나지 않앗을 경우에만 View 를 줄인다.
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let _ = self.view.window?.frame {
            // We're not just minusing the kb height from the view height because
            // the view could already have been resized for the keyboard before
            var modifyRect:CGRect?
            var origin:CGRect
            if let o = originRect {
                origin = o
            }
            else{
                originRect = CGRect(x: self.view.frame.origin.x,
                                    y: self.view.frame.origin.y,
                                    width: self.view.frame.width,
                                    height: self.view.frame.height)
                origin = originRect!
                
            }
            modifyRect = CGRect(x: origin.origin.x,
                                y: origin.origin.y,
                                width: origin.width,
                                height: origin.height - keyboardSize.height)
            self.view.frame = modifyRect!
            
        } else {
            debugPrint("We're showing the keyboard and either the keyboard size or window is nil: panic widely.")
        }
    }
    
    @objc func keyboardWillHideForResizing(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let viewHeight = self.view.frame.height
            
            self.view.frame = CGRect(x: self.view.frame.origin.x,
                                     y: self.view.frame.origin.y,
                                     width: self.view.frame.width,
                                     height: viewHeight + keyboardSize.height)
            
        } else {
            debugPrint("We're about to hide the keyboard and the keyboard size is nil. Now is the rapture.")
        }
    }
}
