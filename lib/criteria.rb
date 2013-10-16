require 'config'
require 'criterion'

module PreReviewer
  class Criteria
    include Enumerable
    attr_reader :config
    def initialize
      @config = PreReviewer::Config.instance
      @criterions = []
    end
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

    def size
      load_criteria
      @criterions.size
    end

    protected
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
