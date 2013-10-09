require 'criteria'

describe PreReviewer::Criteria, "initialize" do
  it "can load several criteria based on the config" do
    criteria_data = [
                     {:specifier => :all, :field => :patch, :meaning => :interesting, :match => '/foo/' },
                     {:specifier => :any, :field => :file, :meaning => :uninteresting, :match => '/bar/' }
                    ]

    config = double("config")
    criteria = PreReviewer::Criteria.new
    criteria.config = config
    # test that it finds the appropriate criteria file from the config
    config.should_receive( :criteria_file ).and_return( :file )
    # then it opens that file
    # reads all of the lines
    # maybe from yaml
    YAML.should_receive(:load).with(:file).and_return(criteria_data)
    # and then creates one criterion object for each entry
    criteria_data.each do | criteria_hash |
      PreReviewer::Criterion.should_receive(:new).with( criteria_hash ).and_return( "criterion_obj1".to_sym )
    end
    # and stores all of those in an instance variable, so that it can get them all easily
    criteria.size.should == 2
  end

end
