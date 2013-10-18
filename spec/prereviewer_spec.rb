# prereviewer

require 'prereviewer'
require 'fileutils'
require 'pathname'
#require 'httparty'
#require 'fakefs'
HOMEDIR = Pathname.new('/tmp/user/')
BASE_PATH = Pathname(__FILE__).parent.dirname.realpath

describe PreReviewer::Main, "initialize" do
  # todo: either get this working with fakefs or
  # use tempfile so that the files won't clobber each other
  # if run concurrently
  before(:all) do
    FileUtils.mkdir_p( HOMEDIR )
  end

  after(:all) do
    FileUtils.rmdir( HOMEDIR )    
  end

  before(:each) do
    FileUtils.rm(HOMEDIR + '.prereviewer/config.yml') if( File.exist?(HOMEDIR + '.prereviewer/config.yml'))
    FileUtils.rmdir( HOMEDIR + '.prereviewer' ) if( File.exist?(HOMEDIR + '.prereviewer'))

    FileUtils.rm(HOMEDIR + 'conf/config.yml') if( File.exist?(HOMEDIR + 'conf/config.yml'))
    FileUtils.rmdir( HOMEDIR + 'conf' ) if( File.exist?(HOMEDIR + 'conf'))

  end

  it "can create a config object, request object, repo object, and load the criteria" do
    expected_path = BASE_PATH + 'default/config.yml'
    args = ['puppetlabs/puppet']
    ARGV.should_receive( :dup ).and_return(args)
    ENV.should_receive(:[]).with('HOME').and_return(HOMEDIR)
    PreReviewer::Config.should_receive( :load ).with( expected_path )
    PreReviewer::Config.should_receive( :instance).and_return( :config )

    PreReviewer::Request.should_receive(:new).with(args).and_return( :request )
    PreReviewer::Repository.should_receive(:new).with( :request )
    PreReviewer::Criteria.should_receive(:new)
    PreReviewer::Main.new
  end

  it "can create a config object from the user's config file" do
    args = ['puppetlabs/puppet']
    ARGV.should_receive( :dup ).and_return(args)
    ENV.should_receive(:[]).with('HOME').and_return(HOMEDIR)
    FileUtils.mkdir_p( HOMEDIR + '.prereviewer' )
    FileUtils.touch(HOMEDIR + '.prereviewer/config.yml')
    PreReviewer::Config.should_receive( :load ).with( HOMEDIR + '.prereviewer/config.yml' )
    PreReviewer::Config.should_receive( :instance ).and_return( :config )

    PreReviewer::Request.stub(:new).with(args).and_return( :request )
    PreReviewer::Repository.stub(:new).with( :request )
    PreReviewer::Criteria.stub(:new)

    PreReviewer::Main.new
  end

  it "can create a config object from a specific file" do
    specific_config = HOMEDIR + 'conf/config.yml'
    args = ['puppetlabs/puppet', specific_config.to_s]
    FileUtils.mkdir_p( HOMEDIR + 'conf' )
    FileUtils.touch(HOMEDIR + 'conf/config.yml')
    ARGV.should_receive( :dup ).and_return(args)
    PreReviewer::Config.should_receive( :load ).with( specific_config )
    PreReviewer::Config.should_receive( :instance ).and_return( :config )

    PreReviewer::Request.stub(:new).with(args).and_return( :request )
    PreReviewer::Repository.stub(:new).with( :request )
    PreReviewer::Criteria.stub(:new)

    PreReviewer::Main.new
  end

end

describe PreReviewer::Main, "run" do
  it "applies criteria to each pull" do
    expected_path = BASE_PATH + 'default/config.yml'
    args = ['puppetlabs/puppet']
    ARGV.stub( :dup ).and_return(args)
    ENV.stub(:[]).with('HOME').and_return(HOMEDIR)
    PreReviewer::Config.stub( :load ).with( expected_path )
    PreReviewer::Config.stub( :instance ).and_return( :config )

    repo = double("repo")
    criterion1 = double("criterion 1")
    criterion2 = double("criterion 2")
    PreReviewer::Request.stub(:new).with(args).and_return( :request )
    PreReviewer::Repository.stub(:new).with( :request ).and_return( repo )
    PreReviewer::Criteria.stub(:new).and_return([criterion1, criterion2])
    pr = PreReviewer::Main.new
    pull1 = double("pull 1")
    pull2 = double("pull 2")

    repo.should_receive(:pulls).and_return([pull1, pull2])
    criterion1.should_receive(:apply).with( pull1 )
    criterion1.should_receive(:apply).with( pull2 )
    criterion2.should_receive(:apply).with( pull1 )
    criterion2.should_receive(:apply).with( pull2 )
    criterion1.should_receive(:applied?).twice.and_return( true )
    criterion2.should_receive(:applied?).twice.and_return( false )
    change1 = double("change 1")
    change2 = double("change 2")
    change1.should_receive( :render ).with( criterion1 ).and_return( :content )
    change1.should_receive( :render ).with( criterion2 ).and_return( :content )
    change2.should_receive( :render ).with( criterion1 ).and_return( :content )
    change2.should_receive( :render ).with( criterion2 ).and_return( :content )
    pull1.should_receive( :changes ).twice.and_return([change1, change2])
    pull1.should_receive( :render )
    pull1.should_receive( :render_reason ).with( criterion1 ).and_return(:output)
    pull2.should_receive( :render )
    pull2.should_receive( :render_reason ).with( criterion1 ).and_return(:output)
    pull2.should_receive( :changes ).twice.and_return([])
    # not sure how to mock 'puts':
    $stdout = File.open "/dev/null", "a"
    pr.run
    $stdout.close
    $stdout = STDOUT
  end
end

describe PreReviewer::Main, "usage" do
  it "can return the appropriate usage information" do
    args = []
    ARGV.stub( :dup ).and_return(args)
    pr = PreReviewer::Main.new
    pr.usage.should == "Usage: #{$0}: ACCOUNT/REPOSITORY [/path/to/config.yml]"
    pr.has_error?.should == true
  end
end
