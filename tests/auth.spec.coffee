expect = require('chai').expect
nock = require('nock')
_ = require('lodash')
async = require('async')
auth = require('../lib/auth')
data = require('../lib/data')
settings = require('../lib/settings')
mock = require('./utils/mock')
johnDoeFixture = require('./utils/fixtures/johndoe')
janeDoeFixture = require('./utils/fixtures/janedoe')

describe 'Auth:', ->

	before ->
		mock.connection.init()

	after ->
		mock.connection.restore()

	beforeEach (done) ->
		mock.fs.init()
		data.prefix.set(settings.get('dataPrefix'), done)

	afterEach ->
		mock.fs.restore()

	describe '#register()', ->

		beforeEach ->
			@credentials =
				username: johnDoeFixture.credentials.username
				password: johnDoeFixture.credentials.password
				email: 'johndoe@gmail.com'

			nock(settings.get('remoteUrl'))
				.post(settings.get('urls.register'), @credentials)
				.reply(201, johnDoeFixture.token)

		describe 'given invalid credentials', ->

			it 'should fail if no email', (done) ->
				auth.register _.omit(@credentials, 'email'), (error, token) ->
					expect(error).to.be.an.instanceof(Error)
					expect(token).to.not.exist
					done()

			it 'should fail if no username', (done) ->
				auth.register _.omit(@credentials, 'username'), (error, token) ->
					expect(error).to.be.an.instanceof(Error)
					expect(token).to.not.exist
					done()

			it 'should fail if no password', (done) ->
				auth.register _.omit(@credentials, 'password'), (error, token) ->
					expect(error).to.be.an.instanceof(Error)
					expect(token).to.not.exist
					done()

		describe 'given valid credentials', ->

			it 'should be able to register a username', (done) ->
				auth.register @credentials, (error, token) ->
					expect(error).to.not.exist
					expect(token).to.equal(johnDoeFixture.token)
					done()

	describe.only '#loginWithToken()', ->

		it 'should save the token', (done) ->
			async.waterfall [

				(callback) ->
					auth.getToken(callback)

				(token, callback) ->
					expect(token).to.not.exist
					auth.loginWithToken('asdf1234', callback)

				(callback) ->
					auth.getToken(callback)

				(token, callback) ->
					expect(token).to.equal('asdf1234')
					return callback(null)

			], (error) ->
				expect(error).to.not.exist
				done()

	describe 'given valid credentials', ->

		beforeEach ->
			nock(settings.get('remoteUrl'))
				.post('/login_', johnDoeFixture.credentials)
				.reply(200, johnDoeFixture.token)

		describe '#authenticate()', ->

			it 'should return a token string', (done) ->
				auth.authenticate johnDoeFixture.credentials, (error, token, username) ->
					return done(error) if error?
					expect(token).to.be.a('string')
					expect(token).to.equal(johnDoeFixture.token)
					expect(username).to.equal(johnDoeFixture.credentials.username)
					done()

		describe '#login()', ->

			it 'should save the token', (done) ->
				async.waterfall [

					(callback) ->
						auth.isLoggedIn (isLoggedIn) ->
							return callback(null, isLoggedIn)

					(isLoggedIn, callback) ->
						expect(isLoggedIn).to.be.false
						auth.login(johnDoeFixture.credentials, callback)

					(callback) ->
						auth.isLoggedIn (isLoggedIn) ->
							return callback(null, isLoggedIn)

					(isLoggedIn, callback) ->
						expect(isLoggedIn).to.be.true
						return callback(null)

				], (error) ->
					expect(error).to.not.exist
					done()

			it 'should save the username', (done) ->
				async.waterfall [

					(callback) ->
						auth.whoami(callback)

					(username, callback) ->
						expect(username).to.be.undefined
						auth.login(johnDoeFixture.credentials, callback)

					(callback) ->
						auth.whoami(callback)

					(username, callback) ->
						expect(username).to.equal(johnDoeFixture.credentials.username)
						return callback()

				], (error) ->
					expect(error).to.not.exist
					done()

	describe 'given invalid credentials', ->

		beforeEach ->
			nock(settings.get('remoteUrl'))
				.post('/login_')
				.reply(401)

		describe '#authenticate()', ->

			it 'should return an error', (done) ->
				auth.authenticate johnDoeFixture.credentials, (error, token, username) ->
					expect(error).to.exist
					expect(error).to.be.an.instanceof(Error)
					expect(token).to.be.undefined
					expect(username).to.be.undefined
					done()

		describe '#login()', ->

			it 'should return an error', (done) ->
				auth.login johnDoeFixture.credentials, (error, token) ->
					expect(error).to.exist
					expect(error).to.be.an.instanceof(Error)
					expect(token).to.be.undefined
					done()

	describe 'given a not logged in user', ->

		describe '#whoami()', ->

			it 'should return undefined', (done) ->
				auth.whoami (error, username) ->
					expect(error).to.not.exist
					expect(username).to.be.undefined
					done()

	describe 'given a logged in user', ->

		beforeEach (done) ->
			nock(settings.get('remoteUrl'))
				.post('/login_', johnDoeFixture.credentials)
				.reply(200, johnDoeFixture.token)

			nock(settings.get('remoteUrl'))
				.post('/login_', janeDoeFixture.credentials)
				.reply(200, janeDoeFixture.token)

			auth.login(johnDoeFixture.credentials, done)

		describe '#whoami()', ->

			it 'should return the username', (done) ->
				auth.whoami (error, username) ->
					expect(error).to.not.exist
					expect(username).to.equal(johnDoeFixture.credentials.username)
					done()

		describe '#login()', ->

			it 'should override the old user', (done) ->
				async.waterfall [

					(callback) ->
						auth.getToken(callback)

					(token, callback) ->
						expect(token).to.equal(johnDoeFixture.token)
						auth.login(janeDoeFixture.credentials, callback)

					(callback) ->
						auth.getToken(callback)

					(token, callback) ->
						expect(token).to.equal(janeDoeFixture.token)
						return callback(null)

				], (error) ->
					expect(error).to.not.exist
					done()

		describe '#isLoggedIn()', ->

			it 'should return true', (done) ->
				auth.isLoggedIn (isLoggedIn) ->
					expect(isLoggedIn).to.be.true
					done()

		describe '#getToken()', ->

			it 'should return the saved token', (done) ->
				auth.getToken (error, token) ->
					expect(error).to.not.exist
					expect(token).to.equal(johnDoeFixture.token)
					done()

		describe '#logout()', ->

			it 'should effectively logout the user', (done) ->
				async.waterfall [

					(callback) ->
						auth.isLoggedIn (isLoggedIn) ->
							return callback(null, isLoggedIn)

					(isLoggedIn, callback) ->
						expect(isLoggedIn).to.be.true
						auth.logout(callback)

					(callback) ->
						auth.isLoggedIn (isLoggedIn) ->
							return callback(null, isLoggedIn)

					(isLoggedIn, callback) ->
						expect(isLoggedIn).to.be.false
						return callback()

				], (error) ->
					expect(error).to.not.exist
					done()

			it 'should clear the token', (done) ->
				async.waterfall [

					(callback) ->
						auth.getToken(callback)

					(savedToken, callback) ->
						expect(savedToken).to.be.a.string
						auth.logout(callback)

					(callback) ->
						auth.getToken(callback)

					(savedToken, callback) ->
						expect(savedToken).to.be.undefined
						return callback()

				], (error) ->
					expect(error).to.not.exist
					done()

			it 'should clear the username', (done) ->
				async.waterfall [

					(callback) ->
						auth.whoami(callback)

					(username, callback) ->
						expect(username).to.be.a.string
						auth.logout(callback)

					(callback) ->
						auth.whoami(callback)

					(username, callback) ->
						expect(username).to.be.undefined
						return callback()

				], (error) ->
					expect(error).to.not.exist
					done()

			it 'should not throw an error if callback is not passed', ->
				expect(auth.logout).to.not.throw(Error)
