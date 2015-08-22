//
//  ResponseEntity.swift
//  SwinjectMVVMExample
//
//  Created by Yoichi Tagaya on 8/21/15.
//  Copyright © 2015 Swinject Contributors. All rights reserved.
//

import Himotoki

public struct ResponseEntity: Decodable {
    public let totalCount: Int64
    public let images: [ImageEntity]

    public static func decode(e: Extractor) -> ResponseEntity? {
        
        return build(
            e <| "totalHits",
            e <|| "hits"
            ).map(ResponseEntity.init)
    }
}
