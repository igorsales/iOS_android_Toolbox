require "ios_android_toolbox/version"

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
end
