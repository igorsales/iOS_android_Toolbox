#!/usr/bin/ruby

require 'rubygems'
require 'git'

username = ENV['USER']

g = Git.open('.')
raise "Cannot open repo" if g.nil?

current_branch = g.current_branch

if !/^t_/.match current_branch
    puts "Not in a topic branch. Nothing to do."
    exit 0
end

puts current_branch

# t_master_igorsales_1_0_2_13_20111223_22h36m
if !/^t_(.+)_#{username}_(.+)_[0-9]{8}_[0-9][0-9]h[0-9][0-9]m$/.match current_branch
    puts "Cannot determine parent branch"
    exit 1
end

parent_branch = $1

puts "Checking out parent branch: #{parent_branch}"

raise "Cannot checkout parent branch." if g.branches[parent_branch].nil?

g.reset_hard

g.checkout(parent_branch)
g.branch(current_branch).delete

