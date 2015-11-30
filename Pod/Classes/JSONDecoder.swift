//
//  JSONDecoder.swift
//  Pods
//
//  Created by Alex Hoppen on 12/11/15.
//
//

import Foundation

public enum ParsingError: ErrorType {
	case StringConversionFailed(atPath: String?)
	case IntegerConversionFailed(atPath: String?)
	case UnsingendConversionFailed(atPath: String?)
	case DoubleConversionFailed(atPath: String?)
	case FloatConversionFailed(atPath: String?)
	case NumberConversionFailed(atPath: String?)
	case NSErrorConversionFailed(atPath: String?)
	case DictionaryConversionFailed(atPath: String?)
	case ArrayConversionFailed(atPath: String?)
	case DateConversionFailed(atPath: String?)
	case EnumConversionFailed(atPath: String?)
	case FoundNilWhenDecodingDictionary(atPath: String?)
}

public struct JSONDecoder {
	/// The acutal value wrapped by the JSONEncoder
	let value: Any
	public let pathIdentifier: String?
	public var description: String {
		return self.toJSON()
	}
	
	// MARK: Initilaizers
	
	public init(_ string: String) throws {
		try self.init(string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
	}
	
	public init(_ data: NSData) throws {
		let jsonObject = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())
		self.init(jsonObject)
	}
	
	private init(_ rawObject: AnyObject) {
		self.init(rawObject, pathIdentifier: nil)
	}
	
	private init(_ rawObject: AnyObject, pathIdentifier: String?) {
		self.pathIdentifier = pathIdentifier
		if let array = rawObject as? NSArray {
			var collect = [JSONDecoder]()
			for val: AnyObject in array {
				collect.append(JSONDecoder(val, pathIdentifier: JSONDecoder.pathIdentifierByAppending(existingPath: pathIdentifier, newPath: collect.count)))
			}
			value = collect
		} else if let dict = rawObject as? NSDictionary {
			var collect = [String:JSONDecoder]()
			for (key, val) in dict {
				collect["\(key)"] = JSONDecoder(val, pathIdentifier: JSONDecoder.pathIdentifierByAppending(existingPath: pathIdentifier, newPath: "\(key)"))
			}
			value = collect
		} else {
			value = rawObject
		}
	}
	
	// MARK: Subscripts
	
	public subscript(index: Int) -> JSONDecoder {
		get {
			if let array = self.value as? [JSONDecoder] {
				if index < array.count {
					return array[index]
				}
			}
			return JSONDecoder(NSNull(), pathIdentifier: pathIdentifierByAppending(index))
		}
	}
	
	public subscript(key: String) -> JSONDecoder {
		get {
			if let dict = self.value as? [String:JSONDecoder] {
				if let value = dict[key] {
					return value
				}
			}
			return JSONDecoder(NSNull(), pathIdentifier: pathIdentifierByAppending(key))
		}
	}
	
	// MARK: Decode methods
	
	public func decode<T: JSONDecodable>() -> T? {
		return T.decode(self)
	}
	
	
	public func decode<T: JSONDecodable>() throws -> T {
		return try T.decode(self)
	}
	
	// MARK: Path identifier
	
	func pathIdentifierByAppending(newPath: String) -> String {
		return JSONDecoder.pathIdentifierByAppending(existingPath: self.pathIdentifier, newPath: newPath)
	}
	
	static func pathIdentifierByAppending(existingPath existingPath: String?, newPath: String) -> String {
		if let existingPath = existingPath {
			return existingPath + "." + newPath
		} else {
			return newPath
		}
	}
	
	func pathIdentifierByAppending(newPath: Int) -> String {
		return JSONDecoder.pathIdentifierByAppending(existingPath: self.pathIdentifier, newPath: newPath)
	}
	
	static func pathIdentifierByAppending(existingPath existingPath: String?, newPath: Int) -> String {
		if let existingPath = existingPath {
			return existingPath + "[" + String(newPath) + "]"
		} else {
			return "[" + String(newPath) + "]"
		}
	}
	
	///print the decoder in a JSON format. Helpful for debugging.
	public func toJSON() -> String {
		if let array = value as? [JSONDecoder] {
			var result = "["
			for decoder in array {
				result += decoder.toJSON() + ","
			}
			result.removeAtIndex(result.endIndex.advancedBy(-1))
			return result + "]"
		} else if let dict = value as? [String:JSONDecoder] {
			var result = "{"
			for (key, decoder) in dict {
				result += "\"\(key)\": \(decoder.toJSON()),"
			}
			result.removeAtIndex(result.endIndex.advancedBy(-1))
			return result + "}"
		} else {
			if let value = value as? String {
				return "\"\(value)\""
			} else if let _ = value as? NSNull {
				return "null"
			}
			return "\(value)"
		}
	}
}