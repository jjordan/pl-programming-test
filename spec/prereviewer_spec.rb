# prereviewer

require 'prereviewer'
require 'fileutils'
require 'pathname'
require 'httparty'
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
    Configurability::Config.should_receive( :load ).with( expected_path ).and_return( :config )
    Configurability.should_receive( :configure_objects ).with( :config )

    PreReviewer::Request.should_receive(:new).with(args).and_return( :request )
    PreReviewer::ProjectRepo.should_receive(:new).with( :request )
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
    PreReviewer::ProjectRepo.stub(:new).with( :request )
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
    PreReviewer::ProjectRepo.stub(:new).with( :request )
    PreReviewer::Criteria.stub(:new).with(:config)

    PreReviewer::Main.new
  end

end

describe PreReviewer::Main, "run" do
  it "applies criteria to each pull" do
    expected_path = BASE_PATH + 'default/config.yml'
    args = ['puppetlabs/puppet']
    ARGV.stub( :dup ).and_return(args)
    ENV.stub(:[]).with('HOME').and_return(HOMEDIR)
    Configurability::Config.stub( :load ).with( expected_path ).and_return( :config )
    Configurability.stub( :configure_objects ).with( :config )

    repo = double("repo")
    criterion1 = double("criterion 1")
    criterion2 = double("criterion 2")
    PreReviewer::Request.stub(:new).with(args).and_return( :request )
    PreReviewer::ProjectRepo.stub(:new).with( :request ).and_return( repo )
    PreReviewer::Criteria.stub(:new).with(:config).and_return([criterion1, criterion2])
    pr = PreReviewer::Main.new
    pull1 = double("pull 1")
    pull2 = double("pull 2")

    repo.should_receive(:pulls).and_return([pull1, pull2])
    criterion1.should_receive(:apply).with( pull1 )
    criterion1.should_receive(:apply).with( pull2 )
    criterion2.should_receive(:apply).with( pull1 )
    criterion2.should_receive(:apply).with( pull2 )

    pull1.should_receive( :render )
    pull2.should_receive( :render )
    pr.run
  end
end
