#!/usr/bin/ruby

require 'rubygems'
require 'git'
require 'ios_android_toolbox'

include IosAndroidToolbox

username = ENV['USER']
date_tag = Time.now.strftime("%Y%m%d_%Hh%Mm")
topic    = ARGV.shift

version_file = VersionController.version_file
raise "Please specify the version file" if version_file.nil?

ctrl = version_controller_for_version_file version_file

if topic.nil?
  topic = ctrl.next_version(2).gsub(/\-.+$/,'').gsub(/\.0$/,'')
end

topic.gsub!(/[\. \t\n]/, '_') if topic

g = Git.open('.')
raise "Cannot open repo" if g.nil?

current_branch = g.current_branch
current_branch = 'master' if current_branch.nil?

topic_branch = "t_" + current_branch + "_" + username

topic_branch = topic_branch + "_" + topic if topic

topic_branch = topic_branch + "_" + date_tag
puts "Starting topic branch: #{topic_branch}"

g.checkout(current_branch)
g.branch(topic_branch).delete if g.branches[topic_branch]
g.branch(topic_branch).checkout

# Update the version number and commit
ctrl.next_version!
ctrl.write_to_output_file version_file

# Commit the result
g.commit_all("Started topic branch '#{topic_branch}'")
