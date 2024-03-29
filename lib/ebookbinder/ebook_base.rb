# encoding: utf-8
require_relative '../ebookbinder'
require 'singleton'

module Ebookbinder

  class EbookBase

    include Singleton
    include Rake::DSL

    attr_accessor :author, :id, :language, :title
    attr_accessor :build_dir, :src_dir
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

    protected

    def define_tasks
      Array(@task_defs).each do |blk|
        instance_exec &blk
      end
    end

  end

end
