# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "keycard/version"

Gem::Specification.new do |spec|
  spec.name    = "keycard"
  spec.version = Keycard::VERSION
  spec.authors = ["Noah Botimer", "Aaron Elkiss"]
  spec.email   = ["botimer@umich.edu", "aelkiss@umich.edu"]
  spec.license = "BSD-3-Clause"

  spec.summary = <<~SUMMARY
    Keycard provides authentication support and user/request information,
    especially in Rails applications.
  SUMMARY
  spec.homepage = "https://github.com/mlibrary/keycard"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "sequel"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-rspec"
  spec.add_development_dependency "sqlite3", "~> 1.3.13"
  spec.add_development_dependency "yard"
end
