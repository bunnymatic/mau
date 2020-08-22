# frozen_string_literal: true

module Mau
  class Version
    VERSION = {
      name: 'Coronet',
      major: '8',
      minor: '0',
      rev: '1',
      build: 'unk',
    }.freeze

    def number
      VERSION.values_at(:major, :minor, :rev).join('.')
    end

    def name
      VERSION[:name]
    end

    def to_s
      "#{name} #{number}"
    end

    def build
      VERSION[:build]
    end
  end
end
