Handlebars = require('handlebars')
marked = require('marked')
sanitizeHTML = require('sanitize-html')

module.exports =
	# Debug helper
	debug_handlebars: (optional) ->
		if optional != "this"
			console.log "#{optional}:", @[optional]
		else
			console.log 'Debug:', @

	# Content scoping helper # Unused
	is_collection: (coll) ->
		params = Array.prototype.slice.call(arguments)
		options = params[params.length - 1]
		if @collection.indexOf(coll) > -1
			return options.fn(this)
		else 
			return ''

	markdown: () ->
		params = Array.prototype.slice.call(arguments)
		mdo = marked(params[0])
		return new Handlebars.SafeString(mdo)

	chain: () ->
		helpers = []
		for arg, index in arguments
			# If the argument is a Handlebars helper
			if Handlebars.helpers[arg]
				# push the helper on the helpers stack
				helpers.push Handlebars.helpers[arg]
			# Otherwise the argumant is the actual value
			else
				# Memoize the argument
				value = arg
				# Chain the helper processing
				for helper in helpers
					# Get the scope from arguments
					scope = arguments[index + 1]
					# Rewrite the value with helper output
					value = helper(value, scope)
				# Break out of the loop to skip processing scope
				return value
		# Return accumulated value
		return value

	strip_html: (markup) ->
		sanitizeHTML(markup, allowedTags: [])
