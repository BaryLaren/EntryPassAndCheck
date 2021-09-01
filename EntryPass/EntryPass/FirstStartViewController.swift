//
//  FirstStartViewController.swift
//  EntryPass
//
//  Created by Иван Николаев on 09.06.2021.
//

import UIKit
import KeychainSwift
let keychain = KeychainSwift()
class FirstStartViewController: UIViewController {
    var id: Int = 0
    
    @IBOutlet weak var textId: UITextField!
    
    @IBOutlet weak var labelError: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }

    @IBAction func buttonSaveId(_ sender: Any) {
        labelError.alpha = 0
        if checkValid() != nil {
            labelError.text = checkValid()}else{   if textId.text?.count == 6  {
                id = (textId.text! as NSString).integerValue // перевод строки в число
                let idStr = textId.text!
                textId.text = idStr
                let alert = UIAlertController(title: "Внимание!", message: "Вы уверены, что введены верные данные?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { (action) in
                    if keychain.get("my idStr") == nil{
                        keychain.set(idStr, forKey: "my idStr")
                            }
                self.present((self.storyboard!.instantiateViewController(withIdentifier: "12")), animated: true, completion: nil)}))
                alert.addAction(UIAlertAction(title: "Отмена", style: .default, handler: { (action) in
                }))
                self.present(alert, animated: true, completion: nil)
                
                //print(type(of: keychain.get("my idStr")))
                //self.present((self.storyboard!.instantiateViewController(withIdentifier: "12")), animated: true, completion: nil) // переход к другому окну
                
            }
                
            }
}
    
    func checkValid()->String?{
        if textId.text == ""{
            labelError.alpha = 1
            return "Поле незаполнено"
        }
        if textId.text!.count < 6{
            labelError.alpha = 1
            return "Неполные данные"
        }
        if textId.text!.count > 7{
            labelError.alpha = 1
            return "Лишние данные"
        }
           return nil
}


}
