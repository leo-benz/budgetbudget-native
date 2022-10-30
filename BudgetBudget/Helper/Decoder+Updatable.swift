//
//  Decoder+Updatable.swift
//  BudgetBudget
//
//  Created by Leo Benz on 30.10.22.
//
//  Based on https://stablekernel.com/article/understanding-extending-swift-4-codable/

import Foundation

protocol DecoderUpdatable {
    mutating func update(from decoder: Decoder) throws
}

protocol DecodingFormat {
    func decoder(for data: Data) -> Decoder
}

extension DecodingFormat {
    func update<T: DecoderUpdatable>(_ value: inout T, from data: Data) throws {
        try value.update(from: decoder(for: data))
    }
}

extension DecodingFormat {
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        return try T.init(from: decoder(for: data))
    }
}

struct DecoderExtractor: Decodable {
    let decoder: Decoder
    
    init(from decoder: Decoder) throws {
        self.decoder = decoder
    }
}

extension JSONDecoder: DecodingFormat {
    func decoder(for data: Data) -> Decoder {
        // Can try! here because DecoderExtractor's init(from: Decoder) never throws
        return try! decode(DecoderExtractor.self, from: data).decoder
    }
}

extension PropertyListDecoder: DecodingFormat {
    func decoder(for data: Data) -> Decoder {
        // Can try! here because DecoderExtractor's init(from: Decoder) never throws
        return try! decode(DecoderExtractor.self, from: data).decoder
    }
}
