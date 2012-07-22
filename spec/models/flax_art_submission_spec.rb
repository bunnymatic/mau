require 'spec_helper'

module SubmissionSpecHelper
  def valid_submission_attributes
    { :user_id => 10,
      :art_piece_ids => '1,2,3'
    }
  end
end

describe FlaxArtSubmission do
  
  fixtures :flax_art_submissions
  
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
  
  describe "named scopes" do
    before do
      #validate fixture data
      s = FlaxArtSubmission.all 
      paid = s.select{|f| f.paid}.length
      unpaid = s.select{|f| !f.paid}.length
      assert(paid > 0)
      assert(unpaid > 0)
    end
    it "paid only shows paid submissions" do
      FlaxArtSubmission.paid.each do |f|
        f.paid.should == true
      end
    end
    it "unpaid only shows unpaid submissions" do
      FlaxArtSubmission.unpaid.each do |f|
        f.paid.should == false
      end
    end
  end
end

