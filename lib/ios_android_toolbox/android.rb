#!/usr/bin/ruby

require 'rubygems'
require 'nokogiri'
require 'ios_android_toolbox'
require 'ios_android_toolbox/base'

module IosAndroidToolbox
    
    class AndroidVersionController < VersionController
        MANIFEST='/manifest'
        ANDROID_VERSION_CODE='versionCode'
        ANDROID_VERSION_NAME='versionName'

        def initialize(manifest_file)
            raise "No manifest file specified" if manifest_file.nil?
            
            begin
                f = File.open(manifest_file)
                @xml = Nokogiri::XML(f)
                f.close
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
        
        def version_code
            @manifest[ANDROID_VERSION_CODE]
        end
        
        def next_version!(inc_idx = nil)
            @manifest[ANDROID_VERSION_NAME] = next_version
        end
        
        def write_to_xml_file(output_file)
            if output_file == '-'
                puts @xml.to_xml
            else
                f = File.new(output_file)
                f.write(@xml.to_xml)
                f.close
            end
        end
    end
end
