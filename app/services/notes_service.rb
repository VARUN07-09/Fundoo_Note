class NotesService
 
  def self.fetch_notes(user)
    cache_key = "user_#{user.id}_notes"
    Rails.logger.info "Checking Redis for key: #{cache_key}"

    notes_json = $redis.get(cache_key)

    if notes_json
      Rails.logger.info "Fetched notes from Redis cache!"
      return JSON.parse(notes_json)
    else
      Rails.logger.info "Cache miss! Fetching from database..."
      
      notes = user.notes.where(trashed: false).as_json(
        only: [:id, :title, :content, :color, :archived, :trashed, :created_at, :updated_at]
      )
      
      $redis.setex(cache_key, 600, notes.to_json)  # Cache for 10 minutes
      Rails.logger.info "Stored notes in Redis for caching."
      return notes
    end
  end


  def self.create_note(user, params)
    note = user.notes.build(params)
    note.color ||= 'white'
    note.archived = false if note.archived.nil?
    note.trashed = false if note.trashed.nil?

    if note.save
      $redis.del("user_#{user.id}_notes") 
      return { success: true, note: note }
    else
      return { success: false, error: note.errors.full_messages.join(", ") }
    end
  end

 
  def self.fetch_note_by_id(user, note_id)
    cache_key = "user_#{user.id}note#{note_id}"
    Rails.logger.info "Checking Redis for key: #{cache_key}"

    note_json = $redis.get(cache_key)

    if note_json
      Rails.logger.info "Fetched note from Redis cache!"
      return { success: true, note: JSON.parse(note_json) }
    else
      Rails.logger.info "Cache miss! Fetching from database..."
      note = user.notes.find_by(id: note_id)
      return { success: false, error: "Note not found" } unless note

      note_data = note.as_json(
        only: [:id, :title, :content, :color, :archived, :trashed, :created_at, :updated_at]
      )
      
      $redis.setex(cache_key, 600, note_data.to_json)
      Rails.logger.info " Stored note in Redis for caching."
      return { success: true, note: note_data }
    end
  end



  def self.update_note(user, note_id, params)
    note = user.notes.find_by(id: note_id)
    return { success: false, error: "Note not found" } unless note

    if note.update(params)
      $redis.del("user_#{user.id}_notes")  # Invalidate notes cache
      $redis.del("user_#{user.id}note#{note_id}")  # Invalidate specific note cache
      $redis.setex("user_#{user.id}note#{note_id}", 600, note.to_json)  # Cache updated note
      
      return { success: true, note: note }
    else
      return { success: false, error: note.errors.full_messages.join(", ") }
    end
  end


  def self.trash_note(user, note_id)
    note = user.notes.find_by(id: note_id)
    return { success: false, error: "Note not found" } unless note

    note.update(trashed: !note.trashed)

    $redis.del("user_#{user.id}_notes")  # Invalidate cache
    $redis.del("user_#{user.id}note#{note_id}")  # Invalidate specific note cache

    return { success: true, message: "Note trash status updated", note: note }
  end

  # Archive a note and update cache
  def self.archive_note(user, note_id)
    note = user.notes.find_by(id: note_id)
    return { success: false, error: "Note not found" } unless note

    note.update(archived: !note.archived)

    $redis.del("user_#{user.id}_notes")  # Clear notes cache
    $redis.del("user_#{user.id}note#{note_id}")  # Clear single note cache

    return { success: true, message: "Note archive status updated", note: note }
  end

  # Change note color and update cache
  def self.change_color(user, note_id, color)
    note = user.notes.find_by(id: note_id)
    return { success: false, error: "Note not found" } unless note

    note.update(color: color)

    $redis.del("user_#{user.id}_notes")  # Invalidate cache
    $redis.del("user_#{user.id}note#{note_id}")  # Invalidate single note cache
    $redis.setex("user_#{user.id}note#{note_id}", 600, note.to_json)  # Store updated note

    return { success: true, message: "Note color updated", note: note }
  end
end