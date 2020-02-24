# frozen_string_literal: true

class MauMailer < ApplicationMailer
  SUBJECT_PREFIX = '[Mission Artists]'
  NOTE_FROM_ADDRESS = 'Mission Artists <mau@missionartists.org>'
  ACCOUNTS_FROM_ADDRESS = 'Mission Artists Accounts <mau@missionartists.org>'

  include ActionMailer::Text

  default content_type: 'multipart/alternative'

  def mailer_list
    Object.const_get(self.class.name + 'List').first
  end

  protected

  def environment_for_subject
    return '' if Rails.env.production?

    "[#{Rails.env}]"
  end

  def build_subject(subject)
    [SUBJECT_PREFIX, subject].join ' '
  end
end
