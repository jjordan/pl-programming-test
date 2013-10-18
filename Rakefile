# -*- ruby -*-

require "rubygems"
#require "hoe"
require 'rspec/core/rake_task'
require 'rdoc'
require 'rdoc/task'
require 'rubygems/package_task'
require 'find'
require 'pathname'

BASE = Pathname(__FILE__).dirname.realpath

RSpec::Core::RakeTask.new(:spec) do |config|
#  config.rcov = true
end

PKG_VERSION = '0.0.1'
PKG_FILES = ['Rakefile', 'README.txt', 'README.md', 'History.txt', 'Manifest.txt']
# find package files
%w{bin lib default spec}.each do |subdir|
  Find.find(BASE + subdir) do |path|
    if FileTest.file?(path)
      file = Pathname.new(path).relative_path_from( BASE )
      PKG_FILES << file.to_s
    end
  end
end

task :default => :spec

# rdoc tasks:
Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("lib/**/*.rb")
end

spec = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.summary = "A GitHub Pull Request Reviewer written in Ruby."
  s.name = 'prereviewer'
  s.version = PKG_VERSION
  s.requirements << 'none'
  s.require_path = 'lib'
  s.files = PKG_FILES
  s.authors = ['Jeremiah Jordan']
  s.email = 'jjordan@perlreason.com'
  s.executables = ['review']
  s.homepage = 'http://www.perlreason.com/prereviewer'
  s.description = <<EOF
  prereviewer is a program that uses the GitHub API to
  check the pull requests for changes that look 'interesting',
  where interesting is defined by various match criteria.
EOF
  end

  Gem::PackageTask.new(spec) do |pkg|
    pkg.need_zip = true
    pkg.need_tar = true
  end

# Hoe.plugin :compiler
# Hoe.plugin :gem_prelude_sucks
# Hoe.plugin :inline

# verify coverage

# Hoe.plugin :minitest
# Hoe.plugin :racc
# Hoe.plugin :rcov
# Hoe.plugin :rubyforge

#Hoe.spec "pl-programming-test" do
  # HEY! If you fill these out in ~/.hoe_template/Rakefile.erb then
  # you'll never have to touch them again!
  # (delete this comment too, of course)

  # developer("FIX", "FIX@example.com")

  # self.group_name = "pl-programming-testx" # if part of an organization/group

  # license "MIT" # this should match the license in the README
#end

# vim: syntax=ruby
