class Api::V1::NotesController < ApplicationController
  before_action :authenticate_user
  skip_before_action :verify_authenticity_token

  def index
    notes = NotesService.fetch_notes(current_user)
    render json: { notes: notes }, status: :ok
  end


  def create
    Rails.logger.info("I am in controller")
    result = NotesService.create_note(current_user, note_params)
    render json: result[:success] ? { message: 'Note created', note: result[:note] } : { error: result[:error] },
    status: result[:success] ? :created : :unprocessable_entity
  end

  def show
    result = NotesService.fetch_note_by_id(current_user, params[:id])
    render json: result[:success] ? { note: result[:note] } : { error: result[:error] },
    status: result[:success] ? :ok : :not_found
  end


  def update
    result = NotesService.update_note(current_user, params[:id], note_params)
    render json: result[:success] ? { message: 'Note updated', note: result[:note] } : { error: result[:error] },
    status: result[:success] ? :ok : :unprocessable_entity
  end



  def trash
    result = NotesService.trash_note(current_user, params[:id])
    if result[:success]
      render json: { message: result[:message], note: result[:note] }, status: :ok
    else
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  end



  def archive
    result = NotesService.archive_note(current_user, params[:id])
    if result[:success]
      render json: { message: result[:message], note: result[:note] }, status: :ok
    else
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  end

  

  def change_color
    result = NotesService.change_color(current_user, params[:id], params[:color])
    render json: result[:success] ? { message: result[:message], note: result[:note] } : { error: result[:error] },
    status: result[:success] ? :ok : :unprocessable_entity
  end

  # def add_collaborator
  #   result = NotesService.add_collaborator(current_user, params[:id], params[:email])
  #   render json: result[:success] ? { message: result[:message], note: result[:note] } : { error: result[:error] },
  #          status: result[:success] ? :ok : :unprocessable_entity
  # end

  private

  def note_params
    params.require(:note).permit(:title, :content, :color)
  end
end