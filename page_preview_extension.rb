class PagePreviewExtension < Radiant::Extension
  version "0.1"
  description "A sample page-preview functionality.  An example of how you can hook into the page-editing interface with the enhancements in the 'facets' branch."
  url "http://radiantcms.org"

  define_routes do |map|
    map.preview_page "admin/page/preview/:id", :controller => "admin/page", :action => "preview"
    map.preview_pages "admin/pages/preview/:id", :controller => "admin/page", :action => "preview"
  end
  
  def activate
    require 'application'
    
    admin.page.edit.add :form_bottom, "preview_button", :before => 'edit_buttons'
    Admin::PageController.send :include, PreviewControllerExtensions
  end
  
  def deactivate
  end

end