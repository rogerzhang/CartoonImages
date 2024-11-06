import Foundation

struct User: Codable {
    let id: String
    let username: String
    let email: String
    // 添加其他需要的用户属性
}

struct Product: Codable {
    let id: String
    let name: String
    let price: Double
    let description: String
    // 添加其他需要的产品属性
}

struct APIError: Codable {
    let message: String
    let code: Int
} 