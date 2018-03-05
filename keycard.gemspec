
# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "keycard/version"

Gem::Specification.new do |spec|
  spec.name          = "keycard"
  spec.version       = Keycard::VERSION
  spec.authors       = ["Noah Botimer", "Aaron Elkiss"]
  spec.email         = ["botimer@umich.edu", "aelkiss@umich.edu"]

  spec.summary = <<~SUMMARY
    Keycard provides authentication support and user/request information,
    especially in Rails applications.
  SUMMARY
  spec.homepage = "https://github.com/mlibrary/keycard"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "mysql2"
  spec.add_dependency "sequel"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "coveralls", "~> 0.8"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 0.52"
  spec.add_development_dependency "rubocop-rails", "~> 1.1"
  spec.add_development_dependency "rubocop-rspec", "~> 1.16"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "yard", "~> 0.9"
end
