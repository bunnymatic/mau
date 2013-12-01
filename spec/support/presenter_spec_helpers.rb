module PresenterSpecHelpers
  class MockViewContext
    include Rails.application.routes.url_helpers

    def initialize(logged_in_as)
      @user = logged_in_as
    end

    def current_user
      @user
    end
  end

  def self.included(base)
    base.send(:include, Rails.application.routes.url_helpers)
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods
    def mock_view_context(logged_in_as)
      @mock_view_context ||= MockViewContext.new(logged_in_as)
    end
  end
end
