# encoding: utf-8

require 'regtest'

EPUB3_DIR = File.join(__dir__,  '../test/epub3/build/epub3')

Dir.chdir(EPUB3_DIR) do
  system('rake -s clobber build')
end

%w(nav.xhtml).each do |fn|

  Regtest.sample fn do
    File.read File.join(EPUB3_DIR, fn)
  end

end
