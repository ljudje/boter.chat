# This build script composes markdown files into HTML with the help of Metalsmith

# Requirements

Metalsmith =        require('metalsmith')
Handlebars =        require('handlebars')
helper =            require('handlebars-helper')
metadata =          require('metalsmith-metadata')
markdown =          require('metalsmith-markdown')
collections =       require('metalsmith-collections')
layouts =           require('metalsmith-layouts')
in_place =          require('metalsmith-in-place')
paths =             require('metalsmith-paths')
permalinks =        require('metalsmith-permalinks')
fs =                require('fs')
utils =             require('./src/builder/utils')
helpers =           require('./src/builder/helpers')

# Dumps entire metalsmith.metadata() to console
debug_metadata = utils.debug_metadata
# Decorates files with appropriate .template according to pattern
assign_layouts = utils.assign_layouts
# Remove images from scope
remove_images = utils.remove_images_from_scope
# Remove drafts
remove_drafts = utils.remove_drafts
# Remove ignored
remove_ignored = utils.remove_ignored_files

# A Handlebars helper that helps debug the local scope
Handlebars.registerHelper "debug", helpers.debug_handlebars
# Template helpers
Handlebars.registerHelper "in_collection", helpers.is_collection
Handlebars.registerHelper "markdown", helpers.markdown
Handlebars.registerHelper "chain", helpers.chain
Handlebars.registerHelper "strip_html", helpers.strip_html

# Register Solidus helpers
helper.help(Handlebars)

# BUILD SCRIPT
metalsmith = Metalsmith(__dirname)
	# Base folder config
	.source('content').destination('build').clean(false)
	# Global site metadata, accessible as `site` in handlebars templates
	.use(metadata(
		site: 'site.yaml'
	))
	# Decorate every collection item with extensible paths info
	.use(paths(
		property: 'paths'
	))
	# Removes drafts & ignored files from the pipeline
	.use(remove_drafts()).use(remove_ignored())
	# Collection of projects
	# .use(collections(
	# 	projects:
	# 		pattern: 'projects/*.md'
	# 		sortBy: 'order'
	# 		reverse: true
	# ))
	# Assign layouts to markdown files according to pattern (source in util.js)
	.use(assign_layouts(
		homepage:
			layout: 'home.hbt'
			pattern: 'index.md'
	))
	# Evaluate handlebars partials within markdown files
	.use(in_place(
		engine: 'handlebars'
		partials: 'src/templates/compiled/partials'
	))
	# Convert markdown to HTML
	.use(markdown())
	# Use handlebars layouts (compiled from HAML files)
	.use(layouts(
		engine: 'handlebars'
		directory: 'src/templates/compiled'
		partials: 'src/templates/compiled/partials'
	))
	# Moves HTML files into a folder with the same name, renames them to index.html
	.use(permalinks())
	# Removes images from the content compilation pipeline
	.use(remove_images())
	# Development utility (source in util.js)
	# .use(debug_metadata())
	# Build
	.build((err) ->
		if err
			console.log err
		else
			console.log('Built HTML files from Markdown and Handlebars')
			console.log("1 Home page")
		return
	)
