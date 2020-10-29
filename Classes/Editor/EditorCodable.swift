struct View: Codable {
    let viewType: String
    let viewInfo: ViewInfo
    let uri: String
}

struct ViewInfo: Codable {
    let rotation: Float
    let translationX: Float
    let translationY: Float
    let scale: Float
    let addedViewTextInfo: TextInfo
    let size: CGSize
}

struct TextInfo: Codable {
    let text: String
    let fontSizePx: Float
    let textColor: Float
    let textAlignment: TextAlignment
}

enum TextAlignment: Int, Codable {
    case left = 0
    case center
    case right

    var nsAlignment: NSTextAlignment {
        switch self {
        case .left:
            return .left
        case .center:
            return .center
        case .right:
            return .right
        }
    }
}
