//
//  EmojiDragHandler.swift
//  Drawsana
//
//  Created by Алексей Гребенкин on 16.04.2021.
//

import CoreGraphics

class EmojiDragHandler {
    
    weak var textTool: EmojiTool?
    let shape: EmojiShape
    var startPoint: CGPoint = .zero
    
    init(shape: EmojiShape, textTool: EmojiTool)
    {
        self.shape = shape
        self.textTool = textTool
    }
    
    func handleDragStart(context: ToolOperationContext, point: CGPoint)
    {
        startPoint = point
    }
    
    func handleDragContinue(context: ToolOperationContext, point: CGPoint, velocity: CGPoint) {}
    func handleDragEnd(context: ToolOperationContext, point: CGPoint) {}
    func handleDragCancel(context: ToolOperationContext, point: CGPoint) {}
}

/// User is dragging the text itself to a new location
class EmojiMoveHandler: EmojiDragHandler {
    private var originalTransform: ShapeTransform
    
    override init(shape: EmojiShape, textTool: EmojiTool)
    {
        self.originalTransform = shape.transform
        super.init(shape: shape, textTool: textTool)
    }
    
    override func handleDragContinue(context: ToolOperationContext, point: CGPoint, velocity: CGPoint)
    {
        let delta = point - startPoint
        shape.transform = originalTransform.translated(by: delta)
        textTool?.updateTextView()
    }
    
    override func handleDragEnd(context: ToolOperationContext, point: CGPoint)
    {
        let delta = CGPoint(x: point.x - startPoint.x, y: point.y - startPoint.y)
        context.operationStack.apply(
            operation: ChangeTransformOperation(
                shape: shape,
                transform: originalTransform.translated(by: delta),
                originalTransform: originalTransform)
        )
    }
    
    override func handleDragCancel(context: ToolOperationContext, point: CGPoint)
    {
        shape.transform = originalTransform
        context.toolSettings.isPersistentBufferDirty = true
        textTool?.updateShapeFrame()
    }
}

/// User is dragging the lower-right handle to change the size and rotation
/// of the text box
class EmojiResizeAndRotateHandler: EmojiDragHandler {
    private var originalTransform: ShapeTransform
    
    override init(shape: EmojiShape, textTool: EmojiTool)
    {
        self.originalTransform = shape.transform
        super.init(shape: shape, textTool: textTool)
    }
    
    private func getResizeAndRotateTransform(point: CGPoint) -> ShapeTransform
    {
        let originalDelta = startPoint - shape.transform.translation
        let newDelta = point - shape.transform.translation
        let originalDistance = originalDelta.length
        let newDistance = newDelta.length
        let originalAngle = atan2(originalDelta.y, originalDelta.x)
        let newAngle = atan2(newDelta.y, newDelta.x)
        let scaleChange = newDistance / originalDistance
        let angleChange = newAngle - originalAngle
        return originalTransform.scaled(by: scaleChange).rotated(by: angleChange)
    }
    
    override func handleDragContinue(context: ToolOperationContext, point: CGPoint, velocity: CGPoint)
    {
        shape.transform = getResizeAndRotateTransform(point: point)
        textTool?.updateTextView()
    }
    
    override func handleDragEnd(context: ToolOperationContext, point: CGPoint)
    {
        context.operationStack.apply(
            operation: ChangeTransformOperation(
                shape: shape,
                transform: getResizeAndRotateTransform(point: point),
                originalTransform: originalTransform)
        )
    }
    
    override func handleDragCancel(context: ToolOperationContext, point: CGPoint)
    {
        shape.transform = originalTransform
        context.toolSettings.isPersistentBufferDirty = true
        textTool?.updateShapeFrame()
    }
}
