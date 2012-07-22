require 'spec_helper'
describe CmsDocumentsController do
  [:index, :show, :edit, :update].each do |meth|
    before do
      get meth
    end
    it_should_behave_like "not authorized"
  end
  
end
