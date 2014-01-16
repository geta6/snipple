# Dependency

fs = require 'fs'
path = require 'path'
http = require 'http'
debug = require('debug')('coah')
express = require 'express'
mongoose = require 'mongoose'
direquire = require 'direquire'

# Environment

for k, v of require path.resolve 'config', 'env'
  debug "mapping env #{k.toUpperCase()} -> #{v}"
  process.env[k.toUpperCase()] = v

process.env.NODE_ENV or= 'development'

# Database

if process.env.MONGO
  mongoose.connect process.env.MONGO
  debug "mongo connect to #{process.env.MONGO}"

# Application

app = exports.app = express()
app.disable 'x-powerd-by'
app.set 'events', direquire path.resolve 'app', 'events'
app.set 'models', direquire path.resolve 'app', 'models'
app.set 'helper', direquire path.resolve 'app', 'helper'
app.set 'views', path.resolve 'app', 'views'
app.set 'view engine', 'jade'
app.use express.favicon()
app.use express.logger 'dev' unless process.env.NODE_ENV is 'test'
app.use express.json()
app.use express.urlencoded()
app.use express.methodOverride()
app.use app.router
app.use express.static path.resolve 'public'

if process.env.NODE_ENV isnt 'production'
  app.use express.errorHandler()
  debug "using error handler"


# Routes

Content = (app.get 'events').Content app

app.get '/:username',  Content.user


# Server

server = exports.server = http.createServer app
