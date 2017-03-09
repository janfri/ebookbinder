# -- encoding: utf-8 --
require_relative 'epub_base'

module Ebookbinder

  class Epub2 < EpubBase

    def set_defaults
      @id ||= Digest::MD5.hexdigest(@title)
      @language ||= 'en'
      @src_dir ||= 'src'
      @build_dir ||= 'build'
      @epub_dir ||= File.join(@build_dir, 'epub2')
      @meta_inf_dir = File.join(@epub_dir, 'META-INF')
      @epub_filename ||= File.join(@build_dir, format('%s - %s.epub', @author, @title))
    end

    def generate_content_file
      puts "generate #{content_filename}" if verbose
      builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.package(xmlns: "http://www.idpf.org/2007/opf", 'unique-identifier': 'pub-id', version: '2.0') do
          xml.metadata('xmlns:dc': 'http://purl.org/dc/elements/1.1/', 'xmlns:dcterms': 'http://purl.org/dc/terms/',
                       'xmlns:xsi': 'http://www.w3.org/2001/XMLSchema-instance', 'xmlns:opf': 'http://www.idpf.org/2007/opf') do
            xml['dc'].identifier(id, id: 'pub-id')
            xml['dc'].title title
            xml['dc'].language language, 'xsi:type' => 'dcterms:RFC3066'
          end
          xml.manifest do
            i = 0
            content_filenames.each do |fn|
              i += 1
              xml.item(id: format('id_%04d', i), href: href(fn), 'media-type' => Ebookbinder.mimetype_for_filename(fn))
            end
            xml.item(id: 'ncx', href: href(ncx_filename), 'media-type' => 'application/x-dtbncx+xml')
          end
          xml.spine toc: 'ncx' do
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

    def ncx_filename
      File.join(@epub_dir, 'toc.ncx')
    end

    def generate_ncx_file
      builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.ncx(xmlns: 'http://www.daisy.org/z3986/2005/ncx/', version: '2005-1') do
          xml.head do
            xml.meta name: 'dtb:uid', content: id
            xml.meta name: 'dtb:depth', content: '2'
            xml.meta name: 'dtb:totalPageCount', content: '0'
            xml.meta name: 'dtb:maxPageNumber', content: '0'
          end
          xml.docTitle do
            xml.text! title
          end
          xml.navMap do
            i = 0
            content_filenames.each do |fn|
              next unless Ebookbinder.mimetype_for_filename(fn) == 'application/xhtml+xml'
              Nokogiri.XML(File.read(fn)).search('h1').each do |e|
                if id = e.attribute('id')
                  i +=1
                  xml.navPoint id: format('id_%04d', i), playOrder: i do
                    xml.navLabel do
                      xml.text! e.text
                    end
                    xml.content src: href(fn, id)
                  end
                end
              end
            end
          end
        end
      end
      File.write(ncx_filename, builder.to_xml)
    end

  end

  Epub2.define_tasks do

    ::CLEAN << epub_dir
    ::CLOBBER << build_dir << epub_filename

    namespace :epub2 do

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

      file ncx_filename => [epub_dir, content_filenames].flatten do
        generate_ncx_file
      end

      all_filenames = [mimetype_filename, container_filename, content_filenames, content_filename, ncx_filename].flatten

      file epub_filename => all_filenames do
        root = Dir.pwd
        epub_filename_fullpath = File.join(root, epub_filename)
        cd epub_dir do
          sh "zip -Xr9D \"#{epub_filename_fullpath}\" mimetype *"
        end
      end

      task :build => epub_filename

    end

    task :build => 'epub2:build'

  end

end
