require 'ios_android_toolbox/version'
require 'ios_android_toolbox/base'
require 'ios_android_toolbox/ios'
require 'ios_android_toolbox/android'

module IosAndroidToolbox
  def is_android_project?
    File.file?('AndroidManifest.xml')
  end

  def is_ios_filename?(filename)
    /\.plist$/.match(filename)
  end

  def is_android_filename?(filename)
    /AndroidManifest\.xml$/.match(filename)
  end

  def version_controller_for_version_file(version_file)
    ctrl = nil
    if is_ios_filename? version_file
      ctrl = IosVersionController.new(version_file)
    elsif is_android_filename? version_file
      ctrl = AndroidVersionController.new(version_file)
    else
      raise "Unrecognizable project type for file #{version_file}"
    end
      
    ctrl
  end
end
