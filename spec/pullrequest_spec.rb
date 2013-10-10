# prereviewer

require 'pullrequest'
require 'change'
require 'config'
require 'fetcher'

describe PreReviewer::PullRequest, "initialize" do
  it "knows its account, name and number" do
    config = double("config")
    request = double("request")
    request.should_receive( :account ).and_return('puppetlabs')
    request.should_receive( :name ).and_return('puppet')
    PreReviewer::Config.should_receive( :instance ).and_return( config )
    pull = PreReviewer::PullRequest.new( request, {"number" => 1521} )
    pull.account.should == 'puppetlabs'
    pull.name.should == 'puppet'
    pull.number.should == 1521
  end

end

describe PreReviewer::PullRequest, "changes" do
  it "returns a set of change objects" do
    config = double("config")
    request = double("request")
    fetcher = double("fetcher")

    request.stub( :account ).and_return('puppetlabs')
    request.stub( :name ).and_return('puppet')
    PreReviewer::Fetcher.should_receive( :new ).and_return( fetcher )
    config.should_receive( :change_api ).with( 'puppetlabs', 'puppet', 1522 ).and_return( :api_url )
    fetcher.should_receive( :fetch ).with( :api_url ).and_return( [{}] )
    PreReviewer::Config.stub( :instance ).and_return( config )
    pull = PreReviewer::PullRequest.new( request, {"number" => 1522} )
    change = double("change")
    PreReviewer::Change.should_receive( :new ).with( {} ).and_return( change )
    changes = pull.changes
    pull.is_interesting?.should == true
    pull.is_interesting = false
    pull.is_interesting?.should == false
  end
end

describe PreReviewer::PullRequest, "render" do
  it "outputs the html url and interesting state" do
    config = double("config")
    request = double("request")
    fetcher = double("fetcher")

    request.stub( :account ).and_return('puppetlabs')
    request.stub( :name ).and_return('puppet')
    pull_number = 1523
    config.should_receive( :html_root ).twice.and_return('https://github.com')
    PreReviewer::Config.stub( :instance ).and_return( config )
    pull = PreReviewer::PullRequest.new( request, {"number" => pull_number} )
    pull.render.should == "https://github.com/puppetlabs/puppet/pull/#{pull_number} - Interesting"
    pull.is_interesting = false
    pull.render.should == "https://github.com/puppetlabs/puppet/pull/#{pull_number} - Not Interesting"

  end
end

