class GcalRouteUpdateEventsJob < ActiveJob::Base
  queue_as :default

  def perform(rte, subscriber_ids_previous)

    # NOTE:
    # So here we have to deal with cases where google subscribers are added/removed and update their calendars accordingly
    # subscriber_ids_previous set within the controller and also within the
    # make_dirty triggerred by the fullcalendar_engine model override
    # Be wary of concurrency issues related to Jobs.  Make sure calendars have been created before adding to.. etc

    subscriber_ids_previous = [] if subscriber_ids_previous.nil?  

    subscriber_ids_current = rte.google_calendar_subscribers.pluck(:id)
    added_user_ids = Array(subscriber_ids_current) - Array(subscriber_ids_previous)
    deleted_user_ids = Array(subscriber_ids_previous) - Array(subscriber_ids_current)
    updated_user_ids = (Array(subscriber_ids_current) - Array(deleted_user_ids)) - Array(added_user_ids)

    # p " "
    # p "subscriber_ids_previous = " + subscriber_ids_previous.to_s
    # p "subscriber_ids_current = " + subscriber_ids_current.to_s
    # p " "
    # p "updated_user_ids = " + updated_user_ids.to_s
    # p "added_user_ids = " + added_user_ids.to_s
    # p "deleted_user_ids = " + deleted_user_ids.to_s
    # p " "
  
    gs = GoogleServiceAccount::Calendar.new 
  
    carpool_google_cal_id = rte.carpool.google_calendar_id

    # Update the Carpool's master global calendar (that contains all routes) and that is shared with all gcal enabled members
    if !carpool_google_cal_id.blank?
      goo_event = rte.to_google_event
      gs.event_update(carpool_google_cal_id, goo_event) # cservice how to pass
    else
      # Say something nice, but not !!!
    end
    
    goo_event = rte.to_google_event

    deleted_user_ids.each do |user_id|
      google_cal_id = User.find(user_id).personal_gcal_id_for(rte.carpool.organization.id)
      gs.event_delete(google_cal_id, goo_event) if !google_cal_id.blank?
    end unless (deleted_user_ids.empty?)

    added_user_ids.each do |user_id|
      google_cal_id = User.find(user_id).personal_gcal_id_for(rte.carpool.organization.id)
      gs.event_add(google_cal_id, goo_event) # think this is getting called during an update !!!  (the event is already there for user) . why is event null? Calendars Seems OK thogh...
    end unless (added_user_ids.empty?)

    updated_user_ids.each do |user_id|
      google_cal_id = User.find(user_id).personal_gcal_id_for(rte.carpool.organization.id)
      gs.event_update(google_cal_id, goo_event)
    end unless (updated_user_ids.empty?)

  end
end
