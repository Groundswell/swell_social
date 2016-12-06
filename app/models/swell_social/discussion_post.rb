module SwellSocial
	class DiscussionPost < UserPost
		
		def discussion
			self.topic.discussion
		end

		def paginated_page( dir='asc', per_page=25 ) # todo -- finish implementing reverse
			priors = self.topic.posts.active.where( "created_at < :my_created_at", my_created_at: self.created_at ).count
			page = ( priors / per_page ) + 1
		end

		def path( args={} )
			path = "/discussions/#{self.discussion.slug}/topics/#{self.topic.slug}?page=#{self.paginated_page}"

			if args.present? && args.delete_if{ |k, v| k.blank? || v.blank? }
				path += '&' unless args.empty?
				path += args.map{ |k,v| "#{k}=#{URI.encode(v)}"}.join( '&' )
			end

			return "#{path}#swell_social_discussion_post_#{self.id}"
		end

		def preview
			self.content
		end

		def topic
			DiscussionTopic.find_by( id: self.parent_obj_id )
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
