module PgqWeb::PgqHelper

  def class_menu(act)
    act == params[:action] ? 'active' : ''
  end
  
  def status_span(status = :ok)
    case status
    when :ok then content_tag(:span, 'ok', :class => "label label-success")
    when :warn then content_tag(:span, 'warn', :class => "label label-warning")
    when :error then content_tag(:span, 'error', :class => "label label-important")
    when :stopped then content_tag(:span, 'stopped', :class => "label")
    else
      content_tag(:span, 'ok', :class => "label label-success")
    end
  end
  
  def human_time(str_time)
    Time.parse(str_time).strftime("%d.%m.%Y %H:%M:%S") rescue '-'
  end

end
