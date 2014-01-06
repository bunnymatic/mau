require 'spec_helper'

describe FasoImporter do

  # tested by Faso model tests
  its(:uri) { should be_a_kind_of URI }

end
