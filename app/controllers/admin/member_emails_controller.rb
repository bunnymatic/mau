module Admin
  class MemberEmailsController < AdminController

    def show
      @email_list = AdminEmailList.new(build_list_names_from_params)

      respond_to do |format|
        format.html {}
        format.csv {
          render_csv_string(@email_list.csv, @email_list.csv_filename)
        }
      end
    end

    private
    def build_list_names_from_params
      list_names = [params[:listname], (params.keys & available_open_studios_keys)].flatten.compact.uniq
      list_names.blank? ? ['active'] : list_names
    end

  end
end
