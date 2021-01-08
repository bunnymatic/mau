# frozen_string_literal: true

shared_examples_for 'redirects to login' do
  it 'redirects to login' do
    expect(response).to redirect_to(new_user_session_path)
  end
end

shared_examples_for 'refuses access by xhr' do
  it 'refuses access' do
    m = JSON.parse(response.body)
    expect(m['message']).to include 'be logged in'
  end
end

shared_examples_for 'renders error page' do
  it 'renders an error page with status 404' do
    expect(response).to render_template 'error/index'
    expect(response.code).to eql '404'
  end
end

shared_examples_for 'not authorized' do
  it 'redirects to error page' do
    expect(response).to be_unauthorized
    expect(response.location).to end_with '/error'
  end
end

shared_examples_for 'successful api json' do
  it do
    expect(response).to be_successful
    expect(response.content_type).to eq('application/vnd.api+json; charset=utf-8')
  end
end

shared_examples_for 'successful json' do
  it do
    expect(response).to be_successful
    expect(response.content_type).to eq('application/json; charset=utf-8')
  end
end
