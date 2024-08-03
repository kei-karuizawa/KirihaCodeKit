//
//  KCKString.swift
//  Kiriha
//
//  Created by 御前崎悠羽 on 2022/3/22.
//

import Foundation

// MARK: - 字符串序号及字串操作。

extension String {
    
    subscript(i: Int) -> String {
        if i < 0 || i >= self.count {
            return ""
        }
        for (index, item) in self.enumerated() {
            if index == i {
                return "\(item)"
            }
        }
        return ""
    }
    
    subscript(r: ClosedRange<Int>) -> String {
        let start: String.Index = self.index(startIndex, offsetBy: max(r.lowerBound, 0))
        let end: String.Index = self.index(startIndex, offsetBy: min(r.upperBound, count - 1))
        return String(self[start...end])
    }
    
    subscript(r: Range<Int>) -> String {
        let start: String.Index = self.index(startIndex, offsetBy: max(r.lowerBound, 0))
        let end: String.Index = self.index(startIndex, offsetBy: min(r.upperBound, count))
        return String(self[start..<end])
    }
    
    subscript(r: PartialRangeThrough<Int>) -> String {
        let end: String.Index = self.index(startIndex, offsetBy: min(r.upperBound, count - 1))
        return String(self[startIndex...end])
    }
    
    subscript(r: PartialRangeFrom<Int>) -> String {
        let start: String.Index = self.index(startIndex, offsetBy: max(r.lowerBound, 0))
        let end: String.Index = self.index(startIndex, offsetBy: count - 1)
        return String(self[start...end])
    }
    
    subscript(r: PartialRangeUpTo<Int>) -> String {
        let end: String.Index = self.index(startIndex, offsetBy: min(r.upperBound, count))
        return String(self[startIndex..<end])
    }
    
    public func kiriha_subString(start: Int, to: Int) -> String {
        let st: String.Index = self.index(startIndex, offsetBy: start)
        let en: String.Index = self.index(st, offsetBy: to)
        return String(self[st..<en])
    }
    
    public func kiriha_subString(start: Int, length: Int) -> String {
        var len: Int = length
        if len == -1 {
            len = count - start
        }
        let st: String.Index = self.index(startIndex, offsetBy:start)
        let en: String.Index = index(st, offsetBy:len)
        return String(self[st..<en])
    }
    
    public func kiriha_replace(from: Int, to: Int, withString: String) -> String {
        var text: String = self
        let range: Range<String.Index> = self.index(endIndex, offsetBy: from - count)..<index(endIndex, offsetBy: to - count)
        text.replaceSubrange(range, with: withString)
        return text
    }
    
    public func kiriha_replace(from: Int, length: Int, withString: String) -> String {
        var text = self
        let range: Range<String.Index> = self.index(endIndex, offsetBy: from - count)..<index(endIndex, offsetBy: from - count + length)
        text.replaceSubrange(range, with: withString)
        return text
    }
    
    public func kiriha_replace(string: String, withString: String) -> String {
        return replacingOccurrences(of: string, with: withString)
    }
}

// MARK: - 字符串正则判断。

extension String {

    public func kiriha_isTelPhone() -> Bool {
        if count <= 0 {
            return false
        }

        let mobile: String = "^1([358][0-9]|4[579]|66|7[0135678]|9[89])[0-9]{8}$"
        let regexMobile: NSPredicate = NSPredicate(format: "SELF MATCHES %@",mobile)
        return regexMobile.evaluate(with: self)
    }

    public func kiriha_isIntNumber() -> Bool {
        let scan: Scanner = Scanner(string: self)
        var val: Int = 0
        return scan.scanInt(&val) && scan.isAtEnd
    }

    public func kiriha_isFloatNumber() -> Bool {
        let scan: Scanner = Scanner(string: self)
        var val: Float = 0
        return scan.scanFloat(&val) && scan.isAtEnd
    }

    public func kiriha_isEmail() -> Bool {
        if self.count <= 0 {
            return false
        }
        let emailRegex: String = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: self)
    }
    
    private func getStringByRangeIntValue(_ string: String, location: Int, length: Int) -> Int {
        let c = string.kiriha_subString(start: location, length: length)
        return Int(c)!
    }

    public func kiriha_isIDNumber() -> Bool {
        var value: String = self
        value = value.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        var length: Int = 0
        length = value.count
        if length != 15 && length != 18{
            // 不满足 15 位和 18 位，即身份证错误。
            return false
        }
        // 省份代码。
        let areasArray: [String] = ["11", "12", "13", "14", "15", "21", "22", "23", "31", "32", "33", "34", "35", "36", "37", "41", "42", "43", "44", "45", "46", "50", "51", "52", "53", "54", "61", "62", "63", "64", "65", "71", "81", "82", "91"]
        // 检测省份身份行政区代码。
        let valueStart2: String = value.kiriha_subString(start: 0, length: 2)
        // 标识省份代码是否正确。
        var areaFlag: Bool = false
        for areaCode in areasArray {
            if areaCode == valueStart2 {
                areaFlag = true
                break
            }
        }
        if !areaFlag {
            return false
        }
        var regularExpression: NSRegularExpression?
        var numberofMatch: Int?
        var year: Int = 0
        switch length {
        case 15:
            // 获取年份对应的数字。
            let valueNSStr: String = value
            let yearStr: String = valueNSStr.kiriha_subString(start: 6, length: 2)
            year = Int(yearStr)! + 1900
            if year % 4 == 0 || (year % 100 == 0 && year % 4 == 0) {
                // 创建正则表达式 NSRegularExpressionCaseInsensitive：不区分字母大小写的模式。
                // 测试出生日期的合法性。
                regularExpression = try! NSRegularExpression.init(pattern: "^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}$", options: NSRegularExpression.Options.caseInsensitive)
            } else {
                // 测试出生日期的合法性。
                regularExpression = try! NSRegularExpression.init(pattern: "^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}$", options: NSRegularExpression.Options.caseInsensitive)
            }
            numberofMatch = regularExpression?.numberOfMatches(in: value, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSRange.init(location: 0, length: value.count))
            return numberofMatch! > 0
        case 18:
            let valueNSStr: String = value
            let yearStr: String = valueNSStr.kiriha_subString(start: 6, length: 4)
            year = Int(yearStr)!
            if year % 4 == 0 || (year % 100 == 0 && year % 4 == 0) {
                // 测试出生日期的合法性。
                regularExpression = try! NSRegularExpression.init(pattern: "^((1[1-5])|(2[1-3])|(3[1-7])|(4[1-6])|(5[0-4])|(6[1-5])|71|(8[12])|91)\\d{4}(((19|20)\\d{2}(0[13-9]|1[012])(0[1-9]|[12]\\d|30))|((19|20)\\d{2}(0[13578]|1[02])31)|((19|20)\\d{2}02(0[1-9]|1\\d|2[0-8]))|((19|20)([13579][26]|[2468][048]|0[048])0229))\\d{3}(\\d|X|x)?$", options: NSRegularExpression.Options.caseInsensitive)

            } else {
                // 测试出生日期的合法性。
                regularExpression = try! NSRegularExpression.init(pattern: "^((1[1-5])|(2[1-3])|(3[1-7])|(4[1-6])|(5[0-4])|(6[1-5])|71|(8[12])|91)\\d{4}(((19|20)\\d{2}(0[13-9]|1[012])(0[1-9]|[12]\\d|30))|((19|20)\\d{2}(0[13578]|1[02])31)|((19|20)\\d{2}02(0[1-9]|1\\d|2[0-8]))|((19|20)([13579][26]|[2468][048]|0[048])0229))\\d{3}(\\d|X|x)?$", options: NSRegularExpression.Options.caseInsensitive)

            }
            numberofMatch = regularExpression?.numberOfMatches(in: value, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSRange.init(location: 0, length: value.count))

            if numberofMatch! > 0 {
                let a: Int = getStringByRangeIntValue(valueNSStr, location: 0, length: 1) * 7
                let b: Int = getStringByRangeIntValue(valueNSStr, location: 10, length: 1) * 7
                let c: Int = getStringByRangeIntValue(valueNSStr, location: 1, length: 1) * 9
                let d: Int = getStringByRangeIntValue(valueNSStr, location: 11, length: 1) * 9
                let e: Int = getStringByRangeIntValue(valueNSStr, location: 2, length: 1) * 10
                let f: Int = getStringByRangeIntValue(valueNSStr, location: 12, length: 1) * 10
                let g: Int = getStringByRangeIntValue(valueNSStr, location: 3, length: 1) * 5
                let h: Int = getStringByRangeIntValue(valueNSStr, location: 13, length: 1) * 5
                let i: Int = getStringByRangeIntValue(valueNSStr, location: 4, length: 1) * 8
                let j: Int = getStringByRangeIntValue(valueNSStr, location: 14, length: 1) * 8
                let k: Int = getStringByRangeIntValue(valueNSStr, location: 5, length: 1) * 4
                let l: Int = getStringByRangeIntValue(valueNSStr, location: 15, length: 1) * 4
                let m: Int = getStringByRangeIntValue(valueNSStr, location: 6, length: 1) * 2
                let n: Int = getStringByRangeIntValue(valueNSStr, location: 16, length: 1) * 2
                let o: Int = getStringByRangeIntValue(valueNSStr, location: 7, length: 1) * 1
                let p: Int = getStringByRangeIntValue(valueNSStr, location: 8, length: 1) * 6
                let q: Int = getStringByRangeIntValue(valueNSStr, location: 9, length: 1) * 3
                let S: Int = a + b + c + d + e + f + g + h + i + j + k + l + m + n + o + p + q

                let Y: Int = S % 11
                var M: String = "F"
                let JYM: String = "10X98765432"
                M = JYM.kiriha_subString(start: Y, length: 1)
                let lastStr: String = valueNSStr.kiriha_subString(start: 17, length: 1)

                if lastStr == "x" {
                    return M == "X"
                } else {
                    return M == lastStr
                }

            } else {
                return false
            }
        default:
            return false
        }
    }
}

// MARK: - 编码。

extension String {
    
    public func kiriha_urlEncoded() -> String {
        let encodeUrlString: String? = addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        return encodeUrlString ?? ""
    }
    
    public func kiriha_urlDecoded() -> String {
        return self.removingPercentEncoding ?? ""
    }
}
