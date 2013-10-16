# prereviewer

require 'pullrequest'
require 'change'
require 'config'
require 'fetcher'

describe PreReviewer::PullRequest, "initialize" do
  it "knows its account, name, state and number" do
    config = double("config")
    request = double("request")
    request.should_receive( :account ).and_return('puppetlabs')
    request.should_receive( :repo ).and_return('puppet')
    PreReviewer::Config.should_receive( :instance ).and_return( config )
    pull = PreReviewer::PullRequest.new( request, {"number" => 1521, "state" => "open"} )
    pull.account.should == 'puppetlabs'
    pull.name.should == 'puppet'
    pull.number.should == 1521
    pull.state.should == "open"
  end

end

describe PreReviewer::PullRequest, "changes" do
  it "returns a set of change objects" do
    config = double("config")
    request = double("request")
    fetcher = double("fetcher")

    request.stub( :account ).and_return('puppetlabs')
    request.stub( :repo ).and_return('puppet')
    PreReviewer::Fetcher.should_receive( :new ).and_return( fetcher )
    config.should_receive( :change_api ).with( 'puppetlabs', 'puppet', 1522 ).and_return( :api_url )
    fetcher.should_receive( :fetch ).with( :api_url ).and_return( [{}] )
    PreReviewer::Config.stub( :instance ).and_return( config )
    pull = PreReviewer::PullRequest.new( request, {"number" => 1522} )
    change = double("change")
    PreReviewer::Change.should_receive( :new ).with( {} ).and_return( change )
    changes = pull.changes
    pull.is_interesting = true
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
    request.stub( :repo ).and_return('puppet')
    pull_number = 1523
    config.should_receive( :html_root ).twice.and_return('https://github.com')
    PreReviewer::Config.stub( :instance ).and_return( config )
    pull = PreReviewer::PullRequest.new( request, {"number" => pull_number} )
    pull.is_interesting = true

    pull.render.should == "https://github.com/puppetlabs/puppet/pull/#{pull_number} - Interesting"
    pull.is_interesting = false
    pull.render.should == "https://github.com/puppetlabs/puppet/pull/#{pull_number} - Not Interesting"

  end
end

describe PreReviewer::PullRequest, "render_reason" do
  it "outputs nothing if the pull request is not interesting" do
    config = double("config")
    request = double("request")
    fetcher = double("fetcher")

    request.stub( :account ).and_return('puppetlabs')
    request.stub( :repo ).and_return('puppet')
    pull_number = 1523
    PreReviewer::Config.stub( :instance ).and_return( config )
    pull = PreReviewer::PullRequest.new( request, {"number" => pull_number} )
    pull.is_interesting = false
    criterion = double("criterion")
    response = pull.render_reason( criterion )
    response.should == nil
  end
  
  it "renders output for when no file names match a pattern" do
    config = double("config")
    request = double("request")
    fetcher = double("fetcher")

    request.stub( :account ).and_return('puppetlabs')
    request.stub( :repo ).and_return('puppet')
    pull_number = 1523
    PreReviewer::Config.stub( :instance ).and_return( config )
    pull = PreReviewer::PullRequest.new( request, {"number" => pull_number} )
    pull.is_interesting = true
    criterion = double("criterion")
    criterion.should_receive(:specifier).and_return( :none )
    criterion.should_receive(:field).and_return( :filename )
    criterion.should_receive(:match).and_return( :keyword )
    response = pull.render_reason( criterion )
    response.should == "\tno file names contained 'keyword'"
  end

  it "renders output for when all file names match a pattern" do
    config = double("config")
    request = double("request")
    fetcher = double("fetcher")

    request.stub( :account ).and_return('puppetlabs')
    request.stub( :repo ).and_return('puppet')
    pull_number = 1523
    PreReviewer::Config.stub( :instance ).and_return( config )
    pull = PreReviewer::PullRequest.new( request, {"number" => pull_number} )
    pull.is_interesting = true
    criterion = double("criterion")
    criterion.should_receive(:specifier).twice.and_return( :all )
    criterion.should_receive(:field).and_return( :filename )
    criterion.should_receive(:match).and_return( :keyword )
    response = pull.render_reason( criterion )
    response.should == "\tall file names contained 'keyword'"
  end

  it "renders output for when no patches match a pattern" do
    config = double("config")
    request = double("request")
    fetcher = double("fetcher")

    request.stub( :account ).and_return('puppetlabs')
    request.stub( :repo ).and_return('puppet')
    pull_number = 1523
    PreReviewer::Config.stub( :instance ).and_return( config )
    pull = PreReviewer::PullRequest.new( request, {"number" => pull_number} )
    pull.is_interesting = true
    criterion = double("criterion")
    criterion.should_receive(:specifier).and_return( :none )
    criterion.should_receive(:field).twice.and_return( :patch )
    criterion.should_receive(:match).and_return( :keyword )
    response = pull.render_reason( criterion )
    response.should == "\tno patches contained 'keyword'"
  end

  it "renders output for when all patches match a pattern" do
    config = double("config")
    request = double("request")
    fetcher = double("fetcher")

    request.stub( :account ).and_return('puppetlabs')
    request.stub( :repo ).and_return('puppet')
    pull_number = 1523
    PreReviewer::Config.stub( :instance ).and_return( config )
    pull = PreReviewer::PullRequest.new( request, {"number" => pull_number} )
    pull.is_interesting = true
    criterion = double("criterion")
    criterion.should_receive(:specifier).twice.and_return( :all )
    criterion.should_receive(:field).twice.and_return( :patch )
    criterion.should_receive(:match).and_return( :keyword )
    response = pull.render_reason( criterion )
    response.should == "\tall patches contained 'keyword'"
  end

end

