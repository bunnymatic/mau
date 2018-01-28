# frozen_string_literal: true

require 'find'
require 'fileutils'
require 'yaml'

alldbconf = YAML.load_file(Rails.root.join('config', 'database.yml'))

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

  desc 'clean up studio 0 artists'
  task indy_studio_artist_cleanup: [:environment] do
    Artists.where(studio_id: 0).each { |a| a.update_attributes(studio_id: nil) }
  end

  desc 'initiate studio slugs'
  task slug_studios: [:environment] do
    Studio.all.each do |s|
      s.touch
      s.save!
    end
  end

  desc 'initiate studio slugs'
  task slug_media: [:environment] do
    Medium.all.each(&:save!)
  end

  desc 'initiate user slugs'
  task slug_users: [:environment] do
    User.all.each do |u|
      u.touch
      u.save
    end
  end

  desc 'migrate user/artist links'
  task migrate_user_links: [:environment] do
    User.active.each do |user|
      user.links ||= {}
      user.website = user.url
      if user.is_a? Artist
        artist = user.becomes(Artist)
        %i[facebook twitter blog pinterest myspace flickr instagram].each do |key|
          val = artist&.artist_info.try(key)
          artist.send("#{key}=", val) if val
        end
      end
      user.save
    end
  end

  desc 'cleanup names (remove leading/trailing whitespace'
  task clean_names: [:environment] do
    Artist.all.each(&:save)
  end

  def ask_for_confirmation(question)
    puts question
    STDOUT.flush
    while (input = STDIN.gets.chomp)
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
    Artist.tally_os
  end

  desc 'import scammer emails from FASO'
  task import_scammer_list: [:environment] do
    Scammer.import_from_FASO
  end

  desc 'reset all passwords to "whatever"'
  task reset_passwords: [:environment] do
    User.all.each do |u|
      u.password = 'whatever'
      u.password_confirmation = 'whatever'
      u.save
    end
  end

  desc 'normalize emails - convert everyone to "@example.com"'
  task normalize_emails: [:environment] do
    User.all.each do |u|
      u.update_attribute(:email, u.email.gsub(/^(.*)\@(.*)/, '\1@example.com'))
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
end
