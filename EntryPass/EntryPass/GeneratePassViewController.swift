//
//  GeneratePassViewController.swift
//  EntryPass
//
//  Created by Иван Николаев on 09.06.2021.
//

import UIKit
import CryptoKit


class GeneratePassViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        labelTimer.alpha = 0
        // Do any additional setup after loading the view.
    }
    var timer: Timer?
    @IBOutlet weak var imageQRcodePass: UIImageView!
    
    @IBOutlet weak var labelTimer: UILabel!
     
    var seconds = 60 // Эта переменная будет содержать начальное значение в секундах. Это может быть любая сумма, превышающая 0.
    var timerPass = Timer()
    var isTimerRunning = false // Это будет использоваться, чтобы убедиться, что одновременно создается только один таймер.
    
    func runTimer () {
        timerPass = Timer.scheduledTimer (timeInterval: 1, target: self, selector: (#selector (updateTimer)), userInfo: nil, repeats: true)
    }
    @objc func updateTimer () {
        if seconds > 0 {
            seconds -= 1 // Это уменьшит (обратный отсчет) секунд.
            labelTimer.text = "\(seconds)" // Это обновит метку.
        }
        else{
            //seconds = 60
            labelTimer.text = "Время вышло! Обновите пропуск"
        }
    }
    
    
    
    @IBAction func buttonGeneratePass(_ sender: Any) {
        timerPass.invalidate()
        seconds = 60
        runTimer()
        labelTimer.alpha = 1
        let idStr = keychain.get("my idStr")! as String
        
        let idData = Data(idStr.utf8)
        let privateKeyPresentation = keychain.getData("my privateKey")!
        let timeInterval = String(Int(NSDate().timeIntervalSince1970))
        let timeData = Data(timeInterval.utf8)
        
        let privateKey1 = try? Curve25519.Signing.PrivateKey(rawRepresentation: keychain.getData("my privateKey")!)
        let publicKeyStr1 = privateKey1!.publicKey.rawRepresentation.hexEncodedString()
        
        let timeIntervalStr = String(timeInterval)
        
        let privateKey = try? Curve25519.Signing.PrivateKey.init(rawRepresentation: privateKeyPresentation)
        
        let idTimeData = idData + timeData
        
        print("\n\n\n\n\n\n\n",publicKeyStr1,"\n\n\n\n\n\n")
        
        if let signature = try? privateKey!.signature(for: idTimeData) {
            let mesign = idStr + "." + timeIntervalStr + "." + signature.hexEncodedString()
            let sign = Data(mesign.utf8)
            print(mesign)
            filter.setValue(sign, forKey: "inputMessage")

            let ciImage = filter.outputImage

            let transform = CGAffineTransform(scaleX:10, y: 10)
            let transformImage = ciImage?.transformed(by: transform)
            let image = UIImage(ciImage: transformImage!)
            imageQRcodePass.image = image
        }
       
        
    }
}


