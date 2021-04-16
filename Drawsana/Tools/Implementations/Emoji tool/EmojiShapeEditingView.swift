//
//  EmojiShapeEditingView.swift
//  Drawsana
//
//  Created by Алексей Гребенкин on 16.04.2021.
//

import UIKit

public class EmojiShapeEditingView: UIView {
    /// Upper left 'delete' button for text. You may add any subviews you want,
    /// set border & background color, etc.
    public let deleteControlView = UIView()
    /// Lower right 'rotate' button for text. You may add any subviews you want,
    /// set border & background color, etc.
    public let resizeAndRotateControlView = UIView()
    
    /// The `UITextView` that the user interacts with during editing
    public let textView: UITextView
    
    public enum DragActionType {
        case delete
        case resizeAndRotate
    }
    
    public struct Control {
        public let view: UIView
        public let dragActionType: DragActionType
    }
    
    public private(set) var controls = [Control]()
    
    init(textView: UITextView) {
        self.textView = textView
        super.init(frame: .zero)
        
        clipsToBounds = false
        backgroundColor = .clear
        layer.isOpaque = false
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        deleteControlView.translatesAutoresizingMaskIntoConstraints = false
        deleteControlView.backgroundColor = UIColor.red
        
        resizeAndRotateControlView.translatesAutoresizingMaskIntoConstraints = false
        resizeAndRotateControlView.backgroundColor = UIColor.white
        
        addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.leftAnchor.constraint(equalTo: leftAnchor),
            textView.rightAnchor.constraint(equalTo: rightAnchor),
            textView.topAnchor.constraint(equalTo: topAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        return textView.sizeThatFits(size)
    }
    
    public func addDeleteControl() {
        addControl(dragActionType: .delete, view: deleteControlView) { (textView, deleteControlView) in
            NSLayoutConstraint.activate(deprioritize([
                deleteControlView.widthAnchor.constraint(equalToConstant: 26),
                deleteControlView.heightAnchor.constraint(equalToConstant: 26),
                deleteControlView.rightAnchor.constraint(equalTo: textView.leftAnchor),
                deleteControlView.bottomAnchor.constraint(equalTo: textView.topAnchor, constant: -3),
            ]))
        }
    }
    
    public func addResizeAndRotateControl() {
        addControl(dragActionType: .resizeAndRotate, view: resizeAndRotateControlView) { (textView, resizeAndRotateControlView) in
            NSLayoutConstraint.activate(deprioritize([
                resizeAndRotateControlView.widthAnchor.constraint(equalToConstant: 26),
                resizeAndRotateControlView.heightAnchor.constraint(equalToConstant: 26),
                resizeAndRotateControlView.leftAnchor.constraint(equalTo: textView.rightAnchor, constant: 5),
                resizeAndRotateControlView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 4),
            ]))
        }
    }
    
    public func addControl<T: UIView>(dragActionType: DragActionType, view: T, applyConstraints: (UITextView, T) -> Void) {
        addSubview(view)
        controls.append(Control(view: view, dragActionType: dragActionType))
        applyConstraints(textView, view)
    }
    
    public func getDragActionType(point: CGPoint) -> DragActionType? {
        guard let superview = superview else { return .none }
        for control in controls {
            if control.view.convert(control.view.bounds, to: superview).contains(point) {
                return control.dragActionType
            }
        }
        return nil
    }
}

private func deprioritize(_ constraints: [NSLayoutConstraint]) -> [NSLayoutConstraint] {
    for constraint in constraints {
        constraint.priority = .defaultLow
    }
    return constraints
}
