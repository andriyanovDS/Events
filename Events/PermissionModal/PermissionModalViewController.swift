//
//  PermissionModalScreenViewController.swift
//  Events
//
//  Created by Сослан Кулумбеков on 28/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//
import Foundation
import UIKit

class PermissionModalViewController: UIViewController {
  var viewModel: PermissionModalViewModel?
  var modalScreenView: PermissionModalView!
  init(modalType: PermissionModalType) {
    modalScreenView = PermissionModalView(modalType: modalType)
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.loadView()
    viewModel = PermissionModalViewModel()
  }
  
  override func loadView() {
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

func openCameraAccessModal(type: PermissionModalType, present: (UIViewController, Bool, (() -> Void)?) -> Void) {
  let permissionModal = PermissionModalViewController(modalType: .photo)
  present(permissionModal, true, nil)
}
