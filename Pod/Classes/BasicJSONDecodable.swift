//
//  BasicJSONDecodable.swift
//  Pods
//
//  Created by Alex Hoppen on 12/11/15.
//
//

import Foundation

extension String: JSONDecodable {
	public init(_ decoder: JSONDecoder) throws {
		if let value = decoder.value as? String {
			self.init(value)
		} else {
			throw ParsingError.StringConversionFailed(atPath: decoder.pathIdentifier)
		}
	}
}

extension Int: JSONDecodable {
	public init(_ decoder: JSONDecoder) throws {
		if let value = decoder.value as? Int {
			self.init(value)
		} else {
			throw ParsingError.IntegerConversionFailed(atPath: decoder.pathIdentifier)
		}
	}
}

extension UInt: JSONDecodable {
	public init(_ decoder: JSONDecoder) throws {
		if let value = decoder.value as? UInt {
			self.init(value)
		} else {
			throw ParsingError.UnsingendConversionFailed(atPath: decoder.pathIdentifier)
		}
	}
}

extension Double: JSONDecodable {
	public init(_ decoder: JSONDecoder) throws {
		if let value = decoder.value as? Double {
			self.init(value)
		} else {
			throw ParsingError.DoubleConversionFailed(atPath: decoder.pathIdentifier)
		}
	}
}

extension Float: JSONDecodable {
	public init(_ decoder: JSONDecoder) throws {
		if let value = decoder.value as? Float {
			self.init(value)
		} else {
			throw ParsingError.FloatConversionFailed(atPath: decoder.pathIdentifier)
		}
	}
}

extension Bool: JSONDecodable {
	public init(_ decoder: JSONDecoder) throws {
		if let str = (decoder.decode() as String?)?.lowercaseString where str == "true" || Int(str) >= 1 {
			self.init(true)
		} else if let num = decoder.decode() as Int? {
			self.init(num > 0)
		} else {
			self.init(false)
		}
	}
}

extension JSONDecoder {
	// Array

	public func decode<T: JSONDecodable>() throws -> [T] {
		if let jsonDecoderArray = value as? [JSONDecoder] {
			return try jsonDecoderArray.map { try $0.decode() as T }
		} else {
			throw ParsingError.ArrayConversionFailed(atPath: self.pathIdentifier)
		}
	}
	
	public func decode<T: JSONDecodable>() -> [T?] {
		if let jsonDecoderArray = value as? [JSONDecoder] {
			return jsonDecoderArray.map { $0.decode() as T? }
		} else {
			return []
		}
	}
	
	// Dictionary
	
	public func decode<T: JSONDecodable>() throws -> [String:T] {
		var results: [String:T] = [:]
		if let decodedDict = value as? [String:JSONDecoder] {
			for key in decodedDict.keys {
				if let decodedValue = decodedDict[key] {
					results[key] = try T.decode(decodedValue) as T
				} else {
					throw ParsingError.FoundNilWhenDecodingDictionary(atPath: pathIdentifierByAppending(key))
				}
			}
		}
		
		return results
	}
	
	public func decode<T: JSONDecodable>() -> [String:T?] {
		var results: [String:T?] = [:]
		if let decodedDict = value as? [String:JSONDecoder] {
			for key in decodedDict.keys {
				if let decodedValue = decodedDict[key] {
					results[key] = T.decode(decodedValue) as T?
				} else {
					results[key] = nil
				}
			}
		}
		
		return results
	}
	
	// Enum (RawRepresentable)
	
	public func decode<T: RawRepresentable where T.RawValue: JSONDecodable>() throws -> T {
		if let decoded = T(rawValue: try decode() as T.RawValue) {
			return decoded
		} else {
			throw ParsingError.EnumConversionFailed(atPath: self.pathIdentifier)
		}
	}
	
	public func decode<T: RawRepresentable where T.RawValue: JSONDecodable>() -> T? {
		if let rawValue = decode() as T.RawValue? {
			return T(rawValue: rawValue)
		} else {
			return nil
		}
	}
}