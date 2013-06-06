module SprintsHelper
  def sprint_header(sprint, options = {})
    result = [%{#{h(sprint.name)}}]
    result << %{<small>#{show_date(sprint.start_at)} to #{show_date(sprint.end_at)}</small>}

    return result.join(" ").html_safe
  end

  def average_velocity(project, opts = {})
    return nil unless velocity = @velocity || project.average_velocity
    options = {:unit => "story points"}.merge(opts)
    "#{velocity} #{options[:unit]}"
  end

end

