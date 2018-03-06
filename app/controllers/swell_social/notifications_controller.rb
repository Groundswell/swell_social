module SwellSocial
	
	class NotificationsController < ApplicationController

		def update
			if params[:id] == 'read_all'
				current_user.notifications.not_read.update_all( status: 3 )
			end
			redirect_back( fallback_location: '/' )
		end

	end

end