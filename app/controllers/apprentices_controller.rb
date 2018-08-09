require 'reporting/data_parser'
require 'apprentices/apprentices_interactor'
require 'apprentices/apprentice_list_presenter'
require 'apprentices/student_list_presenter'
require 'warehouse/identifiers'

# require 'date'

# require 'applicant_dispatch/dispatcher'
# require 'repository'


class ApprenticesController < ApplicationController
  before_filter :require_admin

  def index
    begin

      @residents = Footprints::Repository.applicant.get_all_hired_residents
      @students =  Footprints::Repository.applicant.get_all_hired_students
    rescue ApprenticesInteractor::AuthenticationError => e
      error_message = "You are not authorized through warehouse to use this feature"
      Rails.logger.error(e.message)
      Rails.logger.error(e.backtrace)
      redirect_to root_path, :flash => { :error => [error_message] }
    end  
  end

  def edit
    @resident = Footprints::Repository.applicant.find_by_id(id)
  end

  def update
    begin
      raw_resident = interactor.fetch_resident_by_id(id)
      interactor.modify_resident_end_date!(raw_resident, end_date)
      interactor.modify_corresponding_craftsman_start_date!(raw_resident, next_monday(end_date))
      redirect_to "/apprentices/"
    rescue ArgumentError => e
      error_message = "Please provide a valid date"
      redirect_to "/apprentices/#{id}", :flash => { :error => [error_message] }
    end
  end

  private

  def interactor
    @interactor ||= ApprenticesInteractor.new(session[:id_token])
  end

  def apprentice_params
    params.require(:apprentice).permit(:end_date)
  end

  def id
    params[:id].to_i
  end

  def end_date
    DateTime.parse(apprentice_params[:end_date])
  end

  def next_monday(date)
    date.next_week.at_beginning_of_week 
  end

  # EDITED Below

  #  def new
  #   @residents = repo.apprentices.new
  # end

  # def create
  #   @applicant = repo.applicant.new(applicant_params)
  #   @applicant.save!
  #   redirect_to(applicant_path(@applicant), :notice => "Successfully created #{@applicant.name}")
  # rescue StandardError => e
  #   flash.now[:error] = [e.message]
  #   render :new
  # endf

end





