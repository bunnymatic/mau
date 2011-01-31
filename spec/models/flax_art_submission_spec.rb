require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module SubmissionSpecHelper
  def valid_submission_attributes
    { :user_id => 10,
      :art_piece_ids => '1,2,3'
    }
  end
end

describe FlaxArtSubmission do
  
  include SubmissionSpecHelper

  describe 'validation' do 
    it "requires a user id" do
      attrs = valid_submission_attributes
      attrs.delete(:user_id)
      FlaxArtSubmission.new(attrs).should_not be_valid
    end
    it "requires something in art_piece_ids" do
      attrs = valid_submission_attributes
      attrs.delete(:art_piece_ids)
      FlaxArtSubmission.new(attrs).should_not be_valid
    end
    it "validates with correct args" do
      attrs = valid_submission_attributes
      FlaxArtSubmission.new(attrs).should be_valid
    end
  end
end

