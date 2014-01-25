require 'spec_helper'

describe Feedback do
  
  it{ should validate_presence_of :email }
  it{ should validate_presence_of :subject }
  it{ should validate_presence_of :comment }

end
