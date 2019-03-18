#!/usr/bin/env ruby

require 'rubygems/package'
require 'zlib'
require "open-uri"

a = Gem::Package::TarHeader
def a.strict_oct(str)
  return str.oct if str =~ /\A[0-7]*\z/
  return str.to_i(8)
end

module Helper
  def extract_unitypackage(file, dest)
    gzip_reader = Zlib::GzipReader.open(open(file))

    tar_reader = Gem::Package::TarReader.new(gzip_reader)

    files = []
    name_map = {}
    tar_reader.each do |entry|
      if entry.file?
        full_name = entry.full_name
        if full_name.end_with?("pathname")
          name_map[full_name[0..31]] = entry.read
        end
      end
    end
    tar_reader.rewind
    tar_reader.each do |entry|
      if entry.file?
        full_name = entry.full_name
        path = dest +"/"+name_map[full_name[0..31]]
        dir = File.dirname(path)
        if full_name.end_with?("asset")
          FileUtils.mkdir_p dir
          File.write(path, entry.read)
        end
        if full_name.end_with?("asset.meta")
          FileUtils.mkdir_p dir
          File.write(path+".meta", entry.read)
        end
      end
    end
    tar_reader.close
    gzip_reader.close
  end

  def gen_meta(guid)
    <<"EOS"
fileFormatVersion: 2
guid: #{guid}
TextScriptImporter:
  externalObjects: {}
  userData:
  assetBundleName:
  assetBundleVariant:
EOS
  end
end
