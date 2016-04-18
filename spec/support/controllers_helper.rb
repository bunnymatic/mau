shared_examples_for "redirects to login" do
  it "redirects to login" do
    expect(response).to redirect_to(new_user_session_path)
  end
end


shared_examples_for 'renders error page' do
  it "renders an error page with status 404" do
    expect(response).to render_template 'error/index'
    expect(response.code).to eql '404'
  end
end

shared_examples_for "not authorized" do
  it "redirects to error page" do
    expect(response).to redirect_to error_path
  end
end

shared_examples_for 'successful json' do
  it {
    expect(response).to be_success
    expect(response).to be_json
  }
end
