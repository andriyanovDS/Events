//
//  CreateEventVC.swift
//  Events
//
//  Created by Дмитрий Андриянов on 03/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Stevia
import SwiftIconFont

class CreateEventViewController: UIViewControllerWithActivityIndicator, CreateEventViewModelDelegate {
    var locationView: LocationView?
    var coordinator: CreateEventCoordinator?
    var viewModel: CreateEventViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupView()
        showActivityIndicator(for: nil)
        viewModel = CreateEventViewModel(delegate: self)
        viewModel.coordinator = coordinator
    }

    private func setupView() {
        view.backgroundColor = .white
    }

    func onReceiveCurrentLocationName(_ name: String) {
        removeActivityIndicator()
        locationView = LocationView(locationName: name)
        locationView?.locationButton.addTarget(self, action: #selector(onChangeLocation), for: .touchUpInside)
        locationView?.submitButton.addTarget(self, action: #selector(showDescriptionView), for: .touchUpInside)
        view = locationView
    }

    func onChangeLocationName(_ name: String) {
        locationView?.locationButton.setTitle(name, for: .normal)
    }

    private func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = UIColor.white
        let backButtonImage = UIImage(
            from: .ionicon,
            code: "ios-arrow-back",
            textColor: .black,
            backgroundColor: .clear,
            size: CGSize(width: 40, height: 40)
        )
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: backButtonImage,
            style: .plain,
            target: self,
            action: #selector(onClose)
        )
        navigationController?.isNavigationBarHidden = false
    }

    @objc func showDescriptionView() {

    }

    @objc func onClose() {
        viewModel.closeScreen()
    }

    @objc func onChangeLocation() {
        viewModel.openLocationSearchBar()
    }
}
