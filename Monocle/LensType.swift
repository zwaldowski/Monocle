//
//  LensType.swift
//  Monocle
//
//  Created by Zachary Waldowski on 3/20/16.
//  Copyright © 2016 Robert Böhnke. All rights reserved.
//

public protocol LensType {
    typealias Whole
    typealias Part

    func get(from whole: Whole) throws -> Part
    func set(part: Part, inout within whole: Whole) throws
}

// MARK: - Basics

extension LensType {

    public func get(from whole: Whole?) throws -> Part? {
        return try whole.map(get)
    }

    public func set(part: Part, within whole: Whole) throws -> Whole {
        var whole = whole
        try set(part, within: &whole)
        return whole
    }

    public func modify(whole: Whole, transform: Part throws -> Part) throws -> Whole {
        return try set(transform(get(from: whole)), within: whole)
    }
    
}
