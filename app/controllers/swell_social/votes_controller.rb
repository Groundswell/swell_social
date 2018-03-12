
module SwellSocial
	class VotesController < ApplicationController
		before_action :authenticate_user!


		def index
			create
		end

		def create
			@vote = Vote.where( user_id: current_user.id, parent_obj_type: params[:parent_obj_type], parent_obj_id: params[:parent_obj_id], vote_type: params[:vote_type], context: params[:context] ).first_or_initialize
			@vote.val = params[:val].try( :to_i ) || params[:up].try( :to_i ) || 1

			if @vote.save
				@vote.update_parent_caches

				respond_to do |format|
					format.html { redirect_back( fallback_location: '/' ) }
					format.js {}
				end
			else
				@error = 'Vote could not be saved'
				set_flash @error, :error, @vote

				respond_to do |format|
					format.html { redirect_to :back }
					format.js {}
				end
			end
		end


		def destroy
			@vote = Vote.where( user: current_user ).find_by( parent_obj_id: params[:id], parent_obj_type: params[:parent_obj_type] ) if params[:parent_obj_type].present? && params[:parent_obj_id].nil?
			@vote ||= Vote.where( user: current_user ).find_by( context: params[:id] )
			@vote ||= Vote.where( user: current_user ).find( params[:id] )

			@vote.destroy
			@vote.update_parent_caches

			respond_to do |format|
				format.html { redirect_back( fallback_location: '/' ) }
				format.js {}
			end
		end

		def update
			# this action flips the vote!, unless updating what the vote is for.
			@vote = Vote.where( user: current_user ).find_by( parent_obj_id: params[:id], parent_obj_type: params[:parent_obj_type] ) if params[:parent_obj_type].present? && params[:parent_obj_id].nil?
			@vote ||= Vote.where( user: current_user ).find_by( context: params[:id] )
			@vote ||= Vote.where( user: current_user ).find( params[:id] )

			if params[:parent_obj_type]
				@old_parent_obj = @vote.parent_obj
				@vote.parent_obj_type = params[:parent_obj_type]
				@vote.parent_obj_id = params[:parent_obj_id]
			elsif @vote.up?
				dir = 'down'
				@vote.val = dir
			else
				dir = 'up'
				@vote.val = dir
			end

			puts "@vote #{@vote.to_json}"

			if @vote.save
				@vote.update_parent_caches
			end

			respond_to do |format|
				format.html { redirect_back( fallback_location:'/' ) }
				format.js {}
			end
		end


	end
end