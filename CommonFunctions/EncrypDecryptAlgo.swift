//
//  EncrypDecryptAlgo.swift
//  CommonFunctions
//
//  Created by mac on 03/05/21.
//

import UIKit
import Foundation
import CommonCrypto

let keyData     = "12345678901234567890123456789012".data(using:String.Encoding.utf8)!
 let ivData      = "abcdefghijklmnop".data(using:String.Encoding.utf8)!


func testCrypt(data:Data, operation:Int) -> Data {
          let cryptLength  = size_t(data.count + kCCBlockSizeAES128)
          var cryptData = Data(count:cryptLength)
          let keyLength             = size_t(kCCKeySizeAES256)
          let options   = CCOptions(kCCOptionPKCS7Padding)
           var numBytesEncrypted :size_t = 0
           let cryptStatus = cryptData.withUnsafeMutableBytes {cryptBytes in
              data.withUnsafeBytes {dataBytes in
                  ivData.withUnsafeBytes {ivBytes in
                      keyData.withUnsafeBytes {keyBytes in
                          CCCrypt(CCOperation(operation),
                                    CCAlgorithm(kCCAlgorithmAES),
                                    options,
                                    keyBytes, keyLength,
                                    ivBytes,
                                    dataBytes, data.count,
                                    cryptBytes, cryptLength,
                                    &numBytesEncrypted)
                      }
                  }
              }
          }
          if UInt32(cryptStatus) == UInt32(kCCSuccess) {
              cryptData.removeSubrange(numBytesEncrypted..<cryptData.count)
          } else {
              print("Error: \(cryptStatus)")
          }
          return cryptData;
      }

func encryptIntoBase64Encode(plainText:String)->String{
     let messageData = plainText.data(using:String.Encoding.utf8)!
    let encryptedData = testCrypt(data:messageData, operation:kCCEncrypt)
    let base64String = encryptedData.base64EncodedString()
    return base64String
}

func decriptFromBase64Encode(base64String:String)->String{
    let b64decoded = Data(base64Encoded: base64String, options: Data.Base64DecodingOptions(rawValue: Data.Base64DecodingOptions.RawValue(0)))
    let newdecrypteddata = testCrypt(data:b64decoded!, operation:kCCDecrypt)
    let plainText = String(bytes:newdecrypteddata, encoding:String.Encoding.utf8)!
    return plainText
}
