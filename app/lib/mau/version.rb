module Mau
  class Version

    VERSION = {
      name: 'Challenger',
      major: '7',
      minor: '0',
      rev: '0',
      build: 'unk'
    }

    def number
      VERSION.values_at(:major, :minor, :rev).join(".")
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
