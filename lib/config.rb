require 'yaml'
require 'singleton'

module PreReviewer
  # The default api_root, change_api path and pull_api path
  DEFAULT = {
    :api_root => 'https://api.github.com/repos/',
    :change_api => '%s/%s/pulls/%s/files',
    :pull_api => '%s/%s/pulls',
  }
  ### The error class for config-specific errors.
  class ConfigError < RuntimeError ;  end

  ### The singleton config object
  class Config
    include Singleton

    ### A class method to load the config using the given config_path.  Assumes that the config file is in YAML format.  Throws a ConfigError if the 'criteria' section is missing from the config. Should probably throw more exceptions.
    def self::load( config_path )
#      p config_path
      @@config_data = YAML::load( File.read(config_path.to_s) )
#      p @@config_data
      raise ConfigError, "'criteria' section missing from config" unless(config_data_exists?('criteria'))
    end

    # Given the +account+, +repo+ and +pull_number+, this method returns
    # the URL for fetching changes from GitHub.
    def change_api( account, repo, number )
      api_root = get_config_data( 'api_root' )
      change_api = get_config_data( 'change_api' )
      change_url = api_root + change_api % [account, repo, number]
      access_token = get_config_data( 'access_token' )
      if((access_token) && (!access_token.empty?))
        change_url += "?access_token=%s" % [access_token]
      end
      change_url
    end

    # Given the +account+ and +repo+, this method returns the URL for to
    # fetch PullRequests from GitHub.
    def pull_api( account, repo )
      api_root = get_config_data( 'api_root' )
      pull_api = get_config_data( 'pull_api' )
      pull_url = api_root + pull_api % [account, repo]
      access_token = get_config_data( 'access_token' )
      if((access_token) && (!access_token.empty?))
        pull_url += "?access_token=%s" % [access_token]
      end
      pull_url
    end

    # Checks to see if the called +method+ exists in the config data,
    # if it does, it creates a getter method and installs it into the
    # class, passing the +args+ and any +block+.  If the data doesn't
    # exist in the config, it returns a ConfigError
    def method_missing(method, *args, &block)  
      if( self.class.config_data_exists? method )
        self.class.send( :define_method, method.to_sym ) do
          return self.get_config_data( method )
        end
      else
        raise ConfigError, "No config section '#{method}'"
      end
      return self.send( method.to_sym )
    end 
    protected

    # returns the value of the +key+ as a string, symbol or from the
    # default from the Config
    def get_config_data( key )
      @@config_data[key.to_s] || @@config_data[key.to_sym] || DEFAULT[key.to_sym]
    end

    # returns true if the +key+ exists in the config and the value is
    # not nil or false
    def self::config_data_exists?( key )
      unless(@@config_data.has_key?( key.to_s ) || @@config_data.has_key?( key.to_sym ))
        unless(@@config_data[key.to_s] && @@config_data[key.to_sym])
          return false
        end
      end
      return true
    end

  end
end
