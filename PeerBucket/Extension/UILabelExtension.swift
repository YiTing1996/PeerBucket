//
//  UILabelExtension.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/26.
//

import Foundation
import UIKit

@IBDesignable
extension UILabel {
    
    @IBInspectable var characterSpacing: CGFloat {

        get {
            // swiftlint: disable force_cast
            return attributedText?.value(forKey: NSAttributedString.Key.kern.rawValue) as! CGFloat
            // swiftlint: enable force_cast
        }
        
        set {

            if let labelText = text, labelText.count > 0 {

                let attributedString = NSMutableAttributedString(attributedString: attributedText!)

                attributedString.addAttribute(
                    NSAttributedString.Key.kern,
                    value: newValue,
                    range: NSRange(location: 0, length: attributedString.length - 1)
                )

                attributedText = attributedString
            }
        }
    }
    
    // line spacing
    func setLineSpacing(lineSpacing: CGFloat = 0.0, lineHeightMultiple: CGFloat = 0.0) {

        guard let labelText = self.text else { return }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.lineHeightMultiple = lineHeightMultiple

        let attributedString: NSMutableAttributedString
        if let labelattributedText = self.attributedText {
            attributedString = NSMutableAttributedString(attributedString: labelattributedText)
        } else {
            attributedString = NSMutableAttributedString(string: labelText)
        }

        // Line spacing attribute
        attributedString.addAttribute(
            NSAttributedString.Key.paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: attributedString.length))

        self.attributedText = attributedString
    }
    
    // read more
    func addTrailing(with trailingText: String, moreText: String, moreTextFont: UIFont, moreTextColor: UIColor) {
        
        let readMoreText: String = trailingText + moreText
        
        if self.visibleTextLength == 0 { return }
        
        let lengthForVisibleString: Int = self.visibleTextLength
        
        if let myText = self.text {
            
            let mutableString: String = myText
            
            let trimmedString: String? = (mutableString as NSString)
                .replacingCharacters(in: NSRange(location: lengthForVisibleString,
                                                 length: myText.count - lengthForVisibleString), with: "")
            
            let readMoreLength: Int = (readMoreText.count)
            
            guard let safeTrimmedString = trimmedString else { return }
            
            if safeTrimmedString.count <= readMoreLength { return }
            
//            print("this number \(safeTrimmedString.count) should never be less\n")
//            print("then this number \(readMoreLength)")
            
            let trimmedForReadMore: String = (safeTrimmedString as NSString)
                .replacingCharacters(in: NSRange(location: safeTrimmedString.count - readMoreLength,
                                                 length: readMoreLength), with: "") + trailingText
            
            let answerAttributed = NSMutableAttributedString(string: trimmedForReadMore, attributes:
                                                                [NSAttributedString.Key.font: self.font!])
            let readMoreAttributed = NSMutableAttributedString(string: moreText,
                                                               attributes: [
                                                                NSAttributedString.Key.font: moreTextFont,
                                                                NSAttributedString.Key.foregroundColor: moreTextColor])
            answerAttributed.append(readMoreAttributed)
            self.attributedText = answerAttributed
        }
    }
    
    var visibleTextLength: Int {
        
        let font: UIFont = self.font
        let mode: NSLineBreakMode = self.lineBreakMode
        let labelWidth: CGFloat = self.frame.size.width
        let labelHeight: CGFloat = self.frame.size.height
        let sizeConstraint = CGSize(width: labelWidth, height: CGFloat.greatestFiniteMagnitude)
        
        if let myText = self.text {
            
            let attributes: [AnyHashable: Any] = [NSAttributedString.Key.font: font]
            let attributedText = NSAttributedString(string: myText,
                                                    attributes: attributes as? [NSAttributedString.Key: Any])
            let boundingRect: CGRect = attributedText.boundingRect(with: sizeConstraint,
                                                                   options: .usesLineFragmentOrigin,
                                                                   context: nil)
            
            if boundingRect.size.height > labelHeight {
                var index: Int = 0
                var prev: Int = 0
                let characterSet = CharacterSet.whitespacesAndNewlines
                repeat {
                    prev = index
                    if mode == NSLineBreakMode.byCharWrapping {
                        index += 1
                    } else {
                        index = (myText as NSString)
                            .rangeOfCharacter(from: characterSet,
                                              options: [],
                                              range: NSRange(location: index + 1,
                                                             length: myText.count - index - 1)).location
                    }
                } while index != NSNotFound && index < myText.count && (myText as NSString)
                    .substring(to: index).boundingRect(with: sizeConstraint,
                                                       options: .usesLineFragmentOrigin,
                                                       attributes: attributes as? [NSAttributedString.Key: Any],
                                                       context: nil).size.height <= labelHeight
                return prev
            }
        }
        
        if self.text == nil {
            return 0
        } else {
            return self.text!.count
        }
    }
    
}
