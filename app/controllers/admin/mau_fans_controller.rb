module Admin
  class MauFansController < ::BaseAdminController
    def index
      @fans = MauFan.active.map { |fan| UserPresenter.new(fan) }
    end
  end
end
