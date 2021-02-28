module Admin
  class MemberEmailsController < ::BaseAdminController
    def show
      @email_list = AdminEmailList.new(build_list_names_from_params)

      respond_to do |format|
        format.html {}
        format.csv do
          render_csv_string(@email_list.csv, @email_list.csv_filename)
        end
      end
    end

    private

    def build_list_names_from_params
      known_os_keys = OpenStudiosEvent.pluck(:key)
      list_names = [params[:listname], (params.keys & known_os_keys)].flatten.compact.uniq
      list_names.presence || ['active']
    end
  end
end
