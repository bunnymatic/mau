require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../mobile_shared_spec')

class DummyController < ApplicationController
  def not_found_page
    render_not_found(Exception.new("Where?"))
  end
  def error_page
    render_error(Exception.new("Eat it"))
  end
end

describe DummyController do
  integrate_views
  describe '#not_found_page' do
    before do
      get :not_found_page
    end
    it 'response status is 404' do 
      response.code.should == '404'
    end
    it 'uses error template' do
      response.should render_template 'error/index.html.erb'
    end
    it 'includes a f404 block' do
      response.should have_tag('.f404 p')
    end
  end
  describe '#not_found_page.mobile' do
    before do
      request.stubs(:user_agent).returns(IPHONE_USER_AGENT)
      get :not_found_page
    end
    it 'response status is 404' do 
      response.code.should == '404'
    end
    it 'uses error template' do
      response.should render_template 'error/index.mobile.haml'
    end
    it 'includes an f404 block' do
      response.should have_tag('.f404 p')
    end
  end
  describe '#error_page' do
    before do
      get :error_page
    end
    it 'response status is 500' do 
      response.code.should == '500'
    end
    it 'uses error template' do
      response.should render_template 'error/index.html.erb'
    end
    it 'includes an f404 block' do
      response.should have_tag('.f404 p')
    end
  end
  describe '#error_page.mobile' do
    before do
      request.stubs(:user_agent).returns(IPHONE_USER_AGENT)
      get :error_page
    end
    it 'response status is 500' do 
      response.code.should == '500'
    end
    it 'includes an f404 block' do
      response.should have_tag('.f404 p')
    end
    it 'uses error template' do
      response.should render_template 'error/index.mobile.haml'
    end
  end

end
