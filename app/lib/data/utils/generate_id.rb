require 'securerandom'

module SoT
  class GenerateId
    def call(length: 10)
      SecureRandom.hex(length / 2)
    end
  end
end
