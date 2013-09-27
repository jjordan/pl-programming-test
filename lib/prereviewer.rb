# This program takes a github account/reponame on the command line and
# parses any pull requests looking for "interesting" ones.  It then
# displays the results.
#
# Author::    Jeremiah Jordan (mailto: jjordan@perlreason.com)
# Copyright:: Copyright (c) 2013 Jeremiah Jordan
# License::   Distributes under the same terms as Ruby

# This class is the main program logic


module PreReviewer
  class Config

    # This method creates the config object
    # def initialize
    #   initialize_from_defaults
    #   initialize_from_commandline
    #   initialize_from_configfile
    # end

    # This method applies the defaults to the config object.
    # def initialize_from_defaults
    #   @api_base_url = ''
    #   
    # end

    # This method gets all of the arguments on the command-line and
    # merges them with defaults and any from a config file.
    # def initialize_from_commandline
    # end

    # This method gets the config from a config file and merges it
    # with the defaults
    # def initialize_from_configfile
    # end

  end

  class Main
    # This method initializes the program
    # def initialize
    #   (config, request) = initialize_config
    #   @repo = initialize_repo( config, request )
    #   @criteria = initialize_criteria( config )
    # end

    # This method initializes the Config from defaults, command-line
    # and configfile
    # def initialize_config
    #   config = Config.new( ARGV.dup )
    #   request = Request.new( ARGV.dup )
    #   return config, request
    # end

    # This method initializes the Repo from the config
    # def initialize_repo( config, request )
    #   @repo = ProjectRepo.new( config, request )
    # end

    # This method creates all of the Criteria objects from the config
    # def initialze_criteria( config )
    #   @criteria = Criteria.new( config )
    # end

    # This method runs the program based on defaults from the config
    # def run
    #   pulls = @repo.fetch_pulls
    #   if(pulls)
    #     pulls.each do |pull|
    #       @criteria.each do |criterion|
    #         criterion.apply(pull)
    #       end
    #       pull.render
    #     end
    #   end
    # end

  end

end
