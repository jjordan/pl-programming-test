require 'fetcher'
require 'httparty'

describe PreReviewer::Fetcher, "fetch" do

  it "gets the target URL with optional additions from the config" do
    config = double("config")
    url = 'http://www.google.com'
    response = double("response")
    HTTParty.should_receive(:get).with( url ).and_return( response )
    response.should_receive(:body).and_return( :body )
    JSON.should_receive( :parse ).with( :body ).and_return( :response )
    PreReviewer::Config.should_receive(:instance).and_return( config )
    fetcher = PreReviewer::Fetcher.new
    config.should_receive( :extra_params ).and_return( nil )
    response = fetcher.fetch( url )
    response.should == :response
  end

  it "should attach the optional parameters if any are in the config" do
    config = double("config")
    PreReviewer::Config.stub(:instance).and_return( config )
    fetcher = PreReviewer::Fetcher.new
    url = 'http://www.google.com'
    param = 'access_token'
    value = 'l2k3jlkj32l3k4'
    token_param = "?%s=%s" % [param, value]
    config.should_receive( :extra_params ).twice.and_return( {param => value} )
    response = double("response")
    HTTParty.should_receive(:get).with( url + token_param ).and_return( response )
    response.should_receive(:body).and_return( :body )
    JSON.should_receive( :parse ).with( :body ).and_return( :response )
    output_response = fetcher.fetch( url )
  end

end
