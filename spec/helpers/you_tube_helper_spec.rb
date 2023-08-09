require 'rails_helper'

describe YouTubeHelper do
  it 'renders a you tube embed iframe if the url is youtubey' do
    iframe = helper.embed_you_tube('https://www.youtube.com/watch?v=biwW1Zx2KDU')
    node = Nokogiri::HTML::DocumentFragment.parse(iframe)
    rendered = node.css('iframe')

    expect(rendered.attribute('src').value).to eq 'https://www.youtube.com/embed/biwW1Zx2KDU'
    expect(rendered.attribute('width').value).to eq '100%'
    expect(rendered.attribute('height').value).to eq '200'
    expect(rendered.attribute('title').value).to be_empty
  end

  it 'renders nothing if the url is not youtubey' do
    iframe = helper.embed_you_tube('https://www.youtube.com/not-a-video')
    expect(iframe).to be_empty
  end

  it 'honors title, width and height args' do
    iframe = helper.embed_you_tube('https://www.youtube.com/watch?v=biwW1Zx2KDU', height: 40, width: 20, title: 'whatever')
    node = Nokogiri::HTML::DocumentFragment.parse(iframe)
    rendered = node.css('iframe')
    expect(rendered.attribute('src').value).to eq 'https://www.youtube.com/embed/biwW1Zx2KDU'
    expect(rendered.attribute('width').value).to eq '20'
    expect(rendered.attribute('height').value).to eq '40'
    expect(rendered.attribute('title').value).to eq 'whatever'
  end

  describe '_embed_url_from_url' do
    youtube_urls = [
      'https://youtu.be/23ihawJKZcE',
      'https://www.youtube.com/watch?v=23ihawJKZcE&feature=featured',
      'https://www.youtube.com/watch?v=23ihawJKZcE',
      'http://www.youtube.com/watch?v=23ihawJKZcE',
      'https://youtube.com/watch?v=23ihawJKZcE',
      'http://youtube.com/watch?v=23ihawJKZcE',
      'https://m.youtube.com/watch?v=23ihawJKZcE',
      'http://m.youtube.com/watch?v=23ihawJKZcE',
      'https://www.youtube.com/watch?v=23ihawJKZcE',
    ]

    youtube_urls.each do |url|
      it "returns the embed url for #{url}" do
        expect(helper._embed_url_from_url(url)).to eq 'https://www.youtube.com/embed/23ihawJKZcE'
      end
    end
  end
end
