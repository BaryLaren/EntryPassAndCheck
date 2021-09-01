//
//  GenerateKeysViewController.swift
//  EntryPass
//
//  Created by Иван Николаев on 09.06.2021.
//

import UIKit
import UIKit
import Foundation
import CryptoKit
import SwiftUI
import AVFoundation
import CoreImage.CIFilterBuiltins
import KeychainSwift

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return self.map { String(format: format, $0) }.joined()
    }
}

extension String {
  /// A data representation of the hexadecimal bytes in this string.
  func hexDecodedData() -> Data {
    // Get the UTF8 characters of this string
    let chars = Array(utf8)

    // Keep the bytes in an UInt8 array and later convert it to Data
    var bytes = [UInt8]()
    bytes.reserveCapacity(count / 2)

    // It is a lot faster to use a lookup map instead of strtoul
    let map: [UInt8] = [
      0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, // 01234567
      0x08, 0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // 89:;<=>?
      0x00, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x00, // @ABCDEFG
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  // HIJKLMNO
    ]

    // Grab two characters at a time, map them and turn it into a byte
    for i in stride(from: 0, to: count, by: 2) {
      let index1 = Int(chars[i] & 0x1F ^ 0x10)
      let index2 = Int(chars[i + 1] & 0x1F ^ 0x10)
      bytes.append(map[index1] << 4 | map[index2])
    }

    return Data(bytes)
  }
}

let filter = CIFilter.qrCodeGenerator()
let context = CIContext()


class GenerateKeysViewController: UIViewController {
    
    var proverka = false
    @IBOutlet weak var imageQRcode: UIImageView!
    @IBOutlet weak var labelAdmin: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        labelAdmin.alpha = 0
        
        // Do any additional setup after loading the view.
    }
    
    
    let filter = CIFilter.qrCodeGenerator()
    let context = CIContext()
    
    
    
    func generateQRcode(){
        let generatePrivateKey = Curve25519.Signing.PrivateKey().rawRepresentation
        
        if keychain.getData("my privateKey") == nil{
            keychain.set(generatePrivateKey, forKey: "my privateKey")
        }
        
        let privateKey = try? Curve25519.Signing.PrivateKey(rawRepresentation: keychain.getData("my privateKey")!)
        let publicKeyStr = privateKey!.publicKey.rawRepresentation.hexEncodedString()
        
        let publicKey = Data(publicKeyStr.utf8)
        let idStr = keychain.get("my idStr")!
        let idData = Data(idStr.utf8)
            print("\n\n\n\n\n\n\n",publicKeyStr,"\n\n\n\n\n\n")
            let idPublicKey = idData + publicKey
            filter.setValue(idPublicKey, forKey: "inputMessage")
            
            let ciImage = filter.outputImage
            
            let transform = CGAffineTransform(scaleX:10, y: 10)
            let transformImage = ciImage?.transformed(by: transform)
            let image = UIImage(ciImage: transformImage!)
            imageQRcode.image = image
    }
    
    
    @IBAction func buttonGettingKeys(_ sender: Any) {
        generateQRcode()
        labelAdmin.text = "Предъявите QR-код администратору"
        labelAdmin.alpha = 1
        proverka = true
        
    }
    
    @IBAction func buttonNext(_ sender: Any) {
        if proverka == false{
            labelAdmin.text = "Сгенерируйте ключи"
            labelAdmin.alpha = 1
        }else{
            let alert = UIAlertController(title: "Внимание!", message: "Вы уверены, что предъявили ключ администратору?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { (action) in
            keychain.set("123", forKey: "nextDoor")
            self.present((self.storyboard!.instantiateViewController(withIdentifier: "123")), animated: true, completion: nil)}))
            alert.addAction(UIAlertAction(title: "Отмена", style: .default, handler: { (action) in
            }))
            self.present(alert, animated: true, completion: nil)}
        }
        }

    
    


