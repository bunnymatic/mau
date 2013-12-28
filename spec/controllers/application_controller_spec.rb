require 'spec_helper'

class DummyController < ApplicationController
  def not_found_page
    render_not_found(Exception.new("Where?"))
  end
  def error_page
    render_error(Exception.new("Eat it"))
  end
end

describe DummyController do
  render_views
  describe '#not_found_page' do
    before do
      get :not_found_page
    end
    it 'response status is 404' do
      response.code.should eql '404'
    end
    it 'uses error template' do
      response.should render_template 'error/index'
    end
    it 'includes a f404 block' do
      assert_select('.f404 p')
    end
  end
  describe '#not_found_page.mobile' do
    before do
      request.stub(:user_agent => IPHONE_USER_AGENT)
      get :not_found_page
    end
    it 'response status is 404' do
      response.code.should eql '404'
    end
    it 'uses error template' do
      response.should render_template 'error/index'
    end
    it 'includes an f404 block' do
      assert_select('.f404 p')
    end
  end
  describe '#error_page' do
    before do
      get :error_page
    end
    it 'response status is 500' do
      response.code.should eql '500'
    end
    it 'uses error template' do
      response.should render_template 'error/index'
    end
    it 'includes an f404 block' do
      assert_select('.f404 p')
    end
  end
  describe '#error_page.mobile' do
    before do
      request.stub(:user_agent => IPHONE_USER_AGENT)
      get :error_page
    end
    it 'response status is 500' do
      response.code.should eql '500'
    end
    it 'includes an f404 block' do
      assert_select('.f404 p')
    end
    it 'uses error template' do
      response.should render_template 'error/index'
    end
  end

end
