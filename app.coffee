express = require('express')
http = require('http')
path = require('path')

app = express()

poet = require('poet')(app)

app.configure ->
	poet.init()

	app.set 'port', process.env.PORT or 3000
	app.set 'views', __dirname + '/views'
	app.set 'view engine', 'jade'
	app.use express.favicon()
	app.use express.logger('dev')
	app.use express.bodyParser()
	app.use express.methodOverride()
	app.use app.router
	app.use require('stylus').middleware(__dirname + '/public')
	app.use express.static(path.join(__dirname, 'public'))
	app.use require('connect-assets')(buildDir: 'public')

app.configure 'development', ->
		app.use express.errorHandler()

		app.get '/post/:post', (req, res) ->
				post = req.poet.getPost(req.params.post)
				if post
					res.render 'post',
							post: post
				else
						res.send 404

		app.get '/tag/:tag', (req, res) ->
			taggedPosts = req.poet.postsWithTag(req.params.tag)
			if taggedPosts.length
				res.render 'tag',
					posts: taggedPosts
					tag: req.params.tag


		app.get '/category/:category', (req, res) ->
			categorizedPosts = req.poet.postsWithCategory(req.params.category)
			if categorizedPosts.length
				res.render 'category',
					posts: categorizedPosts
					category: req.params.category

		app.get '/page/:page', (req, res) ->
			page = req.params.page
			lastPost = page * 3
			res.render 'page',
				posts: req.poet.getPosts(lastPost - 3, lastPost)
				page: page

		app.get '/sitemap', (req, res) ->
			postNbr = poet.posts.length
			allPosts = poet.posts
			res.render 'sitemap',
				posts: allPosts

		app.get '/rss', (req, res) ->
			postNbr = poet.posts.length
			allPosts = poet.posts
			res.render 'rss',
				posts: allPosts

		app.get '/', (req, res) ->
				res.render 'index' 

http.createServer(app).listen app.get('port'), ->
		console.info 'Express server listening on port ' + app.get('port')
