import Foundation
import Alamofire

class FADNetwork: NSObject {
    
    let BASE_URL: String! =  "http://10.0.90.13:3004/api/"
    
    func request(post urn: String, params: [String : Any], authorizationRequired: Bool, success: @escaping (_ result: AnyObject) -> Void, failure:@escaping (_ error: NSError) -> Void) {
        
        Alamofire.request(urlString(urn), method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers(authorizationRequired)).responseJSON { (response) in
            
            switch response.result {
            case .success(let JSON):
                print("Success Response: \(JSON)")
                
                if self.isSessionExpired(JSON as AnyObject) == true {
                    self.fetchNewAccessToken(fetchToken: { () in
                        self.request(post: urn, params: params, authorizationRequired: authorizationRequired, success: success, failure: failure)
                    })
                    
                } else {
                    success(JSON as AnyObject)
                }
                
            case .failure(let error):
                print("Failure Response: \(error)")
                
                
                failure(error as NSError)
            }
            
        }
        
    }
    
    func request(get urn: String, params: [String : Any]?, authorizationRequired: Bool, success: @escaping (_ result: AnyObject) -> Void, failure:@escaping (_ error: NSError) -> Void) {
        
        Alamofire.request(urlString(urn), method: .get, parameters: params, encoding: JSONEncoding.default, headers: headers(authorizationRequired)).responseJSON { (response) in
            
            switch response.result {
            case .success(let JSON):
                print("Success Response: \(JSON)")
                
                if self.isSessionExpired(JSON as AnyObject) == true {
                    self.fetchNewAccessToken(fetchToken: { () in
                        self.request(get: urn, params: params, authorizationRequired: authorizationRequired, success: success, failure: failure)
                    })
                    
                } else {
                    success(JSON as AnyObject)
                }
                
            case .failure(let error):
                print("Failure Response: \(error)")
                failure(error as NSError)
            }
            
        }
    }
    
    func fetchNewAccessToken(fetchToken success: @escaping (Void) -> Void) {
        
        request(post: REFRESH_TOKEN_URN, params: ([REFRESH_TOKEN_KEY : FADUser.currentUser()!.refreshToken!] as AnyObject) as! [String : Any], authorizationRequired: false, success: { (result) in
            
            FADUser.updateAccessToken(result as! [String : String])
            success()
        }) { (error) in
            print("New acceess token fetch failed")
        }
    }
    
    func request(put urn: String, params: [String : Any]?, authorizationRequired: Bool, success: @escaping (_ result: AnyObject) -> Void, failure:@escaping (_ error: NSError) -> Void) {
        
        Alamofire.request(urlString(urn), method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers(authorizationRequired)).responseJSON { (response) in
            
            switch response.result {
            case .success(let JSON):
                print("Success Response: \(JSON)")
                
                if self.isSessionExpired(JSON as AnyObject) == true {
                    self.fetchNewAccessToken(fetchToken: { () in
                        self.request(put: urn, params: params!, authorizationRequired: authorizationRequired, success: success, failure: failure)
                    })
                    
                } else {
                    success(JSON as AnyObject)
                }
                
            case .failure(let error):
                print("Failure Response: \(error)")
                failure(error as NSError)
            }
            
        }
    }
    
    func upload(imageUpload urn: String, fileData: Data, success: @escaping (_ result: AnyObject) -> Void, failure: @escaping (_ error: NSError) -> Void) {
        
        Alamofire.upload(multipartFormData: { (data) in
            data.append(fileData, withName: "file", fileName: "file.png", mimeType: "image/png")
        }, to: urlString(urn)) { (response) in
            
            switch response {
                
            case .success(let upload, _, _):
                
                upload.responseJSON(completionHandler: { (finalResponse) in
                    
                    switch finalResponse.result {
                        
                    case .success(let JSON):
                        success(JSON as AnyObject)
                        break
                        
                    case .failure(let error):
                        failure(error as NSError)
                        break
                    }
                    
                })
                
            case .failure:
                failure(NSError(domain: "Error", code: -1234, userInfo: nil))
                break
            }
            
        }
        
    }

    
    func request(download urn: String) {
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (URL(fileURLWithPath: String.profileImagePath()), [.removePreviousFile, .createIntermediateDirectories])
        }
        
        let downloadRequest = Alamofire.download(urlString(urn), to: destination)
        downloadRequest.response { (response) in
            print(response.destinationURL?.absoluteString)
        }
    }
    
    fileprivate func headers(_ authorizationRequired: Bool) -> [String : String]? {
        
        var authToken = [String : String]()
        if FADUser.accessToken().characters.count > 0 && authorizationRequired == true {
            authToken.updateValue(FADUser.accessToken(), forKey: "accessToken")
        }
        
        return authToken
    }
    
    fileprivate func urlString(_ urn: String) -> String {
        return String(format: "%@%@", BASE_URL, urn)
    }
    
    fileprivate func isSessionExpired(_ response: AnyObject) -> Bool {
        
        if response.isKind(of: NSDictionary.self) {
            if ((response as! NSDictionary).allKeys as NSArray).contains("expiredAt") == true {
                return true
            }
        }
        
        return false
    }
}
