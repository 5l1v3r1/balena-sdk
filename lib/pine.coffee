###*
# @module resin/pine
###

_ = require('lodash')
Promise = require('bluebird')
PinejsClientCore = require('pinejs-client-js')(_, Promise)
settings = require('./settings')
server = require('./server')
promisifiedServerRequest = Promise.promisify(server.request, server)

class PinejsClientRequest extends PinejsClientCore

	###*
	# @summary Trigger a request to the resin.io API
	#
	# @description Makes use of [pinejs-client-js](https://bitbucket.org/rulemotion/pinejs-client-js)
	# You shouldn't make use of this method directly, but through models
	#
	# @protected
	#
	# @param {Object} params - request params (same as node-request params)
	###
	_request: (params) ->
		params.json = params.data
		params.gzip ?= true
		promisifiedServerRequest(params).spread (response, body) ->
			if 200 <= response.statusCode < 300
				return body
			throw new Error(body)

module.exports = new PinejsClientRequest
	apiPrefix: settings.get('apiPrefix')
