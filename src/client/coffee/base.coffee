# Namespace

APP =
	m : {}
	v : {}
	c : {}
	r : {}
	g : []


# Handlebars helpers

Handlebars.registerHelper 'each_arr', (items, fn) ->
	_.map(items, (v) ->
		output =
			value : v
		fn output
	).join ''


# Base classes

class View extends Backbone.View
	render : =>
		if @template is undefined
			@template = @constructor.name.toLowerCase() + '.html'
		if @model then @options.model = @model.toJSON()
		@el.innerHTML = Handlebars.templates[@template] @options
		@
	kill : =>
		if @children and @children.length then child.kill() for child in @children
		@remove()
		@unbind()
		#window.active_views = _.without window.active_views, @constructor.name
	screen_append : () =>
		$('#screen').append @render().el
		return true

	set_cookie : (value) =>
		currentDate = new Date()
		exdate = new Date(currentDate.getFullYear(), currentDate.getMonth(), currentDate.getDate() + 1, 0, 0, 0)
		c_value = escape(value) + ("; expires=" + exdate.toUTCString())
		document.cookie = app_config.ck + "=" + c_value
		localStorage.setItem app_config.ck, value

	read_cookie : =>
		name = app_config.ck
		nameEQ = name + "="
		ca = document.cookie.split(";")
		i = 0
		while i < ca.length
			c = ca[i]
			c = c.substring(1, c.length)  while c.charAt(0) is " "
			return c.substring(nameEQ.length, c.length)  if c.indexOf(nameEQ) is 0
			i++
		null

	read_ls : =>
		ls = decodeURIComponent localStorage.getItem(app_config.ck)


### Log client errors
window.onerror = (msg, file, line) ->
	error =
		user_agent	: navigator.userAgent
		message 	: msg
		filename	: file
		line 		: line
		timestamp 	: Math.floor(+new Date() / 1000)
	$.post window.app_config.base_url + 'api/errors', error : error

###

# Models


# Collections

# View
	 






# Router

class APP.r.Router extends Backbone.Router
	routes :
		'example' : 'example'



# Exports

window.APP = APP
