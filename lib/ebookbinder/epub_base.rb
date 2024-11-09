# encoding: utf-8
require_relative 'ebook_base'

require 'date'
require 'digest/md5'
require 'nokogiri'

module Ebookbinder

  class EpubBase < EbookBase

    attr_accessor :epub_filename
    attr_reader :epub_dir, :meta_inf_dir, :mimetype_filename, :nav_filename

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

    private

    def create_header_struct fn
      res = []
      last_h1 = last_h2 = last_h3 = last_h4 = last_h5 = last_h6 = nil
      Nokogiri.XML(File.read(fn)).search('h1,h2,h3,h4,h5,h6').each do |e|
        if id = e.attribute('id')
          case e.name
          when 'h1'
            last_h1 = [e, []]
            res << last_h1
          when 'h2'
            last_h2 = [e, []]
            last_h1.last << last_h2
          when 'h3'
            last_h3 = [e, []]
            last_h2.last << last_h3
          when 'h4'
            last_h4 = [e, []]
            last_h3.last << last_h4
          when 'h5'
            last_h5 = [e, []]
            last_h4.last << last_h5
          when 'h6'
            last_h6 = [e, []]
            last_h5.last << last_h6
          end
        end
      end
      res
    end

  end

end

