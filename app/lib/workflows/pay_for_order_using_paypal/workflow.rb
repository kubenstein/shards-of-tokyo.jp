module SoT
  module PayForOrderUsingPaypal
    class Workflow
      attr_reader :env, :client_id, :secret

      def initialize(env:, client_id:, secret:)
        @env = env
        @client_id = client_id
        @secret = secret
      end

      def call(params)
        puts params
        Results.new(params[:order_id], [])
      end

      class Results < Struct.new(:order_id, :errors)
        def success?
          errors.empty?
        end
      end
    end
  end
end
