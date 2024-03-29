# -*- encoding: utf-8 -*-
# stub: ebookbinder 1.0.1 ruby lib
#
# This file is automatically generated by rim.
# PLEASE DO NOT EDIT IT DIRECTLY!
# Change the values in Rim.setup in Rakefile instead.

Gem::Specification.new do |s|
  s.name = "ebookbinder"
  s.version = "1.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Jan Friedrich"]
  s.date = "2024-03-05"
  s.description = ""
  s.email = "janfri26@gmail.com"
  s.files = ["./.aspell.pws", "Changelog", "Gemfile", "LICENSE", "README.md", "Rakefile", "ebookbinder.gemspec", "examples/epub2/Rakefile", "examples/epub2/src/01.xhtml", "examples/epub2/src/02.xhtml", "examples/epub3/Rakefile", "examples/epub3/src/01.xhtml", "examples/epub3/src/02.xhtml", "lib/ebookbinder", "lib/ebookbinder.rb", "lib/ebookbinder/ebook_base.rb", "lib/ebookbinder/epub2.rb", "lib/ebookbinder/epub3.rb", "lib/ebookbinder/epub_base.rb", "lib/ebookbinder/version.rb", "regtest/epub2.rb", "regtest/epub2.yml", "regtest/epub3.rb", "regtest/epub3.yml"]
  s.homepage = "https://github.com/janfri/ebookbinder"
  s.licenses = ["MIT"]
  s.post_install_message = "\n+-----------------------------------------------------------------------+\n| To run rake check you need epubcheck installed and accessible via     |\n| `epubcheck` on the command line.                                      |\n|                                                                       |\n| https://www.w3.org/publishing/epubcheck/                              |\n+-----------------------------------------------------------------------+\n  "
  s.rubygems_version = "3.6.0.dev"
  s.summary = "This library should help to make ebooks as easy as possible. It interprets an XHTML structure and generate a corresponding ebook on base of easy asumptions."

  s.specification_version = 4

  s.add_development_dependency(%q<rake>, [">= 0"])
  s.add_development_dependency(%q<rim>, ["~> 2.17"])
  s.add_development_dependency(%q<regtest>, ["~> 2"])
end
