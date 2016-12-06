module SwellSocial
	
	class NotificationsController < ApplicationController

		def update
			if params[:id] == 'read_all'
				current_user.notifications.not_read.update_all( status: 3 )
			end
			redirect_to :back
		end

	end

end