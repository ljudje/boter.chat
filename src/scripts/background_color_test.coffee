ABalytics = require('./abalytics.js')

# # # # # # # # # # # # # # # # #
# # # BACKGROUND_EXPERIMENT # # #
# # # # # # # # # # # # # # # # #

initialize_bg_experiment = ->
	console.log('abalytics')
	ABalytics.init({
		background_color_experiment: [
			{
				name: 'blue_background'
				background_experiment: "#006AE3"
			}
		,
			{
				name: 'red_background'
				background_experiment: "#FE5A52"
			}
		]
	})

module.exports =
	init: ->
		initialize_bg_experiment()
		ABalytics.applyBgColors()
		$('input#background').val($('.background_experiment').get(0).style.backgroundColor)
