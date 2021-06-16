//
//  otpWithAutoFill.swift
//  CommonFunctions
//
//  Created by mac on 16/06/21.
//

import UIKit

class otpWithAutoFill: UIViewController {
    @IBOutlet weak var TFotp: UITextField!
    @IBOutlet weak var one: UITextField!
    @IBOutlet weak var two: UITextField!
    @IBOutlet weak var three: UITextField!
    @IBOutlet weak var four: UITextField!
    
    @IBOutlet weak var viewone:  UIView!
    @IBOutlet weak var viewtwo:  UIView!
    @IBOutlet weak var viewthree:UIView!
    @IBOutlet weak var viewfour: UIView!
    @IBOutlet weak var resend: UIButton!
    
    @IBOutlet weak var nextbtn: UIButton!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var error: UILabel!
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var bgImage: UIImageView!
    
    @IBOutlet weak var lblHeaderFirst: UILabel!
    @IBOutlet weak var lblHeaderSecond: UILabel!
    @IBOutlet weak var lblEnterOTP: UILabel!
    
    var isInterestAvailable = false
    var isLanguageAvailable = false
    
    var countdownTimer: Timer!
    var totalTime = 60
    
    var Otp = ""
    var phoneNumber = ""
    var restart: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        otptext()
        startTimer()
        butncolrsimple()
        number.text = self.phoneNumber + "-" + Otp
        self.resend.isEnabled = false
        //self.resend.titleLabel?.textColor = UIColor(red: 81/255, green: 91/255, blue: 112/255, alpha: 1)
        self.resend.setTitleColor(UIColor(red: 81/255, green: 85/255, blue: 95/255, alpha: 1), for: .normal)
        // loadString(Loc:"\(AppDelegate.appDelegate.selectedLanguage)")
        
        if #available(iOS 12.0, *) {
            TFotp.textContentType = .oneTimeCode
        }
        TFotp.isHidden = true
        //TFotp.delegate = self
    }
    
    func loadString(Loc: String){
        self.error.text = "".localizableString(localizedString: Loc)
        self.resend.setTitle("resend".localizableString(localizedString: Loc), for: .normal)
        self.nextbtn.setTitle("next".localizableString(localizedString: Loc), for: .normal)
        //        self.lblHeaderFirst.text = "".localizableString(localizedString: Loc)
        self.lblEnterOTP.text = "enter-otp".localizableString(localizedString: Loc)
        //        self.lblHeaderSecond.text = "".localizableString(localizedString: Loc)
    }
    
    
    
    func startTimer() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateTime() {
        time.text = "\(timeFormatted(totalTime))"
        print("h:- \(totalTime)")
        if totalTime == 0 {
            self.resend.isEnabled = true
            self.time.isHidden = true
            //self.resend.titleLabel?.textColor = UIColor.white
            self.resend.setTitleColor(UIColor.white, for: .normal)
        }
        if totalTime != 0 {
            print("vall")
            totalTime -= 1
        } else {
            print("call")
            endTimer()
        }
    }
    
    func endTimer() {
        totalTime = 60
        countdownTimer.invalidate()
    }
    
    func butncolrsimple(){
        nextbtn.setGradientBackgroundColors([UIColor(hex: "4d586c"), UIColor(hex: "4d586c")], direction: DTImageGradientDirection.toRight, for: UIControl.State.normal)
        nextbtn.backgroundColor = UIColor(hex: "4d586c")
        nextbtn.layer.cornerRadius = 21
        nextbtn.layer.masksToBounds = true
    }
    
    func butoncolorGradiant(){
        nextbtn.setGradientBackgroundColors([UIColor(hex: "f16112"), UIColor(hex: "e50438")], direction: DTImageGradientDirection.toRight, for: UIControl.State.normal)
        nextbtn.layer.cornerRadius = 21
        nextbtn.layer.masksToBounds = true
    }
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    @IBAction func onTapTerms(_ sender: Any) {
      
    }
    
    @IBAction func onTapPolicy(_ sender: Any) {
      
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        
        
        
        let view = UIView(frame: UIScreen.main.bounds)
        let gradient = CAGradientLayer()
        gradient.frame = view.frame
        
        
//        var gradcolor = UIColor()
//        if #available(iOS 13.0, *) {
//            gradcolor = UIColor(named: "STColorBackground")!
//        }else{
//            gradcolor = UIColor(red: 37/255, green: 42/255, blue: 55/255, alpha: 1)
//        }
//        gradient.colors = [UIColor.clear.cgColor, gradcolor.cgColor]
//        gradient.locations = [0.0, 0.99]
//        view.layer.insertSublayer(gradient, at: 0)
        self.bgImage.addSubview(view)
        self.bgImage.bringSubviewToFront(view)
    }
    
    
    func otptext(){
        one.delegate = self
        two.delegate = self
        three.delegate = self
        four.delegate = self
        one.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        two.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        three.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        four.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        
        let charec = string.cString(using: .utf8)
        let isBackspc: Int = Int(strcmp(charec, "\\b"))
        if isBackspc == -92 {
            return true
        }
        
        
        if string == "" {
            return false
        }
        if range.length == 0{
            if textField.tag == 0{
                one.text = string
            }
            if textField.tag == 1{
                two.text = string
            }
            if textField.tag == 2{
                three.text = string
            }
            if textField.tag == 3{
                four.text = string
            }
            print(string)
            if textField == one {
                two.becomeFirstResponder()
            }
            if textField == two {
                three.becomeFirstResponder()
            }
            if textField == three{
                four.becomeFirstResponder()
            }
            if textField == four {
                four.becomeFirstResponder()
            }
            let first = one.text
            let second = two.text
            let third = three.text
            let fourth = four.text
            let mainOtp = "\(first ?? "1")" + "\(second ?? "1")" + "\(third ?? "1")" + "\(fourth ?? "1")"
            if mainOtp != Otp {
                errorotp()
            } else {
                fineotp()
            }
            return false
        }
        
        return true
    }
    
    
    @objc func textFieldDidChange(textField: UITextField){
        let text = textField.text
        
        if  text?.count == 1 {
            switch textField{
            case one:
                two.becomeFirstResponder()
            //                viewone.layer.borderWidth = 1
            //                viewone.layer.borderColor = UIColor.green.cgColor
            case two:
                three.becomeFirstResponder()
            //                viewtwo.layer.borderWidth = 1
            //                viewtwo.layer.borderColor = UIColor.green.cgColor
            case three:
                four.becomeFirstResponder()
            //                viewthree.layer.borderWidth = 1
            //                viewthree.layer.borderColor = UIColor.green.cgColor
            case four:
                four.resignFirstResponder()
                //                viewfour.layer.borderWidth = 1
                //                viewfour.layer.borderColor = UIColor.green.cgColor
                butoncolorGradiant()
                
            default:
                break
            }
        }
        if  text?.count == 0 {
            switch textField{
            case one:
                one.becomeFirstResponder()
            case two:
                one.becomeFirstResponder()
            case three:
                two.becomeFirstResponder()
            case four:
                three.becomeFirstResponder()
            default:
                break
            }
        }
        else{
            
        }
        
        let first = one.text
        let second = two.text
        let third = three.text
        let fourth = four.text
        let mainOtp = "\(first ?? "1")" + "\(second ?? "1")" + "\(third ?? "1")" + "\(fourth ?? "1")"
        if mainOtp != Otp {
            errorotp()
        } else {
            fineotp()
        }
        
    }
    
    @IBAction func onTapNext(_ sender: UIButton) {
        endTimer()
        let first = one.text
        let second = two.text
        let third = three.text
        let fourth = four.text
        let mainOtp = "\(first ?? "1")" + "\(second ?? "1")" + "\(third ?? "1")" + "\(fourth ?? "1")"
        if mainOtp != Otp {
            errorotp()
        } else {
            if !Functions.isInternetAvailable(){
                Functions.ShowAlert(Title: AppName, DisplayMessage: "NoInternetConnect".localizableString(localizedString: AppDelegate.appDelegate.selectedLanguage), VC: self)
                return
            }
            
          //call otp api
        }
    }
    
    func errorotp(){
        error.isHidden = false
        viewone.layer.borderWidth = 1
        viewone.layer.borderColor = UIColor.red.cgColor
        
        viewtwo.layer.borderWidth = 1
        viewtwo.layer.borderColor = UIColor.red.cgColor
        
        viewthree.layer.borderWidth = 1
        viewthree.layer.borderColor = UIColor.red.cgColor
        
        viewfour.layer.borderWidth = 1
        viewfour.layer.borderColor = UIColor.red.cgColor
        butncolrsimple()
    }
    
    func fineotp(){
        error.isHidden = true
        viewone.layer.borderWidth = 1
        viewone.layer.borderColor = UIColor.green.cgColor
        
        viewtwo.layer.borderWidth = 1
        viewtwo.layer.borderColor = UIColor.green.cgColor
        
        viewthree.layer.borderWidth = 1
        viewthree.layer.borderColor = UIColor.green.cgColor
        
        viewfour.layer.borderWidth = 1
        viewfour.layer.borderColor = UIColor.green.cgColor
        butoncolorGradiant()
        
    }
    
    
    @IBAction func nexttapped(sender : UIButton){
        
    }
    
    
  
    
    @IBAction func resend(_ sender : UIButton){
        endTimer()
        countdownTimer.invalidate()
        //startTimer()
        one.text?.removeAll()
        two.text?.removeAll()
        three.text?.removeAll()
        four.text?.removeAll()
        viewone.layer.borderWidth = 0
        viewone.layer.borderColor = UIColor.clear.cgColor
        
        viewtwo.layer.borderWidth = 0
        viewtwo.layer.borderColor = UIColor.clear.cgColor
        
        viewthree.layer.borderWidth = 0
        viewthree.layer.borderColor = UIColor.clear.cgColor
        
        viewfour.layer.borderWidth = 0
        viewfour.layer.borderColor = UIColor.clear.cgColor
        //call api
        self.requestResendOTP()
    }
    
    
    
    
    @IBAction func back(_ sender: Any){
        navigationController?.popViewController(animated: true)
        // dismiss(animated: true, completion: nil)
    }
    
    
    
}
extension OTPViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
    }
}

extension UITextField {
    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(UIResponderStandardEditActions.paste(_:)) ?
            false : super.canPerformAction(action, withSender: sender)
    }
}
