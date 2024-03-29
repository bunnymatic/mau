class AdminNavigation < ViewPresenter
  attr_reader :current_user

  def initialize(user)
    super()
    @current_user = user
  end

  def admin_links
    pr_links = [
      [:open_studios_events, { display: 'os dates' }],
      [:site_preferences, { link: url_helpers.edit_admin_site_preferences_path }],
      [:favorites, {}],
      [:catalog, { link: '/catalog' }],
      [:cms_documents, { display: 'cms', link: url_helpers.admin_cms_documents_path }],
    ]
    model_links = [
      [:artists, {}],
      [:fans, { link: url_helpers.admin_mau_fans_path }],
      [:studios, {}],
      [:media, {}],
      [:art_piece_tags, { display: 'tags' }],
      [:emaillist, { display: 'member emails', link: url_helpers.admin_member_emails_path }],
    ]
    admin_links = [
      [:roles, {}],
      [:internal_email, { display: 'admin email lists', link: url_helpers.admin_email_lists_path }],
      [:denylist, { display: 'denylist', link: url_helpers.admin_denylist_domains_path }],
      [:os_status, {}],
    ]
    internal_links = [
      [:palette, { display: 'colors & icons', link: url_helpers.admin_palette_path }],
      [:app_events, { display: 'app events', icon: :bell, link: url_helpers.admin_application_events_path }],
      [:tests, { link: url_helpers.admin_tests_path }],
    ]
    [
      [:models, model_links],
      [:pr, pr_links],
      [:admin, admin_links],
      [:internal, internal_links],
    ]
  end

  def editor_links
    [
      [:events, {}],
      [:cms_documents, { display: 'cms', link: url_helpers.admin_cms_documents_path }],
    ]
  end

  def manager_links
    [[:studios, {}]]
  end

  def links
    links = if current_user.admin?
              admin_links
            elsif current_user.editor?
              [[nil, editor_links]]
            elsif current_user.manager?
              [[nil, manager_links]]
            end
    links.each do |(_sxn, entries)|
      entries.each do |key, entry|
        entry[:display] = (entry[:display] || key.to_s).tr('_', ' ')
        entry[:link] = entry[:link] || "/admin/#{key}"
      end
    end
  end
end
