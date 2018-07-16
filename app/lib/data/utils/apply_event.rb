require 'securerandom'

module SoT
  class ApplyEvent
    def call(event, state)
      event_module_name = ['SoT::', event.name.split('_').map(&:capitalize).join, 'Event'].join
      if Object.const_defined?(event_module_name)
        event_module = Object.const_get(event_module_name)
        event_module.handle(event, state)
      end
    end
  end
end
