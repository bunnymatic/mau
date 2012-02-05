class CmsDocumentsController < ApplicationController
  before_filter :admin_required
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
      @cms_document = CmsDocument.new()
    end
    render :template => '/cms_documents/new_or_edit'
  end

  def update
    @cms_document = CmsDocument.find(params[:id])

    respond_to do |format|
      if @cms_document.update_attributes(params[:cms_document])
        flash[:notice] = 'CmsDocument was successfully created.'
        format.html { redirect_to(@cms_document) }
        format.xml  { render :xml => @cms_document, :status => :created, :location => @cms_document }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @cms_document.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
  end

  def show
    @cms_document = CmsDocument.find(params[:id])
  end

  def create
    @cms_document = CmsDocument.new(params[:cms_document])

    respond_to do |format|
      if @cms_document.save
        flash[:notice] = 'CmsDocument was successfully created.'
        format.html { redirect_to(@cms_document) }
        format.xml  { render :xml => @cms_document, :status => :created, :location => @cms_document }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @cms_document.errors, :status => :unprocessable_entity }
      end
    end
  end

end
