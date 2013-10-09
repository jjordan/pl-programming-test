# This program takes a github account/reponame on the command line and
# parses any pull requests looking for "interesting" ones.  It then
# displays the results.
#
# Author::    Jeremiah Jordan (mailto: jjordan@perlreason.com)
# Copyright:: Copyright (c) 2013 Jeremiah Jordan
# License::   Distributes under the same terms as Ruby

# This class is the main program logic

require 'configurability'
require 'pathname'
require 'request'
require 'repository'
require 'criteria'

BASEPATH = Pathname(__FILE__).parent.dirname.realpath
DEFAULT_CONFIG_PATH =  'default/config.yml'
HOMEDIR_CONFIG_PATH = '.prereviewer/config.yml'

module PreReviewer

  class Main
    extend Configurability
    # This method initializes the program
    def initialize
      args = ARGV.dup
      @request = PreReviewer::Request.new( args )
      @repo = PreReviewer::Repository.new( @request )
      @criteria = PreReviewer::Criteria.new
      # initialize this last, since it's callback configures all the above
      @config = initialize_config( args )
    end

    # This method creates the config object
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
      config = Configurability::Config.load( config_path )
      Configurability.configure_objects( config )
      return config
    end

    # This method runs the program based on defaults from the config
    def run
      pulls = @repo.pulls
      if(pulls)
        pulls.each do |pull|
          @criteria.each do |criterion|
            criterion.apply(pull)
          end
          pull.render
        end
      end
    end

  end

end
