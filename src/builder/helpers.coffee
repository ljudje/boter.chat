Handlebars = require('handlebars')
marked = require('marked')
sanitizeHTML = require('sanitize-html')

_project_image_hb = (project, image) ->
	# '![](' + _project_image_url(project, image) + ')'
	new Handlebars.SafeString("<p class='project-image'><img src='#{ _project_image_url(project, image) }'/></p>")	

_project_image_url = (project, image) ->
	'/assets/projects/' + project + '/' + image

_doc_image_hb = (doc, image) ->
	'![](' + _doc_image_url(doc, image) + ')'

_doc_image_url = (doc, image) ->
	'/assets/docs/' + doc + '/' + image

_find_image_asset = (image_assets, path) ->
	found = false
	for file in image_assets
		if file.paths.href == "/projects/#{path}"
			found = file
	found

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

	# Handlebars `image` helper
	# Use it with a single parameter within a project page
	# {{# img this.src }}
	# Or with a few parameters, when referring to an image from another project
	# {{# img project project.thumbnail }}
	image_hb: (from, name, options) ->
		# If we didn't specify a scope
		if options == undefined
			options = name
			name = from
			from = undefined
			path = options.data.root.paths
		else
			path = from.paths

		image_assets = options.data.root.image_assets
		asset_host = options.data.root.site.asset_host

		dir = encodeURIComponent(path.dir)
		parent = encodeURIComponent(path.name)
		name = encodeURIComponent(name)
		collection_path = "#{parent}/#{name}"
		full_path = "#{dir}/#{parent}/#{name}"
		remote_src = "http://#{asset_host}/#{collection_path}"

		img = _find_image_asset(image_assets, collection_path)

		data =
			src: collection_path
			remote_src: remote_src
			parent_name: parent
			width: img.geom_width
			height: img.geom_height
			y_ratio: img.geom_y_ratio
			percentage_height: 100 / img.geom_y_ratio
			name: name

		return options.fn(data)

	project_image_url: (image) ->
		_project_image_url(@paths.name, image)

	project_image_hb: (image) ->
		_project_image_hb(@paths.name, image)

	doc_image_url: (image) ->
		_doc_image_url(@paths.name, image)

	doc_image_hb: (image) ->
		_doc_image_hb(@paths.name, image)

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

	image_wrapper: ->
		params = Array.prototype.slice.call(arguments)
		options = params[params.length - 1]
		hash = params[0].hash
		if hash.size
			return "<div class='responsive-image #{hash.size}-image'>" + options.fn(this) + "</div>\n"
		else
			return "<div class='responsive-image'>" + options.fn(this) + "</div>\n"

	image_gallery: ->
		params = Array.prototype.slice.call(arguments)
		options = params[params.length - 1]
		return "<div class='image-gallery'>" + options.fn(this) + "</div>\n"

	strip_html: (markup) ->
		sanitizeHTML(markup, allowedTags: [])
