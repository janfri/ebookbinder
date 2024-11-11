# encoding: utf-8

require 'rim/tire'
require 'rim/regtest'
require 'rim/version'
require_relative 'lib/ebookbinder/version'

Rim.setup do
end

EPUB2_FILE = 'examples/epub2/build/Jan Friedrich - Test Book in EPUB 2.epub'
EPUB3_FILE = EPUB2_FILE.gsub('2', '3')

file EPUB2_FILE do
  cd 'examples/epub2' do
    sh 'rake'
  end
end

file EPUB3_FILE do
  cd 'examples/epub3' do
    sh 'rake'
  end
end

task :regtest => [EPUB2_FILE, EPUB3_FILE]

task :test => :regtest
task :default => :regtest
