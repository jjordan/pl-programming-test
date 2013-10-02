# prereviewer::change

require 'change'

describe PreReviewer::Change, "new_from_hash" do
  it "knows its filename and patch" do
    my_hash = {
      'filename' => 'spec/unit/provider/package/rpm_spec.rb',
      'patch' => '@@ -134,7 +134,7 @@\n \n     describe \"when not already installed\" do',
    }
    change = PreReviewer::Change.new_from_hash( my_hash )
    change.filename.should == 'spec/unit/provider/package/rpm_spec.rb'
    change.patch.should == '@@ -134,7 +134,7 @@\n \n     describe \"when not already installed\" do'

  end
end

