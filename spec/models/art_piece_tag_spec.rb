# frozen_string_literal: true
require 'rails_helper'

describe ArtPieceTag do
  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name).is_at_least(3).is_at_most(25) }
end
