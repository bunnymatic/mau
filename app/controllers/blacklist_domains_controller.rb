class BlacklistDomainsController < AdminController
  def index
    @domains = BlacklistDomain.all
  end

  def new
    new_or_edit
  end

  def edit
    new_or_edit
  end

  def new_or_edit
    @domain = params[:id] ? BlacklistDomain.find(params[:id]) : BlacklistDomain.new
  end

  def create
    @domain = BlacklistDomain.new(params[:blacklist_domain])
    if (@domain.save)
      redirect_to blacklist_domains_path, :notice => "Added entry for #{@domain.domain}"
    else
      render 'new'
    end
  end

  def update
    @domain = BlacklistDomain.find(params[:id])

    if (@domain.update_attributes(params[:blacklist_domain]))
      redirect_to blacklist_domains_path, :notice => "Updated entry for #{@domain.domain}"
    else
      render 'edit'
    end
  end

  def destroy
    @domain = BlacklistDomain.find(params[:id])
    @domain.destroy
    redirect_to blacklist_domains_path, :notice => "Removed entry for #{@domain.domain}"
  end
end
