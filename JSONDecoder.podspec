Pod::Spec.new do |s|
  s.name             = "JSONDecoder"
  s.version          = "0.1.0"
  s.summary          = "Convert JSON to Swift structs or objects with a lightweight syntax"

  s.description      = <<-DESC
						JSONDecoder is a small Swift framework to decode JSON to structs or objects without any custom operators and very few code to write on your side. It enforces Swifts strict type system and fails with a Swift error if any conversion fails.
                       DESC

  s.homepage         = "https://github.com/ahoppen/JSONDecoder"
  s.license          = 'MIT'
  s.author           = { "Alex Hoppen" => "alex@ateamer.de" }
  s.source           = { :git => "https://github.com/ahoppen/JSONDecoder.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
end
