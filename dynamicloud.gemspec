# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dynamicloud/version'

Gem::Specification.new do |spec|
  spec.name = 'dynamicloud'
  spec.version = Dynamicloud::VERSION
  spec.authors = ['dynamicloud']
  spec.email = ['social@dynamicloud.com']
  spec.date = '2015-10-04'

  spec.summary = %q{This a beta gem that has all what you need to communicate with Dynamicloud servers and execute operations.}
  spec.description = %q{
    What you can do using this gem is:
    1. Get records of a model in Dynamicloud servers
    2. CRUD operations on records of a model in Dynamicloud servers
    3. Execute queries to get specifics records in Dynamicloud servers
    4. Get model info in Dynamicloud servers
    5. Get model fields in Dynamicloud servers
    6. Get Field info in Dynamicloud servers.
  }
  spec.homepage = 'https://rubygems.org/gems/dynamicloud'
  spec.license = 'MIT'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubyGems.org.com'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = Dir['lib/**/*.rb', 'lib/*.pem']
  #spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake', '~> 10.0'

  spec.add_runtime_dependency 'httpclient', '2.6.0.1'
  spec.add_runtime_dependency 'json'
end
