require 'find'
require 'fileutils'
require 'yaml'

namespace :mau do
  desc 'show social link counts'
  task show_social_link_type_counts: [:environment] do
    link_count = Artist.active.all.map(&:links).each_with_object({}) do |links, memo|
      links.each do |k, v|
        memo[k] ||= 0
        memo[k] += 1 if v.present?
      end
    end
    puts link_count.inspect
  end

  desc 'check status and email if there are issues'
  task check_and_notify_server_status: [:environment] do
    status = ServerStatus.run
    if !status[:main] || !status[:elasticsearch]
      puts 'ERROR'
      puts status
      AdminMailer.server_trouble(status).deliver_now
    end
  end

  desc 'clean up studio 0 artists'
  task indy_studio_artist_cleanup: [:environment] do
    Artists.where(studio_id: 0).find_each { |a| a.update(studio_id: nil) }
  end

  desc 'initiate studio slugs'
  task slug_studios: [:environment] do
    Studio.find_each do |s|
      s.touch
      s.save!
    end
  end

  desc 'initiate media slugs'
  task slug_media: [:environment] do
    Medium.find_each(&:save!)
  end

  desc 'initiate user slugs'
  task slug_users: [:environment] do
    User.find_each do |u|
      u.touch
      u.save
    end
  end

  desc 'cleanup names (remove leading/trailing whitespace'
  task clean_names: [:environment] do
    Artist.find_each(&:save)
  end

  def ask_for_confirmation(question)
    puts question
    $stdout.flush
    while (input = $stdin.gets.chomp)
      case input.upcase
      when 'Y', 'YES'
        return true
      when 'N', 'NO'
        return false
      else
        puts 'Please answer with yes or no'
      end
    end
  end

  desc 'clean art from suspended artists'
  task clean_suspended_artist_art: [:environment] do
    pieces = ArtPiece.includes(:artist).where(users: { state: :suspended })
    if pieces.count.positive
      if ask_for_confirmation(sprintf('Found %d pieces to destroy - are you sure you want to proceed (yes/no)?', pieces.count))
        pieces.destroy_all
      else
        puts 'nothing lost, nothing gained.'
      end
    else
      puts 'Nothing to do because we have not suspended artists with art.'
    end
  end

  desc 'record todays OS count'
  task daily_os_signup: [:environment] do
    OpenStudiosEventService.tally_os
  end

  desc 'import scammer emails from FASO'
  task import_scammer_list: [:environment] do
    Scammer.import_from_faso
  end

  desc 'reset all passwords to "whatever"'
  task reset_passwords: [:environment] do
    User.find_each do |u|
      u.password = 'whatever'
      u.password_confirmation = 'whatever'
      u.save
    end
  end

  desc 'normalize emails - convert everyone to "@example.com"'
  task normalize_emails: [:environment] do
    User.find_each do |u|
      u.update_attribute(:email, u.email.gsub(/^(.*)@(.*)/, '\1@example.com'))
    end
  end

  namespace :tags do
    desc 'downcase existing tags'
    task downcase: [:environment] do
      ArtPieceTag.all.reject { |t| t.name == t.name.downcase }.each do |t|
        t.name = t.name.downcase
        t.save!
      end
    end
  end

  namespace :open_studios do
    desc 'Set activation dates on open studios event without activation (set to os date boundaries + 1 day)'
    task set_activation_dates: :environment do
      OpenStudiosEvent.where(activated_at: nil).or(OpenStudiosEvent.where(deactivated_at: nil)).find_each do |ev|
        attrs = {
          activated_at: ev.activated_at || (ev.start_date - 1.day),
          deactivated_at: ev.deactivated_at || (ev.end_date + 1.day)
        }
        OpenStudiosEventService.update(ev, attrs)
      end
    end
  end
end
