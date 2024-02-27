# encoding: utf-8
require_relative 'ebook_base'

require 'date'
require 'digest/md5'
require 'nokogiri'

module Ebookbinder

  class EpubBase < EbookBase

    protected

    def check_mandatory_values
      %w(title author).each do |attr|
        unless self.send(attr)
          raise format('No value for %s given!', attr)
        end
      end
    end

    def mimetype_filename
      File.join(@epub_dir, 'mimetype')
    end

    def generate_mimetype_file
      puts "generate #{mimetype_filename}" if verbose
      File.write(mimetype_filename, 'application/epub+zip')
    end

    def container_filename
      File.join(@meta_inf_dir, 'container.xml')
    end

    def generate_container_file
      puts "generate #{container_filename}" if verbose
      builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.container(version: '1.0', xmlns: 'urn:oasis:names:tc:opendocument:xmlns:container') do
          xml.rootfiles do
            xml.rootfile('full-path': content_filename.sub(%r(^#{epub_dir}/?), ''), 'media-type': 'application/oebps-package+xml')
          end
        end
      end
      File.write(container_filename, builder.to_xml)
    end

    def content_filename
      File.join(@epub_dir, 'content.opf')
    end

    def content_filenames
      source_filenames.sub(/^#{src_dir}/, epub_dir)
    end

    def source_filenames
      FileList.new(File.join(src_dir, '**/*')).select {|fn| !File.directory?(fn)}.sort
    end

    def href filename, id=nil
      res = filename.sub(%r(^#{epub_dir}/?), '')
      res << '#' << id.to_s if id
      res
    end

  end

end

