require 'spec_helper'
require File.expand_path(File.dirname(__FILE__) + '/../controllers_helper')

include AuthenticatedTestHelper

describe WizardsController do

  fixtures :users, :artist_infos, :art_piece_tags, :art_pieces_tags, :media, :art_pieces
  fixtures :cms_documents

  integrate_views

  it "actions should fail if not logged in" do
    exceptions = [:flaxart, :mau042012]
    controller_actions_should_fail_if_not_logged_in(:wizard,
                                                    :except => exceptions)
  end
  # ignoring tests for old flaxart endpoint
  [:mau042012].each do |endpoint|
    describe'GET #' + endpoint.to_s do
      before do
        get endpoint
      end
      it_should_behave_like 'returns success'
      it_should_behave_like 'standard sidebar layout'
    end
  end

  describe '#mau042012' do
    before do
      get :mau042012
    end
    it 'fetches the markdown content properly' do
      assigns(:content).should have_key :content
      assigns(:content).should have_key :cmsid
    end

  end

end

