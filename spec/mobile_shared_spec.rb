

describe 'a regular mobile page', :shared => true do
  it "includes the default header reading art is the mission" do
    response.should have_tag('.m-header', :match => /art is the mission/i)
  end
  it "uses the welcome mobile layout" do
    response.layout.should == 'layouts/mobile'
  end
  it "has the footer" do
    response.should have_tag('.m-footer', :count => 1)
  end
  it "has the content" do
    response.should have_tag('.m-content', :count => 1)
  end
end

