module Admin
  class CmsDocumentsController < BaseAdminController

    before_filter :editor_required

    def index
      @cms_documents = CmsDocument.all
    end
    def new
      return new_or_edit
    end

    def edit
      return new_or_edit
    end

    def destroy
      @cms_document = CmsDocument.find(params[:id])
      @cms_document.destroy
      redirect_to admin_cms_documents_path, :notice => "CmsDocument was removed"
    end

    def new_or_edit
      begin 
        @cms_document = CmsDocument.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        @cms_document = CmsDocument.new(params[:doc])
      end
      render 'new_or_edit'
    end

    def update
      @cms_document = CmsDocument.find(params[:id])
      if @cms_document.update_attributes(cms_document_params)
        redirect_to [:admin, @cms_document], :notice => 'CmsDocument was successfully updated.'
      else
        render "new_or_edit"
      end
    end

    def show
      @cms_document = CmsDocument.find(params[:id])
    end

    def create
      @cms_document = CmsDocument.new(cms_document_params)

      if @cms_document.save
        redirect_to [:admin, @cms_document], :notice => 'CmsDocument was successfully created.'
      else
        render "new_or_edit"
      end
    end

    def cms_document_params
      params[:cms_document].merge({user_id: current_user.id})
    end
  end
end
