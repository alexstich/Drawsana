//
//  EmojiShape.swift
//  Drawsana
//
//  Created by Алексей Гребенкин on 16.04.2021.
//

import UIKit

public class EmojiShape: Shape, ShapeSelectable {
    private enum CodingKeys: String, CodingKey {
        case id, transform, text, fontSize, type, boundingRect
    }
    
    public static let type = "Emoji"
    
    public var id: String = UUID().uuidString
    /// This shape is positioned entirely with `EmojiShape.transform.translate`,
    /// rather than storing an explicit position.
    public var transform: ShapeTransform = .identity
    public var text = ""
    public var fontSize: CGFloat = 70
    public var boundingRect: CGRect = .zero
    
    public init() {}
        
    public required init(from decoder: Decoder) throws
    {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let type = try values.decode(String.self, forKey: .type)
        if type != EmojiShape.type {
            throw DrawsanaDecodingError.wrongShapeTypeError
        }
        
        id = try values.decode(String.self, forKey: .id)
        text = try values.decode(String.self, forKey: .text)
        fontSize = try values.decode(CGFloat.self, forKey: .fontSize)
        boundingRect = try values.decodeIfPresent(CGRect.self, forKey: .boundingRect) ?? .zero
        transform = try values.decode(ShapeTransform.self, forKey: .transform)
        
        if boundingRect == .zero {
            print("Text bounding rect not present. This shape will not render correctly because of a bug in Drawsana <0.10.0>")
        }
    }
    
    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(EmojiShape.type, forKey: .type)
        try container.encode(id, forKey: .id)
        try container.encode(text, forKey: .text)
        try container.encode(fontSize, forKey: .fontSize)
        try container.encode(transform, forKey: .transform)
        try container.encode(boundingRect, forKey: .boundingRect)
    }
    
    public func render(in context: CGContext)
    {
        transform.begin(context: context)
        let stringRect = CGRect(origin: CGPoint(x: boundingRect.origin.x + 10, y: boundingRect.origin.y + 5), size: CGSize(width: self.boundingRect.size.width - 10, height: self.boundingRect.size.height - 5))
        (self.text as NSString).draw(in: stringRect, withAttributes: [.font: UIFont(name: "Helvetica Neue", size: self.fontSize)!])
        transform.end(context: context)
    }
    
    public func apply(userSettings: UserSettings)
    {
        fontSize = userSettings.fontSize
    }
}
