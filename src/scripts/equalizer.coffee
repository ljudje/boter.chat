imagesLoaded = require('imagesloaded')

# # # # # # # # # # # # # # #
# # # HEIGHT EQUALIZER  # # #
# # # # # # # # # # # # # # #

# Which elements to equalize
eqalize_selector = '.equalized'

equalize_elements = ->
	# Initial values
	current_row = -1
	# Elements in the current row
	el_row = []
	# Max height
	max_height = 0

	# Iterate through all the target elements
	$(eqalize_selector).each (i, el) ->

		# Memorize the current element top offset as y, outerHeight as el_height
		y = Math.round($(el).offset().top)
		el_height = 0
		for child in $(el).children()
			el_height += $(child).outerHeight()

		# If we're beginning a new row
		if y > current_row
			# While there are elements in the prevous el_row stack
			while el_row.length > 0
				# Pop them from the stack
				popped = el_row.pop()
				# and equalize their height
				$(popped).height(max_height)

			# Reset max_height
			max_height = 0
			y = Math.round($(el).offset().top)
			current_row = y

		# If the current element height is bigger than the max_height
		if el_height > max_height
			# memorize the max height
			max_height = el_height

		# Remember that this el is part of the current row
		el_row.push(el)

	# Equalize the last row
	while el_row.length > 0
		popped = el_row.pop()
		$(popped).height(max_height)

module.exports =

	init: ->
		# Handle element equalization
		$(document).ready ->
			$(document).imagesLoaded ->
				equalize_elements()
			$(document).resize ->
				equalize_elements()
