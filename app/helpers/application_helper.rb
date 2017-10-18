# frozen_string_literal: true

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

  def ckan_url(path = nil)
    ckan = Rails.application.secrets.ckan_url
    path.blank? ? ckan : ::File.join(ckan, path)
  end

  def static_url(path = nil)
    static = Rails.application.secrets.static_url
    path.blank? ? static : ::File.join(static, path)
  end
end
