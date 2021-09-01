//
//  ViewController.swift
//  EntryPass
//
//  Created by Иван Николаев on 09.06.2021.
//

import UIKit
import Darwin
var nextDoor = keychain.get("nextDoor")//
let myIdStr = keychain.get("my idStr")
let myPrivateKey = keychain.getData("my privateKey")
let checkOnFirstStart = checkFirstStart()

class ViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
        
            
            
        if checkOnFirstStart == "Not first launch." &&  myIdStr != nil && myPrivateKey != nil && nextDoor != nil{
            performSegue(withIdentifier: "123", sender: nil)
        }
        else if checkOnFirstStart == "Not first launch." && myIdStr != nil && nextDoor == nil{
            performSegue(withIdentifier: "12", sender: nil)
        }
        else if checkOnFirstStart == "Not first launch." && myIdStr == nil {
            performSegue(withIdentifier: "1", sender: nil)
        }
        else{
            keychain.delete("my idStr")
            keychain.delete("my privateKey")
            keychain.delete("nextDoor")
            performSegue(withIdentifier: "1", sender: nil)
    }

}

}

func checkFirstStart() -> String{
    let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
    if launchedBefore  {
        return "Not first launch."
    } else {
        UserDefaults.standard.set(true, forKey: "launchedBefore")
        return "First launch, setting UserDefault."
    }
}




