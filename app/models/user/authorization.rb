# frozen_string_literal: true
# Roles and User Authorization mixin
class User
  module Authorization
    def is_special?
      is_admin? || is_manager? || is_editor?
    end

    def is_admin?
      roles.include? Role.admin
    end

    def is_manager?
      is_admin? || (roles.include? Role.manager)
    end

    def is_editor?
      is_admin? || (roles.include? Role.editor)
    end
  end
end
