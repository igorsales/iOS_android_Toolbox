#!/usr/bin/ruby

require 'rubygems'
require 'ios_android_toolbox'

module IosAndroidToolbox

  class VersionController
    attr_accessor :inc_idx, :max_comps

    def initialize
      @inc_idx   = 3
      @max_comps = 4
    end
      
    def self.find_project_info_candidates_for_dir
      raise "Abstract class method. Please override"
    end
      
    def self.find_project_info(dir = nil)
      dir ||= '.'
      
      candidates = find_project_info_candidates_for_dir(dir)      

      max_components = 9999
      candidates.each do |filename|
        components = filename.split(File::SEPARATOR)
        if components.length < max_components
          max_components = components.length
        end
      end

      candidates.find_all { |filename| filename.split(File::SEPARATOR).length == max_components }
    end

    def self.version_file
      version_file = ARGV.shift
      if version_file.nil?
        files = IosVersionController.find_project_info << AndroidVersionController.find_project_info
        files.flatten!
        
        if files.length == 1
          version_file = files.first
        elsif files.length > 1
          # Heuristic: choose shorted string path
          version_file = files.sort { |a,b| a.length <=> b.length }[0]
        end
      end
      version_file
    end

    def version
      raise "Abstract method. Please override"
    end

    def components
      v = version
      if version.match /([0-9\.]+)([a-zA-Z0-9\-]*)$/
        v = $1
        suffix = $2
      end
      v.split('.')
    end

    def suffix
      suffix = ''
      if version.match /([0-9\.]+)([a-zA-Z0-9\-]*)$/
        suffix = $2
      end
      suffix
    end

    def next_version(inc_idx = nil)
      inc_idx ||= @inc_idx
      max_comps ||= @max_comps

      comps = components
        
      should_inc_prev_idx = (inc_idx > 0 and comps[inc_idx].nil?)

      while comps.length < inc_idx
        comps.push 0
      end


      if comps.length > inc_idx
        inc_comp = comps[inc_idx].to_i
      else
        inc_comp = -1
      end

      inc_comp += 1
      comps[inc_idx] = inc_comp
      comps.each_index do |i|
        comps[i] = 0 if i > inc_idx
      end

      if should_inc_prev_idx
        comps[inc_idx-1] = comps[inc_idx-1].to_i+1
      end

      comps = comps.slice(0,max_comps)

      comps.join(".") + suffix
    end

    def next_version!(inc_idx = nil)
      raise "Abstract method. Please override"
    end

    def write_to_output_file(output_file)
        raise "Abstract method. Please override"
    end

  end
end
