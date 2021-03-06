module Admin
  class BlacklistDomainsController < ::BaseAdminController
    before_action :admin_required
    before_action :load_blacklist_domain, only: %i[destroy]

    def index
      @domains = BlacklistDomain.all
    end

    def new
      @domain = BlacklistDomain.new
    end

    def create
      @domain = BlacklistDomain.new blacklist_domain_params
      if @domain.save
        redirect_to admin_blacklist_domains_path, notice: "Added entry for #{@domain.domain}"
      else
        render 'new'
      end
    end

    def destroy
      @domain = BlacklistDomain.find(params[:id])
      @domain.destroy
      redirect_to admin_blacklist_domains_path, notice: "Removed entry for #{@domain.domain}"
    end

    private

    def load_blacklist_domain
      @domain = BlacklistDomain.find(params[:id])
    end

    def blacklist_domain_params
      params.require(:blacklist_domain).permit :domain
    end
  end
end
