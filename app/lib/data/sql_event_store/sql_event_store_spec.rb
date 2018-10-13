describe SoT::SqlEventStore do
  let(:event1) { SoT::Event.build(name: 'event_name', payload: { data: 'abc' }, requester_id: 'requester_id') }
  let(:event2) { SoT::Event.build(name: 'event_name', payload: { data: 'abc' }, requester_id: 'requester_id') }
  let(:serialised_event1) { SoT::Serialize.new.call(event1) }
  let(:serialised_event2) { SoT::Serialize.new.call(event2) }
  subject { SoT::SqlEventStore.new('sqlite:/').tap(&:configure) }

  describe 'factory' do
    it 'stores an event' do
      expect_any_instance_of(Sequel::Dataset).to receive(:insert).with(serialised_event1)
      subject.add_event(event1)
    end

    it 'stores multiple events' do
      expect_any_instance_of(Sequel::Dataset).to receive(:insert).with(serialised_event1)
      expect_any_instance_of(Sequel::Dataset).to receive(:insert).with(serialised_event2)
      subject.add_events([event1, event2])
    end

    it 'returns events from particular event id' do
      subject.add_events([event1, event2])

      returned_events = subject.fetch_events_from
      expect(returned_events).to eq [event1, event2]

      returned_events = subject.fetch_events_from(event1.id)
      expect(returned_events).to eq [event2]
    end

    it 'reports if its configured already or not' do
      store = SoT::SqlEventStore.new('sqlite:/')
      expect {
        store.configure
      }.to change {
        store.configured?
      }.from(false).to(true)
    end

    describe 'subscribers' do
      it 'passes old events to a subscriber on registration' do
        subscriber = spy
        subject.add_event(event1)
        subject.add_subscriber(subscriber)
        expect(subscriber).to have_received(:add_event)
      end

      it 'passes new events to a subscriber' do
        subscriber = spy
        subject.add_subscriber(subscriber)
        subject.add_event(event1)
        expect(subscriber).to have_received(:add_event)
      end

      it 'stops passing events after unsubscription' do
        subscriber = spy
        subject.add_subscriber(subscriber)
        subject.remove_subscriber(subscriber)
        subject.add_event(event1)
        expect(subscriber).not_to have_received(:add_event)
      end
    end
  end
end
