require 'criteria'

describe PreReviewer::Criteria, "initialize" do
  it "can load several criteria based on the config" do
    criteria = PreReviewer::Criteria.new
    config = double("config")
    criteria.config = config
    # test that it finds the appropriate criteria file from the config
    # then it opens that file
    # reads all of the lines
    # maybe from yaml
    # and then creates one criterion object for each line/entry
    # and stores all of those in an instance variable, so that it can get them all easily
  end

end
