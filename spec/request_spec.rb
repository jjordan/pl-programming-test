require 'request'

describe PreReviewer::Request, "initialize" do
  it "can find the account and repo name in the arguments" do
    args = ['puppetlabs/puppet']
    req = PreReviewer::Request.new( args )
    req.account.should == 'puppetlabs'
    req.repo.should == 'puppet'
  end
end
