# PreReviewer project repo spec

require 'config'
require 'fetcher'
require 'repository'
require 'pullrequest'
#require 'httparty'
require 'json'

describe PreReviewer::Repository, "initialization" do
  it "knows it's name and account" do
    request = double("request")
    request.should_receive( :account ).and_return('puppetlabs')
    request.should_receive( :repo ).and_return('puppet')
    pr = PreReviewer::Repository.new( request )
    pr.name.should eq("puppet")
    pr.account.should eq("puppetlabs")
  end
end

describe PreReviewer::Repository, "pulls" do
  it "can fetch all pulls with a default state" do
    request = double("request")
    config = double("config")
    fetcher = double("fetcher")
    pull_object = double( "pull request" )
    pull_object2 = double( "pull request2" )
    PreReviewer::Fetcher.should_receive(:new).and_return( fetcher )
    PreReviewer::Config.should_receive(:instance).and_return( config )
    config.should_receive(:pull_api).with( 'puppetlabs', 'puppet' ).and_return( :api_url )
    request.stub( :account ).and_return('puppetlabs')
    request.stub( :repo ).and_return('puppet')
    pr = PreReviewer::Repository.new( request )
    pull_data = [{"state" => 'open'}, {"state" => 'closed'}]
    fetcher.should_receive( :fetch ).with( :api_url ).and_return(pull_data)
    pull_object.should_receive(:state).and_return( 'open' )
    pull_object2.should_receive(:state).and_return( 'closed' )
    PreReviewer::PullRequest.should_receive( :new ).with( request, pull_data[0] ).and_return( pull_object )
    PreReviewer::PullRequest.should_receive( :new ).with( request, pull_data[1] ).and_return( pull_object2 )

    pulls = pr.pulls # default state is 'open'
    pulls.should eq([pull_object])
  end

  it "if pull state is nil, returns all pulls" do
    request = double("request")
    config = double("config")
    fetcher = double("fetcher")
    request.stub( :account ).and_return('puppetlabs')
    request.stub( :repo ).and_return('puppet')
    PreReviewer::Fetcher.should_receive(:new).and_return( fetcher )
    PreReviewer::Config.should_receive(:instance).and_return( config )
    pr = PreReviewer::Repository.new( request )
    pulls = [{"state" => 'open'}, {"state" => 'closed'}]
    pull_object = double( "pull request" )
    pull_object2 = double( "closed pull" )
    PreReviewer::PullRequest.stub( :new ).with( request, pulls[0]).and_return( pull_object )
    PreReviewer::PullRequest.stub( :new ).with( request, pulls[1]).and_return( pull_object2 )
    pull_object.stub(:state).and_return( 'open' )
    pull_object2.stub(:state).and_return( 'closed' )
    config.stub(:pull_api).and_return( :api_url )
    fetcher.stub( :fetch ).and_return(pulls)
 
    pr.pull_state = nil
    pulls = pr.pulls # default state is 'open'
    pulls.should eq([pull_object, pull_object2])
  end

end


