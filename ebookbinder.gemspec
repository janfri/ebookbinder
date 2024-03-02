# -*- encoding: utf-8 -*-
# stub: ebookbinder 0.1.0 ruby lib
#
# This file is automatically generated by rim.
# PLEASE DO NOT EDIT IT DIRECTLY!
# Change the values in Rim.setup in Rakefile instead.

Gem::Specification.new do |s|
  s.name = "ebookbinder"
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Jan Friedrich"]
  s.date = "2024-02-27"
  s.description = ""
  s.email = "janfri26@gmail.com"
  s.files = ["LICENSE", "Rakefile", "Rakefilee", "ebookbinder.gemspec", "lib/ebookbinder", "lib/ebookbinder.rb", "lib/ebookbinder.rbe", "lib/ebookbinder/ebook_base.rb", "lib/ebookbinder/ebook_base.rbe", "lib/ebookbinder/epub2.rb", "lib/ebookbinder/epub2.rbe", "lib/ebookbinder/epub3.rb", "lib/ebookbinder/epub3.rbe", "lib/ebookbinder/epub_base.rb", "lib/ebookbinder/epub_base.rbe", "test/Rakefile", "test/build", "test/build/Jan Friedrich - My book.epub", "test/build/epub2", "test/build/epub2/01.xhtml", "test/build/epub2/02.xhtml", "test/build/epub2/META-INF", "test/build/epub2/META-INF/container.xml", "test/build/epub2/content.opf", "test/build/epub2/mimetype", "test/build/epub2/toc.ncx", "test/src", "test/src/01.xhtml", "test/src/02.xhtml"]
  s.rubygems_version = "3.6.0.dev"
  s.summary = ""

  s.specification_version = 4

  s.add_development_dependency(%q<rake>, [">= 0"])
  s.add_development_dependency(%q<rim>, ["~> 2.17"])
end