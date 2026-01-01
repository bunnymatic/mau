module Admin
  class CmsDocumentsController < ::BaseAdminController
    before_action :editor_required
    before_action :load_document, only: %i[edit destroy update show]

    def index
      @cms_documents = CmsDocument.all
    end

    def show; end

    def new
      @cms_document = CmsDocument.new(cms_document_params)
    end

    def edit; end

    def create
      @cms_document = CmsDocument.new(cms_document_params)

      if @cms_document.save
        redirect_to [:admin, @cms_document], notice: 'CmsDocument was successfully created.'
      else
        render 'edit'
      end
    end

    def update
      if @cms_document.update(cms_document_params)
        redirect_to [:admin, @cms_document], notice: 'CmsDocument was successfully updated.'
      else
        render 'edit'
      end
    end

    def destroy
      @cms_document.destroy
      redirect_to admin_cms_documents_path, notice: 'CmsDocument was removed'
    end

    private

    def load_document
      @cms_document = CmsDocument.find(params[:id])
    end

    def cms_document_params
      return {} unless params[:cms_document]

      params.expect(cms_document: %i[page section article]).merge(user_id: current_user.id)
    end
  end
end
