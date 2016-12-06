
module SwellSocial
	class DiscussionTopicsController < ApplicationController

		before_filter :authenticate_user!, except: :show

		def create
			@discussion = Discussion.published.friendly.find( params[:discussion_id] )

			if current_user.read_attribute_before_type_cast( :role ).to_i < @discussion.read_attribute_before_type_cast( :availability ).to_i
				puts "You don't have permission ot access this discussion"
				redirect_to :back
				return false
			end

			@topic = DiscussionTopic.new( user: current_user, parent_obj_id: @discussion.id, parent_obj_type: @discussion.class.name, subject: params[:subject], content: params[:content] )
			if @topic.save
				record_user_event( on: @discussion, obj: @topic, content: "posted the topic: #{@topic.preview} in the discussion: #{@discussion.title}." )
				set_flash "Topic Posted"
			else
				set_flash "Couldn't create Topic", :danger, @topic
			end
			redirect_to :back
		end

		def show
			@discussion = Discussion.published.friendly.find( params[:discussion_id] )

			if current_user.read_attribute_before_type_cast( :role ).to_i < @discussion.read_attribute_before_type_cast( :availability ).to_i
				puts "You don't have permission ot access this discussion"
				redirect_to :back
				return false
			end

			@topic = @discussion.topics.friendly.find( params[:id] )
			@posts = @topic.posts.active.order( created_at: :desc ).page( params[:page] )
			record_user_event( :impression, on: @topic, content: "viewed #{@topic}" )
		end

	end

end