# # # # # # # # # # # # # # #
# # # BUBBLES # # # # # # # #
# # # # # # # # # # # # # # #

TYPING_MS = 5
DELAY_MS = 1000

FIRST_MESSAGES = 6
BOTTOM_GAP_PX = 50

$spinner = '<div class="spinner bubble shown"><div class="bounce1"></div><div class="bounce2"></div><div class="bounce3"></div></div>'
running = false

remaining = []
scheduled = []
displayed = []

show = (bubble) ->
	# Inform the system that we're running
	running = true

	# Memoize bubble & showNext condition
	$bubble = $(bubble)
	shouldShowNext = $bubble.hasClass('with-link') or $bubble.hasClass('with-linklist')
	
	# Show spinner 
	$bubble.before($spinner)

	# Appear logic
	appear = ->
		# Remove spinner
		$bubble.prev('.spinner').remove()

		# Show the bubble
		$bubble.addClass('shown')
		# Show the link/linklist if necessary
		if shouldShowNext 
			$bubble.next().addClass('shown')

		# If we showed all the scheduled bubbles
		if scheduled.length == 0
			# Inform the system that we stopped
			running = false
		# If thre are scheduled bubbles left
		else
			# Show the next one
			showScheduled()

	# Schedule a proportionately long typing delay
	chars = $bubble.text().replace(' ', '').length
	typingTime = TYPING_MS * chars
		
	setTimeout(appear, typingTime + DELAY_MS)

showScheduled = ->
	# Remove next bubble from the scheduled array
	bubble = scheduled.pop()
	# Show the bubble
	show(bubble)
	# Add it to the displayed array
	displayed.push(bubble)

schedule = (bubble) ->
	# remove from remaining
	index = remaining.indexOf(bubble)
	remaining.splice(index, 1)
	# push to scheduled
	scheduled.unshift(bubble)
	if !running
		showScheduled()

assignRemaining = ->
	remaining = $('.bubble').get()

scheduleFirstFew = ->
	for bubble in remaining[0..(FIRST_MESSAGES - 1)]
		schedule(bubble)

handleScroll = (e) ->
	# Calculate the bottom of the page
	scrollTop = $(window).scrollTop()
	windowHeight = $(window).height()
	scrollBottom = scrollTop + windowHeight - BOTTOM_GAP_PX

	# Collect all remaining&visible buttons
	visible = []
	for bubble in remaining
		# Get the bubbles top coordinteac
		$bubble = $(bubble)
		bubbleTop = $bubble.offset().top
		# If the bubble is visible
		if bubbleTop < scrollBottom
			visible.push(bubble)

	for bubble in visible
		schedule(bubble)

observeScroll = ->
	$(window).on('scroll', handleScroll)

module.exports =
	init: ->
		$(document).ready ->
			assignRemaining()
			scheduleFirstFew()
			observeScroll()
