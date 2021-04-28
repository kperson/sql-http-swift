import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import HttpExecuter


public class DefaultRequestExecuter: RequestExecuter {
    
    public init() {}
    
    public func execute(request: HttpRequest, _ callback: @escaping (HttpResponse?, Error?) -> Void) {
        var urlRequest = URLRequest(url: request.url)
        let session = URLSession.shared
        urlRequest.httpMethod = request.requestMethod.rawValue
        if let b = request.body, !b.isEmpty {
            urlRequest.httpBody = b
        }
        let task = session.dataTask(with: urlRequest, completionHandler: { data, response, error -> Void in
            if let r = response as? HTTPURLResponse, let d = data {
                var responseHeaders: Dictionary<String, String> = [:]
                for (headerKey, headerValue) in r.allHeaderFields {
                    if let value = headerValue as? String {
                        responseHeaders[headerKey as! String] = value
                    }
                }
                let httpResponse = HttpResponse(statusCode: UInt(r.statusCode), body: d, headers: responseHeaders)
                callback(httpResponse, nil)
            }
            else if let e = error {
                callback(nil, e)
            }
        })
        task.resume()
        
    }
    
    
    
    
}
