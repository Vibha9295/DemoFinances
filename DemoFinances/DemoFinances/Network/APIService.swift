//
//  APIService.swift
//  DemoFinances
//
//  Created by Sparrow on 2024-02-07.
//

import Foundation

class APIService {
    static let shared = APIService()
    
    private let apiEndpoint = "https://x8ki-letl-twmt.n7.xano.io/api:O8qF4MsJ/transactions"
    
    func fetchData(completion: @escaping (Transaction?) -> Void) {
        guard let url = URL(string: apiEndpoint) else { completion(nil); return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else { completion(nil); return }
            
            do {
                let transactions = try JSONDecoder().decode(Transaction.self, from: data)
                completion(transactions)
            } catch {
                print("Error decoding data: \(error.localizedDescription)")
                completion(nil)
            }
        }
        
        task.resume()
    }
    func submitTransaction(_ transactionInput: TransactionInput, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: apiEndpoint) else { return  }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(transactionInput)
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let _ = data {
                    completion(true)
                } else {
                    print("Error submitting transaction: \(error?.localizedDescription ?? "Unknown error")")
                    completion(false)
                }
            }.resume()
        } catch {
            print("Error encoding transaction input: \(error)")
            completion(false)
        }
    }
}
