require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../controllers_helper')

include AuthenticatedTestHelper

describe WizardsController do

  fixtures :users
  fixtures :artist_infos
  fixtures :art_pieces

  integrate_views

  it "actions should fail if not logged in" do
    exceptions = [:flaxart, :mau042012]
    controller_actions_should_fail_if_not_logged_in(:wizard,
                                                    :except => exceptions)
  end

  [:mau042012, :flaxart].each do |endpoint|
    describe 'GET #' + endpoint.to_s do
      before do
        get endpoint
      end
      it_should_behave_like 'returns success'
    end
  end

  describe '#mau042012' do
  end

end

