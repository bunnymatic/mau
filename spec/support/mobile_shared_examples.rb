IPHONE_USER_AGENT = 'Mozilla/5.0 (iPhone; U; XXXXX like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A477c Safari/419.3' unless defined? IPHONE_USER_AGENT

shared_examples_for 'a regular mobile page' do
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

shared_examples_for 'non-welcome mobile page' do
  it "uses the mobile layout" do
    response.layout.should == 'layouts/mobile'
  end
end

