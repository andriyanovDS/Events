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
  private let type: PermissionModalType
  private let viewModel: PermissionModalViewModel
  private var modalScreenView: PermissionModalView?

  init(type: PermissionModalType, viewModel: PermissionModalViewModel) {
    self.viewModel = viewModel
    self.type = type
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.loadView()
  }
  
  override func loadView() {
    modalScreenView = PermissionModalView(modalType: type)
    view = modalScreenView
    modalScreenView?.submitButton.addTarget(self, action: #selector(openAppSettings), for: .touchUpInside)
    modalScreenView?.closeButton.addTarget(self, action: #selector(closeModal), for: .touchUpInside)
  }
  
  @objc func openAppSettings() {
    viewModel.openAppSettings()
  }
  
  @objc func closeModal() {
    viewModel.onClose()
  }
}
