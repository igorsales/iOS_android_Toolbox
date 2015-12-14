#!/usr/bin/ruby

require 'rubygems'
require 'plist'
require 'ios_android_toolbox'
require 'ios_android_toolbox/base'

module IosAndroidToolbox

  class IosVersionController < VersionController
    BUILD_VERSION_KEY = 'CFBundleVersion' # User as Build  or release candidate
    BUNDLE_VERSION_KEY = 'CFBundleShortVersionString' # Use as Version
    URL_TYPES_KEY = "CFBundleURLTypes"
    URL_SCHEMES_KEY = "CFBundleURLSchemes"
    BUNDLE_IDENTIFIER_KEY = "CFBundleIdentifier"
    BUNDLE_DISPLAY_NAME = "CFBundleDisplayName"
    BUNDLE_NAME = "CFBundleName"
    BUNDLE_ICON_FILES = "CFBundleIconFiles"
      
    def self.find_project_info_candidates_for_dir(dir)
      candidates = []
      
      plists=`find "#{dir}" -name "*.plist"`
      
      plists.split("\n").each do |filename|
        if File.exists?(filename)
          begin
            dict = Plist.parse_xml(filename)
            candidates.push filename if dict and dict[BUNDLE_VERSION_KEY]
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

      raise "File #{version_file} does not have a #{BUNDLE_VERSION_KEY} key" if @dict[BUNDLE_VERSION_KEY].nil?
        
      self
    end

    def version
      "#{@dict[BUNDLE_VERSION_KEY]}-#{@dict[BUILD_VERSION_KEY]}"
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

    def bundle_icon_files
      @dict[BUNDLE_ICON_FILES]
    end

    def app_id
      bundle_id
    end

    def bundle_version
      @dict[BUNDLE_VERSION_KEY]
    end

    def build_number
      @dict[BUILD_VERSION_KEY]
    end

    def next_version(inc_idx = nil)
      if inc_idx == @inc_idx # trying to increment build number
        v = bundle_version
        s = (build_number.to_i + 1).to_s
      else
        v = super.next_version(inc_idx)
        s = build_number
      end

      "#{v}-#{s}"
    end

    def next_version!(inc_idx = nil)
      if inc_idx < @inc_idx
        @dict[BUNDLE_VERSION_KEY] = next_version(inc_idx)
      else
        @dict[BUILD_VERSION_KEY] = (build_number.to_i + 1).to_s
      end

      version
    end

    def next_build_number
      next_version(@inc_idx)
    end

    def next_build_number!
      next_version!(@inc_idx)
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
