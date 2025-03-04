/*
 * Copyright © 2023 Dustin Collins (Strega's Gate)
 * All Rights Reserved.
 *
 * http://stregasgate.com
 */

public final class Vec2: ShaderValue {
    public let valueRepresentation: ValueRepresentation
    public let valueType: ValueType
    
    public let operation: Operation?
    
    internal var _x: Scalar?
    internal var _y: Scalar?
    
    public var x: Scalar {
        get {Scalar(representation: .vec2Value(self, 0), type: .float)}
        set {self._x = newValue}
    }
    public var y: Scalar {
        get {Scalar(representation: .vec2Value(self, 1), type: .float)}
        set {self._y = newValue}
    }
    
    public subscript (index: Int) -> Scalar {
        switch index {
        case 0: return self.x
        case 1: return self.y
        default: fatalError("Index out of range.")
        }
    }
    
    internal init(representation: ValueRepresentation, type: ValueType) {
        self.valueRepresentation = representation
        self.valueType = type
        self.operation = nil
        self._x = nil
        self._y = nil
    }
    
    internal init(_ operation: Operation) {
        self.valueRepresentation = .operation
        self.valueType = .operation
        self.operation = operation
        self._x = nil
        self._y = nil
    }
    
    public init(x: Float, y: Float) {
        self.valueRepresentation = .vec2
        self.valueType = .float2
        self.operation = nil
        self._x = Scalar(x)
        self._y = Scalar(y)
    }
    
    public init(x: Scalar, y: Scalar) {
        self.valueRepresentation = .vec2
        self.valueType = .float2
        self.operation = nil
        self._x = x
        self._y = y
    }
    
    public func lerp(to dst: Vec2, factor: Scalar) -> Vec2 {
        return Vec2(Operation(lhs: self, operator: .lerp(factor: factor), rhs: dst))
    }
    
    public static func +(lhs: Vec2, rhs: Scalar) -> Vec2 {
        return Vec2(Operation(lhs: lhs, operator: .add, rhs: rhs))
    }
    public static func -(lhs: Vec2, rhs: Scalar) -> Vec2 {
        return Vec2(Operation(lhs: lhs, operator: .subtract, rhs: rhs))
    }
    public static func *(lhs: Vec2, rhs: Scalar) -> Vec2 {
        return Vec2(Operation(lhs: lhs, operator: .multiply, rhs: rhs))
    }
    public static func /(lhs: Vec2, rhs: Scalar) -> Vec2 {
        return Vec2(Operation(lhs: lhs, operator: .divide, rhs: rhs))
    }
    
    public static func +(lhs: Vec2, rhs: Vec2) -> Vec2 {
        return Vec2(Operation(lhs: lhs, operator: .add, rhs: rhs))
    }
    public static func -(lhs: Vec2, rhs: Vec2) -> Vec2 {
        return Vec2(Operation(lhs: lhs, operator: .subtract, rhs: rhs))
    }
    public static func *(lhs: Vec2, rhs: Vec2) -> Vec2 {
        return Vec2(Operation(lhs: lhs, operator: .multiply, rhs: rhs))
    }
    public static func /(lhs: Vec2, rhs: Vec2) -> Vec2 {
        return Vec2(Operation(lhs: lhs, operator: .divide, rhs: rhs))
    }
    
    public static func +=(lhs: inout Vec2, rhs: Vec2) {
        lhs = Vec2(Operation(lhs: lhs, operator: .add, rhs: rhs))
    }
    public static func -=(lhs: inout Vec2, rhs: Vec2) {
        lhs = Vec2(Operation(lhs: lhs, operator: .subtract, rhs: rhs))
    }
    public static func *=(lhs: inout Vec2, rhs: Vec2) {
        lhs = Vec2(Operation(lhs: lhs, operator: .multiply, rhs: rhs))
    }
    public static func /=(lhs: inout Vec2, rhs: Vec2) {
        lhs = Vec2(Operation(lhs: lhs, operator: .divide, rhs: rhs))
    }
}
