mockFs = require('mock-fs')
sinon = require('sinon')
settings = require('../../lib/settings')
connection = require('../../lib/connection')

exports.fs =

	init: (filesystemConfig = {}) ->
		mockFsOptions = {}

		# Mock data prefix automatically to remove
		# duplication in most of the tests
		mockFsOptions[settings.get('dataPrefix')] = mockFs.directory()

		for key, value of filesystemConfig
			mockFsOptions[value.name] = value.contents
		mockFs(mockFsOptions)

	restore: ->
		mockFs.restore()

isOnlineStub = null

exports.connection =

	init: ->
		isOnlineStub = sinon.stub(connection, 'isOnline')
		isOnlineStub.yields(null, true)

	restore: ->
		isOnlineStub.restore()
