require 'yaml'
require 'singleton'
DEFAULT = {
  :api_root => 'https://api.github.com/repos/',
  :change_api => '%s/%s/pulls/%s/files',
  :pull_api => '%s/%s/pulls',
}
module PreReviewer
  class ConfigError < RuntimeError
  end
  class Config
    include Singleton
    def self::load( config_path )
      @@config_data = YAML::load( config_path )
      raise ConfigError, "'criteria' section missing from config" unless(config_data_exists?('criteria'))
    end

    def initialize
    end

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

#    def method_missing(method, *args, &block)  
#      puts "There's no method called #{m} here -- please try again."  
#    end 
    protected

    # returns the value of the key as a string, symbol or from the default
    def get_config_data( key )
      @@config_data[key.to_s] || @@config_data[key.to_sym] || DEFAULT[key.to_sym]
    end

    # returns true if the key exists in the config and the value is not nil or false
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
