import UIKit

struct UnsplashImage {
    let id: String
    let url: String
    let description: String?
    let user: String
    let width: Int
    let height: Int
    
    var aspectRatio: CGFloat {
        CGFloat(height) / CGFloat(width)
    }
}

class UnsplashNetworkManager {
    static let shared = UnsplashNetworkManager()
    
    private let baseURL = "https://api.unsplash.com"
    
    // ИСПРАВЛЕНИЕ: Загружаем API ключ из Info.plist
    private var accessKey: String {
        guard let key = Bundle.main.infoDictionary?["UNSPLASH_ACCESS_KEY"] as? String else {
            print("❌ ОШИБКА: API ключ не найден в Info.plist")
            return ""
        }
        return key
    }
    
    // ИСПРАВЛЕНИЕ: Enum для констант
    private enum Constants {
        static let defaultPerPage = 30
        static let minImageWidth = 300
        static let timeout: TimeInterval = 30
    }
    
    func fetchImages(page: Int = 1, perPage: Int = Constants.defaultPerPage, completion: @escaping ([UnsplashImage]?, Error?) -> Void) {
        let endpoint = "\(baseURL)/photos?page=\(page)&per_page=\(perPage)&client_id=\(accessKey)"
        
        guard let url = URL(string: endpoint) else {
            completion(nil, NSError(domain: "Invalid URL", code: -1, userInfo: nil))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = Constants.timeout
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "No data", code: -1, userInfo: nil))
                return
            }
            
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    var images: [UnsplashImage] = []
                    
                    for item in jsonArray {
                        if let id = item["id"] as? String,
                           let urls = item["urls"] as? [String: String],
                           let regularUrl = urls["regular"],
                           let user = item["user"] as? [String: Any],
                           let userName = user["name"] as? String,
                           let width = item["width"] as? Int,
                           let height = item["height"] as? Int {
                            
                            let description = item["description"] as? String ?? item["alt_description"] as? String
                            let image = UnsplashImage(id: id, url: regularUrl, description: description, user: userName, width: width, height: height)
                            images.append(image)
                        }
                    }
                    
                    completion(images, nil)
                }
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
    
    func fetchImagesByCategory(category: String, page: Int = 1, perPage: Int = Constants.defaultPerPage, completion: @escaping ([UnsplashImage]?, Error?) -> Void) {
        let endpoint = "\(baseURL)/search/photos?query=\(category)&page=\(page)&per_page=\(perPage)&client_id=\(accessKey)"
        
        guard let encodedEndpoint = endpoint.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedEndpoint) else {
            completion(nil, NSError(domain: "Invalid URL", code: -1, userInfo: nil))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = Constants.timeout
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "No data", code: -1, userInfo: nil))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let results = json["results"] as? [[String: Any]] {
                    var images: [UnsplashImage] = []
                    
                    for item in results {
                        if let id = item["id"] as? String,
                           let urls = item["urls"] as? [String: String],
                           let regularUrl = urls["regular"],
                           let user = item["user"] as? [String: Any],
                           let userName = user["name"] as? String,
                           let width = item["width"] as? Int,
                           let height = item["height"] as? Int {
                            
                            let description = item["description"] as? String ?? item["alt_description"] as? String
                            let image = UnsplashImage(id: id, url: regularUrl, description: description, user: userName, width: width, height: height)
                            images.append(image)
                        }
                    }
                    
                    completion(images, nil)
                }
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
}
