import Foundation


public class BatchWriteBuilder {
    
    public let client: SQLHttpClient
    public let sql: String
    public private(set) var params: [[String : SQLValue]] = []
    
    
    public init(client: SQLHttpClient, sql: String) {
        self.client = client
        self.sql = sql
    }
    
    public func addBatch(_ values: [String: SQLValue]) -> BatchWriteBuilder {
        params.append(values)
        return self
    }
    
    public func execute(_ callback: @escaping (BatchWriteResponse?, Error?) -> Void) {
        client.executeBatchWrite(sql: sql, params: params, callback: callback)
    }
    
}
