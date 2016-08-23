module ApplicationHelper
  def breadcrumbs(links)
    content_tag(:ol, class: 'breadcrumb') do
      links.collect do |link|
        content_tag(:li) do
          if link.size == 1
            link.first
          else
            link_to link.first, link.last
          end
        end
      end.join.html_safe
    end
  end
end
