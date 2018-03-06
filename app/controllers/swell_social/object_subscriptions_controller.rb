
module SwellSocial
	class ObjectSubscriptionsController < ApplicationController

		before_action :authenticate_user!

		def create
			@sub = ObjectSubscription.where( user_id: current_user.id, parent_obj_type: params[:obj_type], parent_obj_id: params[:obj_id] ).first_or_initialize
			@button_class = params[:button_class]
			
			respond_to do |format|
			  if @sub.active!
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
					format.html { redirect_to(:back, set_flash: 'Unsubscribed') }
					format.js { render 'destroy' }
				else
					format.html { redirect_to(:back, set_flash: 'Could not unsubscribe') }
					format.js { render 'destroy' }
				end
			end

		end

		def show
			# wtf - http delete method doesn't work????
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
				set_flash "Success"
				redirect_back( fallback_location: '/' )

			else
				set_flash "Error"
				redirect_back( fallback_location: '/' )
			end

		end


		def index
			# huh?
			create
		end

	end

end