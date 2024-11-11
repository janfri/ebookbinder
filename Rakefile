# encoding: utf-8

require 'rim/tire'
require 'rim/regtest'
require 'rim/version'
require_relative 'lib/ebookbinder/version'

Rim.setup do |r|
  r.name = 'ebookbinder'
  r.authors = 'Jan Friedrich'
  r.email = 'janfri26@gmail.com'
  r.homepage = 'https://github.com/janfri/ebookbinder'
  r.license = 'MIT'
  r.summary = 'This library should help to make ebooks as easy as possible. It interprets an XHTML structure and generate a corresponding ebook on base of easy asumptions.'
  r.version = Ebookbinder::VERSION
  r.install_message = %q{
+-----------------------------------------------------------------------+
| To run rake check you need epubcheck installed and accessible via     |
| `epubcheck` on the command line.                                      |
|                                                                       |
| https://www.w3.org/publishing/epubcheck/                              |
+-----------------------------------------------------------------------+
  }
  r.gem_files += FileList.new('examples/*/Rakefile', 'examples/*/src/**/*.*')
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
