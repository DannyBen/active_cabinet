lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_cabinet/version'

Gem::Specification.new do |s|
  s.name        = 'active_cabinet'
  s.version     = ActiveCabinet::VERSION
  s.summary     = 'Database-like interface for HashCabinet'
  s.description = 'ActiveRecord-inspired interface for HashCabinet, the file-basd key-object store.'
  s.authors     = ['Danny Ben Shitrit']
  s.email       = 'db@dannyben.com'
  s.files       = Dir['README.md', 'lib/**/*.*']
  s.homepage    = 'https://github.com/dannyben/active_cabinet'
  s.license     = 'MIT'
  s.required_ruby_version = '>= 3.0'

  s.add_dependency 'hash_cabinet', '~> 0.1', '>= 0.1.3'

  s.metadata = {
    'bug_tracker_uri'       => 'https://github.com/DannyBen/active_cabinet/issues',
    'documentation_uri'     => 'https://rubydoc.info/gems/active_cabinet',
    'source_code_uri'       => 'https://github.com/dannyben/active_cabinet',
    'rubygems_mfa_required' => 'true',
  }
end
