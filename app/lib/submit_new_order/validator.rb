module SoT
  module SubmitNewOrder
    class Validator
      def call(params)
        return Results.new([:empty_text]) if params['text'].to_s.empty?

        Results.new([])
      end

      class Results < Struct.new(:errors)
        def valid?
          errors.empty?
        end
      end
    end
  end
end
