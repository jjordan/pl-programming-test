require 'config'
require 'criterion'

module PreReviewer
  class Criteria
    include Enumerable
    attr_reader :config
    def initialize
      @config = PreReviewer::Config.instance
      @index = 0
    end

    def each
      load_criteria
      yield @criterions[@index]
      @index += 1
    end

    def size
      load_criteria
      @criterions.size
    end

    protected
    def load_criteria
      unless((@criterions) && !@criterions.empty)
        @criterions = []
        criterion_data = YAML::load(@config.criteria_file)
        criterion_data.each do |criterion_datum|
          @criterions << PreReviewer::Criterion.new( criterion_datum )
        end
      end
    end
  end
end
