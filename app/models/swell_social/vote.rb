module SwellSocial
	class Vote < ApplicationRecord
		self.table_name = 'votes'

		enum val: { 'down' => -1, 'up' => 1 }

		belongs_to	:user
		belongs_to	:parent_obj, polymorphic: true

		validates	:user_id, presence: true, uniqueness: { scope: [ :parent_obj_type, :parent_obj_id, :vote_type ] }

		def self.by_vote_type( vote_type='like' )
			where( vote_type: vote_type )
		end

		def self.by_object( obj )
			where( parent_obj_type: obj.class.name, parent_obj_id: obj.id )
		end

		def self.by_user( user )
			where( user_id: user.id )
		end

		def self.likes
			self.up.by_vote_type( 'like' )
		end

		def multiple_choice?
			self.vote_type == 'multiple_choice'
		end



		def numeric_val
			self.read_attribute_before_type_cast( :val ).to_i
		end


		def update_parent_caches( args={} )

			parent_obj_list = [self.parent_obj]

			# if parent_obj was changed (and not during creation)
			if ( self.user.previous_changes[:parent_obj_id] || self.user.previous_changes[:parent_obj_type] ).present? && self.user.previous_changes[:created_at].blank?

				old_parent_obj_type = self.user.previous_changes[:parent_obj_type].try(:first) || self.user.parent_obj_type
				old_parent_obj_id = self.user.previous_changes[:parent_obj_id].try(:first) || self.user.parent_obj_id

				old_parent_obj = old_parent_obj_type.constantize.where( id: old_parent_obj_id ).first

				parent_obj_list << old_parent_obj if old_parent_obj.present?

			end

			parent_obj_list.each do |parent_obj|

				if parent_obj.respond_to?( :cached_vote_count )

					upvotes = Vote.by_object( parent_obj ).up.count
					downvotes = Vote.by_object( parent_obj ).down.count
					totalvotes = upvotes + downvotes

					score = upvotes.to_f
					score = upvotes.to_f / totalvotes if totalvotes > 0

					parent_obj.update( cached_vote_count: totalvotes, cached_vote_score: score, cached_downvote_count: downvotes, cached_upvote_count: upvotes )

				end

			end
		end

	
	end
end