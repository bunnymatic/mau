IPHONE_USER_AGENT = 'Mozilla/5.0 (iPhone; U; XXXXX like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A477c Safari/419.3'


describe 'a regular mobile page', :shared => true do
  it "includes the default header reading art is the mission" do
    response.should have_tag('[data-role=header]', :match => /art is the mission/i)
  end
  it "uses the welcome mobile layout" do
    response.layout.should == 'layouts/mobile'
  end
  it "has the content" do
    response.should have_tag('[data-role=content]', :count => 1)
  end
end

