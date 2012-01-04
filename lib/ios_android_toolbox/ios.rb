#!/usr/bin/ruby

require 'rubygems'
require 'plist'
require 'ios_android_toolbox'
require 'ios_android_toolbox/base'

module IosAndroidToolbox

  class IosVersionController < VersionController
    VERSION_KEY = 'CFBundleVersion'
    SHORT_VERSION_KEY = 'CFBundleShortVersionString'
      
    def self.find_project_info_candidates_for_dir(dir)
      candidates = []
      
      plists=`find "#{dir}" -name "*.plist"`
      
      plists.split("\n").each do |filename|
        if File.exists?(filename)
          begin
            dict = Plist.parse_xml(filename)
            candidates.push filename if dict and dict[VERSION_KEY]
          rescue
            # Do nothing, just skip the file. Must be in binary format
          end
        end
      end

      candidates
    end

    def initialize(version_file)
      super()
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
      @dict[SHORT_VERSION_KEY] = @dict[VERSION_KEY] = next_version
    end

    def write_to_plist_file(output_file)
      if output_file == '-'
        puts @dict.to_plist
      else
        @dict.save_plist output_file
      end
    end

    def write_to_output_file(output_file)
        write_to_plist_file(output_file)
    end
  end
end
