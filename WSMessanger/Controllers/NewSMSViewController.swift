//
//  NewTextViewController.swift
//  WSMessanger
//
//  Created by TTgo on 14/11/2019.
//  Copyright © 2019 TTgo. All rights reserved.
//

import UIKit

class NewSMSViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        
        setupViews()
    }
    
    // MARK: Setups
    private func setupViews() {
        self.view.addSubview(newTextImageView)
        self.view.addSubview(newTextButton)
        
        newTextImageView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        newTextImageView.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor, constant: -50).isActive = true
        
        newTextButton.anchor(top: nil, leading: self.view.safeAreaLayoutGuide.leadingAnchor, bottom: self.view.safeAreaLayoutGuide.bottomAnchor, trailing: self.view.safeAreaLayoutGuide.trailingAnchor, padding: .init(top: 0, left: 50, bottom: 50, right: 50))
        newTextButton.addTarget(self, action: #selector(didTapNewText(_:)), for: .touchUpInside)
    
    }
    
    // MARK: Methods
    @objc func didTapNewText(_ sender: UIButton) {
        
    }
    
    // MARK: Views
    private let newTextImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "imgText")
        
        return imageView
    }()
    
    private let newTextButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("New Text", for: .normal)
        button.setTitleColor(.orange, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        return button
    }()

}
