# PreReviewer project repo spec

require 'project_repo'
require 'httparty'
require 'json'

describe PreReviewer::ProjectRepo, "fetching pulls" do
  it "knows it's name and account" do
    account_repo = 'puppetlabs/puppet'
    config = double("config")
    pr = PreReviewer::ProjectRepo.new( config, account_repo )
    pr.name.should eq("puppet")
    pr.account.should eq("puppetlabs")
  end

  it "can fetch all pulls with a default state" do
    account_repo = 'puppetlabs/puppet'
    config = double("config")
    fetcher = double("fetcher")
    pr = PreReviewer::ProjectRepo.new( config, account_repo )
    expected_url = 'https://api.github.com/repos/puppetlabs/puppet/pulls'
    config.should_receive(:fetcher).and_return( fetcher )
    pulls = [{"state" => 'open'}, {"state" => 'closed'}]
    fetcher.should_receive( :get ).with( expected_url ).and_return(pulls)
    pulls = pr.fetch_pulls # default state is 'open'
    pulls.should eq([{"state" => 'open'}])
  end

  it "if pull state is nil, returns all pulls" do
    account_repo = 'puppetlabs/puppet'
    config = double("config")
    fetcher = double("fetcher")
    pr = PreReviewer::ProjectRepo.new( config, account_repo )
    config.stub(:fetcher).and_return( fetcher )
    pulls = [{"state" => 'open'}, {"state" => 'closed'}]
    fetcher.stub( :get ).and_return(pulls)
    pr.pull_state = nil
    pulls = pr.fetch_pulls # default state is 'open'
    pulls.should eq([{"state" => 'open'}, {"state" => 'closed'}])
  end

  it "creates a pull request object for each pull returned"
end


