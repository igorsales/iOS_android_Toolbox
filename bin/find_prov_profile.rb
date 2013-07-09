#!/usr/bin/ruby

require 'rubygems'
require 'optparse'
require 'ios_android_toolbox/ios_prov_profile'

include IosAndroidToolbox

class FindProvProfile
  def parse_args
    options = {}
    OptionParser.new do |opts|
      opts.banner = "Usage: find_prov_profile.rb [options] <info.plist>"
                  
      opts.on("-i", "--id [BUNDLE_ID]", String, "Specifies the bundle ID") do |v|
        options[:bundle_id] = v
      end

      opts.on("-a", "--adhoc", "Specifies the profile should an adhoc profile") do
        options[:profile_type] = :adhoc
      end

      opts.on("-d", "--development", "The profile should be a development profile") do
        options[:profile_type] = :dev
      end

      opts.on("-s", "--appstore", "The profile should be an App Store profile") do
        options[:profile_type] = :dist
      end
    end.parse!
    options
  end

  def run(args)
    options = parse_args

    bundle_id = options[:bundle_id]
    bundle_id or raise "You must specify the bundle ID"

    type = options[:profile_type]
    type or raise "You must specify the type of profile"

    path = nil
    IosProvisioningProfile.loop_through_profiles_for_app_id(bundle_id) do |profile|
      path = profile.path if type == :adhoc and profile.is_adhoc?
      path = profile.path if type == :dev   and profile.is_development?
      path = profile.path if type == :dist  and profile.is_production?
    end

    if path.nil?
      exit 1
    end

    puts path
  end
end

FindProvProfile.new.run(ARGV)