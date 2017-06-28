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
import AlamofireImage


class APIManager {

    private static let SERVER_IP = "http://188.166.211.232"
//    private static let SERVER_IP = "http://192.168.1.44:8000"

    private static let GET_PLAYLISTS_URL = "\(SERVER_IP)/musicapi/getplaylists"
    private static let GET_SONGS_URL = "\(SERVER_IP)/musicapi/getsongs"
    
    class func getPlaylistsRequest() -> Void {
        
        let parameters: Parameters = [:]
        
        request(URL: GET_PLAYLISTS_URL, method: .get, parameters: parameters, onSuccess: getPlaylistsOnSuccess, onError: defaultOnError)
        
    }

    
    private class func getPlaylistsOnSuccess(json: JSON) -> Void {
        
        print(json)
        let data = json["response"].dictionaryValue
        NotificationCenter.default.post(name: .getPlaylistsCallback, object: nil, userInfo: data)
        
    }
    
    
    class func getSongsRequest(playlist: Playlist) -> Void {
        
        print(playlist)
        
        let parameters: Parameters = [
            "screen" : "xhdpi",
            "playlist_id" : playlist.id
        ]
        
        
        Alamofire.request(GET_SONGS_URL, method: .get, parameters: parameters ).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                getSongsOnSuccess(json: json, playlist: playlist)
            case .failure(let error):
                defaultOnError(error: error)
            }
        }
        
    }
    
    
    private class func getSongsOnSuccess(json: JSON, playlist: Playlist) -> Void {
        
        print(json)
        let data = json["response"].dictionaryValue
        NotificationCenter.default.post(name: .getSongsCallback, object: nil, userInfo: ["data": data, "playlist": playlist])
        
    }
    
    
    class func getSongImage(song: Song, position: Int) {
        
        let URL = "\(SERVER_IP)\(song.img_url)"
        let safeURL = URL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!

        Alamofire.request(safeURL).responseImage { response in
            if let image = response.result.value {
                
                NotificationCenter.default.post(name: .getSongImageCallback, object: nil, userInfo: ["image": image, "position": position])
            }
        }
        
    }
    
    
    class func getServerIP() -> String {
        return SERVER_IP
    }
    
    
    private class func defaultOnSuccess(json: JSON) -> Void {
        
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
