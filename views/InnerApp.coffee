class APP.v.InnerApp extends View
	el : 'screen'
	initialize : =>
		PubSub.on 'load_view', @load_view
	load_view : (view, data) =>
		previous_view = @current_view
		window.current_view = view
		@current_view = new APP.v[view] data
		previous_view && previous_view.kill()

