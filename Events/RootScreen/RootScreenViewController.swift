//
//  ViewController.swift
//  Events
//
//  Created by Дмитрий Андриянов on 04/07/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit
import Hero
import Stevia
import Promises
import AsyncDisplayKit

class RootScreenViewController: ASViewController<RootScreenNode>, ViewModelBased {
  var viewModel: RootScreenViewModel!
	private let loadImage: (_: LoadImageParams) -> Promise<UIImage>
  private let reusablePinIcon: UIImage
	
	struct LoadImageParams {
		let url: String
		let size: CGSize
	}

  init() {
    reusablePinIcon = Icon(material: "location.on", sfSymbol: "mappin.and.ellipse")
      .image(withSize: 30, andColor: .highlightBlue)!
		loadImage = memoizeWith(
			callback: { (params: LoadImageParams) -> Promise<UIImage> in
				ExternalImageCache.shared.loadImage(by: params.url)
				.then(on: .global()) { image -> UIImage in
					let rect = AVMakeRect(aspectRatio: image.size, insideRect: CGRect(
						x: 0, y: 0, width: params.size.width, height: params.size.height
					))
					let size = CGSize(width: rect.width, height: rect.height)
					UIGraphicsBeginImageContextWithOptions(size, true, 0)
					image.draw(in: CGRect(origin: CGPoint.zero, size: size))
					let newImage = UIGraphicsGetImageFromCurrentImageContext()
					UIGraphicsEndImageContext()
					return newImage!
				}
			},
			key: (\.url)
		)

    super.init(node: RootScreenNode())
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    viewModel.delegate = self
    viewModel.loadEventList()
    node.eventTableNode.dataSource = self
    node.eventTableNode.delegate = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: false)
  }

  private func setupView() {
    node.eventTableNode.dataSource = self
  }
}

extension RootScreenViewController: RootScreenViewModelDelegate {
  func reloadList() {
    node.eventTableNode.reloadData()
  }
}

extension RootScreenViewController: ASTableDataSource {
  func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
    return viewModel.eventList.count
  }

  func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
    let event = viewModel.eventList[indexPath.item]
    let pinIcon = reusablePinIcon
    let authorOptional = viewModel.authors[event.author]
    let block = {[unowned self] () -> EventCellNode in
      let cell = EventCellNode(sharedId: event.id, reusablePinIcon: pinIcon)
      cell.setNameNodeText(event.name)
      cell.setLocationNodeText(event.location.fullName)
      cell.setDateNodeText(event.dateLabelText)
      if let author = authorOptional {
        cell.setUserNameNodeText(author.fullName)
      }
      if let url = event.mainImageUrl {
        cell.loadMainImage = {[unowned self] in
          return self.loadImage(LoadImageParams(
            url: url,
            size: EventCellNode.Constants.eventImageSize
          ))
        }
      }
      if let avatarUrl = authorOptional?.avatar {
        cell.loadAvatarImage = {[unowned self] in
          self.loadImage(LoadImageParams(
            url: avatarUrl,
            size: EventCellNode.Constants.authorImageSize
          ))
        }
      }
      return cell
    }
    return block
  }
}

extension RootScreenViewController: ASTableDelegate {
  func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
    guard let cell = tableNode.nodeForRow(at: indexPath) as? EventCellNode else {
      return
    }
    viewModel.openEvent(at: indexPath.item, sharedImage: cell.eventImageNode.image)
  }
}
