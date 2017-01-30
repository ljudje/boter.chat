# # # # # # # # # # # # # # #
# # # Detect Backscroll # # #
# # # # # # # # # # # # # # #

$nav = null
last_top = 0
big_delta = 0
scrolling_down = true
nav_hidden = true
interval = 1000 / 10
threshold = 600

# Calculate delta
detect_scroll_direction = ->
	current_top = $(window).scrollTop()
	delta = current_top - last_top
	last_top = current_top

	if delta > 0
		if scrolling_down
			big_delta += delta
		else
			big_delta = 0
			scrolling_down = true

	else
		if scrolling_down
			big_delta = 0
			scrolling_down = false
		else
			big_delta += delta

	scroll_direction = null

	if big_delta < threshold * -1
		scroll_direction = false

	if big_delta > threshold / 10
		scroll_direction = true

	return scroll_direction

hide_aux_nav = ->
	console.log 'hiding nav'
	$nav.removeClass('shown').addClass('hidden')
	nav_hidden = true


show_aux_nav = ->
	console.log 'showing nav'
	$nav.removeClass('hidden').addClass('shown')
	nav_hidden = false
	
handle_scroll = (e) ->
	scrolling_change = detect_scroll_direction()
	if scrolling_change == false && nav_hidden 
		show_aux_nav()
	if scrolling_change == true && !nav_hidden
		hide_aux_nav()

module.exports =
	init: ->
		$(document).ready ->
			last_top = $(window).scrollTop()
			$nav = $('#popup-nav')

			$(window).on 'scroll', Foundation.util.throttle(handle_scroll, interval) 