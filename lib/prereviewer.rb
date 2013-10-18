# This class is the main program logic
require 'config'
require 'pathname'
require 'request'
require 'repository'
require 'criteria'

# The PreReviewer system is intended to help automate the review
# process of pull requests on GitHub.
# It provides a command-line utility 'review' that takes an account/repository name and optional config yaml file and uses the GitHub API to preselect pull requests that look interesting.
#
# Author::    Jeremiah Jordan (mailto: jjordan@perlreason.com)
# Copyright:: Copyright (c) 2013 Jeremiah Jordan
# License::   MIT or GPL2
module PreReviewer
  # Used to find the default config file.
  BASEPATH = Pathname(__FILE__).parent.dirname.realpath
  # Where in the PreReviewer package it expects to find the default
  # config fie.  'default/config.yml'
  DEFAULT_CONFIG_PATH =  'default/config.yml'
  # Where in the user's home directory it expects to find the user's
  # specific config file. '.prereviewer/config.yml'
  HOMEDIR_CONFIG_PATH = '.prereviewer/config.yml'
  # The class representing the main program.
  class Main
    # Returns the program help text for the usage.
    attr_reader :usage
    # This method loads the Config object, creates the Request, Repository and Criteria.
    def initialize
      args = ARGV.dup
      @usage = "Usage: #{$0}: ACCOUNT/REPOSITORY [/path/to/config.yml]"
      if(args.empty?)
        @error = true
      else
        @error = false
        @config = initialize_config( args )
        @request = PreReviewer::Request.new( args )
        @repo = PreReviewer::Repository.new( @request )
        @criteria = PreReviewer::Criteria.new
      end
    end

    # This method returns whether an error occurred in the initialization.
    # Yes I know I could just use exceptions.  I will fix that soon.
    def has_error?
      @error
    end

    # This method creates the config object based on an argument on
    # the command-line, or the default config file location in the
    # user's homedir or the default config file in the package
    def initialize_config( args )
      homedir = ENV['HOME']
      found_config = args.grep(/\.yml/).first
      if((found_config) && (Pathname.new(found_config).exist?))
        config_path = Pathname.new(found_config)
      elsif(Pathname.new(homedir + HOMEDIR_CONFIG_PATH).exist?)
        config_path = Pathname.new(homedir + HOMEDIR_CONFIG_PATH)
      else
        config_path = BASEPATH + DEFAULT_CONFIG_PATH
      end
      PreReviewer::Config.load( config_path )
      return PreReviewer::Config.instance
    end

    # This method runs the program based on defaults from the config
    def run
      pulls = @repo.pulls
      if(pulls)
        pulls.each do |pull|
          changes = []
          reasons = []
          @criteria.each do |criterion|
          #  p criterion.inspect
            criterion.apply(pull)
            reasons << pull.render_reason( criterion ) if( criterion.applied? )
            pull.changes.each do |change|
              changes << change.render( criterion )
            end
          end
          puts pull.render
          puts reasons.compact.uniq.join("\n") unless(reasons.compact.empty?)
          puts changes.compact.uniq.join("\n") unless(changes.compact.empty?)
        end
      end
    end

  end

end
