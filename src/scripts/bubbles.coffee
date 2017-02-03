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

# Used by scheduler to see whether bubble animatins are running
running = false
# Used to position spinners correctly 
convoOffsetTop = undefined
# Used to track whether bot has animated
# mouth for all the sppech bubbles
talkAnimations = 0

# Main state management queues and stacks
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

	# Memoize $bubble, showNext & boterTalk condition
	$bubble = $(bubble)
	shouldShowNext = $bubble.hasClass('with-link') or $bubble.hasClass('with-linklist')
	shouldTalkBoter = $bubble.parent().hasClass('bot')

	# Spinner logic
	spin = ->
		# Show spinner
		applySpinner(bubble)

	# Appear logic
	appear = (spin = true, talkingDelay = 1) ->
		unless !spin
			# Remove spinner
			removeSpinner(bubble)

		# Show the bubble
		$bubble.addClass('shown')
		# Show the link/linklist if necessary
		if shouldShowNext
			$bubble.next().addClass('shown')

		if shouldTalkBoter and talkingDelay != 0
			talkAnimations += 1
			unless $('.logo').hasClass('talking')
				$('.logo').addClass('talking')

			stopTalking = ->
				talkAnimations -= 1
				if talkAnimations == 0 and $('.logo').hasClass('talking')
					$('.logo').removeClass('talking')

			setTimeout(stopTalking, talkingDelay)

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
		spinnerDelay = (customDelay + (DELAY_MS * 0.5) + (Math.random() * (DELAY_MS * 0.5)))
		# Schedule the spinner
		setTimeout(spin, spinnerDelay)
		# Schedule a proportionately long typing delay
		chars = $bubble.text().trim().replace(' ', '').length
		typingTime = TYPING_MS * chars
		# If the bubble contains an image
		if $bubble.children('img').length > 0 or $bubble.children('svg').length > 0
			# Increase the typing time
			typingTime += IMAGE_MS
		# Schedule the appearance
		typingDelay = customDelay + typingTime + DELAY_MS
		performAppearance = ->
			if $bubble.find('svg').length > 0
				talkingDelay = 0
			else
				talkingDelay = typingDelay
			appear(true, talkingDelay)
		setTimeout(performAppearance, typingDelay)

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
	remaining = $('.bubble, #inputblock').get()

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
	# Only apply a bottom gap on screens wider than 480px
	BOTTOM_GAP_PX = $(window).width() > 480 ? 70 : 0
	convoOffsetTop = $('.convo').offset().top

validateEmail = (input) ->
	isEmail = /\b[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\b/g
	if input.match(isEmail)
		true
	else
		false

validatePhoneNumber = (input) ->
	isPhoneNumber = /\b(((00)|(\+))(\d{3})\D?0?\D?((\d{2}))|(\d{3}))\D?(\d{3})\D?(\d{3})\b/g
	if input.match(isPhoneNumber)
		true
	else
		false

validate = (input) ->
	if validateEmail(input) or validatePhoneNumber(input)
		true
	else
		false

appendUserMessage = (msg) ->
	# Template
	html = '<div class="chatblock user"><div class="bubble immediate">'
	html += msg + '</div></div>'

	$userResponse = $(html)
	$userResponse.insertBefore($('#inputblock'))
	$bubble = $userResponse.find('.bubble')
	# Add to remaining stack
	remaining.push($bubble)
	# Schedule
	schedule($bubble)

appendBotResponse = (isPhoneNumber = false) ->
	# Template
	html = '<div class="chatblock bot"><div class="bubble">'
	if isPhoneNumber
		msg = 'Hvala za številko. Se slišiva kmalu!'
	else
		msg = 'Hvala. Kmalu dobiš pošto!'
	html += msg + '</div></div>'

	$botResponse = $(html)
	$botResponse.insertBefore($('#inputblock'))
	$bubble = $botResponse.find('.bubble')
	# Add to remaining stack
	remaining.push($bubble)
	# Schedule
	schedule($bubble)

handleSubmit = (input) ->
	# If the input is valid
	if validate(input)
		# Lock form
		$('.error').addclass('valid') unless $('.error').hasClass('valid')
		$('#inputblock input').prop('disabled': true)
		$('#inputblock a').off('click')
		# Remove form
		$('#inputblock').hide() # addClass('hidden')
		# Submit to Spreadsheet
		data = $('#inputblock').serialize()
		# Using spreadsheet as DB API: https://goo.gl/rzuHMF
		request = $.post
			url: "https://script.google.com/macros/s/AKfycbxLhkGxx97M4IJYzydSBRGowDqlHDuv3JFGLxkEPp9JIvnv4ms/exec"
			data:
				message: input
				hasEmail: validateEmail(input)
				hasPhoneNumber: validatePhoneNumber(input)
		# Show the rest of the convo
		appendUserMessage(input)
		appendBotResponse(validatePhoneNumber(input))
	# If the input is invalid
	else
		# Show an error
		$('.error')
			.removeClass('valid')
			.text("Sporočilo naj vsebuje email ali telefonsko številko")


handleKeyDown = (e) ->
	# If the user pressed enter
	if e.keyCode == 13
		e.preventDefault()
		# Handle submission
		$input = $(e.currentTarget)
		handleSubmit($input.val())
	# If Another key was presed
	else
		# Clear error message
		$('.error').addClass('valid') unless $('.error').hasClass('valid')

handleSendClick = (e) ->
	e.preventDefault()
	handleSubmit($('#inputblock input').val())

handleInput = () ->
	# Listen for keypresses
	$('#inputblock input').on('keydown', handleKeyDown)
	# And button clicks
	$('#inputblock a').on('click', handleSendClick)

module.exports =
	init: ->
		
		$(document).ready ->
			# Bubbles shouldn't display all the way to the bottom on large screens
			# Measure whether a ~70px gap should be taken into account
			calculateDimensions()
			# There is a bot and a user spinner, that follow the conversation
			# Create them in the dom
			createSpinners()
			# Bubbles are taken off the remaining stack when scheduled
			# Collect the bubbles onto the remaining array
			assignRemaining()
			# Schedule the introductory conversation
			# It prompts the user to scroll down
			scheduleFirstFew()
			# Every time a user scrolls, we should check whether any bubbles
			# can be displayed.
			observeScroll()
			# Handle ENTER keypress in the #inputblock
			handleInput()

		$(window).resize ->
			# Reconsider whether a gap at the bottom is required
			calculateDimensions()
