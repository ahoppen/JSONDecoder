//
//  CustomAtomicDataTypesTests.swift
//  JSONDecoder
//
//  Created by Alex Hoppen on 25/11/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import XCTest
import JSONDecoder

enum MyJSONDecoderError: ErrorType {
	case DateConversionFailed(atPath: String?)
}

class Date: NSDate, JSONDecodable {
	required convenience init(_ json: JSONDecoder) throws {
		if let timestamp = json.decode() as Double? {
			self.init(timeIntervalSince1970: timestamp)
		} else {
			throw MyJSONDecoderError.DateConversionFailed(atPath: json.pathIdentifier)
		}
	}
}

struct MyStruct: JSONDecodable {
	let date: NSDate
	
	init(_ json: JSONDecoder) throws {
		date = try json.decode() as Date
	}
}