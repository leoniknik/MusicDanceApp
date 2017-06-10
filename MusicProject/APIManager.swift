//
//  APIManager.swift
//  MusicProject
//
//  Created by Кирилл Володин on 10.06.17.
//  Copyright © 2017 Кирилл Володин. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class APIManager {

    private static let SERVER_IP = "http://188.166.211.232"

    private static let GET_PLAYLISTS_URL = "\(SERVER_IP)/musicapi/getplaylists"
    private static let GET_SONGS_URL = "\(SERVER_IP)/musicapi/getsongs"
    
    class func getPlaylistsRequest() -> Void {
        
        let parameters: Parameters = [:]
        
        request(URL: GET_PLAYLISTS_URL, method: .post, parameters: parameters, onSuccess: defaultOnSuccess, onError: defaultOnError)
        
    }
//
//    class func signUpOnSuccess(json: JSON) -> Void {
//        print(json)
//        let code = json["code"].int!
//        if code == OK {
//            NotificationCenter.default.post(name: .signUpCallback, object: nil)
//        }
//    }
    
    private class func defaultOnSuccess(json: JSON) -> Void{
        print(json)
    }
    
    private class func defaultOnError(error: Any) -> Void {
        print(error)
    }
    
    private class func request(URL: String, method: HTTPMethod, parameters: Parameters, onSuccess: @escaping (JSON) -> Void , onError: @escaping (Any) -> Void) -> Void {
        Alamofire.request(URL, method: method, parameters: parameters ).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                onSuccess(json)
            case .failure(let error):
                onError(error)
            }
        }
    }
}
