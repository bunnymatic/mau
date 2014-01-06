module PresenterSpecHelpers
  class MockViewContext

    include ActionView::Helpers::UrlHelper
    include Rails.application.routes.url_helpers

    def initialize(logged_in_as = nil)
      @user = logged_in_as
    end

    def current_user
      @user
    end

    def controller
      # this helps the tag_cloud_presenter tag_path method (for some reason)
    end

  end

  def self.included(base)
    base.send(:include, Rails.application.routes.url_helpers)
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods
    def mock_view_context(logged_in_as = nil)
      @mock_view_context ||= MockViewContext.new(logged_in_as)
    end
  end
end
