//
//  UnsplashResponse.swift
//  Events
//
//  Created by Dmitry on 16.02.2020.
//  Copyright © 2020 Дмитрий Андриянов. All rights reserved.
//

import Foundation

struct UnsplashResultItemLinks: Decodable {
	let raw: String
	let full: String
	let regular: String
	let small: String
	let thumb: String
}

struct UnsplashResultItem: Decodable {
	let id: String
	let width: Int
	let height: Int
	let color: String
	let urls: UnsplashResultItemLinks
}

struct UnsplashResult: Decodable {
	let total: Int
	let total_pages: Int
	let results: [UnsplashResultItem]
}
