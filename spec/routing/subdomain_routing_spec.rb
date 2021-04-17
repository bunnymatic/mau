require 'rails_helper'

shared_examples_for :routes_to_app_error_page do
  it 'routes errors to the main app' do
    expect(get: "http://#{host}/path_that_wont_resolve").to route_to('error#index', path: 'path_that_wont_resolve')
  end
end

shared_examples_for :routes_to_os_error_page do
  it 'routes errors to the open studios app' do
    expect(get: "http://#{host}/path_that_wont_resolve").to route_to('open_studios_subdomain/error#index', path: 'path_that_wont_resolve')
  end
end

shared_examples_for :allowed_routes do
  it 'can reach the cms documents' do
    expect(get: admin_cms_documents_url).to route_to('admin/cms_documents#index')
  end
  it 'can reach the api' do
    expect(get: api_v2_art_piece_url(5)).to route_to('api/v2/art_pieces#show', id: '5')
  end
end

shared_examples_for :app_routes do
  it 'can reach the sampler' do
    expect(post: sampler_main_url).to route_to('main#sampler')
  end
  it 'can reach the media' do
    expect(get: media_url).to route_to('media#index')
  end
  it 'routes to studios' do
    expect(get: studios_url).to route_to('studios#index')
  end
end

shared_examples_for :open_studios_routes do
  it 'routes to root' do
    expect(get: root_url).to route_to('open_studios_subdomain/main#index')
  end

  it 'routes to artists' do
    expect(get: artist_url('whomever')).to route_to('open_studios_subdomain/artists#show', id: 'whomever')
  end

  it 'does not route to studios' do
    expect(get: studios_url).to route_to('open_studios_subdomain/error#index', path: 'studios')
  end
end

old_host = Rails.application.routes.default_url_options[:host]

describe 'Subdomain Routing Constraints' do
  let(:tld) { 'test.host' }
  let(:host) do
    [subdomain, tld].compact.join('.')
  end

  before do
    old_host = Rails.application.routes.default_url_options[:host]
    Rails.application.routes.default_url_options[:host] = host
  end

  after do
    Rails.application.routes.default_url_options[:host] = old_host
  end

  describe 'for subdomain mau' do
    let(:subdomain) { 'mau' }
    it_should_behave_like :allowed_routes
    it_should_behave_like :app_routes
    it_should_behave_like :routes_to_app_error_page
  end

  describe 'for subdomain www.mau' do
    let(:subdomain) { 'www.mau' }
    it_should_behave_like :allowed_routes
    it_should_behave_like :app_routes
    it_should_behave_like :routes_to_app_error_page
  end

  describe 'for subdomain openstudios.mau' do
    let(:subdomain) { 'openstudios.mau' }
    it_should_behave_like :allowed_routes
    it_should_behave_like :open_studios_routes
    it_should_behave_like :routes_to_os_error_page
  end

  describe 'for subdomain openstudios' do
    let(:subdomain) { 'openstudios' }
    it_should_behave_like :allowed_routes
    it_should_behave_like :open_studios_routes
    it_should_behave_like :routes_to_os_error_page
  end

  describe 'for nil domain' do
    let(:subdomain) { nil }
    it_should_behave_like :allowed_routes
    it_should_behave_like :app_routes
    it_should_behave_like :routes_to_app_error_page
  end

  describe 'for empty string domain' do
    let(:subdomain) { '' }
    it_should_behave_like :allowed_routes
    it_should_behave_like :app_routes
    it_should_behave_like :routes_to_app_error_page
  end

  describe 'for unknown sub domain' do
    let(:subdomain) { 'other' }
    it_should_behave_like :allowed_routes
    it_should_behave_like :routes_to_app_error_page
  end
end
