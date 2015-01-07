nock = require('nock')
url = require('url')

chai = require('chai')
chaiAsPromised = require('chai-as-promised')
expect = chai.expect
chai.use(chaiAsPromised)

data = require('../lib/data')
mock = require('./utils/mock')
pine = require('../lib/pine')
settings = require('../lib/settings')

describe 'Pine:', ->

	URI =
		application: url.resolve(settings.get('apiPrefix'), 'application')

	RESPONSE =
		applications:
			d: [
				{ id: 1 }
				{ id: 2 }
			]

	beforeEach (done) ->
		mock.fs.init()

		nock(settings.get('remoteUrl'))
			.get(URI.application)
			.reply(200, RESPONSE.applications)

		data.prefix.set(settings.get('dataPrefix'), done)

	afterEach ->
		mock.fs.restore()

	before ->
		mock.connection.init()

	after ->
		mock.connection.restore()

	it 'should construct the correct url', ->
		promise = pine.get
			resource: 'application'

		expect(promise).to.become(RESPONSE.applications.d)
