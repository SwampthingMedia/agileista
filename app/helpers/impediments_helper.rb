module ImpedimentsHelper
  def impediment_complete?(impediment)
    return ' class="complete"' if impediment.resolved_at
  end
  
  def show_resolved_at(impediment)
    if impediment.resolved_at
      return "#{time_ago_in_words(impediment.resolved_at)} ago"
    else
      link_to('Resolve', resolve_impediment_path(:id => impediment, :page => params[:page]), :method => :post)
    end
  end
  
  def impediment_nav(action)
    return link_to("All", impediments_path) if action == "active"
    return link_to("Active", active_impediments_path) if action == "index"
  end
  
  def impediment_feed(action)
    return auto_discovery_link_tag(:atom, formatted_active_impediments_path(:format => :atom)) if action == "active"
    return auto_discovery_link_tag(:atom, formatted_impediments_path(:format => :atom)) if action == "index"
  end
end