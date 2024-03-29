# frozen_string_literal: true

require_relative "lib/simplepush/version"

Gem::Specification.new do |spec|
  spec.name          = "simplepush"
  spec.version       = Simplepush::VERSION
  spec.authors       = ["Christopher Oezbek"]
  spec.email         = ["c.oezbek@gmail.com"]

  spec.summary       = "Ruby SimplePush.io API client (unofficial)"
  spec.description   = "Httparty wrapper for SimplePush.io"
  spec.homepage      = "https://github.com/coezbek/simplepush"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/coezbek/simplepush/README.md#Changelog"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "httparty"

end
