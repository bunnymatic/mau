class CmsDocumentsController < ApplicationController
  before_filter :editor_required
  layout 'mau-admin'

  def index
    @cms_documents = CmsDocument.all
  end
  def new
    return new_or_edit
  end

  def edit
    return new_or_edit
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

    if @cms_document.update_attributes(params[:cms_document])
      redirect_to @cms_document, :notice => 'CmsDocument was successfully updated.'
    else
      render "new_or_edit"
    end
  end

  def show
    @cms_document = CmsDocument.find(params[:id])
  end

  def create
    @cms_document = CmsDocument.new(params[:cms_document])

    if @cms_document.save
      redirect_to @cms_document, :notice => 'CmsDocument was successfully created.'
    else
      render "new_or_edit"
    end
  end

end
