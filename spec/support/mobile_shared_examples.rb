IPHONE_USER_AGENT = 'Mozilla/5.0 (iPhone; U; XXXXX like Mac OS X; en)'+
  ' AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A477c'+
  ' Safari/419.3' unless defined? IPHONE_USER_AGENT

shared_examples_for 'a regular mobile page' do
  it "includes the default header reading art is the mission" do
    assert_select('[data-role=header]', :match => /art is the mission/i)
  end
  it "has the content" do
    assert_select('[data-role=content]', :count => 1)
  end
  it "has jquery-mobile page entry" do
    assert_select('div[data-role=page]', :count => 1)
  end
  it "has footer" do
    assert_select('div[data-role=footer]', :count => 1)
    assert_select('.news-footer', :count => 1)
  end
end

shared_examples_for 'non-welcome mobile page' do
  it "uses the mobile layout" do
    expect(response).to render_template 'layouts/mobile'
  end
end

