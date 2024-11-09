# encoding: utf-8
require_relative 'epub_base'

module Ebookbinder

  class Epub3 < EpubBase

    def set_defaults
      @id ||= Digest::MD5.hexdigest(@title)
      @language ||= 'en'
      @src_dir ||= 'src'
      @build_dir ||= 'build'
      @epub_dir ||= File.join(@build_dir, 'epub3')
      @meta_inf_dir = File.join(@epub_dir, 'META-INF')
      @epub_filename ||= File.join(@build_dir, format('%s - %s.epub', @author, @title))
    end

    def generate_content_file
      puts "generate #{content_filename}" if verbose
      builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.package(xmlns: "http://www.idpf.org/2007/opf", 'unique-identifier': 'pub-id', version: '3.0', 'xml:lang': language) do
          xml.metadata('xmlns:dc': 'http://purl.org/dc/elements/1.1/', 'xmlns:dcterms': 'http://purl.org/dc/terms/',
                       'xmlns:xsi': 'http://www.w3.org/2001/XMLSchema-instance', 'xmlns:opf': 'http://www.idpf.org/2007/opf') do
            xml['dc'].identifier(id, id: 'pub-id')
            xml['dc'].title title
            xml['dc'].creator(@author, 'xml:lang' => language)
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
      puts "generate #{nav_filename}" if verbose
      builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.html(xmlns: 'http://www.w3.org/1999/xhtml') do
          xml.head do
            xml.title @title
          end
          xml.body do
            xml.nav('xmlns:epub' => 'http://www.idpf.org/2007/ops', 'epub:type' => 'toc', id: 'toc') do
              xml.ol do
                content_filenames.each do |fn|
                  next unless Ebookbinder.mimetype_for_filename(fn) == 'application/xhtml+xml'
                  h_struct = create_header_struct(fn)
                  create_li_entries(fn, xml, h_struct)
                end
              end
            end
          end
        end
      end
      File.write(nav_filename, builder.to_xml)
    end

    def create_li_entries fn, xml, h_struct
      h_struct.each do |entry|
        e, children = entry
        id = e.attribute('id')
        xml.li do
          xml.a(e.text, href: href(fn, id))
          unless children.empty?
            xml.ol do
              create_li_entries(fn, xml, children)
            end
          end
        end
      end
    end

  end

  Epub3.define_tasks do

    ::CLEAN << epub_dir
    ::CLOBBER << build_dir << epub_filename

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
          sh "zip -Xqr9D \"#{epub_filename_fullpath}\" mimetype *"
        end
      end

      task :build => epub_filename

    end

    task :build => 'epub3:build'

    task :check => epub_filename do
      sh 'epubcheck', epub_filename
    end

  end

end
