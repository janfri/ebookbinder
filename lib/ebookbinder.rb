# -- encoding: utf-8 --
require 'yaml'

module Ebookbinder

  MIMETYPE_MAPPING = YAML.load <<-END
    css: text/css
    gif: image/gif
    htm: application/html
    html: application/html
    jpe: image/jpeg
    jpeg: image/jpeg
    jpg: image/jpeg
    png: image/png
    svg: image/svg+xml
    svgz: image/svg+xml
    ttc: application/x-font-ttf
    ttf: application/x-font-ttf
    xhtml: application/xhtml+xml
  END

  def self.mimetype_for_filename fn
    MIMETYPE_MAPPING[File.extname(fn).sub(/^\./, '')] or raise "Unknown mimetype for file #{fn}!"
  end

end


