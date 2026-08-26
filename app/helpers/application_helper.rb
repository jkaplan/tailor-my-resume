module ApplicationHelper
  def markdown(text)
    return "" if text.blank?

    sanitize(Kramdown::Document.new(text).to_html)
  end

  def status_badge(status)
    content_tag :span, status.titleize, class: "badge badge-#{status}"
  end
end
