//
//  StringExtension.swift
//
//  Created by Pramod Kumar on 5/17/17.
//  Copyright © 2017 Pramod Kumar. All rights reserved.
//

import Foundation
import UIKit

extension UnicodeScalar {
    
    var isEmoji: Bool {
        
        switch value {
        case 0x3030, 0x00AE, 0x00A9, // Special Characters
        0x1D000 ... 0x1F77F, // Emoticons
        0x2100 ... 0x27BF, // Misc symbols and Dingbats
        0xFE00 ... 0xFE0F, // Variation Selectors
        0x1F900 ... 0x1F9FF: // Supplemental Symbols and Pictographs
            return true
            
        default: return false
        }
    }
    
    var isZeroWidthJoiner: Bool {
        
        return value == 8205
    }
}

//MARK:- glyphCount
extension String {
    
    var utf8Decoded: String {
        
//        let jsonString = (self as NSString).utf8String
//        if jsonString == nil{
//            return self
//        }
//
//        let jsonData: Data = Data(bytes: UnsafeRawPointer(jsonString!), count: Int(strlen(jsonString)))
//        if let goodMessage = NSString(data: jsonData, encoding: String.Encoding.nonLossyASCII.rawValue){
//            return goodMessage as String
//        }else{
//            return self
//        }
        
        let data = self.data(using: String.Encoding.utf8);
        let decodedStr = NSString(data: data!, encoding: String.Encoding.nonLossyASCII.rawValue)
        if let str = decodedStr{
            return str as String
        }
        return self
    }
    
    var utf8Encoded: String {
        
//        let uniText: NSString = NSString(utf8String: (self as NSString).utf8String!)!
//        let msgData: Data = uniText.data(using: String.Encoding.nonLossyASCII.rawValue)!
//        let goodMsg: NSString = NSString(data: msgData, encoding: String.Encoding.utf8.rawValue)!
//        return goodMsg as String
        if let encodeStr = NSString(cString: self.cString(using: .nonLossyASCII)!, encoding: String.Encoding.utf8.rawValue){
            return encodeStr as String
        }
        return self
    }

    ///Returns the base64Encoded string
    var base64Encoded:String {
        
        return Data(self.utf8).base64EncodedString()
    }
    
    ///Returns the string decoded from base64Encoded string
    var base64Decoded:String? {
        
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    var firstCharacter: Character {
        if self.length <= 0 {
            return Character(" ")
        }
        return self[self.index(self.startIndex, offsetBy: 0)]
    }
    
    var lastCharacter: Character {
        if self.length <= 0 {
            return Character(" ")
        }
        return self[self.index(self.endIndex, offsetBy: -1)]
    }
    
    var firstWord: String {
        if self.length <= 0 {
            return ""
        }
        return String(self.split(separator: " ").first ?? Substring(""))
    }
    
    var lastWord: String {
        if self.length <= 0 {
            return ""
        }
        return String(self.split(separator: " ").last ?? Substring(""))
    }

    var glyphCount: Int {
        let richText = NSAttributedString(string: self)
        let line = CTLineCreateWithAttributedString(richText)
        return CTLineGetGlyphCount(line)
    }
    
    var isSingleEmoji: Bool {
        
        return glyphCount == 1 && containsEmoji
    }
    
    var containsEmoji: Bool {
        
        return !unicodeScalars.filter { $0.isEmoji }.isEmpty
    }
    
    var containsOnlyEmoji: Bool {
        
        return unicodeScalars.first(where: { !$0.isEmoji && !$0.isZeroWidthJoiner }) == nil
    }
    
   
    // The next tricks are mostly to demonstrate how tricky it can be to determine emoji's
    // If anyone has suggestions how to improve this, please let me know
    var emojiString: String {
        
        return emojiScalars.map { String($0) }.reduce("", +)
    }
    
    var removeEmojis: String {
        
        var newString = self
        let emojisArr = newString.emojis
        for emoji in emojisArr{
            newString = newString.replacingOccurrences(of: emoji, with: "")
        }
        return newString
    }
    
    var emojis: [String] {
        
        var scalars: [[UnicodeScalar]] = []
        var currentScalarSet: [UnicodeScalar] = []
        var previousScalar: UnicodeScalar?
        
        for scalar in emojiScalars {
            
            if let prev = previousScalar, !prev.isZeroWidthJoiner && !scalar.isZeroWidthJoiner {
                
                scalars.append(currentScalarSet)
                currentScalarSet = []
            }
            currentScalarSet.append(scalar)
            
            previousScalar = scalar
        }
        
        scalars.append(currentScalarSet)
        
        return scalars.map { $0.map{ String($0) } .reduce("", +) }
    }
    
    
    func hilightAsterisk(withFont font: UIFont, textColor: UIColor = .black, asteriskColor: UIColor = .red) -> NSMutableAttributedString {

        guard self.hasSuffix("*") else {
            return NSMutableAttributedString(string: self)
        }
        
        let subTxt1 = self.substring(to: self.length-2)
        let subTxt2 = "*"
        
        let attributedStr1 = NSMutableAttributedString(string: subTxt1)
        attributedStr1.addAttributes([NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: textColor], range: NSRange(location: 0, length: subTxt1.length))
        
        let attributedStr2 = NSMutableAttributedString(string: subTxt2)
        attributedStr2.addAttributes([NSAttributedStringKey.font: font, NSAttributedStringKey.foregroundColor: asteriskColor], range: NSRange(location: 0, length: subTxt2.length))
        attributedStr1.append(attributedStr2)
        return attributedStr1
    }
    
    fileprivate var emojiScalars: [UnicodeScalar] {
        
        var chars: [UnicodeScalar] = []
        var previous: UnicodeScalar?
        for cur in unicodeScalars {
            
            if let previous = previous, previous.isZeroWidthJoiner && cur.isEmoji {
                chars.append(previous)
                chars.append(cur)
                
            } else if cur.isEmoji {
                chars.append(cur)
            }
            
            previous = cur
        }
        
        return chars
    }
    
    /// MARK:- Character count
    public var length: Int {
        return self.count
    }

    var isEmail: Bool{
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    var isPhoneNumber: Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSMakeRange(0, self.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == self.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    var isURL: Bool {
        let types: NSTextCheckingResult.CheckingType = [.link]
        let detector = try? NSDataDetector(types: types.rawValue)
        guard (detector != nil && self.count > 0) else { return false }
        if detector!.numberOfMatches(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) > 0 {
            return true
        }
        return false
    }
    
    var isAnyUrl:Bool{
        return (URL(string:self) != nil)
    }
    
    var hasVideoFileExtension: Bool {
        
        let arr = self.components(separatedBy: ".")
        if arr.count > 1{
            
            switch arr.last! {
            case "mp4","m4a","m4v","mov","wav","mp3":
                return true
            default:
                return false
            }
        }
        return false
    }
    
    // EZSE: remove Multiple Spaces And New Lines
    var removeAllWhiteSpacesAndNewLines: String {
        let components = self.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
    
    var removeLeadingTrailingWhitespaces:String{
        
        let spaceSet = CharacterSet.whitespacesAndNewlines
        return self.trimmingCharacters(in: spaceSet)
    }
    
    // Removing All WhiteSpaces
    var removeAllWhitespaces: String {
        return components(separatedBy: .whitespaces).joined()
    }
    
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    /// EZSE: Converts String to URL
    var toUrl: URL? {
        if self.hasPrefix("http://") || self.hasPrefix("https://"), let url = URL(string: self){
            return url
        }
        if self.hasPrefix("file://"), let url = URL(string: self){
            return url
        }
        else {
            return URL(fileURLWithPath: self)
        }
    }
    
    /// EZSE: Converts String to Int
    var toInt: Int? {
        if let num = NumberFormatter().number(from: self) {
            return num.intValue
        } else {
            return nil
        }
    }
    var toInt32: Int32? {
        if let int = self.toInt{
            return Int32(int)
        }
        return nil
    }
    var toInt64: Int64? {
        if let int = self.toInt{
            return Int64(int)
        }
        return nil
    }
    /// EZSE: Converts String to Double
    var toDouble: Double? {
        if let num = NumberFormatter().number(from: self) {
            return num.doubleValue
        } else {
            return nil
        }
    }
    
    /// EZSE: Converts String to Float
    var toFloat: Float? {
        if let num = NumberFormatter().number(from: self) {
            return num.floatValue
        } else {
            return nil
        }
    }
    var toFloat32: Float32? {
        if let float = self.toFloat{
            return Float32(float)
        }
        return nil
    }
    var toFloat64: Float64? {
        if let float = self.toFloat{
            return Float64(float)
        }
        return nil
    }
    var toCGFloat: CGFloat? {
        if let float = self.toFloat{
            return CGFloat(float)
        }
        return nil
    }
    var toJSONObject:Any? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: [])
            } catch {
                printD(error.localizedDescription)
            }
        }
        return nil
    }
    
    var unitFormattedString: String{
        
        if let value = self.toInt{
            
            switch value{
                
            case 1000..<1000000:
                return "\(value/1000)K"
            case 1000000..<1000000000:
                return "\(value/1000000)M"
            default:
                return self
            }
        }
        return ""
    }
    
    func contains(_ find: String) -> Bool{
        return self.range(of: find) != nil
    }
    
    func containsIgnoringCase(_ find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
    
    func substring(from: Int?, to: Int?) -> String {
        if let start = from {
            guard start < self.length else {
                return ""
            }
        }
        
        if let end = to {
            guard end >= 0 else {
                return ""
            }
        }
        
        if let start = from, let end = to {
            guard end - start >= 0 else {
                return ""
            }
        }
        
        let startIndex: String.Index
        if let start = from, start >= 0 {
            startIndex = self.index(self.startIndex, offsetBy: start)
        } else {
            startIndex = self.startIndex
        }
        
        let endIndex: String.Index
        if let end = to, end >= 0, end < self.length {
            endIndex = self.index(self.startIndex, offsetBy: end + 1)
        } else {
            endIndex = self.endIndex
        }
        
        return String(self[startIndex ..< endIndex])
    }
    
    func substring(from: Int) -> String {
        return self.substring(from: from, to: nil)
    }
    
    func substring(to: Int) -> String {
        return self.substring(from: nil, to: to)
    }
    
    func substring(from: Int?, length: Int) -> String {
        guard length > 0 else {
            return ""
        }
        
        let end: Int
        if let start = from, start > 0 {
            end = start + length - 1
        } else {
            end = length - 1
        }
        
        return self.substring(from: from, to: end)
    }
    
    func substring(length: Int, to: Int?) -> String {
        guard let end = to, end > 0, length > 0 else {
            return ""
        }
        
        let start: Int
        if let end = to, end - length > 0 {
            start = end - length + 1
        } else {
            start = 0
        }
        
        return self.substring(from: start, to: to)
    }
    
    /// EZSE: Capitalizes first character of String
    public mutating func capitalizeFirst() {
        guard self.count > 0 else { return }
        self.replaceSubrange(startIndex...startIndex, with: String(self[startIndex]).capitalized)
    }
    
    /// EZSE: Capitalizes first character of String, returns a new string
    public func capitalizedFirst() -> String {
        guard self.count > 0 else { return self }
        var result = self
        
        result.replaceSubrange(startIndex...startIndex, with: String(self[startIndex]).capitalized)
        return result
    }
    
    /// EZSE: lowerCased first character of String, returns a new string
    public func lowerCaseFirst() -> String {
        guard self.count > 0 else { return self }
        var result = self
        
        result.replaceSubrange(startIndex...startIndex, with: String(self[startIndex]).lowercased())
        return result
    }
    
  
    func heighLightHashTags(hashTagsFont: UIFont, hashTagsColor: UIColor) -> NSMutableAttributedString{
        
        let stringWithTags : NSString  = self as NSString
        let regex: NSRegularExpression = try! NSRegularExpression(pattern: "[#](\\w+)", options: NSRegularExpression.Options.caseInsensitive)
        
        let matches: [NSTextCheckingResult] = regex.matches(in: stringWithTags as String, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, stringWithTags.length))
        let attString: NSMutableAttributedString = NSMutableAttributedString(string: self, attributes: [NSAttributedStringKey.font: hashTagsFont])
        for match: NSTextCheckingResult in matches {
            let wordRange: NSRange = match.range(at: 0)
            //Set Font
            attString.addAttribute(NSAttributedStringKey.font, value: hashTagsFont, range: NSMakeRange(0, stringWithTags.length))
            //Set Foreground Color
            attString.addAttribute(NSAttributedStringKey.foregroundColor, value: hashTagsColor, range: wordRange)
        }
        return attString
    }
    
    func allWords(startWith: String) -> [String] {
        
        var tags = [String]()
        let stringWithTags : NSString  = self as NSString
        let regex: NSRegularExpression = try! NSRegularExpression(pattern: "[\(startWith)](\\w+)", options: NSRegularExpression.Options.caseInsensitive)
        
        let matches: [NSTextCheckingResult] = regex.matches(in: stringWithTags as String, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, stringWithTags.length))
        
        let nsString = NSString(string: self)

        for match in matches {
            let wordRange: NSRange = match.range(at: 0)
            let wordText = nsString.substring(with: wordRange)
            tags.append(String(wordText))
        }
        return tags
    }
    
    func indexOf(subString: String) -> Int? {
        var pos: Int?
        if let range = self.range(of: subString) {
            if !range.isEmpty {
                pos = self.distance(from: self.startIndex, to: range.lowerBound)
            }
        }
        return pos
    }
    
    func sizeCount(withFont font: UIFont, bundingSize size: CGSize) -> CGSize {
        
        let mutableParagraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle()
        mutableParagraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        let attributes: [NSAttributedStringKey : Any] = [NSAttributedStringKey.font: font, NSAttributedStringKey.paragraphStyle: mutableParagraphStyle]
        let tempStr = NSString(string: self)
        
        let rect: CGRect = tempStr.boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        let height = ceilf(Float(rect.size.height))
        let width = ceilf(Float(rect.size.width))
        return CGSize(width: CGFloat(width), height: CGFloat(height))
    }
    
    ///Converts the string into 'Date' if possible, based on the given date format and timezone. otherwise returns nil
    func toDate(dateFormat:String,timeZone:TimeZone = TimeZone.current)->Date?{
        
        let frmtr = DateFormatter()
        frmtr.locale = Locale(identifier: "en_US_POSIX")
        frmtr.dateFormat = dateFormat
        frmtr.timeZone = timeZone
        return frmtr.date(from: self)
    }
    
   
}
