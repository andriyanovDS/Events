//
//  EventsCollectionNodeFlowLayout.swift
//  Events
//
//  Created by Dmitry on 27.03.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class EventsCollectionNodeFlowLayout: UICollectionViewFlowLayout {
	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		guard let attrs = super.layoutAttributesForElements(in: rect) else {
			return nil
		}
		var baseline: CGFloat = -2
		var sameLineElements = [UICollectionViewLayoutAttributes]()
		for element in attrs where element.representedElementCategory == .cell {
			let centerY = element.frame.midY
			if abs(element.frame.midY - baseline) > 1 {
				baseline = centerY
				alignToTopForSameLineElements(sameLineElements: sameLineElements)
				sameLineElements.removeAll()
			}
			sameLineElements.append(element)
		}
		alignToTopForSameLineElements(sameLineElements: sameLineElements)
		return attrs
	}

	private func alignToTopForSameLineElements(sameLineElements: [UICollectionViewLayoutAttributes]) {
		if sameLineElements.count < 1 { return }
		let sorted = sameLineElements.sorted {
			$0.frame.size.height - $1.frame.size.height <= 0
		}
		if let tallest = sorted.last {
			sameLineElements.forEach {
				$0.frame = $0.frame.offsetBy(dx: 0, dy: tallest.frame.origin.y - $0.frame.origin.y)
			}
		}
	}
}
