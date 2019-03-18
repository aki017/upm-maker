#!/usr/bin/env ruby

require "thor"
require "json"
require "./helper"

class App < Thor
  include Helper

  desc "zenject", "desc"
  def zenject(version, old_version)
    if version[0] == "v"
      version = version[1..-1]
    end

    if old_version[0] != "v"
      old_version = "v"+old_version
    end

    puts `rm -rf tmp`
    extract_unitypackage(url || "https://github.com/svermeulen/Zenject/releases/download/v#{version}/Zenject.v#{version}.unitypackage", "tmp") rescue extract_unitypackage("https://github.com/svermeulen/Zenject/releases/download/v#{version}/Zenject@v#{version}.unitypackage", "tmp")

    puts `rm -rf Zenject`
    puts `git clone -b #{old_version} git@github.com:aki017/Zenject-upm.git Zenject`
    puts `rm -rf Zenject/*`
    puts `mv tmp/Assets/Plugins/Zenject/* ./Zenject/`
    puts `rm -rf tmp`
    File.write "Zenject/package.json", JSON.generate({
      "name": "info.aki017.zenject",
      "displayName": "Zenject",
      "version": version,
      "unity": "2018.2",
      "description": "",
      "keywords": [""],
      "category": "",
      "dependencies": { }
    })
    File.write "Zenject/package.json.meta", gen_meta("7c2c064472ee21a489d90a7234ddf82a")
    puts `cd Zenject && git add . && git commit -m "Update #{version}" && git tag -f v#{version} && git push -f origin v#{version}`
  end

  desc "unitask", "desc"
  def unitask(version, old_version, url=nil)
    if version[0] == "v"
      version = version[1..-1]
    end

    if old_version[0] != "v"
      # old_version = "v"+old_version
    end

    puts `rm -rf tmp`
    extract_unitypackage(url || "https://github.com/neuecc/UniRx/releases/download/#{version}/UniRx.Async.#{version}.unitypackage", "tmp")

    puts `rm -rf UniRx.Async`
    puts `git clone -b #{old_version} git@github.com:aki017/UniRx.Async-upm.git UniRx.Async`
    puts `rm -rf UniRx.Async/*`
    puts `mv tmp/Assets/Plugins/UniRx/Scripts/Async/* ./UniRx.Async/`
    puts `rm -rf tmp`
    File.write "UniRx.Async/package.json", JSON.generate({
      "name": "info.aki017.unirx.async",
      "displayName": "UniRx.Async",
      "version": version,
      "unity": "2018.2",
      "description": "",
      "keywords": [""],
      "category": "",
      "dependencies": { }
    })
    File.write "UniRx.Async/package.json.meta", gen_meta("c9ff3cdff80d1dc4a961d074342dfce9")

    {
      "64b064347ca7a404494a996b072e2e29": "CompilerServices",
      "275b87293edc6634f9d72387851dbbdf": "Editor",
      "633f49a8aafb6fa43894cd4646c71743": "Internal",
      "85c0c768ced512e42b24021b3258b669": "Triggers"
    }.each do |meta, name|
      if Dir.exist? "UniRx.Async/#{name}"
        File.write "UniRx.Async/#{name}.meta", gen_meta(meta)
      end
    end

    File.write "UniRx.Async/UniRx.Async.asmdef", JSON.generate({
      "name": "UniRx.Async",
      "references": [],
      "optionalUnityReferences": [],
      "includePlatforms": [],
      "excludePlatforms": [],
      "allowUnsafeCode": false
    })
    File.write "UniRx.Async/UniRx.Async.asmdef.meta", gen_meta("f51ebe6a0ceec4240a699833d6309b23")

    if Dir.exist? "UniRx.Async/Editor"
      File.write "UniRx.Async/Editor/UniRx.Async.Editor.asmdef", JSON.generate({
        "name": "UniRx.Async.Editor",
        "references": [
          "UniRx.Async"
        ],
        "optionalUnityReferences": [],
        "includePlatforms": [
          "Editor"
        ],
        "excludePlatforms": [],
        "allowUnsafeCode": false
      })
      File.write "UniRx.Async/UniRx.Async.Editor.asmdef.meta", gen_meta("4129704b5a1a13841ba16f230bf24a57")
    end

    puts `cd UniRx.Async && git add . && git commit -m "Update #{version}" && git tag -f v#{version} && git push -f origin v#{version}`
  end
end

App.start
