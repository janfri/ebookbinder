# encoding: utf-8

require_relative 'lib/ebookbinder/version'

Gem::Specification.new do |s|
  s.name = 'ebookbinder'
  s.version = Ebookbinder::VERSION
  s.authors = 'Jan Friedrich'
  s.email = 'janfri26@gmail.com'
  s.summary = 'This library should help to make ebooks as easy as possible. It interprets an XHTML structure and generate a corresponding ebook on base of easy asumptions.'
  s.homepage = 'https://github.com/janfri/ebookbinder'
  s.licenses = 'MIT'

  s.require_paths = ['lib']
  s.files = %w[Changelog LICENSE README.md] + Dir['lib/**/*'] + Dir['examples/**/*'].reject {|fn| fn =~ %r(/build/)}
  s.post_install_message = <<~END
    +-----------------------------------------------------------------------+
    | To run rake check you need epubcheck installed and accessible via     |
    | `epubcheck` on the command line.                                      |
    |                                                                       |
    | https://www.w3.org/publishing/epubcheck/                              |
    +-----------------------------------------------------------------------+
  END

  s.required_ruby_version = '>= 2.3'

  s.add_dependency('nokogiri', '~> 1.16')

  s.add_development_dependency('rake', '>= 13.0')
  s.add_development_dependency('rim', '~> 3.0')
  s.add_development_dependency('regtest', '~> 2.4')
end
