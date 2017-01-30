# # # # # # # # # # # # # # #
# # # BUBBLES # # # # # # # #
# # # # # # # # # # # # # # #

TYPING_TIME = 600
ANIMATION_TIME = 150
APPEARANCE_TIME = TYPING_TIME + ANIMATION_TIME

FIRST_MESSAGES = 20

$bubbles = null
$spinner = '<div class="spinner bubble shown"><div class="bounce1"></div><div class="bounce2"></div><div class="bounce3"></div></div>'

showBubble = (bubble) ->
	$bubble = $(bubble)
	shouldSpin = $bubble.parent().hasClass('bot')
	shouldShowNext = $bubble.hasClass('with-link') or $bubble.hasClass('with-linklist')
	
	if shouldSpin
		$bubble.before($spinner)

	appear = ->
		if shouldSpin
			$bubble.prev('.spinner').remove()

		$bubble.addClass('shown')
		if shouldShowNext 
			$bubble.next().addClass('shown')

	setTimeout(appear, TYPING_TIME)

hideBubble = (bubble) ->
	$bubble = $(bubble)
	$bubble.css(visibility: 'hidden')
	if $bubble.hasClass('with-link') or $bubble.hasClass('with-linklist')
		$bubble.next().css(visibility: 'hidden')

showFirstBubbles = ->
	$bubbles.each (index, $bubble) ->
		if (index < FIRST_MESSAGES)
			appear = ->
				showBubble($bubble)
			setTimeout(appear, (index + 1) * APPEARANCE_TIME)

initBubbles = ->
	$bubbles = $('.bubble')
	# $bubbles.each (index, bubble) ->
	# 	hideBubble(bubble)

module.exports =
	init: ->
		$(document).ready ->
			initBubbles()
			showFirstBubbles()
