#!/usr/bin/ruby

require 'rubygems'
require 'git'

username = ENV['USER']
date_tag = Time.now.strftime("%Y%m%d_%Hh%Mm")
suffix   = ARGV.shift
suffix = suffix.gsub(/[ \t\n]/, '_') if suffix

g = Git.open('.')
raise "Cannot open repo" if g.nil?

current_branch = g.current_branch
current_branch = 'master' if current_branch.nil?

topic_branch = "t_" + current_branch + "_" + username

topic_branch = topic_branch + "_" + suffix if suffix

topic_branch = topic_branch + "_" + date_tag
puts topic_branch

g.checkout(current_branch)
g.branch(topic_branch)

# Update the version number and commit
version_plist = `find_project_info_plist.rb`.split("\n")[0]
if version_plist
  `inc_version.rb #{version_plist}`
end

g.commit("Started topic branch '#{topic_branch}'")
