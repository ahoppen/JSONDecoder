//
//  JSONDecoderTests.swift
//  JSONDecoderTests
//
//  Created by Alex Hoppen on 12/11/15.
//
//

import XCTest
import JSONDecoder

class JSONDecoderTests: XCTestCase {
	
	func testDecodeDoesNotFailIfValueIsOptional() {
		struct JSONStruct: JSONDecodable {
			let string: String?
			
			init(_ decoder: JSONDecoder) throws {
				string = decoder["string"].decode()
			}
		}
		
		let json = "{\"string\":7}"
		let parsed = try! JSONDecoder(json).decode() as JSONStruct?
		XCTAssertNotNil(parsed)
		XCTAssertNil(parsed?.string)
	}
	
	func testErrorPathIdentifierWorksForNonExistentKeys() {
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
		
		let json = "{\"data\":{\"users\": [{\"forename\": \"Alex\", \"surname\": \"Hoppen\"}, {\"surname\": \"Mustermann\"}]}}"
		
		do {
			try JSONDecoder(json).decode() as [String:UsersResponse]!
		} catch ParsingError.StringConversionFailed(atPath: let path) {
			XCTAssertEqual("data.users[1].forename", path)
		} catch {
			XCTFail("Wrong error")
		}
	}
	
	func testErrorPathIdentifierWorksWhenConversionFails() {
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
		
		let json = "{\"data\":{\"users\": [{\"forename\": \"Alex\", \"surname\": \"Hoppen\"}, {\"forename\": null,\"surname\": \"Mustermann\"}]}}"
		
		do {
			try JSONDecoder(json).decode() as [String:UsersResponse]!
		} catch ParsingError.StringConversionFailed(atPath: let path) {
			XCTAssertEqual("data.users[1].forename", path)
		} catch {
			XCTFail("Wrong error")
		}
	}
	
	func testErrorPathIdentifierCanStartWithAnArrayIndex() {
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
		
		let json = "[{\"users\": [{\"forename\": \"Alex\", \"surname\": \"Hoppen\"}, {\"forename\": null,\"surname\": \"Mustermann\"}]}]"
		
		do {
			try JSONDecoder(json).decode() as [UsersResponse]!
		} catch ParsingError.StringConversionFailed(atPath: let path) {
			XCTAssertEqual("[0].users[1].forename", path)
		} catch {
			XCTFail("Wrong error")
		}
	}
	
	func testIndexCanBeUsedToAccessValues() {
		struct User: JSONDecodable {
			let forename: String
			let surname: String
			
			init(_ decoder: JSONDecoder) throws {
				forename = try decoder[0].decode()
				surname = try decoder[1].decode()
			}
		}
		
		struct UsersResponse: JSONDecodable {
			let users: [User]
			
			init(_ decoder: JSONDecoder) throws {
				users = try decoder["users"].decode()
			}
		}
		
		let json = "{\"users\": [[\"Alex\", \"Hoppen\"], [\"Max\",\"Mustermann\"]]}"
		
		let parsed = try! JSONDecoder(json).decode() as UsersResponse!
		
		XCTAssertEqual(2, parsed.users.count)
		XCTAssertEqual("Alex", parsed.users[0].forename)
		XCTAssertEqual("Hoppen", parsed.users[0].surname)
		XCTAssertEqual("Max", parsed.users[1].forename)
		XCTAssertEqual("Mustermann", parsed.users[1].surname)
	}
	
	func testIndexAccessFailsIfIndexIsOutOfBounds() {
		struct User: JSONDecodable {
			let forename: String
			let surname: String
			
			init(_ decoder: JSONDecoder) throws {
				forename = try decoder[0].decode()
				surname = try decoder[1].decode()
			}
		}
		
		struct UsersResponse: JSONDecodable {
			let users: [User]
			
			init(_ decoder: JSONDecoder) throws {
				users = try decoder["users"].decode()
			}
		}
		
		let json = "{\"users\": [[\"Alex\", \"Hoppen\"], [\"Max\"]]}"
		
		do {
			let _ = try JSONDecoder(json).decode() as UsersResponse
		} catch ParsingError.StringConversionFailed(atPath: let path) {
			XCTAssertEqual("users[1][1]", path)
		} catch{
			XCTFail("Wrong error")
		}
	}
}
