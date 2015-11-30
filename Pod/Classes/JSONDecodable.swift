//
//  JSONDecodable.swift
//  Pods
//
//  Created by Alex Hoppen on 12/11/15.
//
//

public protocol JSONDecodable {
	init(_ json: JSONDecoder) throws
}

extension JSONDecodable {
	public static func decode(json: JSONDecoder) throws -> Self {
		return try self.init(json)
	}
	
	public static func decode(json: JSONDecoder) -> Self? {
		do {
			return try decode(json) as Self
		} catch {
			return nil
		}
	}
}