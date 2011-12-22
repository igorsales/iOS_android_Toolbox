#!/usr/bin/ruby

require 'rubygems'
require 'ios_android_toolbox'

module IosAndroidToolbox

  class VersionController
    attr_accessor :inc_idx, :max_comps

    @inc_idx   = 3
    @max_comps = 4

    def version
      raise "Abstract method. Please override"
    end

    def components
      version.split('.')
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

      comps.join "."
    end

    def next_version!(inc_idx = nil)
      raise "Abstract method. Please override"
    end
  end
end
