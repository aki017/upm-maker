#!/usr/bin/env ruby

require 'rubygems/package'
require 'zlib'
require "open-uri"
class Main
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

  def main
    version_str = ARGV[0]
    version = Gem::Version.new(version_str) rescue Gem::Version.new(version_str[1..-1])

    extract_unitypackage("https://github.com/svermeulen/Zenject/releases/download/v#{version}/Zenject.v#{version}.unitypackage", "tmp")

    puts `mv tmp/Assets/Plugins/Zenject/* ./`
    puts `rm -rf tmp`
  end
end

Main.new.main
