# -- encoding: utf-8 --
require 'digest/md5'
require 'rake'
require 'rake/clean'
require 'singleton'

class Epub3

  include Singleton
  include Rake::DSL

  attr_accessor :author, :id, :language, :title
  attr_accessor :epub_dir, :epub_filename, :html_dir, :mimetype_filename
  attr_reader :oepbs_dir
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
    @epub_filename ||= format('%s - %s.epub', @author, @title)
  end

  def mimetype_filename
    File.join(@epub_dir, 'mimetype')
  end

  def generate_mimetype_file
    puts "generate #{mimetype_filename}" if verbose
    File.write(mimetype_filename, 'application/epub+zip')
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

    all_filenames = [mimetype_filename, content_filenames].flatten

    desc "Build '#{epub_filename}'"
    task :build => all_filenames

  end

  task :build => 'epub3:build'

end
