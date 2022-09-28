# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ichnite/version'

Gem::Specification.new do |spec|
  spec.name          = "ichnite"
  spec.version       = Ichnite::VERSION
  spec.authors       = ["Yves Senn"]
  spec.email         = ["yves.senn@gmail.com"]

  spec.summary       = %q{A structured logging library.}
  spec.description   = %q{Bring structured logging to your Ruby applications.}
  spec.homepage      = "https://github.com/senny/ichnite"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.3"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.16"
end
