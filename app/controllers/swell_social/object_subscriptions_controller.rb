
module SwellSocial
	class ObjectSubscriptionsController < ApplicationController

		before_filter :authenticate_user!

		def create
			@sub = ObjectSubscription.where( user_id: current_user.id, parent_obj_type: params[:obj_type], parent_obj_id: params[:obj_id] ).first_or_initialize
			@button_class = params[:button_class]
			
			respond_to do |format|
			  if @sub.active!
					record_user_event( event: "subscribe", on: @sub.parent_obj, obj: @sub, content: "subscribed to the #{@sub.parent_obj.class.name.downcase} <a href='#{@sub.parent_obj.try(:url)}'>#{@sub.parent_obj.to_s}</a>!" )
					format.html { redirect_to(:back, set_flash: 'Subscribed') }
					format.js { render 'create' }
			  else
					format.html { redirect_to(:back, set_flash: 'Error') }
					format.js { render 'create' }
			  end
			end

		end


		def destroy
			@sub_id = params[:id]
			if @sub_id == '0'
				@sub = ObjectSubscription.active.where( user_id: current_user.id ).find_by( parent_obj_type: params[:obj_type], parent_obj_id: params[:obj_id] )
				@sub_id = @sub.id
			else
				@sub = ObjectSubscription.active.where( user_id: current_user.id ).find_by( id: @sub_id )
			end
			@button_class = params[:button_class]

			respond_to do |format|
				if @sub.present? && @sub.delete
					record_user_event( event: "unsubscribe", user: current_user, on: @sub.parent_obj, content: "unsubscribed from the #{@sub.parent_obj.class.name.downcase} <a href='#{@sub.parent_obj.try(:url)}'>#{@sub.parent_obj.to_s}</a>!" )
					format.html { redirect_to(:back, set_flash: 'Unsubscribed') }
					format.js { render 'destroy' }
				else
					format.html { redirect_to(:back, set_flash: 'Could not unsubscribe') }
					format.js { render 'destroy' }
				end
			end

		end

		def show
			destroy
		end


		def update
			@sub_id = params[:id]
			if @sub_id == '0'
				@sub = ObjectSubscription.active.where( user_id: current_user.id ).find_by( parent_obj_type: params[:obj_type], parent_obj_id: params[:obj_id] )
				@sub_id = @sub.id
			else
				@sub = ObjectSubscription.active.where( user_id: current_user.id ).find_by( id: @sub_id )
			end

			@sub.attributes = params.require( :object_subscription ).permit( :mute, :availability, :status )

			if @sub.save

				redirect_to(:back, set_flash: 'Success')

			else

				redirect_to(:back, set_flash: 'Error')

			end

		end


		def index
			create
		end

	end

end