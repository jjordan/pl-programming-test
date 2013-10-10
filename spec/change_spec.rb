# prereviewer::change

require 'change'

describe PreReviewer::Change, "new" do
  it "knows its filename and patch" do
    my_hash = {
      'filename' => 'spec/unit/provider/package/rpm_spec.rb',
      'patch' => '@@ -134,7 +134,7 @@\n \n     describe \"when not already installed\" do',
    }
    change = PreReviewer::Change.new( my_hash )
    change.filename.should == 'spec/unit/provider/package/rpm_spec.rb'
    change.patch.should == '@@ -134,7 +134,7 @@\n \n     describe \"when not already installed\" do'

  end
end

describe PreReviewer::Change, "render" do
  it "can output where a match was made" do
    my_hash = {
      'filename' => 'spec/unit/provider/package/rpm_spec.rb',
      'patch' => '@@ -134,7 +134,7 @@\n \n     describe \"when not already installed\" do',
    }
    criteria = double("criteria")
    criteria.should_receive( :regexp ).and_return( Regexp.new(/\bdescribe\b/) )
    criteria.should_receive( :field ).and_return( :patch )
    criteria.should_receive( :component ).and_return( :change )
    criteria.should_receive( :specifier ).and_return( :any )
    criteria.should_receive( :meaning ).and_return( :interesting )
    change = PreReviewer::Change.new( my_hash )
    change.render(criteria).should == 'matched: @@ -134,7 +134,7 @@\n \n     describe \"when not already installed\" do'

    criteria2 = double("criteria2")
    criteria2.should_receive( :regexp ).and_return( Regexp.new(/\bprovider\/\b/) )
    criteria2.should_receive( :field ).twice.and_return( :filename )
    criteria2.should_receive( :component ).and_return( :change )
    criteria2.should_receive( :specifier ).and_return( :any )
    criteria2.should_receive( :meaning ).and_return( :interesting )
    change = PreReviewer::Change.new( my_hash )
    change.render(criteria2).should == 'matched: spec/unit/provider/package/rpm_spec.rb'

  end

  it "returns nil when no match is made" do
    my_hash = {
      'filename' => 'spec/unit/provider/package/rpm_spec.rb',
      'patch' => '@@ -134,7 +134,7 @@\n \n     describe \"when not already installed\" do',
    }
    criteria = double("criteria")
    criteria.should_receive( :regexp ).and_return( Regexp.new(/\balphabet\b/) )
    criteria.should_receive( :field ).and_return( :patch )
    criteria.should_receive( :component ).and_return( :change )
    criteria.should_receive( :specifier ).and_return( :any )
    criteria.should_receive( :meaning ).and_return( :interesting )
    change = PreReviewer::Change.new( my_hash )
    change.render(criteria).should == nil
  end

  it "returns nil when not applicable" do
    my_hash = {
      'filename' => 'spec/unit/provider/package/rpm_spec.rb',
      'patch' => '@@ -134,7 +134,7 @@\n \n     describe \"when not already installed\" do',
    }
    criteria = double("criteria")
    criteria.should_receive( :component ).and_return( :pull_request )
    change = PreReviewer::Change.new( my_hash )
    change.render(criteria).should == nil
  end


end

