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
    
    // read more
    func addTrailing(with trailingText: String = "...", moreText: String) {
        
        let moreTextFont = UIFont.italic(size: 15)
        let moreTextColor = UIColor.darkGreen
        let readMoreText: String = trailingText + moreText
        
        if self.visibleTextLength == 0 { return }
                
        if let myText = self.text {
            // save current visible string to trimmedString and then add trailing text
            let trimmedString: String? = (myText as NSString)
                .replacingCharacters(in: NSRange(location: self.visibleTextLength,
                                                 length: myText.count - self.visibleTextLength), with: "")

            guard let trimmedString = trimmedString,
                  trimmedString.count > readMoreText.count else { return }
            let trimmedForReadMore: String = (trimmedString as NSString)
                .replacingCharacters(in: NSRange(location: trimmedString.count - readMoreText.count,
                                                 length: readMoreText.count), with: "") + trailingText

            // set up color and font by NSMutableAttriburesString
            let answerAttributed = NSMutableAttributedString(string: trimmedForReadMore, attributes:
                                                                [NSAttributedString.Key.font: self.font!])
            let readMoreAttributed = NSMutableAttributedString(string: moreText,
                                                               attributes: [
                                                                NSAttributedString.Key.font: moreTextFont!,
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
        
        guard let myText = self.text else { return 0 }
        
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
        
        return myText.count
    }
    
}
