lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'meeseeks/version'

Gem::Specification.new do |spec|
  spec.name          = 'meeseeks'
  spec.version       = Meeseeks::VERSION
  spec.authors       = ['Jannis Hermanns']
  spec.email         = ['jannis.hermanns@joincoup.com']

  spec.summary       = 'Submits measurements to a circonus http trap'
  spec.description   = 'Submits measurements to a circonus http trap'
  spec.homepage      = 'https://github.com/coup-mobility/meeseeks'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'guard-bundler', '~> 2.1'
  spec.add_development_dependency 'guard-rspec', '~> 4.7'
  spec.add_development_dependency 'guard-rubocop', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov', '~> 0.15'
  spec.add_development_dependency 'simplecov-console', '~> 0.4'
end
