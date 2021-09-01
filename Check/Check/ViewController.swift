//
//  ViewController.swift
//  Check
//
//  Created by Иван Николаев on 18.05.2021.
//

import UIKit
import AVFoundation
import FirebaseDatabase
import CryptoKit

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
    func subString(from: Int, to: Int) -> String {
           let startIndex = self.index(self.startIndex, offsetBy: from)
           let endIndex = self.index(self.startIndex, offsetBy: to)
           return String(self[startIndex..<endIndex])
        }
}


class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    let rootRef = Database.database().reference()
    var video = AVCaptureVideoPreviewLayer()
    //1. Настроим сессию
    let session = AVCaptureSession()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupVideo()
    }
    
    func setupVideo(){

        //2. Настраиваем устройство видео
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        //3. Настроим input
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            session.addInput(input)
        } catch{
            fatalError(error.localizedDescription)
        }
        //4. Настроим output
        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        //5
        video = AVCaptureVideoPreviewLayer(session: session)
        video.frame = view.layer.bounds
    }
    
    func startRunning(){
        view.layer.addSublayer(video)
        session.startRunning()
    }
    @IBAction func checkButton(_ sender: Any) {
        startRunning()}
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard metadataObjects.count > 0 else {return}

        if let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
            if object.type  == AVMetadataObject.ObjectType.qr{ //Проверка на то-что перед камерой QR-код
                let p = object.stringValue as Any //Извлечение из QR-кода информации
                if let k = p as? String{//Перевод информации к строке
                    let QrcodeArray = k.components(separatedBy: ".") //Разбиение информации на массив
                    let id = QrcodeArray[0]
                    let timePass = QrcodeArray[1]
                    let timePassInt = Int(timePass)
                    let sign = QrcodeArray[2].hexDecodedData()//Декодирование
                    let idTime = id + timePass
                    let dataData = Data(idTime.utf8)
                    
                    rootRef.child(id).observeSingleEvent(of : .value, with : { [weak self](snapshot) in // Берем из бд публичный ключ по id
                            if let pKeyStr = snapshot.value as? String {
                                let dataFromString = pKeyStr.hexDecodedData()
                                if let publicKey = try? Curve25519.Signing.PublicKey(rawRepresentation: dataFromString) {
                                    
                                                    if publicKey.isValidSignature(sign, for: dataData) {//Проверка подписи
                                                        
                                                                let timeInt = Int(NSDate().timeIntervalSince1970)
                                                                let minus60Int = timeInt-60

                                                        if timePassInt! > minus60Int {//Проверка времени
                                                                    let alert = UIAlertController(title: "Проверка", message: "Пропуск действителен", preferredStyle: .alert)
                                                                    alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: { (action) in
                                                                    }))
                                                                    self!.present(alert, animated: true, completion: nil)

                                                                }else{
                                                                    let alert = UIAlertController(title: "Проверка", message: "Пропуск просрочен", preferredStyle: .alert)
                                                                    alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: { (action) in
                                                                    }))
                                                                    self!.present(alert, animated: true, completion: nil)
                                                                }
                                                    }else{
                                                        let alert = UIAlertController(title: "Проверка", message: "Подпись неверна", preferredStyle: .alert)
                                                        alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: { (action) in
                                                        }))
                                                        self!.present(alert, animated: true, completion: nil)
                                                    }
                                            }else{
                                                let alert = UIAlertController(title: "Проверка", message: "Пропуск недействителен, обратитесь к администратору", preferredStyle: .alert)
                                                alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: { (action) in
                                                }))
                                                self!.present(alert, animated: true, completion: nil)
                                            }
                            }else{
                                let alert = UIAlertController(title: "Проверка", message: "Пропуск недействителен, обратитесь к администратору", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: { (action) in
                                }))
                                self!.present(alert, animated: true, completion: nil)
                                
                            }
                            })
                        }
                    }
                }
        }
}


