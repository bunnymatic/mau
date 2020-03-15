# frozen_string_literal: true

module Admin
  class SitePreferencesController < ::BaseAdminController
    before_action :load_site_preferences, only: %i[edit update]

    def edit; end

    def update
      if @site_preferences.update(site_preferences_params)
        redirect_to edit_admin_site_preferences_path, notice: 'Got it.  The new preferences are in place.'
      else
        render action: 'edit'
      end
    end

    private

    def load_site_preferences
      @site_preferences = SitePreferences.instance
    end

    def site_preferences_params
      params.require(:site_preferences).permit(:social_media_tags)
    end
  end
end
