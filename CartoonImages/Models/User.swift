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

struct Announcement: Identifiable, Codable {
    let id: Int
    let title: String
    let title_zh: String
    let body: String
    let body_zh: String
    let pub_date: String
    let is_top: Int
    var isRead: Bool = false
    
    enum CodingKeys: String, CodingKey {
         case id, title, title_zh, body, body_zh, pub_date, is_top, isRead
     }

     init(from decoder: Decoder) throws {
         let container = try decoder.container(keyedBy: CodingKeys.self)
         id = try container.decode(Int.self, forKey: .id)
         title = try container.decode(String.self, forKey: .title)
         title_zh = try container.decode(String.self, forKey: .title_zh)
         body = try container.decode(String.self, forKey: .body)
         body_zh = try container.decode(String.self, forKey: .body_zh)
         pub_date = try container.decode(String.self, forKey: .pub_date)
         is_top = try container.decode(Int.self, forKey: .is_top)
         isRead = try container.decodeIfPresent(Bool.self, forKey: .isRead) ?? false
     }
}

extension Announcement {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(title_zh, forKey: .title_zh)
        try container.encode(body, forKey: .body)
        try container.encode(body_zh, forKey: .body_zh)
        try container.encode(pub_date, forKey: .pub_date)
        try container.encode(is_top, forKey: .is_top)
        try container.encode(isRead, forKey: .isRead)
    }
}
