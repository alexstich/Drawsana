//
//  TextShapeEditingView.swift
//  Drawsana
//
//  Created by Steve Landey on 8/8/18.
//  Copyright © 2018 Asana. All rights reserved.
//

import UIKit

public class TextShapeEditingView: UIView {
  /// Upper left 'delete' button for text. You may add any subviews you want,
  /// set border & background color, etc.
  public let deleteControlView = UIView()
  /// Lower right 'rotate' button for text. You may add any subviews you want,
  /// set border & background color, etc.
  public let resizeAndRotateControlView = UIView()
  /// Right side handle to change width of text. You may add any subviews you
  /// want, set border & background color, etc.
  public let changeWidthControlView = UIView()

  /// The `UITextView` that the user interacts with during editing
  public let textView: UITextView

  public enum DragActionType {
    case delete
    case resizeAndRotate
    case changeWidth
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
    deleteControlView.backgroundColor = UIColor.red.withAlphaComponent(0.5)
    deleteControlView.layer.borderColor = UIColor.gray.cgColor
    deleteControlView.layer.borderWidth = 1
    deleteControlView.layer.cornerRadius = 3
    deleteControlView.clipsToBounds = true
    deleteControlView.add
    
    let imageDelete = UIImage(named: "icon_close")
    let imageViewDelete = UIImageView(image: setColor(image: imageDelete!, UIColor.white))
    imageViewDelete.alpha = 0.5
    deleteControlView.addSubview(imageViewDelete)
    
    resizeAndRotateControlView.translatesAutoresizingMaskIntoConstraints = false
    resizeAndRotateControlView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
    resizeAndRotateControlView.layer.borderColor = UIColor.gray.cgColor
    resizeAndRotateControlView.layer.borderWidth = 1
    resizeAndRotateControlView.layer.cornerRadius = 3
    resizeAndRotateControlView.clipsToBounds = true
    
    let imageResizeAndRotate = UIImage(named: "icon_rotate")
    let imageViewResizeAndRotate = UIImageView(image: setColor(image: imageResizeAndRotate!, UIColor.white))
    imageViewResizeAndRotate.alpha = 0.5
    resizeAndRotateControlView.addSubview(imageViewResizeAndRotate)
    
    changeWidthControlView.translatesAutoresizingMaskIntoConstraints = false
    changeWidthControlView.backgroundColor = UIColor.yellow.withAlphaComponent(0.5)
    changeWidthControlView.layer.borderColor = UIColor.gray.cgColor
    changeWidthControlView.layer.borderWidth = 1
    changeWidthControlView.layer.cornerRadius = 3
    changeWidthControlView.clipsToBounds = true
    
    let imageChangeWidth = UIImage(named: "icon_expand")
    let imageViewChangeWidth = UIImageView(image: setColor(image: imageChangeWidth!, UIColor.white))
    imageViewChangeWidth.alpha = 0.5
    changeWidthControlView.addSubview(imageViewChangeWidth)
    
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

  @discardableResult
  override public func becomeFirstResponder() -> Bool {
    return textView.becomeFirstResponder()
  }

  @discardableResult
  override public func resignFirstResponder() -> Bool {
    return textView.resignFirstResponder()
  }

  public func addStandardControls() {
    addControl(dragActionType: .delete, view: deleteControlView) { (textView, deleteControlView) in
      NSLayoutConstraint.activate(deprioritize([
        deleteControlView.widthAnchor.constraint(equalToConstant: 26),
        deleteControlView.heightAnchor.constraint(equalToConstant: 26),
        deleteControlView.rightAnchor.constraint(equalTo: textView.leftAnchor),
        deleteControlView.bottomAnchor.constraint(equalTo: textView.topAnchor, constant: -3),
      ]))
    }

    addControl(dragActionType: .resizeAndRotate, view: resizeAndRotateControlView) { (textView, resizeAndRotateControlView) in
      NSLayoutConstraint.activate(deprioritize([
        resizeAndRotateControlView.widthAnchor.constraint(equalToConstant: 26),
        resizeAndRotateControlView.heightAnchor.constraint(equalToConstant: 26),
        resizeAndRotateControlView.leftAnchor.constraint(equalTo: textView.rightAnchor, constant: 5),
        resizeAndRotateControlView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 4),
      ]))
    }

    addControl(dragActionType: .changeWidth, view: changeWidthControlView) { (textView, changeWidthControlView) in
      NSLayoutConstraint.activate(deprioritize([
        changeWidthControlView.widthAnchor.constraint(equalToConstant: 26),
        changeWidthControlView.heightAnchor.constraint(equalToConstant: 26),
        changeWidthControlView.leftAnchor.constraint(equalTo: textView.rightAnchor, constant: 5),
        changeWidthControlView.bottomAnchor.constraint(equalTo: textView.topAnchor, constant: -4),
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
    
    private func setColor(image: UIImage, _ newColor: UIColor) -> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        newColor.setFill()
        
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.setBlendMode(CGBlendMode.normal)
        
        let rect = CGRect(origin: .zero, size: CGSize(width: image.size.width, height: image.size.height))
        context?.clip(to: rect, mask: image.cgImage!)
        context?.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

private func deprioritize(_ constraints: [NSLayoutConstraint]) -> [NSLayoutConstraint] {
  for constraint in constraints {
    constraint.priority = .defaultLow
  }
  return constraints
}
