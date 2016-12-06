
module SwellSocial
	class Discussion < SwellMedia::Media

		def all_posts
			self.posts + self.topics
		end

		def posts
			DiscussionPost.active.where( parent_obj_id: self.topics.pluck( :id ), parent_obj_type: 'SwellSocial::DiscussionTopic' )
		end
		
		def last_post
			self.all_posts.sort{ |p| p.created_at.to_i }.last
		end

		def topics
			DiscussionTopic.active.where( parent_obj_id: self.id, parent_obj_type: self.class.name )
		end

		def total_posts_count
			self.all_posts.count
		end

	end
end