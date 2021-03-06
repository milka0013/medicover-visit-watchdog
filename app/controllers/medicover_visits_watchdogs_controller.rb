require 'net/http'
require 'net/https'
require 'openssl'
require 'uri'

require 'sendgrid-ruby'

class MedicoverVisitsWatchdogsController < ApplicationController
  before_action :set_medicover_visits_watchdog, only: [:show, :edit, :update, :destroy]

  # GET /medicover_visits_watchdogs
  # GET /medicover_visits_watchdogs.json
  def index
    @medicover_visits_watchdogs = MedicoverVisitsWatchdog.all
    refresh_visits.delay
  end

  def refresh_visits
    # TODO fixme iterate throught avalible apis (user endpoints) and add reference from watchdog to certain api as well
    medicover_api = MedicoverApi.first


    mailClient = SendGrid::Client.new(api_user: ENV['SENDGRID_USERNAME'], api_key: ENV['SENDGRID_PASSWORD'])

    @medicover_visits_watchdogs.each do |medicover_visits_watchdog|
      @toSend = {
          "regionId" => medicover_visits_watchdog.medicover_visit_query.region,
          "bookingTypeId" => medicover_visits_watchdog.medicover_visit_query.booking_type,
          "specializationId" => medicover_visits_watchdog.medicover_visit_query.specialization,
          "clinicId" => medicover_visits_watchdog.medicover_visit_query.clinic,
          "languageId" => medicover_visits_watchdog.medicover_visit_query.language,
          "doctorId" => medicover_visits_watchdog.medicover_visit_query.doctor,
          "searchSince" => medicover_visits_watchdog.medicover_visit_query.search_since,
          "searchForNextSince" => nil, # TODO check if nil
          "periodOfTheDay" => medicover_visits_watchdog.medicover_visit_query.period_of_the_day,
          "isSetBecauseOfPcc" => medicover_visits_watchdog.medicover_visit_query.set_because_of_pcc,
          "isSetBecausePromoteSpecialization" => medicover_visits_watchdog.medicover_visit_query.is_set_because_promote_specialization
      }

      req = Net::HTTP::Post.new(medicover_api.new_visit_path, initheader = {
                                                                     'X-Requested-With' => 'XMLHttpRequest',
                                                                     'Content-Type' =>'application/json',
                                                                     'Cookie' => '.ASPXAUTH=' + "#{medicover_api.token}" + ';'
                                                                 })
      req.body = "#{@toSend.to_json}"

      resp = medicover_api.post(req)
      if resp
        respJson = JSON.parse(resp.body)
        prevDate = medicover_visits_watchdog.first_possible_appointment_date
        medicover_visits_watchdog.first_possible_appointment_date = respJson['firstPossibleAppointmentDate']

        if prevDate != medicover_visits_watchdog.first_possible_appointment_date
          mail = SendGrid::Mail.new do |m|
            m.to = ''
            m.cc = ''
            m.from = ''
            m.subject = '[medicover-visit-watchdog] Alert for your visit query'
            m.text = "previous first_possible_appointment_date: #{medicover_visits_watchdog.first_possible_appointment_date}\n" \
                        "current first_possible_appointment_date: #{respJson['firstPossibleAppointmentDate']}\n\n "
            if respJson && respJson['items'] && respJson['items'][0]
                m.text += "specializationName: #{respJson['items'][0]['specializationName']}\n" \
                          "doctorName: #{respJson['items'][0]['doctorName']}\n" \
                          "appointmentDate: #{respJson['items'][0]['appointmentDate']}\n" \
                          "clinicName: #{respJson['items'][0]['clinicName']}\n"
              end
          end

          mailClient.send(mail)
          medicover_visits_watchdog.save
        end
      end
    end
  end

  # GET /medicover_visits_watchdogs/1
  # GET /medicover_visits_watchdogs/1.json
  def show
  end

  # GET /medicover_visits_watchdogs/new
  def new
    @medicover_visits_watchdog = MedicoverVisitsWatchdog.new
  end

  # GET /medicover_visits_watchdogs/1/edit
  def edit
  end

  # POST /medicover_visits_watchdogs
  # POST /medicover_visits_watchdogs.json
  def create
    @medicover_visits_watchdog = MedicoverVisitsWatchdog.new(medicover_visits_watchdog_params)

    respond_to do |format|
      if @medicover_visits_watchdog.save
        format.html { redirect_to @medicover_visits_watchdog, notice: 'Medicover visits watchdog was successfully created.' }
        format.json { render :show, status: :created, location: @medicover_visits_watchdog }
      else
        format.html { render :new }
        format.json { render json: @medicover_visits_watchdog.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /medicover_visits_watchdogs/1
  # PATCH/PUT /medicover_visits_watchdogs/1.json
  def update
    respond_to do |format|
      if @medicover_visits_watchdog.update(medicover_visits_watchdog_params)
        format.html { redirect_to @medicover_visits_watchdog, notice: 'Medicover visits watchdog was successfully updated.' }
        format.json { render :show, status: :ok, location: @medicover_visits_watchdog }
      else
        format.html { render :edit }
        format.json { render json: @medicover_visits_watchdog.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /medicover_visits_watchdogs/1
  # DELETE /medicover_visits_watchdogs/1.json
  def destroy
    @medicover_visits_watchdog.destroy
    respond_to do |format|
      format.html { redirect_to medicover_visits_watchdogs_url, notice: 'Medicover visits watchdog was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_medicover_visits_watchdog
      @medicover_visits_watchdog = MedicoverVisitsWatchdog.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def medicover_visits_watchdog_params
      params.require(:medicover_visits_watchdog).permit(:medicover_visit_query_id, :first_possible_appointment_date)
    end
end
