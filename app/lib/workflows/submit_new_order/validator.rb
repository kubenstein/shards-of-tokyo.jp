module SoT
  module SubmitNewOrder
    class Validator
      def call(params)
        errors = []
        errors << :empty_text if params[:text].to_s.empty?
        errors << :user_not_found unless params[:user]

        Results.new(errors)
      end

      class Results < Struct.new(:errors)
        def valid?
          errors.empty?
        end
      end
    end
  end
end
