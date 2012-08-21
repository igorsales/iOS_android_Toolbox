#!/usr/bin/ruby

require 'rubygems'
require 'ios_android_toolbox/ios_prov_profile'

include IosAndroidToolbox

class InstallProvProfile
    def run(args)
        profile_path = args.shift
        profile_path or raise "Please specify a provisioning profile name"

        IosProvisioningProfile.install(profile_path)
    end
end

InstallProvProfile.new.run(ARGV)