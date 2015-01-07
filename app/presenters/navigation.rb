require 'forwardable'

class Navigation
  include Enumerable
  extend Forwardable
  def_delegators :items, :each, :<<
end
