module PreviewControllerExtensions
  def preview
    @page = Page.find_or_initialize_by_id(params[:id])
    
    logger.debug("Previewing based on args: " + params.to_s);
    logger.debug("Preview found page: " + @page.to_s);
    
    if @page.new_record?
      @page.slug = params[:slug]
      @page.breadcrumb = params[:breadcrumb]
      @page.parent = params[:parent_id]
    end
    begin
      Page.transaction do
        PagePart.transaction do
          handle_new_or_edit_post
          @page.process(request, response)
          @performed_render = true
          raise "Zoinks!"
        end
      end
    rescue
      render :text => "Could not preview the page!" unless @performed_render
    end
  end
end