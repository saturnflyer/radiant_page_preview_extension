require File.dirname(__FILE__) + '/../spec_helper'

describe Admin::PageController, "routes preview page requests" do
  scenario :pages
  
  it "route a preview page correctly" do
    route_for(preview_page_path(1)).should_equal "/admin/page/preview/1"
  end
  
end
