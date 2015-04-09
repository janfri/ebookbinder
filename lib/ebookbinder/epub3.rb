# -- encoding: utf-8 --
require 'digest/md5'
require 'singleton'

module Ebookbinder

  class Epub3

    include Singleton

    attr_accessor :author, :id, :language, :title
    attr_accessor :epub_dir, :epub_filename, :html_dir

    def self.setup
      yield instance
      instance.complete
      instance
    end

    def complete
      check_mandatory_values
      set_defaults
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
      @epub_filename ||= format('%s - %s.epub', @author, @title)
    end

  end

end
#require_relative 'epub3/tasks'
