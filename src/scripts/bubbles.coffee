# # # # # # # # # # # # # # #
# # # BUBBLES # # # # # # # #
# # # # # # # # # # # # # # #

TYPING_MS = 10
DELAY_MS = 1000
IMAGE_MS = 1000

FIRST_MESSAGES = 6
BOTTOM_GAP_PX = $(window).width() > 480 ? 70 : 0
MARGIN_PX = 5

spinner = '<div class="spinner"><div class="bounce1"></div><div class="bounce2"></div><div class="bounce3"></div></div>'
$userSpinner = undefined
$botSpinner = undefined
running = false
convoOffsetTop = undefined

remaining = []
scheduled = []
displayed = []


createSpinners = ->
	$userSpinner = $(spinner).addClass('user')
	$botSpinner = $(spinner).addClass('bot')
	$('.convo .spinnerblock').append($userSpinner)
	$('.convo .spinnerblock').append($botSpinner)

applySpinner = (bubble) ->
	# Application logic
	apply = ($spinner) ->
		# Align with the bubble
		$spinner.css(top: getBubbleTop(bubble) - convoOffsetTop - MARGIN_PX)
		# Show spinner
		$spinner.addClass('shown').removeClass('hidden')

	# If we're applying to a bot bubble
	if $(bubble).parent().hasClass('bot')
		apply($botSpinner)
	# If we're applying to a user
	else
		apply($userSpinner)

removeSpinner = (bubble) ->
	# Removal logic
	remove = ($spinner) ->
		$spinner.removeClass('shown').addClass('hidden')

	# If we're applying to a bot bubble
	if $(bubble).parent().hasClass('bot')
		remove($botSpinner)
	# If we're applying to a user
	else
		remove($userSpinner)

show = (bubble) ->
	# Inform the system that we're running
	running = true

	# Memoize bubble & showNext condition
	$bubble = $(bubble)
	shouldShowNext = $bubble.hasClass('with-link') or $bubble.hasClass('with-linklist')

	# Spinner logic
	spin = ->
		# Show spinner
		applySpinner(bubble)

	# Appear logic
	appear = (spin=true) ->
		unless !spin
			# Remove spinner
			removeSpinner(bubble)

		# Show the bubble
		$bubble.addClass('shown')
		# Show the link/linklist if necessary
		if shouldShowNext
			$bubble.next().addClass('shown')

		# If we showed all the scheduled bubbles
		if scheduled.length == 0
			# Inform the system that we stopped
			running = false
		# If there are scheduled bubbles left
		else
			# Show the next one
			showScheduled()

	# If the bubble isn't visible anymore
	if getBubbleTop(bubble) < $(window).scrollTop() or
	# the bubble is set to show immediately
	$(bubble).hasClass('immediate')
		# Show it immediately, and omit the spinner
		appear(false)
	# If the bubble is in field of view
	else
		# Obtain timing settings
		customDelay = $(bubble).parent().data('delay') * 1000 || 0
		# Schedule the spinner
		setTimeout(spin, (DELAY_MS * 0.5) + (Math.random() * (DELAY_MS * 0.5)))
		# Schedule a proportionately long typing delay
		chars = $bubble.text().trim().replace(' ', '').length
		typingTime = TYPING_MS * chars
		# If the bubble contains an image
		if $bubble.children('img').length > 0 or $bubble.children('svg').length > 0
			# Increase the typing time
			typingTime += IMAGE_MS
		# Schedule the appearance
		setTimeout(appear, customDelay + typingTime + DELAY_MS)

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

getScrollBottom = ->
	scrollTop = $(window).scrollTop()
	windowHeight = $(window).height()
	return (scrollTop + windowHeight - BOTTOM_GAP_PX)

getBubbleTop = (bubble) ->
	return $(bubble).offset().top

getBubbleBottom = (bubble) ->
	bubbleTop = $(bubble).offset().top
	bubbleHeight = $(bubble).height()
	return (bubbleTop + bubbleHeight)

handleScroll = (e) ->
	# Calculate the bottom of the page
	scrollBottom = getScrollBottom()

	# Collect all remaining&visible buttons
	visible = []
	for bubble in remaining
		# Get the bubbles top coordinteac
		bubbleTop = getBubbleTop(bubble)
		# If the bubble is visible
		if bubbleTop < scrollBottom
			visible.push(bubble)

	for bubble in visible
		schedule(bubble)

observeScroll = ->
	$(window).on('scroll', handleScroll)

calculateDimensions = ->
	BOTTOM_GAP_PX = $(window).width() > 480 ? 70 : 0
	convoOffsetTop = $('.convo').offset().top

validate = (input) ->
	valid = false

	isPhoneNumber = /\b(((00)|(\+))(\d{3})\D?0?\D?((\d{2}))|(\d{3}))\D?(\d{3})\D?(\d{3})\b/g
	isEmail = /\b[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\b/g

	if input.match(isEmail) or input.match(isPhoneNumber)
		valid = true

	return valid

appendUserMessage = (msg) ->
	html = '<div class="chatblock user"><div class="bubble immediate">'
	html += msg + '</div></div>'

	$userResponse = $(html)
	$userResponse.insertBefore($('#inputblock'))
	$bubble = $userResponse.find('.bubble')
	remaining.push($bubble)
	schedule($bubble)

appendBotResponse = (msg) ->
	html = '<div class="chatblock bot"><div class="bubble">'
	html += 'Ksaf Kedušes \\o/</div></div>'

	$botResponse = $(html)
	$botResponse.insertBefore($('#inputblock'))
	$bubble = $botResponse.find('.bubble')
	remaining.push($bubble)
	schedule($bubble)


handleSubmit = (input) ->
	if validate(input)
		$('.error').text('')
		appendUserMessage(input)
		appendBotResponse()
		# Remove input
		$('#inputblock').hide()

	else
		$('.error').text("Sporočilo naj vsebuje email ali telefonsko številko")


handleKeyDown = (e) ->
	if e.keyCode == 13
		e.preventDefault()

		$input = $(e.currentTarget)
		handleSubmit($input.val())
	else
		$('.error').html('&nbsp;')

handleSendClick = (e) ->
	e.preventDefault()
	handleSubmit($('#inputblock input').val())

handleInput = () ->
	$('#inputblock input').on('keydown', handleKeyDown)
	$('#inputblock a').on('click', handleSendClick)

module.exports =
	init: ->
		$(document).ready ->
			calculateDimensions()
			createSpinners()
			assignRemaining()
			scheduleFirstFew()
			observeScroll()
			handleInput()
		$(window).resize ->
			calculateDimensions()
