lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'date'
require 'active_cabinet/version'

Gem::Specification.new do |s|
  s.name        = 'active_cabinet'
  s.version     = ActiveCabinet::VERSION
  s.date        = Date.today.to_s
  s.summary     = "Database-like interface for HashCabinet"
  s.description = "Database-like interface for HashCabinet"
  s.authors     = ["Danny Ben Shitrit"]
  s.email       = 'db@dannyben.com'
  s.files       = Dir['README.md', 'lib/**/*.*']
  s.homepage    = 'https://github.com/dannyben/active_cabinet'
  s.license     = 'MIT'
  s.required_ruby_version = ">= 2.4.0"

  s.add_runtime_dependency 'hash_cabinet', '~> 0.1'
end
