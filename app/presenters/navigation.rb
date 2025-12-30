require 'forwardable'

class Navigation < ViewPresenter
  include Enumerable
  extend Forwardable

  def_delegators :items, :each, :<<
end
