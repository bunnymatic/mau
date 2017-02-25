# frozen_string_literal: true
require 'rails_helper'

describe FasoImporter do
  # tested by Faso model tests

  describe '#uri' do
    subject { super().uri }
    it { should be_a_kind_of URI }
  end
end
