# prereviewer

require 'pullrequest'
require 'change'

describe PreReviewer::PullRequest, "new_from_hash" do
  it "knows its account, name and number" do
    config = double("config")
    request = double("request")
    request.should_receive( :account ).and_return('puppetlabs')
    request.should_receive( :name ).and_return('puppet')
    pull = PreReviewer::PullRequest.new_from_hash( config, request, {"number" => 1521} )
    pull.account.should == 'puppetlabs'
    pull.name.should == 'puppet'
    pull.number.should == 1521
  end

end

describe PreReviewer::PullRequest, "fetch_changes" do
  it "returns a set of change objects" do
    config = double("config")
    request = double("request")
    fetcher = double("fetcher")

    request.stub( :account ).and_return('puppetlabs')
    request.stub( :name ).and_return('puppet')
    config.should_receive( :fetcher ).and_return( fetcher )
    config.should_receive( :change_api ).with( 'puppetlabs', 'puppet', 1522 ).and_return( :api_url )
    fetcher.should_receive( :get ).with( :api_url ).and_return( [{}] )
    pull = PreReviewer::PullRequest.new_from_hash( config, request, {"number" => 1522} )
    change = double("change")
    PreReviewer::Change.should_receive( :new_from_hash ).with( {} ).and_return( change )
    changes = pull.fetch_changes
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
    pull = PreReviewer::PullRequest.new_from_hash( config, request, {"number" => pull_number} )
    pull.render.should == "https://github.com/puppetlabs/puppet/pull/#{pull_number} - Interesting"
    pull.is_interesting = false
    pull.render.should == "https://github.com/puppetlabs/puppet/pull/#{pull_number} - Not Interesting"

  end
end

