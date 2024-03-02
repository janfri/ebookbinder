# encoding: utf-8

require 'rim/tire'
require 'rim/version'
require_relative 'lib/ebookbinder/version'

Rim.setup do |r|
  r.name = 'ebookbinder'
  r.authors = 'Jan Friedrich'
  r.email = 'janfri26@gmail.com'
  r.version = Ebookbinder::VERSION
  r.gem_files.exclude(/build/).exclude {|e| File.directory?(e)}
  r.test_files = FileList.new()
end
