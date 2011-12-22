require "ios_android_toolbox/version"

module IosAndroidToolbox
  def is_android_project?
    File.file?('AndroidManifest.xml')
  end
end
