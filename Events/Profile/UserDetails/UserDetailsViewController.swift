//
//  UserDetailsViewController.swift
//  Events
//
//  Created by Дмитрий Андриянов on 16/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Photos

class UserDetailsViewController: KeyboardAttachViewController, UserDetailsViewModelDelegate {
    var viewModel: UserDetailsViewModel?
    weak var coordinator: UserDetailsScreenCoordinator? {
        didSet {
            viewModel?.coordinator = coordinator
        }
    }

    let titlelabel = UILabel()
    let scrollView = UIScrollView()
    let contentView = UIView()
    let closeButton = UIButton()
    let firstNameSectionView = UserDetailsSectionView()
    let lastNameSectionView = UserDetailsSectionView()
    let dateSectionView = UserDetailsSectionView()
    let genderSectionView = UserDetailsSectionView()
    let workSectionView = UserDetailsSectionView()
    let descriptionSetionView = UserDetailsSectionView()
    let avatarView = UIButtonScaleOnPress()

    let dateTextField = TextFieldWithBottomLine()
    let genderTextField = TextFieldWithBottomLine()
    let descriptionTextView = UITextView()
    var datePicker = UIDatePicker()

    var selectedGender: Gender?
    var selectedAvatarUrl: URL?

    var user: User? {
        didSet {
            setupInitialView()
        }
    }

    override var keyboardAttachInfo: KeyboardAttachInfo? {
        didSet {
            onKeyboardHeightDidChange()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = UserDetailsViewModel(delegate: self)
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
        dateTextField.text = dateFormatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }

    @objc func endEditing() {
        self.view.endEditing(true)
    }

    @objc func submitProfile() {
        let date = Calendar.current.isDateInToday(datePicker.date)
            ? nil
            : datePicker.date

        let userInfo: [String: Any?] = [
            "firstName": firstNameSectionView.getChildText(),
            "lastName": lastNameSectionView.getChildText(),
            "description": descriptionSetionView.getChildText(),
            "gender": selectedGender,
            "dateOfBirth": date,
            "work": workSectionView.getChildText(),
            "avatar": selectedAvatarUrl
        ]
        self.viewModel?.submitProfile(userInfo: userInfo)
    }

    private func scrollToActiveTextField(keyboardHeight: CGFloat) {
        let activeField = [
            firstNameSectionView,
            lastNameSectionView,
            dateSectionView,
            genderSectionView,
            descriptionSetionView,
            workSectionView
        ].first { $0.isChildFirstResponder() }

        if let activeField = activeField {
            var viewFrame = view.frame
            viewFrame.size.height -= keyboardHeight

            if viewFrame.contains(activeField.frame.origin) {
                let scrollPointY = activeField.frame.origin.y - keyboardHeight
                let scrollPoint = CGPoint(x: 0, y: scrollPointY >= 0 ? scrollPointY : 0)
                scrollView.setContentOffset(scrollPoint, animated: true)
            }
        }
    }

    private func onKeyboardHeightDidChange() {
        let inset = keyboardAttachInfo.foldL(
            none: { UIEdgeInsets.zero },
            some: { info in UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: info.height,
                right: 0
            )}
        )
        scrollView.contentInset = inset
        scrollView.scrollIndicatorInsets = inset

        if inset.bottom > 0 {
            scrollToActiveTextField(keyboardHeight: inset.bottom)
        }
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
        guard let imageUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL else {
            return
        }
        selectedAvatarUrl = imageUrl
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: false, completion: nil)
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

    private func pickerRowValueToGenderLabel(_ row: Int) -> String? {
        switch row {
        case 0: return "Мужской"
        case 1: return "Женский"
        case 2: return "Другое"
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
        genderTextField.text = pickerRowValueToGenderLabel(row)
        selectedGender = pickerRowValueToGender(row)
        view.endEditing(true)
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerRowValueToGenderLabel(row)
    }
}

extension UserDetailsViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.x = 0
    }
}
