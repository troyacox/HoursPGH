class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  before_action :require_admin, only: [:edit, :update, :destroy, :new]
  # GET /events
  # GET /events.json
  def landing

  end
  def index
    @events = Event.all
    @b = Time.now.in_time_zone("Eastern Time (US & Canada)").hour
    @c = (Time.now.in_time_zone("Eastern Time (US & Canada)").min)
    @l = Time.now.in_time_zone("Eastern Time (US & Canada)").min
  end

  def shadyside
    @b = Time.now.in_time_zone("Eastern Time (US & Canada)").hour #this is what decides whether a special will be shown of clear
    @c = (Time.now.in_time_zone("Eastern Time (US & Canada)").min)
    t= Time.now.in_time_zone("Eastern Time (US & Canada)")
  if t.wday == 0 && t.hour < 2 #these conditionals make sure the day doesn't change till 2am
    x = "Saturday"
    @day_tag = "Saturday"
  elsif t.wday == 0
    x = "Sunday"
    @day_tag = "Sunday"
  elsif t.wday == 1 && t.hour < 2
    x = "Sunday"
    @day_tag = "Sunday"
  elsif t.wday == 1
      x = "Monday"
      @day_tag = "Monday"
    elsif t.wday == 2 && t.hour < 2
      x = "Monday"
      @day_tag = "Monday"
    elsif  t.wday==2
      x = "Tuesday"
      @day_tag  = "Tuesday"
    elsif t.wday == 3 && t.hour < 2
      x = "Tuesday"
      @day_tag  = "Tuesday"
    elsif  t.wday==3
      x = "Wednesday"
      @day_tag  = "Wednesday"
    elsif t.wday == 4 && t.hour < 2
      x = "Wednesday"
      @day_tag  = "Wednesday"
    elsif  t.wday==4
      x = "Thursday"
      @day_tag  = "Thursday"
    elsif t.wday == 5 && t.hour < 2
      x = "Thursday"
      @day_tag  = "Thursday"
    elsif t.wday==5
      x = "Friday"
      @day_tag  = "Friday"
    elsif t.wday == 6 && t.hour < 2
       x = "Friday"
      @day_tag  = "Friday"
     else t.wday==6
      x= "Saturday"
      @day_tag  = "Saturday"
    end
    @v = @venues.where( neighborhood_id: 2)
    @events = Event.where(venue_id: @v.pluck(:id), day: x )
    @events_monday = Event.where(venue_id: @v.pluck(:id), day: "Monday" )
    @events_tuesday = Event.where(venue_id: @v.pluck(:id), day: "Tuesday" )
    @events_wednesday = Event.where(venue_id: @v.pluck(:id), day: "Wednesday" )
    @events_thursday = Event.where(venue_id: @v.pluck(:id), day: "Thursday" )
    @events_friday = Event.where(venue_id: @v.pluck(:id), day: "Friday" )
  end

  def south_side
    @b = Time.now.in_time_zone("Eastern Time (US & Canada)").hour
    @c = (Time.now.in_time_zone("Eastern Time (US & Canada)").min)
    t= Time.now.in_time_zone("Eastern Time (US & Canada)")
    if t.wday == 0 && t.hour < 2 #these conditionals make sure the day doesn't change till 2am
    x = "Saturday"
    @day_tag = "Saturday"
  elsif t.wday == 0
    x = "Sunday"
    @day_tag = "Sunday"
  elsif t.wday == 1 && t.hour < 2
    x = "Sunday"
    @day_tag = "Sunday"
  elsif t.wday == 1
      x = "Monday"
      @day_tag = "Monday"
    elsif t.wday == 2 && t.hour < 2
      x = "Monday"
      @day_tag = "Monday"
    elsif  t.wday==2
      x = "Tuesday"
      @day_tag  = "Tuesday"
    elsif t.wday == 3 && t.hour < 2
      x = "Tuesday"
      @day_tag  = "Tuesday"
    elsif  t.wday==3
      x = "Wednesday"
      @day_tag  = "Wednesday"
    elsif t.wday == 4 && t.hour < 2
      x = "Wednesday"
      @day_tag  = "Wednesday"
    elsif  t.wday==4
      x = "Thursday"
      @day_tag  = "Thursday"
    elsif t.wday == 5 && t.hour < 2
      x = "Thursday"
      @day_tag  = "Thursday"
    elsif t.wday==5
      x = "Friday"
      @day_tag  = "Friday"
    elsif t.wday == 6 && t.hour < 2
       x = "Friday"
      @day_tag  = "Friday"
     else t.wday==6
      x= "Saturday"
      @day_tag  = "Saturday"
    end
    @v = @venues.where( neighborhood_id: 1)
    @events = Event.where(venue_id: @v.pluck(:id), day: x )
    @events_monday = Event.where(venue_id: @v.pluck(:id), day: "Monday" )
    @events_tuesday = Event.where(venue_id: @v.pluck(:id), day: "Tuesday" )
    @events_wednesday = Event.where(venue_id: @v.pluck(:id), day: "Wednesday" )
    @events_thursday = Event.where(venue_id: @v.pluck(:id), day: "Thursday" )
    @events_friday = Event.where(venue_id: @v.pluck(:id), day: "Friday" )
  end

  def oakland
    @b = Time.now.in_time_zone("Eastern Time (US & Canada)").hour
    @c = (Time.now.in_time_zone("Eastern Time (US & Canada)").min)
    t= Time.now.in_time_zone("Eastern Time (US & Canada)")
    if t.wday == 1
      x = "Monday"
      @day_tag = "Monday"
    elsif  t.wday==2
      x = "Tuesday"
      @day_tag  = "Tuesday"
    elsif  t.wday==3
      x = "Wednesday"
      @day_tag  = "Wednesday"
    elsif  t.wday==4
      x = "Thursday"
      @day_tag  = "Thursday"
    elsif t.wday==5
      x = "Friday"
      @day_tag  = "Friday"
     elsif t.wday==6
      x= "Saturday"
      @day_tag  = "Saturday"
     else
      x= "Sunday"
      @day_tag  = "Sunday"
    end
    @v = @venues.where( neighborhood_id: 3)
    @events = Event.where(venue_id: @v.pluck(:id), day: x )
    @events_monday = Event.where(venue_id: @v.pluck(:id), day: "Monday" )
    @events_tuesday = Event.where(venue_id: @v.pluck(:id), day: "Tuesday" )
    @events_wednesday = Event.where(venue_id: @v.pluck(:id), day: "Wednesday" )
    @events_thursday = Event.where(venue_id: @v.pluck(:id), day: "Thursday" )
    @events_friday = Event.where(venue_id: @v.pluck(:id), day: "Friday" )
  end


  # GET /events/1
  # GET /events/1.json
  def show
  end

  # GET /events/new
  def new
    @event = Event.new
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new(event_params)

    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: 'Event was successfully created.' }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: 'Event was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      params.require(:event).permit(:special, :day, :venue_id, :start, :end,)
    end
end