# prereviewer::criterion

require 'criterion'

def bound_and_escape( keyword )
  '\b' + Regexp.escape( keyword ) + '\b'
end

describe PreReviewer::Criterion, "initialize" do
  it "knows what its fields are" do    
    criterion = PreReviewer::Criterion.new({:specifier => :all, :field => :filename, :meaning => :interesting, :match => 'spec'})
    criterion.specifier.should == :all
    criterion.field.should == :filename
    criterion.meaning.should == :interesting
    criterion.match.should == Regexp.new(bound_and_escape('spec') )
  end

end

describe PreReviewer::Criterion, "apply" do

  it "can find any matches in the filename" do 
    pull_request = double("pull request")
    change = double("change")
    change2 = double("change 2")
    pull_request.should_receive( :changes ).and_return( [change, change2] )
    pull_request.should_receive( :is_interesting= ).with( true )
    change.should_receive(:filename).and_return('Gemfile')
    change2.should_receive(:filename).and_return('Rakefile')
    criterion = PreReviewer::Criterion.new({:specifier => :any, :field => :filename, :meaning => :interesting, :match => 'Gemfile'})
    criterion.apply( pull_request )
    criterion.applied?.should == true
  end

  it "can find any matches in the patch" do 
    pull_request = double("pull request")
    change = double("change")
    change2 = double("change 2")
    pull_request.should_receive( :changes ).and_return( [change, change2] )
    pull_request.should_receive( :is_interesting= ).with( true )
    change.should_receive(:patch).and_return(<<EOS
@@ -134,7 +134,7 @@\n \n     describe \"when not already installed %x\" do\n       it \"should only include the '-i' flag\" do\n-        Puppet::Util::Execution.expects(:execute).with([\"/bin/rpm\", \"-i\", '/path/to/package'], execute_options)\n+        Puppet::Util::Execution.expects(:execute).with([\"/bin/rpm\", [\"-i\"], '/path/to/package'], execute_options)\n         provider.install\n       end\n    end
EOS
)
    change2.should_receive(:patch).and_return('@@ -187,3 + 187,3 @@\n+haptic baloney dancers\n+are nice\n+at twice the price.\n')
    criterion = PreReviewer::Criterion.new({:specifier => :any, :field => :patch, :meaning => :interesting, :match => '%x'})
    criterion.apply( pull_request )
    criterion.applied?.should == true
  end

  it "can find all matches in the filenames" do
    pull_request = double("pull request")
    change = double("change")
    change2 = double("change 2")
    pull_request.should_receive( :changes ).and_return( [change, change2] )
    change.should_receive(:filename).and_return('Gemfile')
    change2.should_receive(:filename).and_return('Rakefile')
    criterion = PreReviewer::Criterion.new({:specifier => :all, :field => :filename, :meaning => :interesting, :match => 'Gemfile'})
    criterion.apply( pull_request )
    criterion.applied?.should == false

    # positive test
    pull_request = double("pull request")
    change = double("change")
    change2 = double("change 2")
    pull_request.should_receive( :is_interesting= ).with( true )
    pull_request.should_receive( :changes ).and_return( [change, change2] )
    change.should_receive(:filename).and_return('Gemfile')
    change2.should_receive(:filename).and_return('Gemfile')
    criterion = PreReviewer::Criterion.new({:specifier => :all, :field => :filename, :meaning => :interesting, :match => 'Gemfile'})
    criterion.apply( pull_request )
    criterion.applied?.should == true
  end

  it "can find all matches in the patches" do
    pull_request = double("pull request")
    change = double("change")
    change2 = double("change 2")
    pull_request.should_receive( :changes ).and_return( [change, change2] )
    change.should_receive(:patch).and_return(<<EOS
@@ -134,7 +134,7 @@\n \n     describe \"when not already installed %x\" do\n       it \"should only include the '-i' flag\" do\n-        Puppet::Util::Execution.expects(:execute).with([\"/bin/rpm\", \"-i\", '/path/to/package'], execute_options)\n+        Puppet::Util::Execution.expects(:execute).with([\"/bin/rpm\", [\"-i\"], '/path/to/package'], execute_options)\n         provider.install\n       end\n    end
EOS
)
    change2.should_receive(:patch).and_return('@@ -187,3 + 187,3 @@\n+haptic baloney dancers\n+are nice\n+at twice the prie.\n')
    criterion = PreReviewer::Criterion.new({:specifier => :all, :field => :patch, :meaning => :interesting, :match => '%x'})
    criterion.apply( pull_request )
    criterion.applied?.should == false

    # positive test
    pull_request = double("pull request")
    change = double("change")
    change2 = double("change 2")
    pull_request.should_receive( :changes ).and_return( [change, change2] )
    pull_request.should_receive( :is_interesting= ).with( true )
    change.should_receive(:patch).and_return(<<EOS
@@ -134,7 +134,7 @@\n \n     describe \"when not already installed %x\" do\n       it \"should only include the '-i' flag\" do\n-        Puppet::Util::Execution.expects(:execute).with([\"/bin/rpm\", \"-i\", '/path/to/package'], execute_options)\n+        Puppet::Util::Execution.expects(:execute).with([\"/bin/rpm\", [\"-i\"], '/path/to/package'], execute_options)\n         provider.install\n       end\n    end
EOS
)
    change2.should_receive(:patch).and_return('@@ -187,3 + 187,3 @@\n+haptic baloney dancers\n+are nice\n+at twice the price %x.\n')
    criterion = PreReviewer::Criterion.new({:specifier => :all, :field => :patch, :meaning => :interesting, :match => '%x'})
    criterion.apply( pull_request )
    criterion.applied?.should == true
  end

  it "can find no matches in the filenames" do
    pull_request = double("pull request")
    change = double("change")
    change2 = double("change 2")
    pull_request.should_receive( :is_interesting= ).with( true )
    pull_request.should_receive( :changes ).and_return( [change, change2] )
    change.should_receive(:filename).and_return('.gemspec')
    change2.should_receive(:filename).and_return('Rakefile')
    criterion = PreReviewer::Criterion.new({:specifier => :none, :field => :filename, :meaning => :interesting, :match => 'Gemfile'})
    criterion.apply( pull_request )
    criterion.applied?.should == true

    # negative test
    pull_request = double("pull request")
    change = double("change")
    change2 = double("change 2")
    pull_request.should_receive( :changes ).and_return( [change, change2] )
    change.should_receive(:filename).and_return('Gemfile')
    change2.should_receive(:filename).and_return('Rakefile')
    criterion = PreReviewer::Criterion.new({:specifier => :none, :field => :filename, :meaning => :interesting, :match => 'Gemfile'})
    criterion.apply( pull_request )
    criterion.applied?.should == false

  end

  it "can find no matches in the patches (miss)" do
    pull_request = double("pull request")
    change = double("change")
    change2 = double("change 2")
    pull_request.should_receive( :changes ).and_return( [change, change2] )
    change.should_receive(:patch).and_return(<<EOS
@@ -134,7 +134,7 @@\n \n     describe \"when not already installed %x\" do\n       it \"should only include the '-i' flag\" do\n-        Puppet::Util::Execution.expects(:execute).with([\"/bin/rpm\", \"-i\", '/path/to/package'], execute_options)\n+        Puppet::Util::Execution.expects(:execute).with([\"/bin/rpm\", [\"-i\"], '/path/to/package'], execute_options)\n         provider.install\n       end\n    end
EOS
)
    change2.should_receive(:patch).and_return('@@ -187,3 + 187,3 @@\n+haptic baloney dancers\n+are nice\n+at twice the prie.\n')
    criterion = PreReviewer::Criterion.new({:specifier => :none, :field => :patch, :meaning => :interesting, :match => '%x'})
    criterion.apply( pull_request )
    criterion.applied?.should == false
  end

  it "can find no matches in the patches (match)" do
    # positive test
    pull_request = double("pull request")
    change = double("change")
    change2 = double("change 2")
    pull_request.should_receive( :changes ).and_return( [change, change2] )
    pull_request.should_receive( :is_interesting= ).with( true )
    change.should_receive(:patch).and_return(<<EOS
@@ -134,7 +134,7 @@\n \n     describe \"when not already installed\" do\n       it \"should only include the '-i' flag\" do\n-        Puppet::Util::Execution.expects(:execute).with([\"/bin/rpm\", \"-i\", '/path/to/package'], execute_options)\n+        Puppet::Util::Execution.expects(:execute).with([\"/bin/rpm\", [\"-i\"], '/path/to/package'], execute_options)\n         provider.install\n       end\n    end
EOS
)
    change2.should_receive(:patch).and_return('@@ -187,3 + 187,3 @@\n+haptic baloney dancers\n+are nice\n+at twice the prie.\n')
    criterion = PreReviewer::Criterion.new({:specifier => :none, :field => :patch, :meaning => :interesting, :match => '%x'})
    criterion.apply( pull_request )
    criterion.applied?.should == true
    criterion.matched?.should == true
  end

end
