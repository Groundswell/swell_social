module SwellSocial
	class DiscussionsController < ApplicationController

		def index
			@discussions = Discussion.published	
		end

		def show
			@discussion = Discussion.published.friendly.find( params[:id] )

			if current_user.read_attribute_before_type_cast( :role ).to_i < @discussion.read_attribute_before_type_cast( :availability ).to_i
				puts "You don't have permission ot access this discussion"
				redirect_to :back
				return false
			end

			@topics = @discussion.topics.active.order( created_at: :desc ).page( params[:page] )
			
			record_user_event( :impression, on: @discussion, content: "viewed #{@discussion}" )
		end

	end
end