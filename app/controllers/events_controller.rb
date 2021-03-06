class EventsController < ApplicationController
 

   after_filter "save_my_previous_url", only: [:new]
 # before_action :admin_redirect, only: [:under_construction]
   #before_action :require_admin_construction, except: [:under_construction]
  before_action :set_event, only: [:show, :edit, :update, :destroy, :event_upvote, :event_downvote, :event_verified]
  before_action :authenticate_user!, only: [:new, :edit, :update, :destroy]
 # before_action :require_owner_event, only: [:edit, :update, :destroy]
  before_action :verified_venues, only: [:shadyside, :south_side, :lawrenceville, :oakland, :north_side, :bloomfield, :east_liberty, :strip_district, :downtown, :squirrel_hill]
  before_action :event_time, only: [:daily_mailer,:shadyside, :south_side, :lawrenceville, :oakland, :north_side, :bloomfield, :east_liberty, :strip_district, :downtown, :squirrel_hill]
  autocomplete :event, :special, :full => true
  # GET /events
  # GET /events.json

  def under_construction
  end
  
  def event_verified
    if @event.event_verify || @event.varified_user
        @event.update_attribute(:event_verify, Time.now)
        @event.update_attribute(:varified_user, current_user.id)
        current_user.increment!(:experience, by = 10)
    else
        @event.event_verify = Time.now
        @event.varified_user = current_user.id
        @event.save
    end 
  end

  def daily_mailer
    @new_events = Event.after(Date.today - 7).to_a
    @updated_events = Event.after(Date.today - 7, field: :updated_at).to_a
    @users = User.where(id: [1,4])
    @users.each do |user|
      users_likes = user.get_up_voted Event.where(day: @day_specials)
      if users_likes != 0
        EventMailer.event_reminder_email(user, users_likes).deliver
        EventMailer.welcome_email(user, users_likes).deliver
      end
    end
  end


  def verified_venues
    @claim = Claim.new
    @today = Time.now
    @week_ago = 7.day.ago
    @month_ago = 1.month.ago
    @verified_this_week = Venue.between_times(@week_ago, @today)
    @verified_after_week = Venue.between_times(@month_ago,@week_ago)
    @verified_month_ago = Venue.before(@month_ago)
    @owned_venues = Venue.where("owner > ?", 1)
    
    claim_index = Claim.all
    claim_index.each do |claim|
        if claim.status == 1 && (claim.created_at + 7.days).to_date == Date.current
            claim.event.status = 1
            claim.event.save
            claim.destroy
        elsif claim.status == 0 && (claim.created_at + 7.days).to_date == Date.current
            claim.destroy
        end
    end
    
    
  end

  def event_time
    @b = Time.now.in_time_zone("Eastern Time (US & Canada)").hour
    @c = (Time.now.in_time_zone("Eastern Time (US & Canada)").min)
    t= Time.now.in_time_zone("Eastern Time (US & Canada)")

    if t.wday == 0 && @b < 2
      x = 6
    elsif @b < 2
      x = t.wday - 1
    else
      x = t.wday
    end

       if  x == 0
       @day_tag = "Sunday"
       elsif x == 1
       @day_tag = "Monday"
       elsif x == 2
       @day_tag = "Tuesday"
       elsif x == 3
       @day_tag = "Wednesday"
       elsif x == 4
       @day_tag = "Thursday"
       elsif x == 5
       @day_tag = "Friday"
       else
       @day_tag = "Saturday"
       end


      if  x == 0
       @day_specials = ["Sunday","Everyday","Weekend"]
       elsif x == 1
       @day_specials = ["Monday","Everyday","Weekdays"]
       elsif x == 2
       @day_specials = ["Tuesday","Everyday","Weekdays"]
       elsif x == 3
       @day_specials = ["Wednesday","Everyday","Weekdays"]
       elsif x == 4
       @day_specials = ["Thursday","Everyday","Weekdays"]
       elsif x == 5
       @day_specials = ["Friday","Everyday","Weekdays"]
       else
       @day_specials = ["Saturday","Everyday","Weekend"]
       end
  end

  def event_upvote
  @event.liked_by current_user
    current_user.increment!(:experience, by = 5)
  end

  def event_downvote
  @event.unliked_by current_user
    current_user.decrement!(:experience, by = 5)
  end

  def landing
    #this is for OG
    @topic = "Hours"
    @topic_description = "Hours provides Happy Hours/Specials and Featured dishes throughout Pittsburgh"
    @page_url = ""
    @new_events = Event.after(Date.today - 7).to_a
    @updated_events = Event.after(Date.today - 7, field: :updated_at).to_a
    
    @top_users = []
    User.all.each do |user|
        if user.fullname
            @top_users.push(user)
        end 
    end 
   
  end

  def urbanist
    #this is for OG
    @topic = "Happy Hours at Urbanist Approved Venues in Pittsburgh"
    @topic_description = "URBANIST guide aims to produce the best printed city guides in the nation"


    @autocomplete_path = urbanist_autocomplete_event_special_path
    @neighborhood_path = urbanist_path
    @today = Time.now
    @week_ago = 7.day.ago
    @month_ago = 1.month.ago

    @shadyside_venues = Venue.where(urbanist: true, neighborhood_id: 2)
    @south_side_venues = Venue.where(urbanist: true, neighborhood_id: 1)
    @oakland_venues = Venue.where(urbanist: true, neighborhood_id: 3)
    @lawrenceville_bloomfield_venues = Venue.where(urbanist: true, neighborhood_id: [7,6])
    @market_square_venues = Venue.where(urbanist: true, neighborhood_id: 5)
    @strip_district_venues = Venue.where(urbanist: true, neighborhood_id: 11)

    @urbanist_venues = Venue.where(urbanist: true)
    @todays_feature =  DailySpecial.today

    @verified_this_weeku = Venue.between_times(@week_ago, @today).where(urbanist: true)
    @verified_after_weeku = Venue.between_times(@month_ago,@week_ago).where(urbanist: true)
    @verified_month_agou = Venue.before(@month_ago).where(urbanist: true)



    @b = Time.now.in_time_zone("Eastern Time (US & Canada)").hour
    @c = (Time.now.in_time_zone("Eastern Time (US & Canada)").min)
    t= Time.now.in_time_zone("Eastern Time (US & Canada)")

    if t.wday == 0 && @b < 2
      x = 6
    elsif @b < 2
      x = t.wday - 1
    else
      x = t.wday
    end

       if  x == 0
       @day_tag = "Sunday"
       elsif x == 1
       @day_tag = "Monday"
       elsif x == 2
       @day_tag = "Tuesday"
       elsif x == 3
       @day_tag = "Wednesday"
       elsif x == 4
       @day_tag = "Thursday"
       elsif x == 5
       @day_tag = "Friday"
       else
       @day_tag = "Saturday"
       end




   @v = @venues.where( urbanist: true)

   @events = Event.where(day: @day_tag)
   if params[:search]
      @events = Event.where(venue_id: @v.pluck(:id), day: @day_tag).special_like("%#{params[:search]}%").order('special')
    else
    end
  end

  def save_my_previous_url
    # session[:previous_url] is a Rails built-in variable to save last url.
    session[:my_previous_url] = URI(request.referer || '').path
  end

  def index
    @events = Event.all
    @v = @venues.all
    @daily_specials = DailySpecial.where(venue_id: @v.pluck(:id), day: @day_tag)
    @b = Time.now.in_time_zone("Eastern Time (US & Canada)").hour
    @c = (Time.now.in_time_zone("Eastern Time (US & Canada)").min)
    @l = Time.now.in_time_zone("Eastern Time (US & Canada)").min
  end

 def shadyside
   @page_url = "shadyside"
   @autocomplete_path = shadyside_autocomplete_event_special_path
   @neighborhood_path = shadyside_path
   @neighborhood_tag = 2

   @v = @venues.where( neighborhood_id: 2)
   @daily_specials = DailySpecial.where(venue_id: @v.pluck(:id), day: @day_tag)
   @scheduled_events = Event.where(venue_id: @v.pluck(:id), event_date: Date.today)
   @events = Event.where(venue_id: @v.pluck(:id), day: @day_specials)
   @tag_events = Event.where(venue_id: @v.pluck(:id), day: @day_specials)
   @tag_topic = ""
    if params[:search]
      @events = Event.where(venue_id: @v.pluck(:id), day: @day_specials).special_like("%#{params[:search]}%").order('special')
      @tag_topic = "##{params[:search]}"
    elsif params[:shady_tag]
      @events = Event.tagged_with(params[:shady_tag]).where(venue_id: @v.pluck(:id), day: @day_specials)
      @tag_topic = "##{params[:shady_tag]}"
    end
    #@todays_feature =  DailySpecial.where(venue_id: @v.pluck(:id))
    @todays_feature =  DailySpecial.where(venue_id: @v.pluck(:id)).today

    #this is for OG
    @topic = "Hours in #{Neighborhood.where(id: @neighborhood_tag).first.name}"
    @topic_description = "Never miss another happy hour in Pittsburgh with HoursPGH"

  end


  def south_side
   @page_url = "southside"
   @autocomplete_path = south_side_autocomplete_event_special_path
   @neighborhood_path = south_side_path
   @neighborhood_tag = 1
   @v = @venues.where( neighborhood_id: 1)
   @daily_specials = DailySpecial.where(venue_id: @v.pluck(:id))
   @scheduled_events = Event.where(venue_id: @v.pluck(:id), event_date: Date.today)
   @events = Event.where(venue_id: @v.pluck(:id), day: @day_specials)
   @tag_events = Event.where(venue_id: @v.pluck(:id), day: @day_specials)
   @tag_topic = ""
    if params[:search]
      @events = Event.where(venue_id: @v.pluck(:id), day: @day_specials).special_like("%#{params[:search]}%").order('special')
      @tag_topic = "##{params[:search]}"    
    elsif params[:south_tag]
      @events = Event.tagged_with(params[:south_tag]).where(venue_id: @v.pluck(:id), day: @day_specials)
      @tag_topic = "##{params[:south_tag]}"
    end

    #@todays_feature =  DailySpecial.where(venue_id: @v.pluck(:id))
    @todays_feature =  DailySpecial.where(venue_id: @v.pluck(:id)).today

     #this is for OG
    @topic = "Hours in #{Neighborhood.where(id: @neighborhood_tag).first.name}"
    @topic_description = "Never miss another happy hour in Pittsburgh with HoursPGH"

  end

  def oakland
    @page_url = "oakland"
    @autocomplete_path = oakland_autocomplete_event_special_path
    @neighborhood_path = oakland_path


   @neighborhood_tag = 3
   @v = @venues.where( neighborhood_id: 3)
   @daily_specials = DailySpecial.where(venue_id: @v.pluck(:id))
   @events = Event.where(venue_id: @v.pluck(:id), day: @day_specials)
   @tag_events = Event.where(venue_id: @v.pluck(:id), day: @day_specials)
   @tag_topic = ""
    if params[:search]
      @events = Event.where(venue_id: @v.pluck(:id), day: @day_specials).special_like("%#{params[:search]}%").order('special')
      @tag_topic = "##{params[:search]}"
    elsif params[:oakland_tag]
      @events = Event.tagged_with(params[:oakland_tag]).where(venue_id: @v.pluck(:id), day: @day_specials)
      @tag_topic = "##{params[:oakland_tag]}"
    end

    #@todays_feature =  DailySpecial.where(venue_id: @v.pluck(:id))
    @todays_feature =  DailySpecial.where(venue_id: @v.pluck(:id)).today

     #this is for OG
    @topic = "Hours in #{Neighborhood.where(id: @neighborhood_tag).first.name}"
    @topic_description = "Never miss another happy hour in Pittsburgh with HoursPGH"

  end

  def downtown
    @page_url = "downtown"
    @autocomplete_path = downtown_autocomplete_event_special_path
    @neighborhood_path = downtown_path


   @neighborhood_tag = 5
   @v = @venues.where( neighborhood_id: 5)
   @daily_specials = DailySpecial.where(venue_id: @v.pluck(:id))
   @scheduled_events = Event.where(venue_id: @v.pluck(:id), event_date: Date.today)
   @events = Event.where(venue_id: @v.pluck(:id), day: @day_specials)
   @tag_events = Event.where(venue_id: @v.pluck(:id), day: @day_specials)
   
   
   @tag_topic = ""
    if params[:search]
      @events = Event.where(venue_id: @v.pluck(:id), day: @day_specials).special_like("%#{params[:search]}%").order('special')
      @tag_topic = "##{params[:search]}"
     elsif params[:down_tag]
      @events = Event.tagged_with(params[:down_tag]).where(venue_id: @v.pluck(:id), day: @day_specials)
     @tag_topic = "##{params[:down_tag]}"
    end

    #@todays_feature =  DailySpecial.where(venue_id: @v.pluck(:id))
    @todays_feature =  DailySpecial.where(venue_id: @v.pluck(:id)).today

     #this is for OG
    @topic = "Hours in #{Neighborhood.where(id: @neighborhood_tag).first.name}"
    @topic_description = "Never miss another happy hour in Pittsburgh with HoursPGH"

  end


  def lawrenceville
   @page_url = "lawrencville"
   @autocomplete_path = lawrenceville_autocomplete_event_special_path
   @neighborhood_path = lawrenceville_path
   @neighborhood_tag = 7
   hood_id = Neighborhood.where(id: 7).first.id
   @v = @venues.where( neighborhood_id: hood_id)
   @daily_specials = DailySpecial.where(venue_id: @v.pluck(:id))
   @events = Event.where(venue_id: @v.pluck(:id), day: @day_specials)
   @tag_events = Event.where(venue_id: @v.pluck(:id), day: @day_specials)
   @tag_topic = ""
   if params[:search]
     @events = Event.where(venue_id: @v.pluck(:id), day: @day_specials).special_like("%#{params[:search]}%").order('special')
     @tag_topic = "##{params[:search]}"
   elsif params[:law_tag]
      @events = Event.tagged_with(params[:law_tag]).where(venue_id: @v.pluck(:id), day: @day_specials)
     @tag_topic = "##{params[:law_tag]}" 
   end

    #@todays_feature =  DailySpecial.where(venue_id: @v.pluck(:id))
    @todays_feature =  DailySpecial.where(venue_id: @v.pluck(:id)).today

     #this is for OG
    @topic = "Hours in #{Neighborhood.where(id: @neighborhood_tag).first.name}"
    @topic_description = "Never miss another happy hour in Pittsburgh with HoursPGH"
  end


  def bloomfield
   @page_url = "bloomfield"
   @autocomplete_path = bloomfield_autocomplete_event_special_path
   @neighborhood_path = bloomfield_path
   @neighborhood_tag = 6
   hood_id = Neighborhood.where(id: 6).first.id
   @v = @venues.where( neighborhood_id: hood_id)
   @daily_specials = DailySpecial.where(venue_id: @v.pluck(:id))
   @events = Event.where(venue_id: @v.pluck(:id), day: @day_specials)
   @tag_events = Event.where(venue_id: @v.pluck(:id), day: @day_specials)
   @tag_topic = ""
    if params[:search]
      @events = Event.where(venue_id: @v.pluck(:id), day: @day_specials).special_like("%#{params[:search]}%").order('special')
      @tag_topic = "##{params[:search]}"
    elsif params[:bloom_tag]
      @events = Event.tagged_with(params[:bloom_tag]).where(venue_id: @v.pluck(:id), day: @day_specials)
     @tag_topic = "##{params[:bloom_tag]}"
    end

    #@todays_feature =  DailySpecial.where(venue_id: @v.pluck(:id))
    @todays_feature =  DailySpecial.where(venue_id: @v.pluck(:id)).today

     #this is for OG
    @topic = "Hours in #{Neighborhood.where(id: @neighborhood_tag).first.name}"
    @topic_description = "Never miss another happy hour in Pittsburgh with HoursPGH"
  end


  def east_liberty
   @page_url = "east_liberty"
   @autocomplete_path = east_liberty_autocomplete_event_special_path
   @neighborhood_path = east_liberty_path
   @neighborhood_tag = 9
   hood_id = Neighborhood.where(id: 9).first.id
   @v = @venues.where( neighborhood_id: hood_id)
   @daily_specials = DailySpecial.where(venue_id: @v.pluck(:id))
   @events = Event.where(venue_id: @v.pluck(:id), day: @day_specials)
   @tag_events = Event.where(venue_id: @v.pluck(:id), day: @day_specials)
   @tag_topic = ""
    if params[:search]
      @events = Event.where(venue_id: @v.pluck(:id), day: @day_specials).special_like("%#{params[:search]}%").order('special')
      @tag_topic = "##{params[:search]}"
    elsif params[:east_tag]
      @events = Event.tagged_with(params[:east_tag]).where(venue_id: @v.pluck(:id), day: @day_specials)
      @tag_topic = "##{params[:east_tag]}"
    end

    #@todays_feature =  DailySpecial.where(venue_id: @v.pluck(:id))
    @todays_feature =  DailySpecial.where(venue_id: @v.pluck(:id)).today

     #this is for OG
    @topic = "Hours in #{Neighborhood.where(id: @neighborhood_tag).first.name}"
    @topic_description = "Never miss another happy hour in Pittsburgh with HoursPGH"
  end


  def strip_district
   @page_url = "strip_district"
   @autocomplete_path = strip_district_autocomplete_event_special_path
   @neighborhood_path = strip_district_path
   @neighborhood_tag = 11
   hood_id = Neighborhood.where(id: 11).first.id
   @v = @venues.where( neighborhood_id: hood_id)
   @daily_specials = DailySpecial.where(venue_id: @v.pluck(:id))
   @events = Event.where(venue_id: @v.pluck(:id), day: @day_specials)
   @tag_events = Event.where(venue_id: @v.pluck(:id), day: @day_specials)
   @tag_topic = ""
   if params[:search]
     @events = Event.where(venue_id: @v.pluck(:id), day: @day_specials).special_like("%#{params[:search]}%").order('special')
     @tag_topic = "##{params[:search]}"
   elsif params[:strip_tag]
      @events = Event.tagged_with(params[:strip_tag]).where(venue_id: @v.pluck(:id), day: @day_specials)
     @tag_topic = "##{params[:strip_tag]}"
   end

    #@todays_feature =  DailySpecial.where(venue_id: @v.pluck(:id))
    @todays_feature =  DailySpecial.where(venue_id: @v.pluck(:id)).today

     #this is for OG
    @topic = "Hours in #{Neighborhood.where(id: @neighborhood_tag).first.name}"
    @topic_description = "Never miss another happy hour in Pittsburgh with HoursPGH"
  end

  def squirrel_hill
   @page_url = "squirrel_hill"
   @autocomplete_path = bloomfield_autocomplete_event_special_path
   @neighborhood_path = bloomfield_path
   @neighborhood_tag = 10
   hood_id = Neighborhood.where(id: 10).first.id
   @v = @venues.where( neighborhood_id: hood_id)
   @daily_specials = DailySpecial.where(venue_id: @v.pluck(:id))
   @events = Event.where(venue_id: @v.pluck(:id), day: @day_specials)
   @tag_events = Event.where(venue_id: @v.pluck(:id), day: @day_specials)
   @tag_topic = ""
   if params[:search]
      @events = Event.where(venue_id: @v.pluck(:id), day: @day_specials).special_like("%#{params[:search]}%").order('special')
      @tag_topic = "##{params[:search]}"
   elsif params[:sq_tag]
      @events = Event.tagged_with(params[:sq_tag]).where(venue_id: @v.pluck(:id), day: @day_specials)
      @tag_topic = "##{params[:sq_tag]}"
   end

    #@todays_feature =  DailySpecial.where(venue_id: @v.pluck(:id))
    @todays_feature =  DailySpecial.where(venue_id: @v.pluck(:id)).today

     #this is for OG
    @topic = "Hours in #{Neighborhood.where(id: @neighborhood_tag).first.name}"
    @topic_description = "Never miss another happy hour in Pittsburgh with HoursPGH"
  end

  def north_side
   @page_url = "north_side"
   @autocomplete_path = north_side_autocomplete_event_special_path
   @neighborhood_path = north_side_path
   @neighborhood_tag = 12
   hood_id = Neighborhood.where(id: 12).first.id
   @v = @venues.where( neighborhood_id: hood_id)
   @daily_specials = DailySpecial.where(venue_id: @v.pluck(:id))
   @events = Event.where(venue_id: @v.pluck(:id), day: @day_specials)
   @tag_events = Event.where(venue_id: @v.pluck(:id), day: @day_specials)
   @tag_topic = ""
   if params[:search]
      @events = Event.where(venue_id: @v.pluck(:id), day: @day_specials).special_like("%#{params[:search]}%").order('special')
      @tag_topic = "##{params[:search]}"
   elsif params[:north_tag]
      @events = Event.tagged_with(params[:north_tag]).where(venue_id: @v.pluck(:id), day: @day_specials)
      @tag_topic = "##{params[:north_tag]}"
   end

    #@todays_feature =  DailySpecial.where(venue_id: @v.pluck(:id))
    @todays_feature =  DailySpecial.where(venue_id: @v.pluck(:id)).today

     #this is for OG
    @topic = "Hours in #{Neighborhood.where(id: @neighborhood_tag).first.name}"
    @topic_description = "Never miss another happy hour in Pittsburgh with HoursPGH"
  end

  def mt_washington
   @page_url = "mt_washington"
   @autocomplete_path = mt_washington_autocomplete_event_special_path
   @neighborhood_path = mt_washington_path
   @neighborhood_tag = 13
   hood_id = Neighborhood.where(id: 13).first.id
   @v = @venues.where( neighborhood_id: hood_id)
   @daily_specials = DailySpecial.where(venue_id: @v.pluck(:id))
   @events = Event.where(venue_id: @v.pluck(:id), day: @day_specials)
   @tag_events = Event.where(venue_id: @v.pluck(:id), day: @day_specials)
   @tag_topic = ""
   if params[:search]
      @events = Event.where(venue_id: @v.pluck(:id), day: @day_specials).special_like("%#{params[:search]}%").order('special')
      @tag_topic = "##{params[:search]}"
   elsif params[:mt_tag]
      @events = Event.tagged_with(params[:mt_tag]).where(venue_id: @v.pluck(:id), day: @day_specials)
      @tag_topic = "##{params[:mt_tag]}"
   end

    #@todays_feature =  DailySpecial.where(venue_id: @v.pluck(:id))
    @todays_feature =  DailySpecial.where(venue_id: @v.pluck(:id)).today

     #this is for OG
    @topic = "Hours in #{Neighborhood.where(id: @neighborhood_tag).first.name}"
    @topic_description = "Never miss another happy hour in Pittsburgh with HoursPGH"
  end

  # GET /events/1
  # GET /events/1.json
  def show
  end

  # GET /events/new
  def new
    @event = current_user.events.build
    #@event = Event.new
    @back_url = session[:my_previous_url]
  end

  # GET /events/1/edit
  def edit
  end

  # POST /events
  # POST /events.json
  def create

    expire_action :action => [:shadyside, :south_side, :lawrenceville, :oakland, :bloomfield, :strip_district, :downtown]
    @event = current_user.events.build(event_params)
    #@event = Event.new(event_params)
    if @event.day == "Weekdays"
        @event.day = "Monday"
        @event_tue = current_user.events.build(event_params)
        @event_tue.day = "Tuesday"
        @event_wed = current_user.events.build(event_params)
        @event_wed.day = "Wednesday"
        @event_thu = current_user.events.build(event_params)
        @event_thu.day = "Thursday"
        @event_fri = current_user.events.build(event_params)
        @event_fri.day = "Friday"


        respond_to do |format|
        if @event.save && @event_tue.save && @event_wed.save && @event_thu.save && @event_fri.save
            #EventMailer.sample_email(current_user, @event).deliver

            Venue.where(id: @event.venue_id).first.update_attribute(:venue_verify, Time.now)
            format.html { redirect_to Venue.where(id: @event.venue_id).first, notice: 'Hour was successfully created.' }
            format.json { head :no_content }
            format.js { render :layout => false }
        else
            format.html { render :new }
            format.json { render json: @event.errors, status: :unprocessable_entity }
        end
    end
    elsif @event.day == "Everyday"
        @event.day = "Monday"
        @event_tue = current_user.events.build(event_params)
        @event_tue.day = "Tuesday"
        @event_wed = current_user.events.build(event_params)
        @event_wed.day = "Wednesday"
        @event_thu = current_user.events.build(event_params)
        @event_thu.day = "Thursday"
        @event_fri = current_user.events.build(event_params)
        @event_fri.day = "Friday"
        @event_sat = current_user.events.build(event_params)
        @event_sat.day = "Saturday"
        @event_sun = current_user.events.build(event_params)
        @event_sun.day = "Sunday"


        respond_to do |format|
            if @event.save && @event_tue.save && @event_wed.save && @event_thu.save && @event_fri.save && @event_sat.save && @event_sun.save
            #EventMailer.sample_email(current_user, @event).deliver

            Venue.where(id: @event.venue_id).first.update_attribute(:venue_verify, Time.now)
            format.html { redirect_to Venue.where(id: @event.venue_id).first, notice: 'Hour was successfully created.' }
            format.json { head :no_content }
            format.js { render :layout => false } 
            else
            format.html { render :new }
            format.json { render json: @event.errors, status: :unprocessable_entity }
            end
        end
   elsif @event.day == "Weekend"
    @event_sat = current_user.events.build(event_params)
    @event_sat.day = "Saturday"
    @event_sun = current_user.events.build(event_params)
    @event_sun.day = "Sunday"

    respond_to do |format|
      if @event.save && @event_sun.save
        #EventMailer.sample_email(current_user, @event).deliver

        Venue.where(id: @event.venue_id).first.update_attribute(:venue_verify, Time.now)
        format.html { redirect_to Venue.where(id: @event.venue_id).first, notice: 'Hour was successfully created.' }
        format.json { head :no_content }
        format.js { render :layout => false }
      else
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
    else
      respond_to do |format|
      if @event.save
        #EventMailer.sample_email(current_user, @event).deliver

        Venue.where(id: @event.venue_id).first.update_attribute(:venue_verify, Time.now)
        format.html { redirect_to Venue.where(id: @event.venue_id).first, notice: 'Hour was successfully created.' }
        format.json { head :no_content }
        format.js { render :layout => false }
      else
        format.html { render :new }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
    end
  end

  # PATCH/PUT /events/1
  # PATCH/PUT /events/1.json
  def update
     expire_action :action => [:shadyside, :south_side, :lawrenceville, :oakland, :bloomfield, :strip_district, :downtown]
    respond_to do |format|
      if @event.update(event_params)
        Venue.where(id: @event.venue_id).first.update_attribute(:venue_verify, Time.now)
        format.html { redirect_to Venue.where(id: @event.venue_id).first, notice: 'Hour was successfully updated.' }
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
     expire_action :action => [:shadyside, :south_side, :lawrenceville, :oakland, :bloomfield, :strip_district, :downtown]
    @event.destroy
    respond_to do |format|
      Venue.where(id: @event.venue_id).first.update_attribute(:venue_verify, Time.now)
      format.html { redirect_to Venue.where(id: @event.venue_id).first, notice: 'Event was successfully destroyed.' }
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
      params.require(:event).permit(:special,:detail, :day, :venue_id, :start, :end, :tag_list, :event_verify, :varified_user, :event_date)
    end
end
