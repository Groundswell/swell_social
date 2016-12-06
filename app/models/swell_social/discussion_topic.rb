module SwellSocial
	class DiscussionTopic < UserPost

		def discussion
			Discussion.find_by( id: self.parent_obj_id )
		end

		def last_post
			last = self.posts.order( created_at: :desc ).last
			last ||= self
			return last
		end

		def paginated_page( dir='asc', per_page=25 ) # todo -- finish implementing reverse
			priors = DiscussionTopic.active.where( parent_obj_id: self.parent_obj_id ).where( "created_at < :my_created_at", my_created_at: self.created_at ).count
			page = ( priors / per_page ) + 1
		end

		def path( args={} )
			path = "/discussions/#{self.discussion.slug}/topics/#{self.slug}?page=#{self.paginated_page}"

			if args.present? && args.delete_if{ |k, v| k.blank? || v.blank? }
				path += '&' unless args.empty?
				path += args.map{ |k,v| "#{k}=#{URI.encode(v)}"}.join( '&' )
			end

			return path
		end

		def posts
			DiscussionPost.where( parent_obj_id: self.id, parent_obj_type: self.class.name )
		end

		def preview
			self.subject
		end

		def to_s
			self.subject
		end


		def url( args={} )
			domain = ( args.present? && args.delete( :domain ) ) || ENV['APP_DOMAIN'] || 'localhost:3000'
			protocol = ( args.present? && args.delete( :protocol ) ) || 'http'
			path = self.path( args )
			url = "#{protocol}://#{domain}#{self.path( args )}"

			return url

		end


	end
end



			


