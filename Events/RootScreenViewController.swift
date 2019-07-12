//
//  ViewController.swift
//  Events
//
//  Created by Дмитрий Андриянов on 04/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class RootScreenViewController: UIViewController {
    
    let router = RootScreenRouter()
    let viewModel = RootScreenViewModel()
    
    let titleLabel = UILabel()
    let categoriesView = CategoriesView()
    let datesButton = FilterButton(frame: CGRect(x: 0, y: 0, width: 40, height: 30))
    var searchBar = SearchBarViewController(nibName: nil, bundle: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        view.addSubview(searchBar.view)
        view.addSubview(categoriesView.view)
        setupSearchBarViewConstraints()
        setupDatesButton()
        setupTitleLabel()
        setupCategoryViewConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hideNavigationBar()
    }
    
    @objc func openCalendar() {
        guard let navigationController = self.navigationController else {
            return
        }
        router.navigateToCalendar(
            navigationController: navigationController,
            selectedDates: viewModel.getSelectedDates(),
            onComplete: onDatesChanged
        )
    }
    
    func onDatesChanged(dates: SelectedDates) {
        viewModel.setSelectedDates(dates: dates)
        let buttonTitle = viewModel.selectedDatesToString()
        
        if buttonTitle == datesButton.title(for: .normal) {
            return
        }
        
        if buttonTitle == nil {
            datesButton.isFilterEmpty = true
            datesButton.layer.borderWidth = 1
            datesButton.setTitleColor(UIColor.gray600(), for: .normal)
            datesButton.backgroundColor = .white
        } else {
            datesButton.isFilterEmpty = false
            datesButton.layer.borderWidth = 0
            datesButton.setTitleColor(.white, for: .normal)
            datesButton.backgroundColor = UIColor.lightBlue()
        }
        datesButton.setTitle(buttonTitle ?? "Dates", for: .normal)
    }
}

extension RootScreenViewController {
    
    func hideNavigationBar() {
        tabBarController?.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func setupView() {
        view.backgroundColor = .white
    }
    
    func setupSearchBarViewConstraints() {
        
        guard let saerchBarView = searchBar.view else {
            return
        }
        
        saerchBarView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            saerchBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            saerchBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            saerchBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8)
        ])
    }
    
    func setupDatesButton() {
        datesButton.setTitle("Dates", for: .normal)
        datesButton.addTarget(self, action: #selector(openCalendar), for: .touchUpInside)
        view.addSubview(datesButton)
        setupDatesButtonConstraints()
    }
    
    func setupTitleLabel() {
        titleLabel.text = "Choose your next experience"
        titleLabel.font = UIFont.init(name: "AirbnbCerealApp-Bold", size: 22)
        titleLabel.textAlignment = .left
        titleLabel.textColor = UIColor.gray900()
        view.addSubview(titleLabel)
        
        setupTitleLabelConstraints()
    }
    
    func setupDatesButtonConstraints() {
        guard let saerchBarView = searchBar.view else {
            return
        }
        datesButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            datesButton.leadingAnchor.constraint(equalTo: saerchBarView.leadingAnchor, constant: 20),
            datesButton.topAnchor.constraint(equalTo: saerchBarView.bottomAnchor, constant: 7)
        ])
    }
    
    func setupTitleLabelConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: datesButton.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    func setupCategoryViewConstraints() {
        let categoryView = self.categoriesView.view
        categoryView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            categoryView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            categoryView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            categoryView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            categoryView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
}

class FilterButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        self.layer.cornerRadius = 4
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.gray400().cgColor
        self.contentEdgeInsets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        self.setTitleColor(UIColor.gray600(), for: .normal)
        self.titleLabel?.font = UIFont.init(name: "AirbnbCerealApp-Medium", size: 12)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var isFilterEmpty: Bool = true
    
    override var isHighlighted: Bool {
        didSet {
            if isFilterEmpty {
                backgroundColor = isHighlighted ? UIColor.gray200() : UIColor.white
            } else {
                backgroundColor = isHighlighted ? UIColor.blue() : UIColor.lightBlue()
            }
        }
    }
}
