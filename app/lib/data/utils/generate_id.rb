require 'securerandom'

module SoT
  class GenerateId
    def call
      SecureRandom.hex(5)
    end
  end
end
