//
//  TextFormattingsTextStorage.swift
//  Events
//
//  Created by Дмитрий Андриянов on 13/08/2019.
//  Copyright © 2019 Дмитрий Андриянов. All rights reserved.
//

import UIKit

class TextFormattingsTextStorage: NSTextStorage {
  let backingStore = NSMutableAttributedString()
  private let fontSize: CGFloat
  private var replacements: [String: ([NSAttributedString.Key: Any]) -> [NSAttributedString.Key: Any]] = [:]

  override var string: String {
    return backingStore.string
  }

  init(fontSize: CGFloat) {
    self.fontSize = fontSize
    super.init()

    replacements = [
      "((\\*)+([^.*?$]+)+(\\*))": getBoldAttributes,
      "((\\_)+([^._?$]+)+(\\_))": getItalicAttributes,
      "((\\~)+([^.~?$]+)+(\\~))": getStrikeThroughAttributes
    ]
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func attributes(
    at location: Int,
    effectiveRange range: NSRangePointer?
    ) -> [NSAttributedString.Key: Any] {
    return backingStore.attributes(at: location, effectiveRange: range)
  }

  override func replaceCharacters(in range: NSRange, with str: String) {
    beginEditing()
    backingStore.replaceCharacters(in: range, with: str)
    edited(
      .editedCharacters,
      range: range,
      changeInLength: (str as NSString).length - range.length
    )
    endEditing()
  }

  override func setAttributes(_ attrs: [NSAttributedString.Key: Any]?, range: NSRange) {
    beginEditing()
    backingStore.setAttributes(attrs, range: range)
    edited(
      .editedAttributes,
      range: range,
      changeInLength: 0
    )
    endEditing()
  }

  override func processEditing() {
    performReplacementsForRange(changedRange: editedRange)
    super.processEditing()
  }

  private func getBoldFontFamily(for currentFont: UIFont?) -> UIFont {
    if let currentFont = currentFont {
      let descriptor = currentFont.fontDescriptor
      let fontAttribute = UIFontDescriptor.AttributeName(rawValue: "NSFontNameAttribute")
      if let fontName = descriptor.fontAttributes[fontAttribute] as? String {
        if fontName == fontFamilyItalic {
          return FontStyle.boldItalic.font(size: fontSize)
        }
      }
    }
    return FontStyle.bold.font(size: fontSize)
  }

  private func getItalicFontFamily(for currentFont: UIFont?) -> UIFont {
    if let currentFont = currentFont {
      let descriptor = currentFont.fontDescriptor
      let fontAttribute = UIFontDescriptor.AttributeName(rawValue: "NSFontNameAttribute")
      if let fontName = descriptor.fontAttributes[fontAttribute] as? String {
        if fontName == fontFamilyBold {
          return FontStyle.boldItalic.font(size: fontSize)
        }
      }
    }
    return FontStyle.italic.font(size: fontSize)
  }

  private func getBoldAttributes(
    currentAttributes: [NSAttributedString.Key: Any]
    ) -> [NSAttributedString.Key: Any] {
    var attributes = currentAttributes
    let currentFont = attributes[.font]
    attributes[.font] = getBoldFontFamily(for: currentFont as? UIFont)
    return attributes
  }

  private func getItalicAttributes(
    currentAttributes: [NSAttributedString.Key: Any]
    ) -> [NSAttributedString.Key: Any] {
    var attributes = currentAttributes
    let currentFont = attributes[.font]
    attributes[.font] = getItalicFontFamily(for: currentFont as? UIFont)
    return attributes
  }

  private func getStrikeThroughAttributes(
  currentAttributes: [NSAttributedString.Key: Any]
    ) -> [NSAttributedString.Key: Any] {
    var attributes = currentAttributes
    attributes[.strikethroughStyle] = 1
    return attributes
  }

  func applyStylesToRange(searchRange: NSRange) {
    let searchString = backingStore.string
    var removedIndices: [Int] = []
    replacements.forEach({ pattern, attributesGetter in
      do {
        let regex = try NSRegularExpression(pattern: pattern)
        regex.enumerateMatches(
          in: searchString,
          range: searchRange
        ) { match, _, _ in
          if let matchRange = match?.range(at: 1) {
            let maxRange = matchRange.location + matchRange.length
            let rangeOffsetStart = removedIndices
              .filter { $0 < matchRange.location }
              .count
            let rangeOffsetEnd = removedIndices
              .filter { $0 < maxRange && $0 > matchRange.location }
              .count
            let updatedRange = NSRange(
              location: matchRange.location - rangeOffsetStart,
              length: matchRange.length - rangeOffsetEnd
            )
            let attributeRange = NSRange(
              location: updatedRange.location + 1,
              length: updatedRange.length - 2
            )
            let rangeAttributes = attributes(
              at: attributeRange.location,
              longestEffectiveRange: nil,
              in: attributeRange
            )
            addAttributes(attributesGetter(rangeAttributes), range: updatedRange)

            let firstCharacterRange = NSRange(
              location: updatedRange.location,
              length: 1
            )
            let lastCharacterRange = NSRange(
              location: updatedRange.location + updatedRange.length - 2,
              length: 1
            )
            removedIndices.append(matchRange.location)
            removedIndices.append(maxRange - 1)
            deleteCharacters(in: firstCharacterRange)
            deleteCharacters(in: lastCharacterRange)
          }
        }
      } catch {}
    })
  }

  func performReplacementsForRange(changedRange: NSRange) {
    let range = NSRange(location: changedRange.location, length: 0)
    let extendedRange = NSUnionRange(
        changedRange,
        NSString(string: backingStore.string).lineRange(for: range)
    )
    applyStylesToRange(searchRange: extendedRange)
  }
}
