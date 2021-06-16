//
//  Webservices.swift
//  CommonFunctions
//
//  Created by mac on 16/06/21.
//

import UIKit
import Alamofire

    class WebService: NSObject {
        static var shared = WebService()
        
        func updateCourseProgress(UserID:String, courseID:String, ClassID:String, Type:String, Duration:Int,  completion: @escaping (NSDictionary?)->Void)->Void{
            
            let url:String = "\(APIURL)\(courseProgress)"
            print(url)
            let param : [String: Any] = [
                "userId":"\(UserID)",
              //  "courseId":"\(courseID)",
                   "id":"\(ClassID)",
                   "type":"module",                   "duration":Duration
               ]
            var headers: HTTPHeaders = [.authorization(bearerToken: "\(AppDelegate.appDelegate.AuthToken)")]
            headers["Accept-Language"] = (AppDelegate.appDelegate.appLanguage)
            print(param)
            AF.sessionConfiguration.timeoutIntervalForRequest = 60
            AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                print(response.data)
                print(response.response)
                print(response.error)
                if response.data != nil {
                    let data  = try? JSONSerialization.jsonObject(with: response.data!, options: .allowFragments)
                    if let result = data as? NSDictionary{
                        completion(result)
                    }
                }else{
                    completion(nil)
                }
            }
        }
        
        //video upload
        func upload(vdo:URL,Tags:[String] ,soundName:String, soundDescription:String, soundId:String, soundPAthMp3:String, soundPathAcc:String, soundSection:String,
                    soundCreated:String, Lat:String, Long:String, Description:String, Category:String, Language:String, completion: @escaping (NSDictionary?)->Void)->Void{
            
            // func upload(vdo:URL, completion: @escaping (NSDictionary)->Void)->Void{
            let parameters = ["createdBy":"\(AppDelegate.appDelegate.userId)",
                              
                              "language":"\(Language)",
                              "category":"\(Category)",
                              "description":"\(Description)",
                              "location.lat":"\(Lat)",
                              "location.long":"\(Long)",
                              "sound.id":"\(soundId)",
                              "sound.audio_path.mp3":"\(soundPAthMp3)",
                              "sound.audio_path.acc":"\(soundPathAcc)",
                              "sound.sound_name":"\(soundName)",
                              "sound.description":"\(soundDescription)",
                              "sound.thum":"",
                              "sound.section":"\(soundSection)",
                              "sound.created":"\(soundCreated)"
            ]
            
            
            
            var headers: HTTPHeaders = [.authorization(bearerToken: "\(AppDelegate.appDelegate.AuthToken)")]
            // var headers: HTTPHeaders = HTTPHeaders()
            headers["Accept-Language"] = (AppDelegate.appDelegate.appLanguage)
            AF.sessionConfiguration.timeoutIntervalForRequest = 900
            AF.upload(multipartFormData: {
                MultipartFormData in
                for (key, value) in parameters {
                    MultipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                }
                for i in 0..<Tags.count {
                    let value = Tags[i]
                    MultipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: "tags[\(i)]")
                }
                MultipartFormData.append(vdo, withName: "video", fileName: "video.mp4", mimeType: "video/mp4")
            }, to: "\(APIURL)\(postVideo)", headers:headers).responseJSON { response in
                //print(response.data)
                //print(response.response)
                print(response.error)
                if response.data != nil {
                    let data  = try? JSONSerialization.jsonObject(with: response.data!, options: .allowFragments)
                    if let result = data as? NSDictionary{
                        print("***************************************************************")
                        print(result)
                        print("***************************************************************")
                        completion(result)
                        ////*************************************************************
                    }
                }else{
                    completion(nil)
                }
            }
        }
        
        //image upload using alamofire
        func uploadProfileImage(id:String,image:UIImage,fileName:String, completion: @escaping (NSDictionary)->Void)-> Void{
            if let data = image.jpegData(compressionQuality: 1) {
                let parameters: Parameters = [
                    "_id" : "\(id)"
                ]
                // You can change your image name here, i use NSURL image and convert into string
                
                let fileName = fileName
                // Start Alamofire
                var headers: HTTPHeaders = HTTPHeaders()
                headers["Accept-Language"] = (AppDelegate.appDelegate.appLanguage)
                AF.upload(multipartFormData: { multipartFormData in
                    multipartFormData.append(data, withName: "propic",fileName: "file.jpg", mimeType: "image/jpg")
                    for (key, value) in parameters {
                        multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
                    } //Optional for extra parameters
                },
                to:"\(APIURL)\(update_propic)", method: .patch)
                { (result) in
                     print("***************************************************************")
                        print(result)
                        print("***************************************************************")
                    //                switch result {
                    //                case .success(let upload, _, _):
                    //
                    //                    upload.uploadProgress(closure: { (progress) in
                    //                        print("Upload Progress: \(progress.fractionCompleted)")
                    //                    })
                    //
                    //                    upload.responseJSON { response in
                    //                         print(response.result.value)
                    //                    }
                    //
                    //                case .failure(let encodingError):
                    //                    print(encodingError)
                    //                }
                }
              }
        }
        
    //image upload with url session
        func uploadCoverImageToServer(image: Data,imageName:String,userID:String,completion: @escaping (NSDictionary?) -> Void) -> Void {
            let paramName = "banner"
            let currentTimeStamp = String(Int(NSDate().timeIntervalSince1970))
            let fileName = "img\(currentTimeStamp)\(imageName)"
            let id  = "_id"
            let idValue = "\(userID)"
            //let url = URL(string: "\(APIURL)/user/update_propic")
            let boundary = UUID().uuidString
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            var urlRequest = URLRequest(url: URL(string: "\(APIURL)\(update_banner)")!)
            urlRequest.httpMethod = "PATCH"
            urlRequest.setValue("\(AppDelegate.appDelegate.AuthToken)", forHTTPHeaderField: "Authorization")
            
            urlRequest.timeoutInterval = 30
            urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            var data = Data()
            
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(id)\"\r\n\r\n".data(using: .utf8)!)
            data.append("\(idValue)".data(using: .utf8)!)
            
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
            data.append(image as Data)
            
            data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
            
            session.uploadTask(with: urlRequest, from: data, completionHandler: { responseData, response, error in
                
                print(responseData)
                print(response)
                print(error)
                
                if error == nil {
                    let jsonData = try? JSONSerialization.jsonObject(with: responseData!, options: .allowFragments)
                    if let json = jsonData as? NSDictionary {
                        print(json)
                        completion(json)
                    }
                }else{
                    completion(nil)
                }
            }).resume()
        }
}
