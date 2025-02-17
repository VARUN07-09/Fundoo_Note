require 'rails_helper'

RSpec.describe NotesService, type: :service do
  let(:user) { create(:user) }
  let(:note_params) { { title: 'Test Note', content: 'This is a test', color: 'blue' } }

  describe '.fetch_notes' do
    context 'when notes are in the cache' do
      it 'returns notes from Redis cache' do
        $redis.set("user_#{user.id}_notes", [{ id: 1, title: 'Test Note' }].to_json)

        notes = NotesService.fetch_notes(user)

        expect(notes).to be_an(Array)
        expect(notes.first['title']).to eq('Test Note')
      end
    end

    context 'when notes are not in the cache' do
      it 'fetches notes from the database and stores them in Redis' do
        create(:note, user: user)

        notes = NotesService.fetch_notes(user)

        expect(notes).to be_an(Array)
        expect(notes.first['title'])==("Test Note")
        expect($redis.get("user_#{user.id}_notes")).not_to be_nil
      end
    end
  end

  describe '.create_note' do
    it 'creates a note and invalidates the cache' do
      expect {
        result = NotesService.create_note(user, note_params)
        expect(result[:success]).to eq(true)
      }.to change { user.notes.count }.by(1)

      # Verify that the cache is invalidated
      expect($redis.get("user_#{user.id}_notes")).to be_nil
    end

    it 'returns an error if note is invalid' do
      invalid_params = { title: nil, content: nil }
      result = NotesService.create_note(user, invalid_params)

      expect(result[:success]).to eq(false)
      expect(result[:error]).to include("Title can't be blank")
    end
  end
end
