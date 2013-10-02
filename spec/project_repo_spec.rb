# PreReviewer project repo spec

require 'project_repo'
require 'pullrequest'
require 'httparty'
require 'json'

describe PreReviewer::ProjectRepo, "fetching pulls" do
  it "knows it's name and account" do
    request = double("request")
    config = double("config")
    request.should_receive( :account ).and_return('puppetlabs')
    request.should_receive( :repo ).and_return('puppet')
    pr = PreReviewer::ProjectRepo.new( config, request )
    pr.name.should eq("puppet")
    pr.account.should eq("puppetlabs")
  end

  it "can fetch all pulls with a default state" do
    request = double("request")
    config = double("config")
    fetcher = double("fetcher")
    pull_object = double( "pull request" )
    pull_object2 = double( "pull request2" )
    config.should_receive(:fetcher).and_return( fetcher )
    config.should_receive(:pull_api).with( 'puppetlabs', 'puppet' ).and_return( :api_url )
    request.stub( :account ).and_return('puppetlabs')
    request.stub( :repo ).and_return('puppet')
    pr = PreReviewer::ProjectRepo.new( config, request )
    pull_data = [{"state" => 'open'}, {"state" => 'closed'}]
    fetcher.should_receive( :get ).with( :api_url ).and_return(pull_data)
    pull_object.should_receive(:state).and_return( 'open' )
    pull_object2.should_receive(:state).and_return( 'closed' )
    PreReviewer::PullRequest.should_receive( :new_from_hash ).with( pull_data[0] ).and_return( pull_object )
    PreReviewer::PullRequest.should_receive( :new_from_hash ).with( pull_data[1] ).and_return( pull_object2 )

    pulls = pr.fetch_pulls # default state is 'open'
    pulls.should eq([pull_object])
  end

  it "if pull state is nil, returns all pulls" do
   #  request = double("request")
   #  config = double("config")
   #  fetcher = double("fetcher")
   #  request.stub( :account ).and_return('puppetlabs')
   #  request.stub( :repo ).and_return('puppet')
   #  pr = PreReviewer::ProjectRepo.new( config, request )
   #  config.stub(:fetcher).and_return( fetcher )
   #  pulls = [{"state" => 'open'}, {"state" => 'closed'}]
   #  pull_object = double( "pull request" )
   #  pull_object2 = double( "closed pull" )
   #  PreReviewer::PullRequest.stub( :load_from_json ).and_return( [pull_object, pull_object2] )
   #  pull_object.stub(:state).and_return( 'open' )
   #  pull_object2.stub(:state).and_return( 'closed' )
   #  config.stub(:pull_api).and_return( :api_url )
   #  fetcher.stub( :get ).and_return(pulls)
 
   # pr.pull_state = nil
   #  pulls = pr.fetch_pulls # default state is 'open'
   #  pulls.should eq([pull_object, pull_object2])
  end

end


