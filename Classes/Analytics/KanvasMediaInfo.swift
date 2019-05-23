//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public typealias KanvasMediaInfo = KanvasMediaInfoSimple

public struct KanvasMediaInfoSimple {

    public enum Source {
        case kanvas_camera
        case media_library
        case media_library_kanvas_camera
    }

    public let source: Source
}

extension KanvasMediaInfoSimple: Codable {
    private enum CodingKeys: String, CodingKey {
        case source
    }
}

extension KanvasMediaInfoSimple.Source: Codable {
    private enum CodingKeys: String, CodingKey {
        case kanvas_camera
        case media_library_kanvas_camera
        case media_library
    }

    enum CodingError: Error {
        case decoding(String)
    }

    public init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        switch value {
        case CodingKeys.kanvas_camera.rawValue:
            self = .kanvas_camera
        case CodingKeys.media_library.rawValue:
            self = .media_library
        case CodingKeys.media_library_kanvas_camera.rawValue:
            self = .media_library_kanvas_camera
        default:
            throw CodingError.decoding("Invalid Source: \(value)")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .kanvas_camera:
            try container.encode(CodingKeys.kanvas_camera.rawValue)
        case .media_library:
            try container.encode(CodingKeys.media_library.rawValue)
        case .media_library_kanvas_camera:
            try container.encode(CodingKeys.media_library_kanvas_camera.rawValue)
        }
    }

    public func stringValue() -> String {
        switch self {
        case .kanvas_camera:
            return CodingKeys.kanvas_camera.rawValue
        case .media_library:
            return CodingKeys.media_library.rawValue
        case .media_library_kanvas_camera:
            return CodingKeys.media_library_kanvas_camera.rawValue
        }
    }
}
