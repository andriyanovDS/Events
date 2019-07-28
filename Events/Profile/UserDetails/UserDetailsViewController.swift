//
//  UserDetailsViewController.swift
//  Events
//
//  Created by Дмитрий Андриянов on 16/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Photos

class UserDetailsViewController: UIViewControllerWithActivityIndicator, UserDetailsViewModelDelegate {
    var viewModel: UserDetailsViewModel?
    weak var coordinator: UserDetailsScreenCoordinator?

    let titlelabel = UILabel()
    lazy var firstNameSectionView: UserDetailsSectionView = {
        return UserDetailsSectionView()
    }()
    lazy var surnameSectionView: UserDetailsSectionView = {
        return UserDetailsSectionView()
    }()
    lazy var dateSectionView: UserDetailsSectionView = {
        return UserDetailsSectionView()
    }()
    lazy var genderSectionView: UserDetailsSectionView = {
        return UserDetailsSectionView()
    }()
    lazy var visualEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    lazy var popUpWindow: PopUpWindow = {
        let view = PopUpWindow()
        view.setupView(with: "Разрешите доступ к камере в настройках")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.delegate = self
        return view
    }()
    lazy var avatarView: UIButtonScaleOnPress = {
        return UIButtonScaleOnPress()
    }()
    lazy var dateTextField: TextFieldWithBottomLine = {
        return TextFieldWithBottomLine()
    }()

    var datePicker: UIDatePicker?
    var genderTextField: TextFieldWithBottomLine?

    var userId: String? {
        didSet {
            setupInitialView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = UserDetailsViewModel(delegate: self)
        viewModel?.coordinator = coordinator
    }

    @objc func showSelectImageActionSheet() {
        viewModel?.showSelectImageActionSheet()
    }

    @objc func closeScreen() {
        viewModel?.closeScreen()
    }

    @objc func selectDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd LLLL YYYY"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateTextField.text = dateFormatter.string(from: datePicker!.date)
        self.view.endEditing(true)
    }

    @objc func endEditing() {
        self.view.endEditing(true)
    }

}

extension UserDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        defer {
            self.dismiss(animated: true, completion: nil)
        }
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        avatarView.setImage(image, for: .normal)
        avatarView.imageView?.layer.cornerRadius = 60
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: false, completion: nil)
    }
}

extension UserDetailsViewController: PopUpDelegate {
    func hadleDismissal() {
        UIView.animate(withDuration: 0.5, animations: {
            self.visualEffectView.alpha = 0
            self.popUpWindow.alpha = 0
            
            self.popUpWindow.transform = CGAffineTransform.identity
        }) { (_) in
            self.popUpWindow.removeFromSuperview()
            
        }
    }
}

extension UserDetailsViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    private func pickerRowValueToGender(_ row: Int) -> Gender? {
        switch row {
        case 0: return .male
        case 1: return .female
        case 2: return .other
        default: return nil
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderTextField?.text = pickerRowValueToGender(row)?.rawValue
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch row {
        case 0: return "Мужчина"
        case 1: return "Женщина"
        case 2: return "Другое"
        default: return nil
        }
    }
}
