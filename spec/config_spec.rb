require 'config'

CORRECT_CONFIG = {
  :criteria => [
                {:specifier => :all, :field => :filename, :meaning => :interesting, :match => 'spec'}
               ],
}

describe PreReviewer::Config, "load" do
  it "can load the config file" do
    YAML.should_receive(:load).with( :config_path ).and_return( CORRECT_CONFIG )
    PreReviewer::Config.load( :config_path )
  end
  it "throws an error if criteria section is missing" do
    expect {
      YAML.stub(:load).with( :config_path ).and_return( {:bloo => "blarf"} )
      PreReviewer::Config.load( :config_path )
    }.to raise_error
  end
end

describe PreReviewer::Config, "instance" do
  it "returns a singleton instance of the config" do
    YAML.stub(:load).with( :config_path ).and_return( CORRECT_CONFIG )
    PreReviewer::Config.load( :config_path )
    config = PreReviewer::Config.instance
    config2 = PreReviewer::Config.instance
    config.should === config2
  end
end

describe PreReviewer::Config, "change_api" do
  it "uses a default if change_api is missing" do
    YAML.stub(:load).with( :config_path ).and_return( CORRECT_CONFIG )
    PreReviewer::Config.load( :config_path )
    config = PreReviewer::Config.instance
    config.change_api( 'foo', 'bar', 123 ).should == 'https://api.github.com/repos/foo/bar/pulls/123/files'
  end
  it "uses the api_root and change_api sections in the config file if present" do
    new_config = CORRECT_CONFIG.dup
    new_config[:api_root] = 'https://api.github-mirror.com/repos/'
    new_config[:change_api] = '%s/%s/pullsx/%s/files'
    YAML.stub(:load).with( :config_path ).and_return( new_config )
    PreReviewer::Config.load( :config_path )
    config = PreReviewer::Config.instance
    config.change_api( 'foo', 'bar', 123 ).should == 'https://api.github-mirror.com/repos/foo/bar/pullsx/123/files'
  end

  it "appends the access token to the end of the URL if it is present" do
    new_config = CORRECT_CONFIG.dup
    access_token = '1324098as7dl12k3'
    new_config[:access_token] = access_token
    YAML.stub(:load).with( :config_path ).and_return( new_config )
    PreReviewer::Config.load( :config_path )
    config = PreReviewer::Config.instance
    config.change_api( 'foo', 'bar', 123 ).should == "https://api.github.com/repos/foo/bar/pulls/123/files?access_token=#{access_token}"
  end
end

describe PreReviewer::Config, "pull_api" do
  it "uses a default if pull_api is missing" do
    YAML.stub(:load).with( :config_path ).and_return( CORRECT_CONFIG )
    PreReviewer::Config.load( :config_path )
    config = PreReviewer::Config.instance
    config.pull_api( 'foo', 'bar' ).should == 'https://api.github.com/repos/foo/bar/pulls'
  end

  it "uses the api_root and pull_api sections in the config file if present" do
    new_config = CORRECT_CONFIG.dup
    new_config[:api_root] = 'https://api.github-mirror.com/repos/'
    new_config[:pull_api] = '%s/%s/pullsx'
    YAML.stub(:load).with( :config_path ).and_return( new_config )
    PreReviewer::Config.load( :config_path )
    config = PreReviewer::Config.instance
    config.pull_api( 'foo', 'bar' ).should == 'https://api.github-mirror.com/repos/foo/bar/pullsx'
  end
  it "appends the access token to the end of the URL if it is present" do
    new_config = CORRECT_CONFIG.dup
    access_token = '1324098as7dl12k3'
    new_config[:access_token] = access_token
    YAML.stub(:load).with( :config_path ).and_return( new_config )
    PreReviewer::Config.load( :config_path )
    config = PreReviewer::Config.instance
    config.pull_api( 'foo', 'bar' ).should == "https://api.github.com/repos/foo/bar/pulls?access_token=#{access_token}"
  end

end

describe PreReviewer::Config, "method_missing" do
  it "converts config sections into methods"
end

