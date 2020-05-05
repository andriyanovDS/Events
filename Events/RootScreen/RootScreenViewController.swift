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
import func AVFoundation.AVMakeRect

class RootScreenViewController: UIViewController, ViewModelBased {
  var viewModel: RootScreenViewModel!
  var rootView: RootScreenView!
  private var dataSource: TableViewSingleSectionDataSource<Event, EventCellView>!
	private var loadImage: ((_: LoadImageParams) -> Promise<UIImage>)!
	
	struct LoadImageParams {
		let url: String
		let size: CGSize
	}
  
  override func viewDidLoad() {
    super.viewDidLoad()
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
    setupView()
    viewModel.loadEventList()
      .then {[weak self] events in
        self?.handleLoadedEvents(events)
      }
  }
  
  init() {
    super.init(nibName: nil, bundle: nil)
    self.dataSource = TableViewSingleSectionDataSource { (event, cell, _) in
      cell.id = event.id
      cell.cardView.categoryLabel.text = event.categories.first!.translatedLabel()
      cell.cardView.titleLabel.text = event.name
      cell.cardView.locationLabel.text = event.location.fullName
      
      if let url = event.mainImageUrl {
        self.loadImage(LoadImageParams(
          url: url,
          size: EventCellView.Constants.eventImageSize
        ))
          .then {[weak cell] image in
            guard let cell = cell, cell.id == event.id else { return }
            cell.cardView.imageView.image = image
        }
      }
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: false)
  }

  private func setupView() {
    let view = RootScreenView()
    view.eventTableView.delegate = self
    view.eventTableView.dataSource = dataSource
    view.eventTableView.register(EventCellView.self, forCellReuseIdentifier: EventCellView.reuseIdentifier)
    
    self.view = view
    rootView = view
  }
  
  private func handleLoadedEvents(_ events: [Event]) {
    let indexPaths = events
      .enumerated()
      .map {(index, _) in IndexPath(item: index, section: 0)}
    dataSource.append(events)
    rootView.eventTableView.performBatchUpdates({
      rootView.eventTableView.insertRows(at: indexPaths, with: .bottom)
    }, completion: nil)
  }
}

extension RootScreenViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cell = rootView.eventTableView.cellForRow(at: indexPath) as? EventCellView else {
      return
    }
    let origin = cell.superview!.convert(cell.frame.origin, to: view)
    let sharedCardInfo = SharedEventCardInfo(
      frame: cell.cardView.frame,
      origin: origin,
      imageHeight: cell.cardView.imageView.frame.height,
      containerView: cell.shadowView
    )
    viewModel.openEvent(
      dataSource.model(at: indexPath.item),
      sharedCardInfo: sharedCardInfo,
      sharedImage: cell.cardView.imageView.image
    )
  }
}
