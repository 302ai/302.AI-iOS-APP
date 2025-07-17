//
//  AIModel.swift
//  GPTalks
//
//  Created by Adswave on 2025/3/25.
//

import Foundation
 

struct AI302Model: Hashable, Codable,Identifiable {
    
    var id: String
    var is_moderated: Bool 
     
    init(id: String, is_moderated: Bool = true) {
           self.id = id
           self.is_moderated = is_moderated
       }
    
    // 自定义解码逻辑：如果 JSON 无 `is_moderated`，则使用默认值 `true`
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            is_moderated = try container.decodeIfPresent(Bool.self, forKey: .is_moderated) ?? true
        }
        
        enum CodingKeys: String, CodingKey {
            case id, is_moderated
        }
     
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
//    
//    static func == (lhs: AI302Model, rhs: AI302Model) -> Bool {
//        lhs.id == rhs.id
//    }
//
//    init(id: String) {
//        self.id = id
//    }
    
    
    /**
     let id: String
     //let object: String
     
     init(
     id: String = "gpt-4"
     //object: String
     ) {
     self.id = id
     //self.object = object
     }
     
     init(from decoder: Decoder) throws {
     let container = try decoder.container(keyedBy: CodingKeys.self)
     self.id = try container.decode(String.self, forKey: .id)
     //self.object = try container.decode(String.self, forKey: .object)
     }
     */

}
