#!/usr/bin/ruby

require 'rubygems'
require 'plist'
require 'ios_android_toolbox'
require 'ios_android_toolbox/base'

module IosAndroidToolbox

  class IosVersionController < VersionController
    VERSION_KEY = 'CFBundleVersion'

    def initialize(version_file)
      raise "No version file specified" if version_file.nil?

      begin
        @dict = Plist.parse_xml(version_file)
      rescue
        raise "Cannot parse file #{version_file}"
      end

      raise "File #{version_file} does not have a #{VERSION_KEY} key" if @dict[VERSION_KEY].nil?
        
      self
    end

    def version
      @dict[VERSION_KEY]
    end

    def next_version!(inc_idx = nil)
      @dict[VERSION_KEY] = next_version
    end

    def write_to_plist_file(output_file)
      if output_file == '-'
        puts @dict.to_plist
      else
        @dict.save_plist output_file
      end
    end
  end
end
