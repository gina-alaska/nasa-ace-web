# frozen_string_literal: true

module ApplicationHelper
  def breadcrumbs(links)
    content_tag(:ol, class: 'breadcrumb') do
      safe_join(
        links.collect do |link|
          content_tag(:li) do
            if link.size == 1
              link.first
            else
              link_to link.first, link.last
            end
          end
        end
      )
    end
  end

  def ckan_url(path = nil)
    ckan = Rails.application.secrets.ckan_url
    path.blank? ? ckan : ::File.join(ckan, path)
  end
end
