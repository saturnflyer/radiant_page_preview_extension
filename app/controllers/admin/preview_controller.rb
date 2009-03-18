class Admin::PreviewController < ApplicationController
  
  def create
    @page = page_class.new
    set_attributes
    if config['page.preview.validate?'] == false
      begin
        Page.transaction do
          PagePart.transaction do
            @page.process(request, response)
            @performed_render = true
            raise "Unvalidated Render performed"
          end
        end
      rescue Exception => ex
        unless @performed_render
          render :update do |page|
            page.alert("Could not preview the page! #{ex.message}")
          end
        end
      end
    elsif config['page.preview.validate?'] && @page.valid? #|| (@page.errors.size == 1 && @page.errors.on(:slug) =~ /slug already in use/)
      begin
        Page.transaction do
          PagePart.transaction do
            @page.process(request, response)
            @performed_render = true
            raise "Render performed"
          end
        end
      rescue Exception => ex
        unless @performed_render
          render :update do |page|
            page.alert("Could not preview the page! #{ex.message}")
          end
        end
      end
    else
      render :update do |page|
        page.alert("Could not preview the page!\n\n\t-#{@page.errors.full_messages.join("\n\t-")}")
      end
    end
  end
  
  private
    def set_attributes
      @page.slug = params[:slug]
      if params[:page_preview] && params[:page_preview][:parent_id]
        @page.parent = Page.find_by_id(params[:page_preview][:parent_id].to_i)
      end
      params[:page][:meta_tags] = '' if @page.respond_to?(:meta_tags)
      @page.attributes = params[:page]
      set_times
      set_parts
      set_layout
    end
    
    def set_parts
      parts_to_update = []
      name_parts, filter_parts, content_parts = [], [], []
      (params[:page][:parts]||{}).each {|form_part|
        name_parts << form_part['name'] if form_part.has_key?('name')
        filter_parts << form_part['filter_id'] if form_part.has_key?('filter_id')
        content_parts << form_part['content'] if form_part.has_key?('content')
      }
      name_parts.each_with_index do |name, i|
        parts_to_update << {:name => name, :filter_id => filter_parts[i], :content => content_parts[i]}
      end
      @page.parts_with_pending = parts_to_update
    end
    
    def set_layout
      preview_layout = @config['page.preview.layout']
      if !preview_layout.blank? && @layout = (Layout.find_by_name(preview_layout) || Layout.find(preview_layout))
        @page[:layout_id] = @layout.id
      end
    end
    
    def set_times
      if params[:page_preview] && params[:page_preview][:page_id]
        if db_page = Page.find_by_id(params[:page_preview][:page_id])
          @page.created_at = db_page.created_at
          @page.published_at = db_page.published_at
        end
      end
      @page.created_at = Time.now if @page.created_at.blank?
      @page.published_at = Time.now if @page.published_at.blank?
      @page.updated_at = Time.now
    end
    
    def page_class
      classname = params[:page][:class_name].classify
      if Page.descendants.collect(&:name).include?(classname)
        classname.constantize
      else
        Page
      end
    end
    
end
