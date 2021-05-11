//
//  APIRequest.swift
//  Habits
//
//  Created by Dmitry Reshetnik on 05.05.2021.
//

import UIKit

protocol APIRequest {
    associatedtype Response
    
    var path: String { get }
    var queryItems: [URLQueryItem]? { get }
    var request: URLRequest { get }
    var postData: Data? { get }
}

extension APIRequest {
    var host: String { "localhost" }
    var port: Int { 8080 }
}

extension APIRequest {
    var queryItems: [URLQueryItem]? { nil }
    var postData: Data? { nil }
}

extension APIRequest {
    var request: URLRequest {
        var componetns = URLComponents()
        componetns.scheme = "http"
        componetns.host = host
        componetns.port = port
        componetns.path = path
        componetns.queryItems = queryItems
        
        var request = URLRequest(url: componetns.url!)
        
        if let data = postData {
            request.httpBody = data
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
        }
        
        return request
    }
}

extension APIRequest where Response: Decodable {
    func send(completion: @escaping (Result<Response, Error>) -> Void) {
        URLSession.shared.dataTask(with: request) { data, _, error in
            do {
                if let data = data {
                    let decoded = try JSONDecoder().decode(Response.self, from: data)
                    completion(.success(decoded))
                } else if let error = error {
                    completion(.failure(error))
                }
            } catch {
                
            }
        }.resume()
    }
}

enum ImageRequestError: Error {
    case couldNotInitializeFromData
}

extension APIRequest where Response == UIImage {
    func send(completion: @escaping (Result<Self.Response, Error>) -> Void) {
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let data = data,
               let image = UIImage(data: data) {
                completion(.success(image))
            } else if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(ImageRequestError.couldNotInitializeFromData))
            }
        }.resume()
    }
}
