require 'simplecov'
SimpleCov.start

require 'rubygems'
require 'bundler'
Bundler.require :default, :development

require_relative 'spec_mixin'
requires 'mocks'
include Mocks

RSpec.configure do |c|
  c.include SpecMixin
  c.before(:all) do 
    system "mkdir -p spec/tmp && rm -f spec/tmp/*"
    ActiveCabinet::Config.dir = "spec/tmp"
  end
end
