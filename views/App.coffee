class APP.v.App extends View
	el : '#app'
	initialize : =>
		$.ajaxSetup cache : false
		jQuery.support.cors = true
		window.PubSub = _.extend {}, Backbone.Events
		new APP.v.InnerApp
		PubSub.trigger 'load_view', 'Home'


