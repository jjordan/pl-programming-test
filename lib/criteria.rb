require 'config'
require 'criterion'

module PreReviewer
  ### The Criteria class represents a collection of specific Criterions
  class Criteria
    include Enumerable
    attr_reader :config

    # load the config
    def initialize
      @config = PreReviewer::Config.instance
      @criterions = []
    end

    # load the criterions from the config object if they aren't
    # loaded, then iterate over them.
    def each &block
      load_criteria
      if block_given?
        @criterions.each do |criterion|
          block.call criterion
        end
      else
        @criterions.each
      end
    end

    # return the number of criterions loaded
    def size
      load_criteria
      @criterions.size
    end

    protected
    # load the criteria from the config object and convert them from
    # hashes into objects.
    def load_criteria
      unless((@criterions) && !@criterions.empty?)
        @criterions = []
        criterion_data = @config.criteria
        criterion_data.each do |criterion_datum|
          @criterions << PreReviewer::Criterion.new( criterion_datum )
        end
      end
#      p @criterions.inspect
      return @criterions
    end

  end
end
