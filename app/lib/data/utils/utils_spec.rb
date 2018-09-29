describe 'Utils' do
  describe SoT::ApplyEvent do
    module SoT::SomethingHappenedEvent # rubocop:disable Style/ClassAndModuleChildren
      def self.received
        @received
      end

      def self.handle(event, state)
        @received = { event: event, state: state }
      end
    end

    it 'delegates event handling to coresponding class' do
      state = double
      event = SoT::Event.build(name: 'something_happened', payload: 'payload')
      SoT::ApplyEvent.new.call(event, state)

      received = SoT::SomethingHappenedEvent.received
      expect(received[:event].name).to eq 'something_happened'
      expect(received[:event].payload).to eq 'payload'
      expect(received[:state]).to eq state
    end
  end

  describe 'Eventable' do
    class Klass
      include SoT::Eventable
    end

    it 'adds events methods to a class' do
      obj = Klass.new
      obj.add_event('eventA')
      obj.add_events(%w[eventB eventC])
      expect(obj.events).to eq %w[eventA eventB eventC]

      obj.reset_events
      expect(obj.events).to eq []
    end
  end

  describe SoT::I18nProvider do
    it 'returns proper translation from loaded yaml' do
      i18n = described_class.new(ymls_load_path: Dir[File.join('spec', 'fixtures', '*.yml')])

      expect(i18n.t('text')).to eq 'Text not in any scope'
      expect(i18n.t('text', scope: 'in_scope')).to eq 'Text in scope'
    end
  end

  describe SoT::GenerateId do
    it 'generates id (default: 10 chars)' do
      id = SoT::GenerateId.new.call
      expect(id.length).to eq 10
    end

    it 'generates id (with custom length)' do
      id = SoT::GenerateId.new.call(length: 4)
      expect(id.length).to eq 4
    end
  end

  describe SoT::Serialize do
    class Klass
      def initialize
        @_attr_a = 'a'
        @_attr_b = 'b'
        @attr_c = 'c'
        @attr_d = 'd'
      end
    end
    it 'serializes an object using only @x instance variables' do
      obj = Klass.new
      expected_hash = { attr_c: 'c', attr_d: 'd' }
      expect(subject.call(obj)).to eq(expected_hash)
    end
  end
end
