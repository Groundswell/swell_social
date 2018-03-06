module SwellSocial
	class UserPostsController < ApplicationController

		before_action 	:authenticate_user!
		before_action   :get_parent_obj, only: :create


		def admin
			authorize!( :admin, Comment )
			@posts = UserPost.order( created_at: :desc )
			render layout: 'admin'
		end

		def index
			create
		end

		def create

			@post = UserPost.new( type: params[:comment_type], parent_obj_id: @parent_obj.id, parent_obj_type: @parent_obj.class.name, user: current_user, subject: params[:subject], content: params[:content], status: ( params[:draft] ? 'draft' : 'active' ), reply_to_id: params[:reply_to_id] )
			@context_selector = ''
			@context_selector = "#{params[:context_selector]} " if params[:context_selector].present?
			@direction = (params[:direction] || 'desc').to_sym

			respond_to do |format|
				if @post.save
					SwellSocial::UserPostWorker.perform_async_if_possible( @post.id )
					format.html { redirect_to(:back, set_flash: 'Thanks for your comment') }
					format.js {}
				else
					format.html { redirect_to(:back, set_flash: 'Comment could not be saved') }
					format.js {}
				end
			end

			# redirect_to :back
		end

		def destroy
			authorize!( :admin, UserPost )
			@post = UserPost.find( params[:id] )
			@post.update( status: 'deleted' )
			set_flash 'Comment Deleted'
			redirect_back( fallback_location: '/' )
		end

		def edit
			authorize!( :admin, UserPost )
			@post = UserPost.find( params[:id] )
			render layout: 'admin'
		end

		def update
			@post = UserPost.find( params[:id] )
			@context_selector = ''
			@context_selector = "#{params[:context_selector]} " if params[:context_selector].present?

			authorize( @post, :admin_update? )

			respond_to do |format|
				if @post.update( comment_params )
					SwellSocial::UserPostWorker.perform_async_if_possible( @post.id )
					format.html { redirect_to(:back, set_flash: 'Comment updated') }
					format.js {}
				else
					format.html { redirect_to(:back, set_flash: 'Comment could not be updated') }
					format.js {}
				end
			end

		end


		private

			def comment_params
				params.require( :user_post ).permit( :title, :subject, :user_id, :content, :status )
			end

			def get_parent_obj
				if params[:type].present?
					@parent_obj = params[:type].constantize.where( id: params[:id] ).first
				else
					set_flash 'Can not comment without parent', :error
					redirect_back( fallback_location: '/' )
					return false
				end
			end

	end
end
