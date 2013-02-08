remote = 'ec2:/srv/www/cloud.chaffin.ch/chaf'

fs 					= require 'fs'
{exec} 				= require 'child_process'

ansi =
	red  			: '\x1B[31m'
	green 			: '\x1B[36m'
	yellow 			: '\x1B[33m'
	blue  			: '\x1B[34m'
	dark_grey  		: '\x1B[1;30m'
	light_grey  	: '\x1B[1;32m'
	reset   		: '\x1B[0m'

log = (message, color) ->
	console.log ansi[color] + message + ansi.reset

option '-m', '--message [COMMIT_MESSAGE]', 'set git commit message'
option '-n', '--name [NAME]', 'set class name'

task 'build', 'build app from src files', (options) ->
	invoke 'build:index'
	invoke 'build:jade'
	invoke 'build:stylus'
	invoke 'build:coffee', options

task 'build:stylus', 'build style.css from src/styl', ->
	exec 'stylus -c -u nib -o www/css/ src/client/styl/style.styl', (err, stdout, stderr) ->
		err && throw err
		exec 'cat www/css/reset.css www/css/bootstrap.css www/css/animate.min.css www/css/style.css > www/css/c.css', (err, stdout, stderr) ->
			err && throw err
			exec 'cleancss -o www/css/c.min.css www/css/c.css', (err, stdout, stderr) ->
				err && throw err
				log 'Build Stylus OK!', 'green'

task 'build:jade', 'build src/html from src/jade', ->
	exec 'jade -O src/html/ src/client/jade/*', (err, stdout, stderr) ->
		err && throw err
		log 'Build Jade OK!', 'green'
		invoke 'build:handlebars'

task 'build:index', 'build index.html from index.jade', ->
	exec 'jade index.jade', (err, stdout, stderr) ->
		err && throw err
		log 'Build Index OK!', 'green'

task 'build:handlebars', 'build www/js/templates.js from src/html', ->
	exec 'handlebars src/html/* -f www/js/templates.js', (err, stdout, stderr) ->
		err && throw err
		exec 'find src/html/*', (err, stdout, stderr) ->
			files = stdout.split '\n'
			remain = files.length
			for file, i in files then do (file, i) ->
				fs.unlink file, (err) ->
					finish() if --remain is 0
			finish = ->
				fs.rmdir 'src/html', (err) ->
					log 'Build Handlebars OK!', 'green'

task 'build:coffee', 'build src/client.js file from source files', (options) ->
	content = []
	backbone =
		models : []
		collections : []
		views : []
	finished = {}
	fs.readFile 'src/client/coffee/base.coffee', 'utf8', (err, contents) ->
		content.push contents
		for dir in ['views', 'collections', 'models'] then do (dir) ->
			exec 'find src/client/coffee/' + dir, (err, stdout, stderr) ->
				files = stdout.split '\n'
				remain = files.length
				for file, i in files then do (file, i) ->
					fs.readFile file, 'utf8', (err, contents) ->
						backbone[dir].push contents
						if --remain is 0
							finished[dir] = true
							if finished.models and finished.collections and finished.views then finish()
	finish = ->
		content.push backbone.models...
		content.push backbone.collections...
		content.push backbone.views...
		fs.writeFile 'src/client/coffee/client.coffee', content.join('\n\n'), 'utf8', (err) ->
			err && throw err
			exec 'coffee -c -o www/js src/client/coffee/client.coffee', (err, stdout, stderr) ->
				err && throw err
				fs.unlink 'src/client/coffee/client.coffee', (err) ->
					err && throw err
					log 'Build Coffee OK!', 'green'

task 'ship', 'commit to git and push to remote server', (options) ->
	message = options.message || 'minor change'
	exec 'git add -f *;', (err, stdout, stderr) ->
		log stdout + stderr, 'light_grey'
		err && log err, 'red'
		exec 'git commit -m "' + message + '"', (err, stdout, stderr) ->
			log stdout + stderr, 'light_grey'
			err && log err, 'red'
			exec 'rsync -avzP --exclude .git --exclude node_modules . ' + remote, (err, stdout, stderr) ->
				log stdout + stderr, 'light_grey'
				err && throw err
				log 'Ship OK!', 'green'

task 'model', 'create new Backbone Model', (options) ->
	console.log options.model_name
	name = if options.model_name then options.model_name else options.name
	exec 'echo "class APP.m.' + name + ' extends Backbone.Model" > src/client/coffee/models/' + name + '.coffee', (err, stdout, stderr) ->
		err && throw err
		log 'Model created!', 'green'

task 'collection', 'create new Backbone Collection', (options) ->
	filename = 'src/client/coffee/collections/' + options.name + '.coffee'
	exec 'echo "class APP.c.' + options.name + ' extends Backbone.Collection" > ' + filename, (err, stdout, stderr) ->
		err && throw err
		model_name = options.name.slice 0, -1
		exec 'echo "    model : APP.m.' + model_name + '" >> ' + filename, (err, stdout, stderr) ->
			err && throw err
			log 'Collection created!', 'green'
			options.model_name = model_name
			invoke 'model', options

task 'view', 'create new Backbone View', (options) ->
	filename = 'src/client/coffee/views/' + options.name + '.coffee'
	exec 'echo "class APP.v.' + options.name + ' extends View" > ' + filename, (err, stdout, stderr) ->
		err && throw err
		model_name = options.name.slice 0, -1
		exec 'touch src/client/jade/' + options.name.toLowerCase() + '.jade', (err, stdout, stderr) ->
			err && throw err
			log 'View created!', 'green'
