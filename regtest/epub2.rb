# encoding: utf-8

require 'regtest'

EPUB2_DIR = File.join(__dir__,  '../test/epub2/build/epub2')

Dir.chdir(EPUB2_DIR) do
  system('rake -s clobber build')
end

%w(toc.ncx).each do |fn|

  Regtest.sample fn do
    File.read File.join(EPUB2_DIR, fn)
  end

end
