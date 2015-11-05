# -- encoding: utf-8 --
require 'digest/md5'
require 'nokogiri'
require 'rake'
require 'rake/clean'
require 'singleton'

class Epub3

  include Singleton
  include Rake::DSL

  attr_accessor :author, :id, :language, :title
  attr_accessor :epub_dir, :epub_filename, :html_dir, :mimetype_filename
  attr_reader :oepbs_dir, :meta_inf_dir
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
    @html_dir ||= 'html'
    @epub_dir ||= 'epub'
    @oepbs_dir = File.join(@epub_dir, 'OEPBS')
    @meta_inf_dir = File.join(@epub_dir, 'META-INF')
    @epub_filename ||= format('%s - %s.epub', @author, @title)
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
        end
        xml.manifest do
          FileList.new(File.join(oepbs_dir, '**/*')).each do |fn|
            next if File.directory?(fn)
            fn_rel = fn.sub(%r(^#{epub_dir}/?), '')
            xml.item(id: "id-#{fn_rel}", href: fn_rel)
          end
        end
      end
    end
    File.write(content_filename, builder.to_xml)
  end

  def define_tasks
    Array(@task_defs).each do |blk|
      instance_exec &blk
    end
  end

end

Epub3.define_tasks do

  CLEAN << epub_dir
  CLOBBER << epub_filename

  namespace :epub3 do

    directory epub_dir
    directory oepbs_dir
    directory meta_inf_dir

    source_filenames = FileList.new(File.join(html_dir, '**/*')).select {|fn| !File.directory?(fn)}

    content_filenames = source_filenames.sub(/^#{html_dir}/, oepbs_dir)
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

    all_filenames = [mimetype_filename, container_filename, content_filenames, content_filename].flatten

    task :build => all_filenames

  end

  desc 'Build ebook file(s)'
  task :build => 'epub3:build'

  task :default => :build

end
