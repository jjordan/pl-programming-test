require 'configurability'

module PreReviewer
  class Criteria
    attr_accessor :config
    extend Configurability
  end
end
