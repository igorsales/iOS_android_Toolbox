#!/usr/bin/ruby

require 'rubygems'
require 'plist'
require 'ios_android_toolbox'
require 'ios_android_toolbox/base'

module IosAndroidToolbox

  class IosVersionController < VersionController
    VERSION_KEY = 'CFBundleVersion'
    SHORT_VERSION_KEY = 'CFBundleShortVersionString'
    URL_TYPES_KEY = "CFBundleURLTypes"
    URL_SCHEMES_KEY = "CFBundleURLSchemes"
    BUNDLE_IDENTIFIER_KEY = "CFBundleIdentifier"
    BUNDLE_DISPLAY_NAME = "CFBundleDisplayName"
    BUNDLE_NAME = "CFBundleName"
      
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

    def bundle_id
      @dict[BUNDLE_IDENTIFIER_KEY]
    end

    def bundle_display_name
      @dict[BUNDLE_DISPLAY_NAME]
    end

    def bundle_name
      @dict[BUNDLE_NAME]
    end

    def app_id
      bundle_id
    end

    def next_version!(inc_idx = nil)
      @dict[SHORT_VERSION_KEY] = @dict[VERSION_KEY] = next_version
    end

    def url_types
      @dict[URL_TYPES_KEY]
    end

    def url_schemes
      schemes = url_types.collect do |ary|
        ary[URL_SCHEMES_KEY]
      end
      schemes.flatten
    end

    def replace_url_scheme(prev, replace)
      url_types.each do |url_type_dict|
        schemes = url_type_dict[URL_SCHEMES_KEY]
        schemes.each_index do |i|
          schemes[i] = replace if prev == schemes[i]
        end
      end
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
