# frozen_string_literal: true

# Roles and User Authorization mixin
class User
  module Authorization
    def special?
      admin? || manager? || editor?
    end

    def admin?
      roles.include? Role.admin
    end

    def manager?
      admin? || (roles.include? Role.manager)
    end

    def editor?
      admin? || (roles.include? Role.editor)
    end
  end
end
