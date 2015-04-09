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

  def generate_mimetype_file
    File.write(mimetype_filename, 'application/epub+zip')
  end

  def mimetype_filename
    File.join(@epub_dir, 'mimetype')
  end

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
    @epub_filename ||= format('%s - %s.epub', @author, @title)
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

    file mimetype_filename => epub_dir do
      generate_mimetype_file
    end

    desc "Build '#{epub_filename}'"
    task :build => mimetype_filename

  end

  task :build => 'epub3:build'

end
