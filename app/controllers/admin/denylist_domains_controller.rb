module Admin
  class DenylistDomainsController < ::BaseAdminController
    before_action :admin_required
    before_action :load_denylist_domain, only: %i[destroy]

    def index
      @domains = DenylistDomain.all
    end

    def new
      @domain = DenylistDomain.new
    end

    def create
      @domain = DenylistDomain.new denylist_domain_params
      if @domain.save
        redirect_to admin_denylist_domains_path, notice: "Added entry for #{@domain.domain}"
      else
        render 'new'
      end
    end

    def destroy
      @domain = DenylistDomain.find(params[:id])
      @domain.destroy
      redirect_to admin_denylist_domains_path, notice: "Removed entry for #{@domain.domain}"
    end

    private

    def load_denylist_domain
      @domain = DenylistDomain.find(params[:id])
    end

    def denylist_domain_params
      params.require(:denylist_domain).permit :domain
    end
  end
end
