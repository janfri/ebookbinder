# -- encoding: utf-8 --
require 'date'
require 'digest/md5'
require 'nokogiri'
require 'rake'
require 'rake/clean'
require 'singleton'

require_relative '../ebookbinder'

module Ebookbinder

  class Epub3

    include Singleton
    include Rake::DSL

    attr_accessor :author, :id, :language, :title
    attr_accessor :build_dir, :epub_filename, :src_dir, :mimetype_filename
    attr_reader :epub_dir, :meta_inf_dir, :nav_filename
    attr_accessor :task_defs

    def self.setup
      instance.setup do |i|
        yield i
      end
    end

    def self.define_tasks &blk
      instance.task_defs ||= []
      instance.task_defs << blk
    end

    def setup
      yield self
      check_mandatory_values
      set_defaults
      define_tasks
      self
    end

    private

    def check_mandatory_values
      %w(title author).each do |attr|
        unless self.send(attr)
          raise format('No value for %s given!', attr)
        end
      end
    end

    def set_defaults
      @id ||= Digest::MD5.hexdigest(@title)
      @language ||= 'en'
      @src_dir ||= 'src'
      @build_dir ||= 'build'
      @epub_dir ||= File.join(@build_dir, 'epub3')
      @meta_inf_dir = File.join(@epub_dir, 'META-INF')
      @epub_filename ||= File.join(@build_dir, format('%s - %s.epub', @author, @title))
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

    def generate_content_file
      puts "generate #{content_filename}" if verbose
      builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.package(xmlns: "http://www.idpf.org/2007/opf", 'unique-identifier': 'pub-id', version: '3.0', 'xml:lang': language) do
          xml.metadata('xmlns:dc': 'http://purl.org/dc/elements/1.1/', 'xmlns:dcterms': 'http://purl.org/dc/terms/',
                       'xmlns:xsi': 'http://www.w3.org/2001/XMLSchema-instance', 'xmlns:opf': 'http://www.idpf.org/2007/opf') do
            xml['dc'].identifier(id, id: 'pub-id')
            xml['dc'].title title
            xml['dc'].language language
            xml.meta(Time.now.utc.to_datetime.to_s.sub(/\+00:00$/, 'Z'), property: 'dcterms:modified')
          end
          xml.manifest do
            i = 0
            content_filenames.each do |fn|
              i += 1
              xml.item(id: format('id_%04d', i), href: href(fn), 'media-type' => Ebookbinder.mimetype_for_filename(fn))
            end
            xml.item(id: 'nav', href: href(nav_filename), 'media-type' => Ebookbinder.mimetype_for_filename(nav_filename), properties: 'nav')
          end
          xml.spine do
            i = 0
            content_filenames.each do |fn|
              i += 1
              next unless Ebookbinder.mimetype_for_filename(fn) == 'application/xhtml+xml'
              xml.itemref(idref: format('id_%04d', i))
            end
          end
        end
      end
      File.write(content_filename, builder.to_xml)
    end

    def nav_filename
      File.join(@epub_dir, 'nav.xhtml')
    end

    def generate_nav_file
      puts "generate #{nav_filename}"
      builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.html(xmlns: 'http://www.w3.org/1999/xhtml') do
          xml.head
          xml.body do
            xml.nav('xmlns:epub' => 'http://www.idpf.org/2007/ops', 'epub:type' => 'toc', id: 'toc') do
              xml.ol do
                content_filenames.each do |fn|
                  next unless Ebookbinder.mimetype_for_filename(fn) == 'application/xhtml+xml'
                  Nokogiri.XML(File.read(fn)).search('h1').each do |e|
                    if id = e.attribute('id')
                      xml.li do
                        xml.a(e.text, href: href(fn, '#' << id))
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
      File.write(nav_filename, builder.to_xml)
    end

    def define_tasks
      Array(@task_defs).each do |blk|
        instance_exec &blk
      end
    end

    def content_filenames
      source_filenames.sub(/^#{src_dir}/, epub_dir)
    end

    def source_filenames
      FileList.new(File.join(src_dir, '**/*')).select {|fn| !File.directory?(fn)}.sort
    end

    def href filename, postfix=''
      filename.sub(%r(^#{epub_dir}/?), '') << postfix
    end

  end

  Epub3.define_tasks do

    CLEAN << epub_dir
    CLOBBER << build_dir << epub_filename

    namespace :epub3 do

      directory build_dir
      directory epub_dir
      directory meta_inf_dir

      content_filenames.zip(source_filenames) do |cf, sf|
        td = File.dirname(cf)
        directory td
        file cf => [td, sf] do
          cp sf, cf
        end
      end

      file mimetype_filename => epub_dir do
        generate_mimetype_file
      end

      file container_filename => meta_inf_dir do
        generate_container_file
      end

      file content_filename => [epub_dir, content_filenames].flatten do
        generate_content_file
      end

      file nav_filename => [epub_dir, content_filenames].flatten do
        generate_nav_file
      end

      all_filenames = [mimetype_filename, container_filename, content_filenames, content_filename, nav_filename].flatten

      file epub_filename => all_filenames do
        root = Dir.pwd
        epub_filename_fullpath = File.join(root, epub_filename)
        cd epub_dir do
          sh "zip -Xr9D \"#{epub_filename_fullpath}\" mimetype *"
        end
      end

      task :build => epub_filename

    end

    task :build => 'epub3:build'

  end

end
