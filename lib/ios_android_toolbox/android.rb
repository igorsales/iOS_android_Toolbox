#!/usr/bin/ruby

require 'rubygems'
require 'nokogiri'
require 'ios_android_toolbox'
require 'ios_android_toolbox/base'

module IosAndroidToolbox
    
    class AndroidVersionController < VersionController
        MANIFEST='/manifest'
        ANDROID_NS='android:'
        ANDROID_VERSION_CODE='versionCode'
        ANDROID_VERSION_NAME='versionName'
        APP='application'
        ANDROID_DEBUGGABLE='debuggable'

        def self.find_project_info_candidates_for_dir(dir)
          candidates = []

          manifests=`find "#{dir}" -name "AndroidManifest.xml"`
        
          manifests.split("\n").each do |filename|
            if File.exists?(filename)
              begin
                manifest = Nokogiri::XML(File.open(filename)).xpath(MANIFEST, 'android' => "http://schemas.android.com/apk/res/android").first
                candidates.push filename if manifest and manifest[ANDROID_VERSION_NAME]
              rescue
                # Do nothing, just skip the file. Must be in binary format
              end
            end
          end

          candidates
        end

        def initialize(manifest_file)
            super()
            raise "No manifest file specified" if manifest_file.nil?
            
            begin
                @xml = Nokogiri::XML(File.open(manifest_file))
                @manifest = @xml.xpath(MANIFEST, 'android' => "http://schemas.android.com/apk/res/android").first
            rescue
                raise "Cannot parse file #{version_file}"
            end
            
            raise "File #{manifest_fiile} does not have a #{MANIFEST} node" if @xml.xpath(MANIFEST).nil?
            
            self
        end
        
        def version
            @manifest[ANDROID_VERSION_NAME]
        end

        def app_id
            raise "Not implemented yet."
        end
        
        def version_code
            @manifest[ANDROID_VERSION_CODE]
        end
        
        def next_version!(inc_idx = nil)
            @manifest[ANDROID_NS+ANDROID_VERSION_NAME] = next_version
        end

        def next_version_code
            version_code.to_i + 1
        end
        
        def next_version_code!
            @manifest[ANDROID_NS+ANDROID_VERSION_CODE] = next_version_code
        end

        def application
            @manifest.xpath(APP, 'android' => "http://schemas.android.com/apk/res/android").first
        end

        def set_debuggable(on = true)
            application[ANDROID_NS+ANDROID_DEBUGGABLE] = (on ? 'true' : 'false')
        end

        def release_version
            @manifest[ANDROID_NS+ANDROID_VERSION_NAME] = components.slice(0,3).join "."
        end
        
        def write_to_xml_file(output_file)
            if output_file == '-'
                puts @xml.to_xml
            else
                File.open output_file, "w+" do |f|
                    f.write(@xml.to_xml)
                end
            end
        end

        def write_to_output_file(output_file)
            write_to_xml_file(output_file)
        end
    end
end
