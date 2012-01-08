IPHONE_USER_AGENT = 'Mozilla/5.0 (iPhone; U; XXXXX like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A477c Safari/419.3' unless defined? IPHONE_USER_AGENT

describe 'a regular mobile page', :shared => true do
  it "includes the default header reading art is the mission" do
    response.should have_tag('[data-role=header]', :match => /art is the mission/i)
  end
  it "has the content" do
    response.should have_tag('[data-role=content]', :count => 1)
  end
  it "has jquery-mobile page entry" do
    response.should have_tag('div[data-role=page]', :count => 1)
  end
  it "has footer" do
    response.should have_tag('div[data-role=footer]', :count => 1)
    response.should have_tag('.news-footer', :count => 1)
  end
end

describe 'non-welcome mobile page', :shared => true do
  it "uses the mobile layout" do
    response.layout.should == 'layouts/mobile'
  end
end

