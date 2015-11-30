# JSONDecoder

## Usage

JSONDecoder is a small swift framework that allows an easy conversion of JSON to Swift structs or objects. Its reduces the amout of code you have to write to a minimum while maintaining all of Swift's safety features.

## Example
	struct User: JSONDecodable {
		let id: UInt
		let forename: String
		let surname: String?
		let favouriteQuotes: [String]
		
		init(_ json: JSONDecoder) throws {
			// Take the value for the key "forename" in the json data and decode it as a String (inferred by the declaration of forename)
			forename = try json["forename"].decode()
			
			// surname is declared as an optional. No try required, since it can will set to nil upon error or if no surname is provided in the JSON data
			surname = json["surname"].decode()
			
			// Decode the value of "user_id" in the JSON data as a UInt and assign it to the field named id. Types are treated strictly, i.e. if "user_id" maps to a string in the JSON data this will throw
			id = try decoder["user_id"].decode()
			
			// More complex types are also supported
			favouriteQuotes = json["favouriteQuotes"].decode()
		}
	}
	
	let json: NSData = ...
	let users = JSONDecoder(json).decode() as [User]
## How does it work?
### The `JSONDecodable` protocol
All types that can be represented in JSON conform to `JSONDecodable`

	public protocol JSONDecodable {
		init(_ json: JSONDecoder) throws
	}
	
In particular this is already handled for `String`, `Int`, `UInt`, `Float`, `Double`, `Bool`, `[JSONDecodable]`, `[String:JSONDecodable]` and all `enum`s that are backed by a `JSONDecodable` type.

The only requirement for implementing `JSONDecodable` is to provide an initializer that takes a `JSONDecoder` and either completely initializes the object or fails.
All native types fail if there is a type mismatch between the JSON value and the expected one(e.g. `String`s are __not__ automatically converted to `Int`)

### `JSONDecoder`

`JSONDecoder` is a wrapper around any part of the JSON data. It basically provides three methods:

- An `Int` subscript to pick the _n_-th element in a JSON array
- A `String` subscript to pick a value in JSON dictionary
- The method `decode()` is overloaded based on its return type and decodes its information into a natives swift object that conforms to `JSONDecodable`. It always provides two variants. One that returns an optional if an error occurred when decoding or if the key did not exist and another one returning an 

### Create custom `JSONDecodable` structs

You will mostly want to create custom structs that represent part of your JSON data. To do so just define your struct that conforms to `JSONDecodable` with all its properties and assign them like in the example above. Not that all assignments to non-optional properties may fail and thus have to be marked with `try`. All assignments to 

### Add custom atomic data types
You may want to support custom atomic data types like `NSDate` or `UIColor` so that they can be used alongisde `String`, `Int`, etc. in your structs. Due to limitations and errors in Swift's type system conformance to `JSONDecodable` for final classes or structs. So to be able to decode `NSDate`s natively, you have to subclass `NSDate`: 

	enum MyJSONDecoderError: ErrorType {
		case DateConversionFailed(atPath: String?)
	}

	final class Date: NSDate, JSONDecodable {
		required convenience init(_ json: JSONDecoder) throws {
			if let timestamp = json.decode() as Double? {
				self.init(timeIntervalSince1970: timestamp)
			} else {
				throw MyJSONDecoderError.DateConversionFailed(atPath: json.pathIdentifier)
			}
		}
	}

Now you may either use `Date` as in your structs or decode the JSON value as `Date` and assign it to an `NSDate` property:

	let json: JSONDecoder = ...
	let date: NSDate = try json["date"].decode() as Date


## (Beauty) issues due to Swift
- `[String:JSONDecodable]` and `[JSONDecodable]` should conform to `JSONDecodable` but it is not yet possible to add protocol conformance to existing structs using extension with type constraints. [rdar://23255436](http://www.openradar.me/23255436)
- The subclasses created as defined in "Add custom atomic data types" should not have to be final. [rdar://23671426](http://www.openradar.me/23671426)


## Author

Alex Hoppen, alex@ateamer.de

## License

JSONDecoder is available under the MIT license. See the LICENSE file for more info.
