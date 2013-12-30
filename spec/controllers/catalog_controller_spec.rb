require 'spec_helper'

describe CatalogController do

  fixtures :users, :roles, :roles_users, :studios, :artist_infos

  describe "#index" do
    let(:jesse) { users(:jesseponce) }
    let(:artist) { users(:artist1) }
    let(:catalog) { assigns(:catalog) }
    before do
      ActiveRecord::Base.connection.execute("update artist_infos set open_studios_participation = '201210'")
      Artist.any_instance.stub(:in_the_mission? => true)
      jesse.update_attribute(:studio, studios(:s1890))
      artist.update_attribute(:studio, studios(:blue))
    end
    context 'format=html' do
      render_views
      before do
        get :index
      end
      it{response.should be_success}
    end

    context 'format=csv' do
      before do
        get :index, :format => :csv
      end
      it { response.should be_success }
      it { response.should be_csv_type }
    end

  end

  describe '#social' do
    context 'format=html' do
      before do
        get :social
      end
      it { response.should_not be_success }
    end
    context 'format=mobile' do
      before do
        get :social, :format => :mobile
      end
      it { response.should redirect_to root_path }
    end
    context 'format=csv' do
      before do
        get :social, :format => :csv
      end
      it { response.should be_success }
      it { response.should be_csv_type }
    end

  end
end
