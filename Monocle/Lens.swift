//
//  Lens.swift
//  Monocle
//
//  Created by Robert Böhnke on 1/17/15.
//  Copyright (c) 2015 Robert Böhnke. All rights reserved.
//

import Swift

public struct Lens<A, B> {
    public typealias Get = A throws -> B
    public typealias Set = (inout A, B) throws -> Void

    private let getter: Get
    private let setter: Set

    public init(get getter: Get, set setter: Set) {
        self.getter = getter
        self.setter = setter
    }

    public init(get getter: Get, set setter: (A, B) throws -> A) {
        self.getter = getter
        self.setter = { (inout a: A, b) throws in
            a = try setter(a, b)
        }
    }
}

extension Lens: LensType {

    public typealias Whole = A
    public typealias Part = B

    public func get(from whole: Whole) throws -> Part {
        return try getter(whole)
    }

    public func set(part: Part, inout within whole: Whole) throws {
        try setter(&whole, part)
    }

}

// MARK: - Compose

infix operator >>> {
    associativity right
    precedence 170
}

public func >>> <A, B, C>(lhs: Lens<A, B>, rhs: Lens<B, C>) -> Lens<A, C> {
    return lhs.compose(with: rhs)
}

infix operator <<< {
    associativity right
    precedence 170
}

public func <<< <A, B, C>(lhs: Lens<B, C>, rhs: Lens<A, B>) -> Lens<A, C> {
    return rhs.compose(with: lhs)
}

extension LensType {

    public func compose<Other: LensType where Other.Whole == Part>(with other: Other) -> Lens<Whole, Other.Part> {
        return .init(get: { outer in
            try other.get(from: self.get(from: outer))
        }, set: { (inout outer: Whole, part) in
            var inner = try self.get(from: outer)
            try other.set(part, within: &inner)
            try self.set(inner, within: &outer)
        })
    }

}

// MARK: - Lift

extension LensType {

    public func lift() -> Lens<[Whole], [Part]> {
        return .init(get: { whole in
            try whole.map(self.get)
        }, set: { (wholes, parts) in
            try zip(parts, wholes).map(self.set)
        })
    }
    
}

// MARK: - Split

infix operator *** {
    associativity left
    precedence 150
}

public func *** <A, B, C, D>(lhs: Lens<A, B>, rhs: Lens<C, D>) -> Lens<(A, C), (B, D)> {
    return lhs.split(from: rhs)
}

extension LensType {

    public func split<Other: LensType>(from other: Other) -> Lens<(Whole, Other.Whole), (Part, Other.Part)> {
        return .init(get: { (first, second) in
            try (self.get(from: first), other.get(from: second))
        }, set: { (inout wholes: (Whole, Other.Whole), parts) in
            try self.set(parts.0, within: &wholes.0)
            try other.set(parts.1, within: &wholes.1)
        })
    }

}

// MARK: - Fanout

infix operator &&& {
    associativity left
    precedence 120
}

public func &&& <A, B, C>(lhs: Lens<A, B>, rhs: Lens<A, C>) -> Lens<A, (B, C)> {
    return lhs.fanout(from: rhs)
}

extension LensType {

    public func fanout<Other: LensType where Other.Whole == Whole>(from other: Other) -> Lens<Whole, (Part, Other.Part)> {
        return .init(get: { whole in
            try (self.get(from: whole), other.get(from: whole))
        }, set: { (inout whole: Whole, parts) in
            try self.set(parts.0, within: &whole)
            try other.set(parts.1, within: &whole)
        })
    }

}

// MARK: - Unavailable

@available(*, unavailable, message="call the 'get(from:)' method on the lens")
public func get<A, B>(lens: Lens<A, B>, _ a: A) throws -> B {
    fatalError("unavailable function can't be called")
}

@available(*, unavailable, message="use the 'get(from:)' method on the lens' type")
public func get<A, B>(lens: Lens<A, B>)(_ a: A) throws -> B {
    fatalError("unavailable function can't be called")
}

@available(*, unavailable, message="call the 'get(from:)' method on the lens")
public func get<A, B>(lens: Lens<A, B>, _ a: A?) throws -> B? {
    fatalError("unavailable function can't be called")
}

@available(*, unavailable, message="use the 'get(from:)' method on the lens' type")
public func get<A, B>(lens: Lens<A, B>)(_ a: A?) throws -> B? {
    fatalError("unavailable function can't be called")
}

@available(*, unavailable, message="call the 'set(within:value:)' method on the lens")
public func set<A, B>(lens: Lens<A, B>, _ a: A, _ b: B) throws -> A {
    fatalError("unavailable function can't be called")
}

@available(*, unavailable, message="use the 'set(within:value:)' method on the lens' type")
public func set<A, B>(lens: Lens<A, B>, _ a: A)(_ b: B) throws -> A {
    fatalError("unavailable function can't be called")
}

@available(*, unavailable, message="call the 'modify(_:transform:)' method on the lens")
public func mod<A, B>(lens: Lens<A, B>, _ a: A, _ f: B -> B) throws -> A {
    fatalError("unavailable function can't be called")
}

@available(*, unavailable, message="call the 'compose(with:)' method on the lens")
public func compose<A, B, C>(left: Lens<A, B>, _ right: Lens<B, C>) -> Lens<A, C> {
    fatalError("unavailable function can't be called")
}

@available(*, unavailable, message="call the 'lift()' method on the lens")
public func lift<A, B>(lens: Lens<A, B>) -> Lens<[A], [B]> {
    fatalError("unavailable function can't be called")
}

@available(*, unavailable, message="call the 'split(from:)' method on the lens")
public func split<A, B, C, D>(left: Lens<A, B>, _ right: Lens<C, D>) -> Lens<(A, C), (B, D)> {
    fatalError("unavailable function can't be called")
}

@available(*, unavailable, message="call the 'fanout(from:)' method on the lens")
public func fanout<A, B, C>(left: Lens<A, B>, _ right: Lens<A, C>) -> Lens<A, (B, C)> {
    fatalError("unavailable function can't be called")
}
