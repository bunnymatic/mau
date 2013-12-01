module PresenterSpecHelpers
  class MockViewContext
    include Rails.application.routes.url_helpers
  end

  def self.included(base)
    base.send(:include, Rails.application.routes.url_helpers)
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods
    def mock_view_context
      @mock_view_context ||= MockViewContext.new
    end
  end
end
