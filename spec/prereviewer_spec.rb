# prereviewer

require 'prereviewer'
require 'fileutils'
require 'pathname'
#require 'fakefs'
HOMEDIR = Pathname.new('/tmp/user/')
BASE_PATH = Pathname(__FILE__).parent.dirname.realpath

describe PreReviewer::Main, "initialize" do
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
    Configurability::Config.should_receive( :load ).with( expected_path ).and_return( :config )
    Configurability.should_receive( :configure_objects ).with( :config )

    PreReviewer::Request.should_receive(:new).with(args).and_return( :request )
    PreReviewer::ProjectRepo.should_receive(:new).with( :config, :request )
    PreReviewer::Criteria.should_receive(:new).with(:config)
    PreReviewer::Main.new
  end

  it "can create a config object from the user's config file" do
    args = ['puppetlabs/puppet']
    ARGV.should_receive( :dup ).and_return(args)
    ENV.should_receive(:[]).with('HOME').and_return(HOMEDIR)
    FileUtils.mkdir_p( HOMEDIR + '.prereviewer' )
    FileUtils.touch(HOMEDIR + '.prereviewer/config.yml')
    Configurability::Config.should_receive( :load ).with( HOMEDIR + '.prereviewer/config.yml' ).and_return( :config )
    Configurability.should_receive( :configure_objects ).with( :config )

    PreReviewer::Request.stub(:new).with(args).and_return( :request )
    PreReviewer::ProjectRepo.stub(:new).with( :config, :request )
    PreReviewer::Criteria.stub(:new).with(:config)

    PreReviewer::Main.new
  end

  it "can create a config object from a specific file" do
    specific_config = HOMEDIR + 'conf/config.yml'
    args = ['puppetlabs/puppet', specific_config.to_s]
    FileUtils.mkdir_p( HOMEDIR + 'conf' )
    FileUtils.touch(HOMEDIR + 'conf/config.yml')
    ARGV.should_receive( :dup ).and_return(args)
    Configurability::Config.should_receive( :load ).with( specific_config ).and_return( :config )
    Configurability.should_receive( :configure_objects ).with( :config )

    PreReviewer::Request.stub(:new).with(args).and_return( :request )
    PreReviewer::ProjectRepo.stub(:new).with( :config, :request )
    PreReviewer::Criteria.stub(:new).with(:config)

    PreReviewer::Main.new
  end

end

