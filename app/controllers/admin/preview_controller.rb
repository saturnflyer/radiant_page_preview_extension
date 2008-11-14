class Admin::PreviewController < ApplicationController
  only_allow_access_to(:show,
                       { :when => [:admin, :developer],
                         :denied_url => {:controller => 'page', :action => :index},
                         :denied_message => 
                         'You must have administrative privileges to perform this action.' })
  
  def create
    @page = Page.new
    set_attributes
    if @page.valid? || (@page.errors.size == 1 && @page.errors.on(:slug) =~ /slug already in use/)
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
        page.alert("Could not preview the page!\n\n\t-#{@page.errors.full_messages.join("\n\n\t-")}")
      end
    end
  end
  
  private
    def set_attributes
      @page.slug = params[:slug]
      @page.parent = Page.find_by_id(params[:page_preview][:parent_id].to_i)
      @page.attributes = params[:page]
      set_parts
    end
    
    def set_parts
      parts_to_update = {}
      (params[:part]||{}).each {|k,v| parts_to_update[v[:name]] = v }
      parts_to_update.values.each do |attrs|
        @page.parts.build(attrs)
      end
    end
    
end
