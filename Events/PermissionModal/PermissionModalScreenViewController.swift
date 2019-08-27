//
//  PermissionModalScreenViewController.swift
//  Events
//
//  Created by Сослан Кулумбеков on 28/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import Foundation
import UIKit

class PermissionModalScreenViewController: UIViewController {
  var viewModel: PermissionModalScreenViewModel?
  var modalScreenView: PermissionModalScreenView!
  let permissionModal: PermissionModal
  init(modalType: PermissionModalType) {
    self.permissionModal = modalType.model()
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.loadView()
    viewModel = PermissionModalScreenViewModel()
  }
  
  override func loadView() {
    modalScreenView = PermissionModalScreenView(dataView: permissionModal)
    view = modalScreenView
    modalScreenView.submitButton.addTarget(self, action: #selector(openAppSettings), for: .touchUpInside)
    modalScreenView.closeButton.addTarget(self, action: #selector(closeModal), for: .touchUpInside)
  }
  
  @objc func openAppSettings() {
    viewModel?.openAppSettings()
  }
  
  @objc func closeModal() {
    dismiss(animated: true, completion: nil)
  }
}
