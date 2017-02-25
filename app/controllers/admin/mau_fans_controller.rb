# frozen_string_literal: true
module Admin
  class MauFansController < ::BaseAdminController
    def index
      @fans = MauFan.active
    end
  end
end
