//
//  MainTab.swift
//  SkillTopp
//
//  Created by mac on 11/05/21.
//  Copyright © 2021 skilltop. All rights reserved.
//

import UIKit
import AVKit
import CallKit


//center bigger button
class MainTabBar: UITabBar {

    private var middleButton = UIButton()

    override func awakeFromNib() {
        super.awakeFromNib()
        setupMiddleButton()
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.isHidden {
            return super.hitTest(point, with: event)
        }
        
        let from = point
        let to = middleButton.center

        return sqrt((from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)) <= 39 ? middleButton : super.hitTest(point, with: event)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        middleButton.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: 0)
    }

    func setupMiddleButton() {
        middleButton.frame.size = CGSize(width: 55, height: 55)
        middleButton.backgroundColor = .clear
        middleButton.layer.cornerRadius = 55/2
        middleButton.layer.masksToBounds = true
        middleButton.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: 0)
        middleButton.addTarget(self, action: #selector(test), for: .touchUpInside)
        middleButton.setImage(UIImage(named: "Plus75"), for: .normal)
        addSubview(middleButton)
    }

    @objc func test() {
        if let vc = AppDelegate.BaseVC.frontVC as? customTabViewController {
            if isUploadActive == true {
                vc.showToast(message: "waitUntilUploading".localizableString(localizedString: AppDelegate.appDelegate.selectedLanguage), font: .systemFont(ofSize: 12.0))
                return
            }
        Functions.checkForCameraPermission(){success in
            if success == false {
                DispatchQueue.main.async {
                    vc.showAlertWithTwoControllerAction(AlertTitle: AppName, AlertMessage: "cameraAccessDenied".localizableString(localizedString: AppDelegate.appDelegate.selectedLanguage), ActionTitle1: "btnsetting".localizableString(localizedString: AppDelegate.appDelegate.selectedLanguage), ActionTitle2: "cancel".localizableString(localizedString: AppDelegate.appDelegate.selectedLanguage), ActionStyle1: .default, ActionStyle2: .destructive, success: { success in
                        if success {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                                    //self.dismiss(animated: false, completion: nil)
                                })
                            }
                        }
                    })
                }
            }else{
                DispatchQueue.main.async {
                    try! AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .videoRecording, options: [.mixWithOthers, .defaultToSpeaker, .allowBluetooth, .allowAirPlay, .allowBluetoothA2DP])
                    print( self.isOnPhoneCall())
                    if (self.isOnPhoneCall())
                    {
                        let alert = UIAlertController(title: AppName, message: "unableToOpenCam".localizableString(localizedString: AppDelegate.appDelegate.selectedLanguage), preferredStyle: .alert)
                                                           alert.addAction(UIAlertAction(title: "ok".localizableString(localizedString: AppDelegate.appDelegate.selectedLanguage), style: .default, handler: { success in
                                                           }))
                        vc.present(alert, animated: true, completion: nil)
                        return;
                    }
                   if let vcCreate = MainStoryBoard.instantiateViewController(withIdentifier: "ActionViewContoller") as? ActionViewContoller
                    {
                        vcCreate.modalPresentationStyle = .fullScreen
                        let nav: UINavigationController = UINavigationController(rootViewController: vcCreate)
                        nav.modalPresentationStyle = .fullScreen
                        nav.setNavigationBarHidden(true, animated: false)
                    vc.present(nav, animated: true, completion: nil)
                        UIApplication.shared.isIdleTimerDisabled = true
                }
              }
             }
           }
         }
       }
    
    private func isOnPhoneCall() -> Bool {
        for call in CXCallObserver().calls {
            if call.hasEnded == false {
                return true
            }
        }
        return false
    }

}
