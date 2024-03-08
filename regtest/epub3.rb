# encoding: utf-8

require 'regtest'

EPUB3_DIR = File.join(__dir__,  '../examples/epub3/build/epub3')

Dir.chdir(EPUB3_DIR) do
  system('rake -s clobber build')
end

%w(content.opf nav.xhtml).each do |fn|

  Regtest.sample fn do
    File.read(File.join(EPUB3_DIR, fn)).gsub(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/, 'YYYY-mm-ddTHH:MM:SS')
  end

end
