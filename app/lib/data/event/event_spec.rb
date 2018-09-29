describe SoT::Event do
  describe 'factory' do
    it 'can be created' do
      event = described_class.build(
        name: 'event_name',
        payload: 'payload data',
      )

      expect(event.id).not_to be_nil
      expect(event.name).to eq 'event_name'
      expect(event.payload).to eq 'payload data'
      expect(event.requester_id).to eq 'system'
      expect(event.created_at.to_date).to eq Time.now.to_date
    end

    it 'can be created with a custom requester' do
      event = described_class.build(
        name: 'event_name',
        payload: 'payload data',
        requester_id: 'custom requester',
      )
      expect(event.requester_id).to eq 'custom requester'
    end
  end
end
