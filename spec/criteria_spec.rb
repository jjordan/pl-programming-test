require 'criteria'

describe PreReviewer::Criteria, "initialize" do
  it "can load several criteria based on the config" do
    criteria_data = [
                     {:specifier => :all, :field => :patch, :meaning => :interesting, :match => '/foo/' },
                     {:specifier => :any, :field => :file, :meaning => :uninteresting, :match => '/bar/' }
                    ]

    config = double("config")
    PreReviewer::Config.should_receive(:instance).and_return( config )
    criteria = PreReviewer::Criteria.new
    # test that it finds the appropriate criteria file from the config
    config.should_receive( :criteria ).and_return( criteria_data )
    criteria_data.each do | criteria_hash |
      PreReviewer::Criterion.should_receive(:new).with( criteria_hash ).and_return( "criterion_obj1".to_sym )
    end
    # and stores all of those in an instance variable, so that it can get them all easily
    criteria.size.should == 2
  end


end

describe PreReviewer::Criteria, "each" do
  it "can receive a block to iterate over" do
    criteria_data = [
                     {:specifier => :all, :field => :patch, :meaning => :interesting, :match => '/foo/' },
                     {:specifier => :any, :field => :file, :meaning => :uninteresting, :match => '/bar/' }
                    ]

    config = double("config")
    PreReviewer::Config.stub(:instance).and_return( config )
    criteria = PreReviewer::Criteria.new
    # test that it finds the appropriate criteria file from the config
    config.stub( :criteria ).and_return( criteria_data )
    i = 1
    criteria_data.each do | criteria_hash |
      PreReviewer::Criterion.stub(:new).with( criteria_hash ).and_return( "criterion_obj#{i}".to_sym )
      i += 1
    end
    i = 1
    criteria.each do |criterion|
      criterion.should == "criterion_obj#{i}".to_sym
      i += 1
    end
  end

  it "can return the next criterion without a block" do
    criteria_data = [
                     {:specifier => :all, :field => :patch, :meaning => :interesting, :match => '/foo/' },
                     {:specifier => :any, :field => :file, :meaning => :uninteresting, :match => '/bar/' }
                    ]

    config = double("config")
    PreReviewer::Config.stub(:instance).and_return( config )
    criteria = PreReviewer::Criteria.new
    # test that it finds the appropriate criteria file from the config
    config.stub( :criteria ).and_return( criteria_data )
    i = 1
    criteria_data.each do | criteria_hash |
      PreReviewer::Criterion.stub(:new).with( criteria_hash ).and_return( "criterion_obj#{i}".to_sym )
      i += 1
    end
    criteria_iterator = criteria.each
    criterion1 = criteria_iterator.next
    criterion1.should == :criterion_obj1
  end
end
