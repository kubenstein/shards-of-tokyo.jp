module SoT
  class RegistrationValidator
    def validate(params)
      errors = []
      errors << :email_empty if params['email'].empty?
      errors << :email_invalid unless params['email'].include?('@')
      Results.new(errors)
    end

    class Results < Struct.new(:errors)
      def valid?
        errors.empty?
      end
    end
  end
end
