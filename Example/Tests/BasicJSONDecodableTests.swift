//
//  BasicJSONDecodableTests.swift
//  JSONDecoder
//
//  Created by Alex Hoppen on 25/11/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import XCTest
import JSONDecoder

class BasicJSONDecodableTests: XCTestCase {
	func testDecodeString() {
		struct JSONStruct: JSONDecodable {
			let string: String
			
			init(_ decoder: JSONDecoder) throws {
				string = try decoder["string"].decode()
			}
		}
		
		let json = "{\"string\":\"the value\"}"
		
		let parsed = try! JSONDecoder(json).decode() as JSONStruct?
		
		XCTAssertEqual("the value", parsed?.string)
		
		let malformattedJSON = "{\"string\":7}"
		
		do {
			try JSONDecoder(malformattedJSON).decode() as JSONStruct
		} catch ParsingError.StringConversionFailed(atPath: let path) {
			XCTAssertEqual(path, "string")
		} catch {
			XCTFail("Wrong error")
		}
	}
	
	func testDecodeInt() {
		struct JSONStruct: JSONDecodable {
			let int: Int
			
			init(_ decoder: JSONDecoder) throws {
				int = try decoder["number"].decode()
			}
		}
		
		let json = "{\"number\":6}"
		
		let parsed = try! JSONDecoder(json).decode() as JSONStruct?
		
		XCTAssertEqual(6, parsed?.int)
		
		let malformattedJSON = "{\"number\":\"7\"}"
		
		do {
			try JSONDecoder(malformattedJSON).decode() as JSONStruct
		} catch ParsingError.IntegerConversionFailed(atPath: let path) {
			XCTAssertEqual(path, "number")
		} catch {
			XCTFail("Wrong error")
		}
	}
	
	func testDecodeUInt() {
		struct JSONStruct: JSONDecodable {
			let uint: UInt
			
			init(_ decoder: JSONDecoder) throws {
				uint = try decoder["number"].decode()
			}
		}
		
		let json = "{\"number\":6}"
		
		let parsed = try! JSONDecoder(json).decode() as JSONStruct?
		
		XCTAssertEqual(6, parsed?.uint)
		
		let malformattedJSON = "{\"number\":\"7\"}"
		
		do {
			try JSONDecoder(malformattedJSON).decode() as JSONStruct
		} catch ParsingError.UnsingendConversionFailed(atPath: let path) {
			XCTAssertEqual(path, "number")
		} catch {
			XCTFail("Wrong error")
		}
	}
	
	func testDecodeFloat() {
		struct JSONStruct: JSONDecodable {
			let float: Float
			
			init(_ decoder: JSONDecoder) throws {
				float = try decoder["number"].decode()
			}
		}
		
		let json = "{\"number\":6}"
		
		let parsed = try! JSONDecoder(json).decode() as JSONStruct?
		
		XCTAssertEqual(6, parsed?.float)
		
		let malformattedJSON = "{\"number\":\"7\"}"
		
		do {
			try JSONDecoder(malformattedJSON).decode() as JSONStruct
		} catch ParsingError.FloatConversionFailed(atPath: let path) {
			XCTAssertEqual(path, "number")
		} catch {
			XCTFail("Wrong error")
		}
	}
	
	func testDecodeDouble() {
		struct JSONStruct: JSONDecodable {
			let double: Double
			
			init(_ decoder: JSONDecoder) throws {
				double = try decoder["number"].decode()
			}
		}
		
		let json = "{\"number\":6}"
		
		let parsed = try! JSONDecoder(json).decode() as JSONStruct?
		
		XCTAssertEqual(6, parsed?.double)
		
		let malformattedJSON = "{\"number\":\"7\"}"
		
		do {
			try JSONDecoder(malformattedJSON).decode() as JSONStruct
		} catch ParsingError.DoubleConversionFailed(atPath: let path) {
			XCTAssertEqual(path, "number")
		} catch {
			XCTFail("Wrong error")
		}
	}
	
	func testDecodeBool() {
		struct JSONStruct: JSONDecodable {
			let bool: Bool
			
			init(_ decoder: JSONDecoder) throws {
				bool = try decoder["bool"].decode()
			}
		}
		
		var json = "{\"bool\":\"true\"}"
		XCTAssertEqual((try! JSONDecoder(json).decode() as JSONStruct?)?.bool, true)
		
		json = "{\"bool\":\"false\"}"
		XCTAssertEqual((try! JSONDecoder(json).decode() as JSONStruct?)?.bool, false)
		
		json = "{\"bool\":\"1\"}"
		XCTAssertEqual((try! JSONDecoder(json).decode() as JSONStruct?)?.bool, true)
		
		json = "{\"bool\":\"0\"}"
		XCTAssertEqual((try! JSONDecoder(json).decode() as JSONStruct?)?.bool, false)
		
		json = "{\"bool\":1}"
		XCTAssertEqual((try! JSONDecoder(json).decode() as JSONStruct?)?.bool, true)
		
		json = "{\"bool\":0}"
		XCTAssertEqual((try! JSONDecoder(json).decode() as JSONStruct?)?.bool, false)
		
		json = "{\"bool\":0.5}"
		XCTAssertEqual((try! JSONDecoder(json).decode() as JSONStruct?)?.bool, false)
		
		json = "{\"bool\":12.5}"
		XCTAssertEqual((try! JSONDecoder(json).decode() as JSONStruct?)?.bool, true)
	}
	
	func testDecodeIntBackedEnum() {
		enum Enum: Int {
			case One = 1
			case Two = 2
			case Three = 3
		}
		
		struct JSONStruct: JSONDecodable {
			let value: Enum
			
			init(_ decoder: JSONDecoder) throws {
				value = try decoder["value"].decode()
			}
		}
		
		var json = "{\"value\":3}"
		let parsed = try! JSONDecoder(json).decode() as JSONStruct?
		
		XCTAssertEqual(Enum.Three, parsed?.value)
		
		json = "{\"value\":8}"
		
		do {
			try JSONDecoder(json).decode() as JSONStruct
		} catch ParsingError.EnumConversionFailed(atPath: let path) {
			XCTAssertEqual(path, "value")
		} catch {
			XCTFail("Wrong error")
		}
	}
	
	func testDecodeNestedJSONDecodableInArray() {
		struct User: JSONDecodable {
			let forename: String
			let surname: String
			
			init(_ decoder: JSONDecoder) throws {
				forename = try decoder["forename"].decode()
				surname = try decoder["surname"].decode()
			}
		}
		
		struct UsersResponse: JSONDecodable {
			let users: [User]
			
			init(_ decoder: JSONDecoder) throws {
				users = try decoder["users"].decode()
			}
		}
		
		let json = "{\"users\": [{\"forename\": \"Alex\", \"surname\": \"Hoppen\"}, {\"forename\": \"Max\", \"surname\": \"Mustermann\"}]}"
		
		let parsed = try! JSONDecoder(json).decode() as UsersResponse!
		
		XCTAssertEqual(2, parsed.users.count)
		XCTAssertEqual("Alex", parsed.users[0].forename)
		XCTAssertEqual("Hoppen", parsed.users[0].surname)
		XCTAssertEqual("Max", parsed.users[1].forename)
		XCTAssertEqual("Mustermann", parsed.users[1].surname)
	}
	
	func testArrayOfAtomicValuesCanBeDecodedInsideACustomSwiftStruct() {
		struct User: JSONDecodable {
			let forename: String
			let surname: String
			let favouriteNumbers: [Double]
			
			init(_ decoder: JSONDecoder) throws {
				forename = try decoder["forename"].decode()
				surname = try decoder["surname"].decode()
				favouriteNumbers = try decoder["favouriteNumbers"].decode()
			}
		}
		
		struct UsersResponse: JSONDecodable {
			let users: [User]
			
			init(_ decoder: JSONDecoder) throws {
				users = try decoder["users"].decode()
			}
		}
		
		let json = "{\"users\": [{\"forename\": \"Alex\", \"surname\": \"Hoppen\", \"favouriteNumbers\": [3.1416, 42]}]}"
		
		let parsed = try! JSONDecoder(json).decode() as UsersResponse
		
		XCTAssertEqual(1, parsed.users.count)
		XCTAssertEqual("Alex", parsed.users[0].forename)
		XCTAssertEqual("Hoppen", parsed.users[0].surname)
		XCTAssertEqual([3.1416, 42], parsed.users[0].favouriteNumbers)
	}
}