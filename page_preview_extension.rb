require_dependency 'application'

class PagePreviewExtension < Radiant::Extension
  version "1.0"
  description "A page-preview functionality."
  url "http://github.com/brianjlandau/radiant_page_preview_extension"

  define_routes do |map|
    map.resources :preview, :path_prefix => 'admin', :controller => 'admin/preview'
    map.preview_page 'admin/preview', :controller => 'admin/preview', 
                                       :action => 'create'
  end
  
  def activate
    if ActiveRecord::Base.connection.tables.include?('config')
      Radiant::Config['page.preview.validate?'] = true unless Radiant::Config['page.preview.validate?'] == false
    end
    admin.pages.edit.add :form_bottom, "preview_button", :before => 'edit_buttons'
  end
  
  def deactivate
  end

end