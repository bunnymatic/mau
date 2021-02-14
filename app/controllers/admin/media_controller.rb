module Admin
  class MediaController < ::BaseAdminController
    def index
      @media = Medium.alpha
    end

    # GET /media/new
    # GET /media/new.xml
    def new
      @medium = Medium.new
    end

    # GET /media/1/edit
    def edit
      @medium = Medium.find(params[:id])
    end

    def create
      @medium = Medium.new(medium_params)

      if @medium.save
        flash[:notice] = 'Medium was successfully created.'
        redirect_to admin_media_path
      else
        render 'new'
      end
    end

    def update
      @medium = Medium.find(params[:id])

      if @medium.update(medium_params)
        flash[:notice] = 'Medium was successfully updated.'
        redirect_to admin_media_path
      else
        render 'edit'
      end
    end

    def destroy
      @medium = Medium.find(params[:id])
      @medium.destroy

      redirect_to(admin_media_url)
    end

    private

    def medium_params
      params.require(:medium).permit(:name)
    end
  end
end
