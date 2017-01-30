module.exports = (grunt) ->
	# Required tasks
	grunt.loadNpmTasks('grunt-exec')
	grunt.loadNpmTasks('grunt-haml')
	grunt.loadNpmTasks('grunt-browserify')
	grunt.loadNpmTasks('grunt-contrib-sass')
	grunt.loadNpmTasks('grunt-contrib-coffee')
	grunt.loadNpmTasks('grunt-contrib-copy')
	grunt.loadNpmTasks('grunt-contrib-clean')
	grunt.loadNpmTasks('grunt-contrib-watch')

	# Configuration
	grunt.initConfig
		pkg: grunt.file.readJSON('package.json')

		clean:
			build: "build"
			templates: "src/templates/compiled"

		watch:
			options:
				nospawn: true
				livereload: true

			coffee:
				files: ['src/scripts/{,*/}*.coffee']
				tasks: ['scripts']

			sass:
				files: ['src/stylesheets/{,*/}*.{scss,sass}'],
				tasks: ['styles']

			haml:
			  files: ['src/templates/{,*/}*.haml'],
			  tasks: ['haml', 'exec:metalsmith']

			handlebars:
				files: [
					'src/scripts/templates/compiled/{,*/}*.hbt'
				]
				tasks: ['exec:metalsmith']

			rebuild:
				files: ['content/{,*/}*.md', 'build.coffee', 'src/builder/{,*/}*.coffee', 'content/site.yaml']
				tasks: ['exec:metalsmith']

			assets:
				files: ['src/assets/{,*/}*.*']
				tasks: ['copy:assets']

		sass:
			options:
				loadPath: [
					'node_modules/foundation-sites/scss'
				]
			dist:
				options:
					sourcemap: 'none'
					style: 'nested'
				files: [{
					expand: true
					cwd: 'src/stylesheets'
					src: ['*.scss', '*.sass']
					dest: 'build/assets/css'
					ext: '.css'
				}]

		coffee:
			dist:
				files: [{
					expand: true
					cwd: 'src/scripts'
					src: '{,*/}*.coffee'
					dest: 'build/assets/js'
					ext: '.js'	
				}]

		browserify:
			dist:
				files:
					'build/assets/js/bundle.js': [ 'build/assets/js/app.js' ]

		copy:
			project_images:
				files: [{
					expand: true
					cwd: 'content/projects'
					src: '{,*/}*.{jpg,JPG,jpeg,JPEG,png,PNG,gif,GIF}'
					dest: 'build/assets/projects'
				}]

			assets:
				files: [{
					expand: true
					cwd: 'src/assets'
					src: '{,*/}*.*'
					dest: 'build/assets'
				}]


		haml:
			compile:
				files: [{
					expand: true
					cwd: 'src/templates'
					src: '{,*/}*.haml'
					dest: 'src/templates/compiled'
					ext: '.hbt'	
				}]
				options:
					language: 'ruby'
					target: 'html'
					rubyHamlCommand: 'haml -t indented'

		exec:
			metalsmith: './node_modules/coffee-script/bin/coffee build.coffee'
			clean_css: './node_modules/clean-css/bin/cleancss -o build/assets/css/app.min.css build/assets/css/app.css'
			uglify: './node_modules/uglify-js/bin/uglifyjs --compress -o build/assets/js/bundle.min.js build/assets/js/bundle.js'

		# useminPrepare:
		# 	html: [
		# 		'build/people/*/index.html'
		# 		'build/projects/*/index.html'
		# 		'build/index.html'
		# 	]
		# 	options:
		# 		dest: 'build'

	# Subtasks
	grunt.registerTask('wipe', ['clean'])
	grunt.registerTask('styles', ['sass', 'exec:clean_css'])
	grunt.registerTask('scripts', ['coffee', 'browserify'])
	# grunt.registerTask('scripts', ['coffee', 'browserify', 'exec:uglify'])
	grunt.registerTask('templates', ['haml'])
	grunt.registerTask('content', ['exec:metalsmith', 'copy'])
	# grunt.registerTask('optimization', [
	# 	'useminPrepare'
	# 	'concat'
	# 	'cssmin'
	# 	'uglify'
	# 	'filerev'
	# 	'usemin'
	# ])

	# Main build task
	grunt.registerTask('build',  [
		'wipe'
		'scripts'
		'styles'
		'templates'
		'content'
		# 'optimization'
	])
	grunt.registerTask('dev', ['build', 'watch'])
