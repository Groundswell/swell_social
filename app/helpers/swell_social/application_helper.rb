module SwellSocial
	module ApplicationHelper
	  	
	  	def vote_count( num )
	  		if num > 0
	  			number_to_human( num, units: { thousand: 'K', million: 'M', billion: 'B' } )
	  		end
	  	end

	end
end
