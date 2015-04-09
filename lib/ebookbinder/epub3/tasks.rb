# -- encoding: utf-8 --

require 'rake'
require 'rake/clean'

EPUB = Ebookbinder.instance

directory EPUB
directory META_INF = File.join(EPUB, 'META-INF')
directory OEBPS = File.join(EPUB, 'OEBPS')

CLEAN << EPUB
CLOBBER << EPUB_FILE

file MIMETYPE_FILE = File.join(EPUB, 'mimetype') => EPUB do
  File.write(MIMETYPE_FILE, 'application/epub+zip')
end

SOURCE_FILES = FileList.new(File.join(HTML, '**/*'))

CONTENT_FILES = SOURCE_FILES.map {|f| f.sub(/^#{HTML}/, OEBPS)}
CONTENT_FILES.zip(SOURCE_FILES) do |cf, sf|
  file cf => [OEBPS, sf] do
    sh "rsync -a --delete-after #{File.join(HTML, '.').sub(/\.$/, '')} #{OEBPS}"
  end
end

CONTAINER_FILE = File.join(META_INF, 'container.xml')
file CONTAINER_FILE => META_INF do
  File.write(CONTAINER_FILE, gen_container)
end

CONTENT_FILE = File.join(EPUB, 'content.opf')
file CONTENT_FILE do
  File.write(CONTENT_FILE, gen_content)
end

ALL_FILES = [MIMETYPE_FILE, CONTENT_FILES, CONTAINER_FILE, CONTENT_FILE].flatten

file EPUB_FILE => ALL_FILES do
  cd EPUB do
    sh "zip -qXr9D ../#{EPUB_FILE} mimetype *"
  end
end

desc 'Build ePub'
task :build => EPUB_FILE

task :default => :build

##################
# helper methods #
##################

require 'nokogiri'

def gen_container
  builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
    xml.container(version: '1.0', xmlns: 'urn:oasis:names:tc:opendocument:xmlns:container') {
      xml.rootfiles {
        xml.rootfile('full-path': 'content.opf', 'media-type': 'application/oebps-package+xml')
      }
    }
  end
  builder.to_xml
end

def gen_content
  builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
    xml.package(xmlns: "http://www.idpf.org/2007/opf", 'unique-identifier': 'pub-id', version: '3.0', 'xml:lang': LANGUAGE) {
      xml.metadata('xmlns:dc': 'http://purl.org/dc/elements/1.1/', 'xmlns:dcterms': 'http://purl.org/dc/terms/',
                   'xmlns:xsi': 'http://www.w3.org/2001/XMLSchema-instance', 'xmlns:opf': 'http://www.idpf.org/2007/opf') {
        xml['dc'].identifier(ID, id: 'pub-id')
        xml['dc'].title TITLE
        xml['dc'].language LANGUAGE
      }
      xml.manifest {
        FileList.new(File.join(OEBPS, '**/*')).each do |f|
          xml.item(id: "id-#{f}", href: f)
        end
      }
    }
  end
  builder.to_xml
end

