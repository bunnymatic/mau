# Previous version names
#
# Gremlin v1
# Corvair v4
# Dart v5
# Charger v6
# Challenger v7
# Coronet v8
# Impala v9 - ruby3/rails7
module Mau
  class Version
    VERSION = {
      name: 'Impala',
      major: '9',
      minor: '0',
      rev: '0',
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
