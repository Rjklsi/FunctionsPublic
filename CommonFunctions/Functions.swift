//
//  Functions.swift
//  CommonFunctions
//
//  Created by mac on 03/05/21.
//

import AVFoundation
import AWSCore
import AWSMobileClient
import AWSS3
import CoreLocation
import FirebaseCrashlytics
import Photos
import SystemConfiguration
import UIKit
import CommonCrypto

class Functions: NSObject {
    /// Activity Indicator
    private var indicatorView: UIActivityIndicatorView?
    /// Shared object
    static var shared = Functions()
    /// Activity Indicator
    private var activityIndicator: UIActivityIndicatorView?
    /// Indicator Label Text
    private var strLabel: UILabel?
    /// Base View Blurred
    private var blurView: UIView?
    /// Background View for effectView
    private var baseWhiteView: UIView?
    /// Effect View
    private let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private static var uuid: String = ""
    
    
}

// MARK: - uuid Functions

extension Functions {
    //MARK:from SkillTopp
    class func playVideoAt(url:URL, inView: UIViewController){
                let vAsset = AVAsset(url: url as! URL)
                DispatchQueue.main.async {
        
                      //let savedVDOAsset = self.videoObject.videoEditableAsset!
                   let playerController = AVPlayerViewController()
                   let playerItem = AVPlayerItem(asset: vAsset)
                  // playerItem.videoComposition = composition
        
                   let player = AVPlayer(playerItem: playerItem)
        
                  // player.volume = 0.0
        
                   playerController.player = player
        
                    inView.present(playerController, animated: true, completion: {
                       playerController.player!.play()
                   })
                           }
    }
    //save video at url to gallery
    class func saveVideoToPhotos(_ url: URL) {
         let save = {
             PHPhotoLibrary.shared().performChanges({ PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url) }, completionHandler: { _, _ in
                 let fileManager = FileManager.default
                 if fileManager.fileExists(atPath: url.path) {
                     try? fileManager.removeItem(at: url)
                 }
             })
         }
         if PHPhotoLibrary.authorizationStatus() != .authorized {
             PHPhotoLibrary.requestAuthorization { status in
                 if status == .authorized {
                     save()
                 }
             }
         } else {
             save()
         }
     }

     // Get user's documents directory path
       func getDocumentDirectoryPath() -> URL {
         let arrayPaths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
         let docDirectoryPath = arrayPaths[0]
         return docDirectoryPath
       }
       
       // Get user's cache directory path
       func getCacheDirectoryPath() -> URL {
         let arrayPaths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
         let cacheDirectoryPath = arrayPaths[0]
         return cacheDirectoryPath
       }
       
       // Get user's temp directory path
       func getTempDirectoryPath() -> URL {
         let tempDirectoryPath = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
         return tempDirectoryPath
       }
     class func getAllDataInDirectory(){
         let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
             let documentsDirectory = urls[0]
         print("****************************************************************************")
         print(documentsDirectory)
         print("****************************************************************************")

     }
    
    class func removeFileAt(UrlPath:URL){
 //        let fileNameToDelete = "myFileName.txt"
 //        var filePath = ""
 //        // Fine documents directory on device
 //         let dirs : [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
 //        if dirs.count > 0 {
 //            let dir = dirs[0] //documents directory
 //            filePath = dir.appendingFormat("/" + fileNameToDelete)
 //            print("Local path = \(filePath)")
 //        } else {
 //            print("Could not find local directory to store file")
 //            return
 //        }
         let fileManager = FileManager.default
         // Check if file exists
         if fileManager.fileExists(atPath: UrlPath.path) {
             print("File exists")
             try? fileManager.removeItem(at: UrlPath)
         } else {
             print("File does not exist")
         }
     }
    class func mergeVideoWithAudioRepeat(videoUrl: URL,
                                       audioUrl: URL,fileName: String,onSuccess: @escaping(URL) -> Void, onFailure: @escaping(Error) -> Void){
    //                                    completion:@escaping (_ path : URL) -> ()) -> Void {
    
               let mixComposition: AVMutableComposition = AVMutableComposition()
               var mutableCompositionVideoTrack: [AVMutableCompositionTrack] = []
               var mutableCompositionAudioTrack: [AVMutableCompositionTrack] = []
               let totalVideoCompositionInstruction: AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
 //    let url = Bundle.main.url(forResource: "BringToTheMasses", withExtension: "m4a")!
               let aVideoAsset: AVAsset = AVAsset(url: videoUrl)
               let aAudioAsset: AVAsset = AVAsset(url: audioUrl)
    
    
               if let videoTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid), let audioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) {
                   mutableCompositionVideoTrack.append( videoTrack )
                   mutableCompositionAudioTrack.append( audioTrack )
    
                   if let aVideoAssetTrack: AVAssetTrack = aVideoAsset.tracks(withMediaType: .video).first, let aAudioAssetTrack: AVAssetTrack = aAudioAsset.tracks(withMediaType: .audio).first {
                       do {
                           try mutableCompositionVideoTrack.first?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration), of: aVideoAssetTrack, at: CMTime.zero)
    
                           let videoDuration = aVideoAsset.duration
                           if CMTimeCompare(videoDuration, aAudioAsset.duration) == -1 {
                               try mutableCompositionAudioTrack.first?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration), of: aAudioAssetTrack, at: CMTime.zero)
                           } else if CMTimeCompare(videoDuration, aAudioAsset.duration) == 1 {
                               var currentTime = CMTime.zero
                               while true {
                                   var audioDuration = aAudioAsset.duration
                                   let totalDuration = CMTimeAdd(currentTime, audioDuration)
                                   if CMTimeCompare(totalDuration, videoDuration) == 1 {
                                       audioDuration = CMTimeSubtract(totalDuration, videoDuration)
                                   }
                                   try mutableCompositionAudioTrack.first?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration), of: aAudioAssetTrack, at: currentTime)
    
                                   currentTime = CMTimeAdd(currentTime, audioDuration)
                                   if CMTimeCompare(currentTime, videoDuration) == 1 || CMTimeCompare(currentTime, videoDuration) == 0 {
                                       break
                                   }
                               }
                           }
                           videoTrack.preferredTransform = aVideoAssetTrack.preferredTransform
    
                       } catch {
                           print(error)
                       }
    
                       totalVideoCompositionInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration)
                   }
               }
    
               let mutableVideoComposition: AVMutableVideoComposition = AVMutableVideoComposition()
               mutableVideoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
               mutableVideoComposition.renderSize = CGSize(width: 480, height: 640)
    
               if let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
                   let outputURL = URL(fileURLWithPath: documentsPath).appendingPathComponent("\(fileName).m4v")
    
                   do {
                       if FileManager.default.fileExists(atPath: outputURL.path) {
    
                           try FileManager.default.removeItem(at: outputURL)
                       }
                   } catch { }
    
                   if let exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) {
                       exportSession.outputURL = outputURL
                       exportSession.outputFileType = AVFileType.mp4
                       exportSession.shouldOptimizeForNetworkUse = true
    
                       // try to export the file and handle the status cases
                       exportSession.exportAsynchronously(completionHandler: {
                           switch exportSession.status {
                           case .failed:
                               if let error = exportSession.error {
                                onFailure(error)
                               }
    
                           case .cancelled:
                               if let error = exportSession.error {
                                onFailure(error)
                               }
    
                           default:
                               print("finished")
                            onSuccess(outputURL)
    //                        completion(outputURL)
                           }
                       })
                   } else {
                    
 //                    onFailure()
                      // failure(nil)
                   }
               }
           }
    
    class func showActivityIndicatorInViewController(view: UIViewController) {
        activityIndicator?.removeFromSuperview()
        activityIndicator = UIActivityIndicatorView()
        blurView?.removeFromSuperview()
        blurView = UIView()
        effectView = UIView()
        effectView.removeFromSuperview()
        blurView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        blurView?.backgroundColor = .black
        blurView?.alpha = 0.4
        view.view.addSubview(blurView!)
        effectView.frame = CGRect(x: view.view.frame.midX-25, y: view.view.frame.midY-25, width: 50, height: 50)
        activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicator?.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
        activityIndicator?.startAnimating()
        activityIndicator?.tag = 999999
        effectView.addSubview(activityIndicator!)
        view.view.addSubview(effectView)
        view.view.bringSubviewToFront(effectView)
        if let topMostController = UIApplication.shared.windows[0].rootViewController {
            topMostController.view.isUserInteractionEnabled = false
        }
    }
    
    
    class func showActivityIndicatorToEntireTabbar() {
       let view = AppDelegate.BaseVC.frontVC as! customTabViewController
        activityIndicator?.removeFromSuperview()
        activityIndicator = UIActivityIndicatorView()
        blurView?.removeFromSuperview()
        blurView = UIView()
        effectView = UIView()
        effectView.removeFromSuperview()
        blurView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        blurView?.backgroundColor = .black
        blurView?.alpha = 0.4
        view.view.addSubview(blurView!)
        effectView.frame = CGRect(x: view.view.frame.midX-25, y: view.view.frame.midY-25, width: 50, height: 50)
        activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicator?.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
        activityIndicator?.startAnimating()
        activityIndicator?.tag = 999999
        effectView.addSubview(activityIndicator!)
        view.view.addSubview(effectView)
        view.view.bringSubviewToFront(effectView)
        if let topMostController = UIApplication.shared.windows[0].rootViewController {
            topMostController.view.isUserInteractionEnabled = false
        }
    }
    class func hideActivityIndicatorFromView() {
        activityIndicator?.removeFromSuperview()
        effectView.removeFromSuperview()
        blurView?.removeFromSuperview()
        activityIndicator = nil
        blurView = nil
        if let topMostController = UIApplication.shared.windows[0].rootViewController {
            topMostController.view.isUserInteractionEnabled = true
        }
    }
    class func dateFormate(datstr: String)->String{
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "EEEE,MMMM dd, h:mm a"
            let datee = dateFormatterGet.date(from: datstr)
          let  Msg_Date =  dateFormatterPrint.string(from: datee ?? Date())
         print(Msg_Date)
        return "\(Msg_Date)"
    }
    //MARK: Date functions
    class func CurrentWeekDayNumber()->Int{
        let date = Date()
        let weekday = Calendar.current.component(.weekday, from: date)
        return weekday
    }
    class func isCurrent(date:Date)->Bool{
        let current = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let first = formatter.string(from: current)
        let second = formatter.string(from: date)
        if first.compare(second) == .orderedSame {
            return true
        }
        return false
    }
    
    class func saveImageInDocumentDirectory(image: UIImage, fileName: String) -> URL? {
            let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!;
            let fileURL = documentsUrl.appendingPathComponent(fileName)
        
              if let imageData = image.pngData() {
                try? imageData.write(to: fileURL, options: .atomic)
                return fileURL
              }
            return nil
        }

    class func loadImageFromDocumentDirectory(fileName: String) -> UIImage? {

            let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!;
            let fileURL = documentsUrl.appendingPathComponent(fileName)
            do {
                let imageData = try Data(contentsOf: fileURL)
                return UIImage(data: imageData)
            } catch {}
            return nil
        }
    
   class func isFileAvailable(name:String)->Bool{
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent("\(name)") {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
              //  print("FILE AVAILABLE")
                return true
            } else {
              //  print("FILE NOT AVAILABLE")\
                return false
            }
        } else {
            return false
           // print("FILE PATH NOT AVAILABLE")
        }
    }
    //MARK: Validations
    /// Email and Phone number validation
    class func isPhoneNumberValid(value: String) -> Bool {
        let PHONE_REGEX = "^((\\+)|(00))[0-9]{6,14}|[0-9]{6,14}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: value)
        return result
    }
    class func isEmailValid(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        return result
    }
    
    
   class func mergeAV(videoUrl: URL, audioUrl: URL, completion:@escaping (_ path : URL) -> ()) -> Void {
        let mixComposition: AVMutableComposition = AVMutableComposition()
        var mutableCompositionVideoTrack: [AVMutableCompositionTrack] = []
        var mutableCompositionAudioTrack: [AVMutableCompositionTrack] = []
        var mutableCompositionAudioOfVideoTrack: [AVMutableCompositionTrack] = []
        let totalVideoCompositionInstruction: AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        
        let aAudioAsset: AVAsset = AVAsset(url: audioUrl)
        let aVideoAsset = AVAsset(url: videoUrl)
        
        mutableCompositionVideoTrack.append(mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)!)
        mutableCompositionAudioTrack.append(mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)!)
        mutableCompositionAudioOfVideoTrack.append(mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)!)
        
        guard Int(aVideoAsset.tracks(withMediaType: AVMediaType.video).count) > 0 && Int(aAudioAsset.tracks(withMediaType: AVMediaType.audio).count) > 0 else{
            return
        }
        let aAudioOfVideoTrack: AVAssetTrack = aVideoAsset.tracks(withMediaType: AVMediaType.audio)[0]
        let aVideoAssetTrack: AVAssetTrack = aVideoAsset.tracks(withMediaType: AVMediaType.video)[0]
        let aAudioAssetTrack: AVAssetTrack = aAudioAsset.tracks(withMediaType: AVMediaType.audio)[0]
        
        do {
            try mutableCompositionAudioOfVideoTrack[0].insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration), of: aAudioOfVideoTrack, at: CMTime.zero)
            try mutableCompositionVideoTrack[0].insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration), of: aVideoAssetTrack, at: CMTime.zero)
            try mutableCompositionAudioTrack[0].insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration), of: aAudioAssetTrack, at: CMTime.zero)
        } catch {
            
        }
        
        totalVideoCompositionInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration)
        
        let mutableVideoComposition: AVMutableVideoComposition = AVMutableVideoComposition()
        mutableVideoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        
        mutableVideoComposition.renderSize = CGSize(width: 1280, height: 720)//CGSize(1280,720)
        
        let savePathUrl = URL(fileURLWithPath: NSTemporaryDirectory() + "newVideo.mp4")
        if FileManager.default.fileExists(atPath: savePathUrl.path) {
            do{
                try FileManager.default.removeItem(at:savePathUrl as URL )
            }catch{
                //print(error.localizedDescription)
            }
        }
        let assetExport: AVAssetExportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)!
        assetExport.outputFileType = AVFileType.mp4
        assetExport.outputURL = savePathUrl as URL
        assetExport.shouldOptimizeForNetworkUse = true
        
        assetExport.exportAsynchronously {
            switch assetExport.status {
            case AVAssetExportSessionStatus.completed:
                //print("success")
                completion(savePathUrl)
            // self.saveVideoToPhotos(savePathUrl as URL)
            case AVAssetExportSessionStatus.failed:
                print("failed \(assetExport.error)")
            case AVAssetExportSessionStatus.cancelled:
                print("cancelled \(assetExport.error)")
            default:
                print("complete")
            }
        }
    }

    
    
    //MARK: from mobohub
    //***************************************************************
    //*******ENCRYPTION/DECRYPTION ON DATED 10NOV20 BY RAJVEER ******
    //***************************************************************
    func testCrypt(data:Data, operation:Int) -> Data {
        let keyData     = ENC_KEY.data(using:String.Encoding.utf8)!
        let ivData      = IV.data(using:String.Encoding.utf8)!
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

    //***************************************************************
    
    
    //*****dynamic aws key
//    class func awsSetup(){
//        if AppDelegate.appDelegate.poolIdentity != "" {
//            //print(AppDelegate.appDelegate.poolIdentity)
//           UserDefaults.standard.set("\(AppDelegate.appDelegate.poolIdentity)", forKey: "PoolId")
//        }
//        AppDelegate.appDelegate.configAWS()
//    }
    
    
    //***********************************************************************************************
    //******SAVE DATA GOT FROM VALIDATE PIN API IN ORDER TO SUPPORT OFFLINE LOGIN  FUNCTIONALITY*****
    //*****************ON DATED 15july 2020 BY RAJVEER **********************************************
    
    ///SAVE DATA TO DOCUMENTS
    class func saveValidatePinData(DataToParse:Data){
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent("ValidatePinData.txt") {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                print("FILE AVAILABLE")
                do {
                    try DataToParse.write(to: pathComponent)
                    //print(pathComponent)
                } catch {
                    print("Failed to write JSON data: \(error.localizedDescription)")
                }
            } else {
                print("FILE NOT AVAILABLE and written")
                //********CREATE AND WRITE TO FILE*************
                let paths2 = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
                let pathDirectory =  NSURL(fileURLWithPath: paths2)
                try? FileManager().createDirectory(at: pathDirectory as URL, withIntermediateDirectories: true)
                let filePath = pathDirectory.appendingPathComponent("ValidatePinData.txt")
                do {
                    try DataToParse.write(to: filePath!)
                    //print(filePath!)
                } catch {
                    print("Failed to write JSON data: \(error.localizedDescription)")
                }
                //***********************************
            }
        } else {
            print("FILE PATH NOT AVAILABLE")
        }
    }
    ///REMOVE DATA FROM DOCUMENTS
    class func removeFileLocalPath(localPathName:String) {
        let filemanager = FileManager.default
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0] as NSString
        let destinationPath = documentsPath.appendingPathComponent(localPathName)
        do {
            try filemanager.removeItem(atPath: destinationPath)
            print("Local path removed successfully")
        } catch let error as NSError {
            print("------Error",error.debugDescription)
        }
    }
    //*******************************************************************************
    
    //SOS METHOD
    class func setupSOSCall(){
        var id :String = ""
        if let idvalue = UserDefaults.standard.string(forKey: "PersonID")
        {
            id = idvalue
        }
        let navigationController = UIApplication.shared.windows[0].rootViewController as! UINavigationController
        let activeViewCont = navigationController.visibleViewController
        if AppDelegate.appDelegate.SOSType == "3" {
            activeViewCont?.showConformationAlert(AlertTitle: MAppName, AlertMessage: NSLocalizedString("Do you want to send panic alert?",comment: ""), ActionTitle1: NSLocalizedString("Yes", comment: ""), ActionTitle2: NSLocalizedString("no", comment: ""), ActionStyle1: .default, ActionStyle2: .destructive, vc: activeViewCont!, success: {success in
                if success {
                    if let url = URL(string: "tel://\(AppDelegate.appDelegate.SOSCallNumber)"),
                        UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                        if Functions.isInternetAvailable(){
                            WebServices.shared.SOSTextOREmail(personID: id)
                        } else {
                            activeViewCont?.noNetworkAvailable(vc: activeViewCont!)
                        }
                    }
                }
            })
            
        } else if (AppDelegate.appDelegate.SOSType == "1" || AppDelegate.appDelegate.SOSType == "2") {
            if Functions.isInternetAvailable(){
                activeViewCont?.showConformationAlert(AlertTitle: MAppName, AlertMessage: NSLocalizedString("Do you want to send panic alert?", comment: ""), ActionTitle1: NSLocalizedString("Yes", comment: ""), ActionTitle2: NSLocalizedString("no", comment: ""), ActionStyle1: .default, ActionStyle2: .destructive, vc: activeViewCont!, success: {success in
                    if success {
                        Functions.shared.showActivityIndicator(Title: NSLocalizedString("Sending Panic Alert", comment: ""), In: activeViewCont!)
                        WebServices.shared.SOSTextOREmail(personID: id)
                    }
                })
            } else {
                activeViewCont?.noNetworkAvailable(vc: activeViewCont!)
            }
        }
    }
    ///ADD PLUS BUTTON PROGRAMMATICALLY
    class func DisplayPlusBtn(viewController: UIViewController, headerView: UIView){
        let plusBtn = UIButton()
        plusBtn.setImage(UIImage(named: "deviceList"), for: .normal)
        plusBtn.backgroundColor = UIColor.clear
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            if Env.iPad {
                plusBtn.frame = CGRect(x: (headerView.frame.size.width - 46), y: (headerView.frame.size.height/2), width: 28, height: 28)
            } else {
                if UIScreen.main.bounds.height >= 812  {
                    plusBtn.frame = CGRect(x: (headerView.frame.size.width - 46), y: (headerView.frame.size.height/2 + 10), width: 35, height: 35)
                } else {
                    plusBtn.frame = CGRect(x: (headerView.frame.size.width - 46), y: (headerView.frame.size.height/2), width: 35, height: 35)
                }
            }
            plusBtn.removeFromSuperview()
            plusBtn.addTarget(viewController, action: #selector(plusBtnAction), for: .touchUpInside)
            headerView.addSubview(plusBtn)
        })
    }
    @objc func plusBtnAction(){}
    
    
    /// Email and Phone number validation
    class func isPhoneNumberValid(value: String) -> Bool {
        let PHONE_REGEX = "^((\\+)|(00))[0-9]{6,14}|[0-9]{6,14}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: value)
        return result
    }
    class func isEmailValid(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        return result
    }
    
    //**************************************************************
    //******TEST IF THERE IS URL IN STRING OR NOT ******************
    //*************ON DATED 3 MARCH BY RAJVEER *********************
    //**************************************************************
    class func isURLContained(input:String)-> Bool{
        let types: NSTextCheckingResult.CheckingType = [.link]
        let detector = try! NSDataDetector(types: types.rawValue)
        guard  let link = detector.firstMatch(in: input, range: NSRange(input.startIndex..., in: input))  else{
            return false
        }
        return true
    }
    //***************************************************************
    //***IF THERE IS A URL IN NOTIFICATION MESSAGE DISPLAY ALERT ****
    //*************ON DATED 2 MARCH BY RAJVEER **********************
    //***************************************************************
    class func showAlertWithURL(input:String, vc:UIViewController){
        let types: NSTextCheckingResult.CheckingType = [.link]
        let detector = try! NSDataDetector(types: types.rawValue)
        guard  let link = detector.firstMatch(in: input, range: NSRange(input.startIndex..., in: input))  else {
            return
        }
        DispatchQueue.main.async {
            vc.showAlertWithTwoControllerAction(AlertTitle: MAppName, AlertMessage:NSLocalizedString("Do you want to add this event to calander.", comment: "") , ActionTitle1: NSLocalizedString("Yes", comment: ""), ActionTitle2: NSLocalizedString("no", comment: ""), ActionStyle1: .default, ActionStyle2: .destructive, success: {success in
                if success {
                    UIApplication.shared.openURL(link.url!)
                }
            })
        }
    }
    //******************************************************************
    
    //******************************************************************
    //** ADD SOS BUTTON ON VIEWCONTROLLER ON DATED 22 FEB BY RAJVEER ***
    //******************************************************************
    class func AddSOSButton(viewController: UIViewController, headerView: UIView) {
        if AppDelegate.appDelegate.isSOSEnabled == true {
            let sosImage = UIImage(named: "sos2")
            let sosButton = UIButton()
            sosButton.setImage(sosImage, for: .normal)
            sosButton.backgroundColor = UIColor.clear
            sosButton.addTarget(AppDelegate.appDelegate, action:#selector(AppDelegate.appDelegate.SOSCall), for: .touchUpInside)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                if Env.iPad {
                    sosButton.frame = CGRect(x: 80, y: (headerView.frame.size.height/2), width: 35, height: 35)
                } else {
                    if UIScreen.main.bounds.height >= 812  {
                        sosButton.frame = CGRect(x: 38, y: (headerView.frame.size.height/2 + 10), width: 35, height: 35)
                    } else {
                        sosButton.frame = CGRect(x: 38, y: (headerView.frame.size.height/2), width: 35, height: 35)
                    }
                }
                sosButton.removeFromSuperview()
                headerView.addSubview(sosButton)
            })
        }
    }
    @objc @IBAction func SOSCall(sender: UIButton){}
    
    
    
    
    //*********************************************************
    //**ADD RECORD TO LOCAL ARRAY ON DATED JAN 29 BY RAJVEER **
    //*********************************************************
    class func updateNFCLocationName(locationName:String,locationCode:String) {
        if Global.availableNFCScanPoints == nil{
            Global.availableNFCScanPoints = []
        }
        
        let LocationRecord : NSMutableDictionary = NSMutableDictionary()
        LocationRecord.setValue(locationName, forKey: "name")
        LocationRecord.setValue(locationCode, forKey: "qrCodeId")
        Global.availableNFCScanPoints.add(LocationRecord)
    }
    
    //**************************************************************************
    //***GLOBAL FUNCTION FOR NOTIFICATION BUTTON ON DATED 7JAN BY RAJVEER ******
    //**************************************************************************
    
    ///add notification button for  API version 5.2
    class func AddNotificationButton(viewController: UIViewController, headerView: UIView, isUnReadMessage: Bool) {
        var notificationImage = UIImage(named: "message_read")
        let searchPredicate = NSPredicate(format: "status = %ld", 1)
        var count = 0
        
        if Global.NotificationListForSection != nil {
            if Global.NotificationListForSection.count >= 1{
                for i in 0..<Global.NotificationListForSection.count{
                    if let dict = Global.NotificationListForSection[i] as? NSDictionary{
                        if let data = dict.value(forKey: "data") as? NSArray{
                            if data.count >= 1{
                                let unreadCount =  data.filtered(using: searchPredicate) as! NSArray
                                if unreadCount.count >= 1{
                                    count += 1
                                }
                            }
                        }
                    }
                }
            }
        }
        
        if count >= 1{
            //set image for unread notifs
            notificationImage = UIImage(named: "message_unread")
        }
        
        //  DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: {
        var temp = false
        let theSubviews = headerView.subviews
        for subview in theSubviews {
            if (subview.tag == 1001){
                subview.removeFromSuperview()
                temp = true
            }
        }
        
        let notificationButton = UIButton()
        notificationButton.tag = 1001
        
        notificationButton.setImage(notificationImage, for: .normal)
        notificationButton.backgroundColor = UIColor.clear
        
        if Env.iPad {
            notificationButton.frame = CGRect(x: viewController.view.frame.size.width - 46, y: (headerView.frame.size.height/2), width: 36, height: 28)
        } else {
            if UIScreen.main.bounds.height >= 812 {
                notificationButton.frame = CGRect(x: viewController.view.frame.size.width - 46, y: (headerView.frame.size.height/2 + 10), width: 36, height: 28)
            }else{
                notificationButton.frame = CGRect(x: viewController.view.frame.size.width - 46, y: (headerView.frame.size.height/2), width: 36, height: 28)
            }
        }
        notificationButton.addTarget(viewController, action: #selector(Click_ShowNotifications), for: .touchUpInside)
        notificationButton.removeFromSuperview()
        headerView.addSubview(notificationButton)
        //})
    }
    
    
    
    @objc func Click_ShowNotifications() {}
    //***************************************************************************
    
    
    // MARK: Get UUID
    
    class func getUUIDString() -> String {
        if !uuid.trimmed().isEmpty {
            return uuid // return cached value
        }
        /// Generate A Dynamic UDID
        var toRet = ""
        /// Wrapper Object
        let keychainWrapperObj = KeychainItemWrapper(identifier: "ManDown", accessGroup: nil)
        /// Check is Any UDID Stored
        if let udidSavedVal = keychainWrapperObj?.object(forKey: kSecAttrService) {
            print("Old UDID is being Used now as ==> \(udidSavedVal as? String ?? "")")
            toRet = udidSavedVal as? String ?? ""
        }
        
        /// Check Do we have anything In ToRet String?
        if toRet.trimmed().isEmpty {
            /// We have no UDID Saved Need to get New
            if UserDefaultManager.getUUIDSaved() != nil {
                toRet = UserDefaultManager.getUUIDSaved()!
                keychainWrapperObj?.setObject(toRet, forKey: kSecAttrService)
            } else {
                /// Need to Get new UUID
                var newUUIDStr: String?
                newUUIDStr = UIDevice.current.identifierForVendor!.uuidString
                UserDefaultManager.saveUUIDInDefaultAs(UUIDString: newUUIDStr!)
                toRet = newUUIDStr!
                keychainWrapperObj?.setObject(toRet, forKey: kSecAttrService)
            }
        }
        
        uuid = toRet
        Crashlytics.crashlytics().setUserID(uuid)
        return uuid
    }
}

// MARK: - Common Functions

extension Functions {
    /// Delete All Enity Data
    
    class func deleteAllSavedEntityData() {
        /// Delete All Enity Data
        DispatchQueue.main.async {
            let coreObj = CoreDBManager.shared.getContext()
            ///***initial code ***
          //  let entityArray: [String] = ["Form", "FormValues", "Incident", "OfflineForm", "Scan", "ShiftFormData", "ShiftTaskData", "Task", "TimeSheet"]
            ///***last code ***
             let entityArray: [String] = ["Form", "Incident", "OfflineForm", "Scan", "ShiftFormData", "ShiftTaskData", "Task", "TimeSheet"]
            ///***recent experimental code ***
           // let entityArray: [String] = ["Form", "FormValues" , "ShiftFormData", "ShiftTaskData", "Task", "TimeSheet"]
            for entity in entityArray {
                coreObj.deleteCompleteEntityDataWith(EntityName: entity)
            }
        }
    }
    
    // MARK: Get Date Formatted
    
    class func getDateTimeFormatted(Date lastDate: Date, FormatterType type: DateFormatsSupported) -> String {
        var df: DateFormatter?
        df = DateFormatter()
        df?.amSymbol = "AM"
        df?.pmSymbol = "PM"
        switch type {
        case .HMMA: df?.dateFormat = "h:mm a"
        case .MMMDD: df?.dateFormat = "MMM dd"
        case .DDMMYYYYHMMA: df?.dateFormat = "dd/MM/yyyy h:mm a"
        default: df?.dateFormat = "dd/MM/yyyy"
        }
        var dateString: String?
        dateString = df?.string(from: lastDate) ?? ""
        df = nil
        return dateString ?? ""
    }
    
    // MARK: Check is user logged in
    
    class func isUserLoggedIn() -> Bool {
        let oldPin = getOldPin()
        if let loggedUser = UserDefaults.standard.object(forKey: "LoggedUser") as? [String: Any] {
            CurrentLoggedUser.shared.fetchUserDetails(UserDict: loggedUser, NeedToSave: true)
            return true
        } else if oldPin != "" {
            CurrentLoggedUser.loginPin = oldPin
            return true
        } else {
            return false
        }
    }
    
    // MARK: Save App Logo URL
    
    class func saveAppLogo(URL appURL: String) {
        UserDefaults.standard.set(appURL, forKey: appLogoURLSavedStr)
        UserDefaults.standard.synchronize()
    }
    
    // MARK: Get App Logo URL Saved
    
    class func getAppLogoSavedInDefaults() {
        if let appURL = UserDefaults.standard.value(forKey: appLogoURLSavedStr) as? String {
            Global.appLogoURL = appURL
        } else { Global.appLogoURL = "" }
    }
    
    class func getOldPin() -> String {
        guard let pin = UserDefaults.standard.object(forKey: "pin__Number") as? String else {
            return ""
        }
        return pin
    }
    
    // MARK: Validate Scanned QRCode
    
    class func validateQRCodeWith(QRCode code: String) -> (Bool, String, String) {
        // print(code)
        //*****************************************************************************
        //**********ALERT MESSAGE APP NAME CHANGED FROM MOBOTOUR TO MOBOHUBB **********
        //********ON DATED 24 NOV 2020 BY RAJVEER *************************************
        let scanErrorMessage: String = "This QR Code has not been \nconfigured for mobohubb - \nPlease contact your \nAdministrator"
        //*****************************************************************************
        let commaSepratedArray = code.components(separatedBy: ",")
        if commaSepratedArray.count == 2 {
            let pin = commaSepratedArray[0].trimmed()
            //print(pin)
            if pin.trimmed().count < 1 {
                return (false, scanErrorMessage, pin)
            } else if !(pin.trimmed() == (CurrentLoggedUser.loginPin ?? "").trimmed()) {
                return (false, scanErrorMessage, pin)
            } else {
                return (true, commaSepratedArray[1], pin)
            }
        } else if commaSepratedArray.count == 1 {
            /// It's new Valid QRCode Format
            return (true, commaSepratedArray[0], CurrentLoggedUser.loginPin ?? "")
        } else {
            return (false, scanErrorMessage, "")
        }
    }
    
    // MARK: Get Device Name
    
    class func getDeviceName() -> String {
        return ("\(UIDevice.current.name)-\(getUUIDString())").trimmed()
    }
    
    // MARK: Get Only Device Name
    
    class func getOnlyDeviceName() -> String {
        return UIDevice.current.name
    }
    
    // MARK: Get Time Zone
    
    class func getTimeZone() -> String {
        return String(format: "%ld", TimeZone.current.secondsFromGMT())
    }
    
    // MARK: Get TimeStamp
    
    class func getTimeStamp() -> String {
        return String(format: "%.f", floor(Date().timeIntervalSince1970))
    }
    
    // MARK: Get Auth Header
    
    class func getAuthString() -> String {
        var md5String: String?
        var timeStampStr: String?
        timeStampStr = Functions.getTimeStamp()
        md5String = (MD5_PREFIX + timeStampStr! + MD5_SUFFIX).md5
        let first: String = (md5String! as NSString).substring(with: NSRange(location: 0, length: 16))
        let second: String = (md5String! as NSString).substring(from: 16)
        md5String = nil
        // print("Auth String ==> \(first + timeStampStr! + second)")
        return first + timeStampStr! + second
    }
    
    // MARK: Has Connectivity
    
    /**
     This Function is used to check do App is connected to internet or not ?
     */
    class func isInternetAvailable() -> Bool {
        /// Sample Socket Address
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        /// Reachability status
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        /// Flags of Reachability
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        
        /// Check Connectivity Flag
        let isReachable = flags.contains(.reachable)
        /// If needs a Conection
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    // MARK: Get Date Formatted From String
    
    class func getDateFromDateTimeString(Date date: String, Time time: String) -> Date? {
        let newDateCollected = "\(date) \(time)"
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:s"
        if let newDate = df.date(from: newDateCollected) {
            return newDate
        } else {
            return nil
        }
    }
    
    // MARK: Resize Image
    
    /**
     This function is used to resize an image
     - parameter image: Image who need to be Resized
     - parameter targetSize: Size of newImage
     */
    class func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio = targetSize.width / image.size.width
        let heightRatio = targetSize.height / image.size.height
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}

// MARK: - Permissions

extension Functions {
    // MARK: Check For Camera Permission
    
    class func checkForCameraPermission(success: @escaping (Bool) -> Void) {
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            // already authorized
            success(true)
        } else if AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined {
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
                success(response)
            }
        } else {
            success(false)
        }
    }
    
    // MARK: Check for photos App Permission
    
    class func checkForGalleryPermission(success: @escaping (Bool) -> Void) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized: success(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    success(true)
                } else { success(false) }
            }
        default: success(false)
        }
    }
    
    // MARK: Check for Microphone Permission
    
    class func checkForAudioPermission() {}
}

// MARK: - API Functions

extension Functions {
    // MARK: Post - URL Session - Custom Header
    
    class func requestPostWithURLSessionCustomHeader(MethodName _: String, APIURL strURL: String, HeaderDict headerDict: [String: String], Parameters params: String, ContentTypeHeader contentHeader: String, success: @escaping (Data) -> Void, failure: @escaping (Error) -> Void) {
        let urlwithPercentEscapes = strURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let postData = NSMutableData(data: params.data(using: String.Encoding.ascii, allowLossyConversion: true)!)
        let request = NSMutableURLRequest(url: NSURL(string: urlwithPercentEscapes!)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 90.0)
        if !headerDict.isEmpty {
            for (key, Value) in headerDict {
                request.addValue(Value, forHTTPHeaderField: key)
            }
        }
        request.setValue(contentHeader, forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postData as Data
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            guard let data = data, error == nil else {
                OperationQueue.main.addOperation {
                    failure(error! as Error)
                }
                return
            }
            
            
        print("Response ==> \(String(describing: response))")
        let strData = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        print("Body: \(String(describing: strData))")
            
            
            success(data)
        })
        task.resume()
    }
    
    // MARK: Get JSON Param String Format
    
    class func getJSONParam(With paramDict: [String: String]) -> String {
        var finalParamString: String = ""
        for (key, value) in paramDict {
            if finalParamString != "" { finalParamString = finalParamString + "," }
            finalParamString = finalParamString + "\"\(key)\":\"\(value)\""
        }
        return finalParamString
    }
    
    // MARK: Get Cipher String Formatted
    
    class func getCipherStringFormatted(With cipherStringArray: [String]) -> String {
        var finalCipherString: String = ""
        for val in cipherStringArray {
            finalCipherString = finalCipherString + "\(val)"
        }
        return finalCipherString
    }
    
    // MARK: Get String Out of Any
    
    class func getStringValueForNum(_ value: Any) -> String {
        if let castedValue = value as? String {
            return castedValue
        } else {
            if let castedValue = value as? Int {
                return String(castedValue)
            } else {
                if let castedValue = value as? NSNumber {
                    return "\(castedValue)"
                } else { return "" }
            }
        }
    }
}

// MARK: - Animations

extension Functions {
    // MARK: Slide View - Right To Left
    
    class func viewSlideInFromLeftToRight(AnimateView view: UIView, TimeDuration duration: CFTimeInterval) {
        let transition: CATransition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.fade
        transition.subtype = CATransitionSubtype.fromLeft
        view.layer.add(transition, forKey: kCATransition)
    }
    
    // MARK: Slide View - Left To Right
    
    class func viewSlideInFromRightToLeft(AnimateView view: UIView, TimeDuration duration: CFTimeInterval) {
        let transition: CATransition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        view.layer.add(transition, forKey: kCATransition)
    }
}

// MARK: - JS Files - Document Directory

extension Functions {
    // MARK: Doc Directory URL
    
    class func getDocumentsDirectory(FormID formID: String) -> URL {
        // Get Basic URL
        let documentsDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let dataPath1 = documentsDirectory.appendingPathComponent("Mobotour")
        let dataPath = dataPath1.appendingPathComponent(formID)
        // Handler
        do {
            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating directory: \(error.localizedDescription)")
        }
        return dataPath
    }
    //********oct 8
    class func getDocumentImageDirectory(PersonID personID: String) -> URL {
        // Get Basic URL
        let documentsDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let dataPath1 = documentsDirectory.appendingPathComponent("Mobotour")
        let dataPath = dataPath1.appendingPathComponent(personID)
        // Handler
        do {
            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating directory: \(error.localizedDescription)")
        }
        return dataPath
    }
    
    //*****
    class func getDocumentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let dir = paths[0]
        return dir
    }
}

// MARK: - Spinner Functions

extension Functions {
    // MARK: Show Spinner
    
    /**
     This Function is used to Show Spinner
     - parameter title : Title for the label to be Displayed
     - parameter view : ViewController in which Spinner is to be added
     */
    func showActivityIndicator(Title title: String, In view: UIViewController) {
        strLabel?.removeFromSuperview()
        strLabel = UILabel()
        activityIndicator?.removeFromSuperview()
        activityIndicator = UIActivityIndicatorView()
        blurView?.removeFromSuperview()
        blurView = UIView()
        baseWhiteView?.removeFromSuperview()
        baseWhiteView = UIView()
        effectView.removeFromSuperview()
        
        blurView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        blurView?.backgroundColor = .black
        blurView?.alpha = 0.4
        view.view.addSubview(blurView!)
        let width = getLabelWidth(Message: title)
        strLabel = UILabel(frame: CGRect(x: 40, y: 0, width: width + 20, height: 46))
        strLabel?.text = ""
        strLabel?.text = title
        strLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        strLabel?.textColor = UIColor.black
        
        effectView.frame = CGRect(x: view.view.frame.midX - ((width + 50) / 2), y: view.view.frame.midY - (strLabel?.frame.height)! / 2, width: width + 50, height: 46)
        effectView.layer.cornerRadius = 15
        effectView.layer.masksToBounds = true
        
        baseWhiteView?.frame = effectView.frame
        baseWhiteView?.backgroundColor = UIColor.white
        baseWhiteView?.layer.shadowColor = UIColor.white.cgColor
        baseWhiteView?.layer.shadowOpacity = 1
        baseWhiteView?.layer.masksToBounds = false
        baseWhiteView?.clipsToBounds = false
        baseWhiteView?.layer.shadowOffset = CGSize(width: 0, height: 0)
        baseWhiteView?.layer.shadowRadius = 3
        baseWhiteView?.layer.cornerRadius = 15
        
        activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator?.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
        activityIndicator?.startAnimating()
        
        effectView.contentView.addSubview(activityIndicator!)
        effectView.contentView.addSubview(strLabel!)
        view.view.addSubview(baseWhiteView!)
        view.view.addSubview(effectView)
        view.view.bringSubviewToFront(effectView)
        
        if let topMostController = UIApplication.shared.windows[0].rootViewController {
            topMostController.view.isUserInteractionEnabled = false
        }
    }
    
    // MARK: Hide Spinner
    
    /**
     This Function is used to Hide Running Spinner and remove the Added Views
     */
    func hideActivityIndicator() {
        strLabel?.removeFromSuperview()
        activityIndicator?.removeFromSuperview()
        effectView.removeFromSuperview()
        blurView?.removeFromSuperview()
        baseWhiteView?.removeFromSuperview()
        strLabel = nil
        activityIndicator = nil
        blurView = nil
        baseWhiteView = nil
        
        if let topMostController = UIApplication.shared.windows[0].rootViewController {
            topMostController.view.isUserInteractionEnabled = true
        }
    }
    
    // MARK: Get Label Width
    
    /**
     This Function is used to get the maximum possible width a label can have with
     input text
     */
    func getLabelWidth(Message message: String) -> CGFloat {
        let label: UILabel = UILabel()
        label.text = message
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label.intrinsicContentSize.width
    }
    
    // MARK: Change LoaderView Text
    
    /**
     This Function is used to change the Loader text being Displayed
     - parameter message: Text to be displayed in Label
     - parameter view: Controller in which Loader is Being currently Dispalyed
     */
    func changeLoaderLabelText(Message message: String, In view: UIViewController) {
        let width = getLabelWidth(Message: message)
        strLabel?.frame.size.width = width + 20
        strLabel?.text = message
        effectView.frame = CGRect(x: view.view.frame.midX - ((width + 50) / 2), y: view.view.frame.midY - (strLabel?.frame.height)! / 2, width: width + 50, height: 46)
        baseWhiteView?.frame = effectView.frame
        baseWhiteView?.setNeedsDisplay()
        effectView.setNeedsDisplay()
    }
}

// MARK: - Transfer Offline Data

extension Functions {
    // MARK: Send Offline Data
    
    class func sendOfflineDataToServer() {
        if Global.sendingOfflineData {
            Global.sendingOfflineData = true
            return
        }
        
        Migration.doMigrate() // first migrate any data from old app
        if !Functions.isInternetAvailable() {
            return
        }
        Global.sendingOfflineData = true
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        func done(Error error: Error?) {
            DispatchQueue.main.async {
                Global.sendingOfflineData = false
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                let msgDict: [String: String?] = ["error": error?.localizedDescription]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RefreshOfflineTable"), object: nil, userInfo: msgDict as [AnyHashable: Any])
            }
        }
        let coreDBClassObj = CoreDBManager.shared.getContext()
        
        func scans() {
            OfflineSubmit.getAndSubmitScans(Context: coreDBClassObj, success: { timeSheets() }) { error in
                /// We Encounterd an error while submitting Scans
                done(Error: error)
                ///data need to be uploaded in case error
                timeSheets()
            }
            // OfflineSubmit.getAndSubmitScans(Context: coreDBClassObj, success: { timeSheets() }, failure: { done() })
        }
        func timeSheets() {
            OfflineSubmit.getAndSubmitTimeSheet(Context: coreDBClassObj, success: { alerts() }) { error in
                /// We Encounterd an error while submitting Timesheets
                done(Error: error)
                ///data need to be uploaded in case error
                alerts()
            }
        }
        func alerts() {
            OfflineSubmit.getOfflineAlertToSubmit(Context: coreDBClassObj, success: { forms() }) { error in
                /// We Encounterd an error while submitting Alerts
                done(Error: error)
                ///data need to be uploaded in case error
                forms()
            }
        }
        func forms() {
            OfflineSubmit.getOfflineFormToSubmit(Context: coreDBClassObj, success: { notifications() }) { error in
                /// We Encounterd an error while submitting Forms
                done(Error: error)
                ///data need to be uploaded in case error
                notifications()
            }
        }
        //****************************************************************************
        //***NOTIFICATION THREAD ADDED FOR OFFLINE UPLOAD ON DATED 6JAN BY RAJVEER ***
        //****************************************************************************
        func notifications(){
            OfflineSubmit.getAndSubmitOfflineNotification(Context: coreDBClassObj, success: { done(Error: nil) }) { error in
                /// We Encounterd an error while submitting Forms
                done(Error: error)
            }
        }
        //***************************************************************************
        
        /// Check For Tasks To Submit
        OfflineSubmit.getOfflineTaskToSubmit(Context: coreDBClassObj, success: { scans() }) { error in
            /// We Encounterd an error while submitting Tasks
            done(Error: error)
            scans()
        }
    }
}

// MARK: - AWS Work

extension Functions {
    // MARK: Upload Image To Server
    
    class func transferImageToServer(ImageURL imgURL: URL, BucketName bucketName: String, dispatchGroup: DispatchGroup) {
        let newTransferQueue: AWSS3TransferUtility = AWSS3TransferUtility.default()
        
        newTransferQueue.uploadFile(imgURL, bucket: bucketName, key: "\(CurrentLoggedUser.SubId ?? "")/\(imgURL.lastPathComponent)", contentType: "image/png", expression: nil, completionHandler: nil).continueWith(executor: AWSExecutor.mainThread()) { (myTask) -> Any? in
            if let error = myTask.error {
                print("Error While Uploading ==> \(error.localizedDescription)")
            } else {
                if let taskResult = myTask.result {
                    print("Output Desc ==> \(taskResult.description)")
                } else {
                    print("Some Error")
                }
            }
            dispatchGroup.leave()
            return nil
        }
    }
    
    // MARK: Upload Audio To Server
    
    class func transferAudioFileToServer(AudioURL audioURL: URL, BucketName bucketName: String, dispatchGroup: DispatchGroup) {
        let newTransferQueue: AWSS3TransferUtility = AWSS3TransferUtility.default()
        newTransferQueue.uploadFile(audioURL, bucket: bucketName, key: "\(CurrentLoggedUser.SubId ?? "")/\(audioURL.lastPathComponent)", contentType: "audio/mp3", expression: nil, completionHandler: nil).continueWith(executor: AWSExecutor.mainThread()) { (myTask) -> Any? in
            if let error = myTask.error {
                print("Error While Uploading ==> \(error.localizedDescription)")
            } else {
                if let taskResult = myTask.result {
                    print("Output Desc ==> \(taskResult.description)")
                } else {
                    print("Some Error")
                }
            }
            dispatchGroup.leave()
            return nil
        }
    }
    
    // MARK: Upload Video To Server
    
    class func transferVideoFileToServer(VideoURL videoURL: URL, BucketName bucketName: String, dispatchGroup: DispatchGroup) {
        let newTransferQueue: AWSS3TransferUtility = AWSS3TransferUtility.default()
        newTransferQueue.uploadFile(videoURL, bucket: bucketName, key: "\(CurrentLoggedUser.SubId ?? "")/\(videoURL.lastPathComponent)", contentType: "movie/MPEG-4", expression: nil, completionHandler: nil).continueWith(executor: AWSExecutor.mainThread()) { (myTask) -> Any? in
            if let error = myTask.error {
                print("Error While Uploading ==> \(error.localizedDescription)")
            } else {
                if let taskResult = myTask.result {
                    print("Output Desc ==> \(taskResult.description)")
                } else {
                    print("Some Error")
                }
            }
            dispatchGroup.leave()
            return nil
        }
    }
    
    
    //MARK:Save and retrive country state and city data in document folder
    
    ///store contrystatecity in document folder and retrive methods
    class func readFile(FileName:String) -> Data{
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent("\(FileName)")
            //reading
            do {
                let text2 = try! Data(contentsOf: fileURL)
                return text2
            }
            catch {
                print("err reading file")
            }
        }
        return 0 as! Data
    }
    class func readDataFromFile(FileName:String, completion: @escaping (Data) -> Void) -> Void{
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent("\(FileName)") {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                let str = self.readFile(FileName: FileName)
                if let usableData = str as? Data{
                    do {
                        DispatchQueue.main.async {
                            print(usableData)
                            completion(usableData)
                        }
                    } catch {
                        print("JSON Processing Failed")
                    }
                }
            }else{
                
            }
        }
    }
    
    class func saveDataToFile(fileName:String,DataToSave:Data){
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        if let pathComponent = url.appendingPathComponent("\(fileName)") {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                print("FILE AVAILABLE")
                do {
                    try DataToSave.write(to: pathComponent)
                    //print(pathComponent)
                } catch {
                    print("Failed to write JSON data: \(error.localizedDescription)")
                }
            } else {
                print("FILE NOT AVAILABLE and written")
                //********CREATE AND WRITE TO FILE*************
                let paths2 = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
                let pathDirectory =  NSURL(fileURLWithPath: paths2)
                try? FileManager().createDirectory(at: pathDirectory as URL, withIntermediateDirectories: true)
                let filePath = pathDirectory.appendingPathComponent("\(fileName)")
                do {
                    try DataToSave.write(to: filePath!)
                    //print(filePath!)
                } catch {
                    print("Failed to write JSON data: \(error.localizedDescription)")
                }
                //***********************************
            }
        } else {
            print("FILE PATH NOT AVAILABLE")
        }
    }
    
    class func removeFileLocalPath(localPathName:String) {
        let filemanager = FileManager.default
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0] as NSString
        let destinationPath = documentsPath.appendingPathComponent(localPathName)
        do {
            try filemanager.removeItem(atPath: destinationPath)
            print("Local path removed successfully")
        } catch let error as NSError {
            print("------Error",error.debugDescription)
        }
    }
    
    class func downloadLocationData(paramString: String, finished: @escaping ((_ responseData: Data)->Void))
    {
        let url = URL(string: "\(getCountryStateCity)")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = paramString.data(using:String.Encoding.ascii, allowLossyConversion: false)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if( error == nil && data!.count >= 0)
            {
                do {
                    let string1 = String(data: data!, encoding: String.Encoding.utf8)?.trimmingCharacters(in: .whitespaces) ?? "Data could not be printed"
                    if let data2 = string1.data(using: .utf8) {
                        do {
                            let dict = try JSONSerialization.jsonObject(with: data2, options:[]) as! [String: Any]
                            finished(data!)
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
            else
            {
                print("ws error: \(String(describing: error?.localizedDescription))")
            }
        }
        task.resume()
    }
    
    
    
    //MARK: Api request method
    
    class func URLRequestSession(apiURL: URL,body: Data, completion: @escaping (NSDictionary) -> Void) -> Void{
        var request = URLRequest(url: apiURL)
        request.timeoutInterval = 30
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = body
        let task = URLSession.shared.dataTask(with: request){(data,response,error)in
            print(data)
            print(response)
        
            guard let dataResponse = data,
                error == nil else{
                    print(error?.localizedDescription as Any)
                    var jsonResponse : NSMutableDictionary = NSMutableDictionary()
                    jsonResponse.setValue(400, forKey: "responseCode")
                    jsonResponse.setValue(error?.localizedDescription as! String, forKey: "responseMessage")
                    completion(jsonResponse)
                    return
            }
            do{
                var jsonResponse : NSDictionary!
                jsonResponse = try JSONSerialization.jsonObject(with: dataResponse, options: .allowFragments)as? NSDictionary
                completion(jsonResponse)
            } catch let parsingError {
                print("an error occurred parsing json data : \(parsingError)")
            }
        }
        task.resume()
    }
    
    
    class func getDataFromServer(apiURL:String,FileName:String){
        let url = URL(string: "\(apiURL)")
        var request = URLRequest(url: url!)
        request.timeoutInterval = 30
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        //request.httpBody = body
        let task = URLSession.shared.dataTask(with: request){(data,response,error)in
            guard let dataResponse = data,
                error == nil else{
                    return
            }
            do{
                var jsonResponse : NSDictionary!
                jsonResponse = try JSONSerialization.jsonObject(with: dataResponse, options: .allowFragments)as? NSDictionary
                //completion(data!)
                saveDataToFile(fileName: FileName, DataToSave: data!)
            } catch let parsingError {
                print("an error occurred parsing json data : \(parsingError)")
            }
        }
        task.resume()
    }
}

// MARK: - string to json obj

extension Functions {
    class func convertToJson(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    class func convertToString(dic: [String: Any]) -> String? {
        if let theJSONData = try? JSONSerialization.data(withJSONObject: dic, options: []) {
            let theJSONText = String(data: theJSONData, encoding: .ascii)
            return theJSONText
        }
        return nil
    }
}
extension Date {
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).capitalized
        // or use capitalized(with: locale) if you want
    }
}
extension Double {
    // MARK: Round Double To Places (Location)
    
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
