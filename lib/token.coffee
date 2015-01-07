data = require('./data')

# @nodoc
# TODO: Move to settings
TOKEN_KEY = 'token'

# Save token
#
# The token is saved to $(dataPrefix)/token, which usually equals to $HOME/.resin/token
#
# @param {String} newToken the token
# @param {Function} callback callback(error)
#
# @note The token is saved as plain text.
#
# @todo We should make the token more secure
#
# @example Save Token
#		resin.token.saveToken myToken, (error) ->
#			throw error if error?
#
exports.saveToken = (newToken, callback) ->
	data.setText(TOKEN_KEY, newToken, callback)

# Check if we have any token saved
#
# @param {Function} callback callback(hasToken)
#
# @example Has Token
#		resin.token.hasToken (hasToken) ->
#			if hasToken
#				console.log('It\'s there!')
#			else
#				console.log('It\'s not there!')
#
exports.hasToken = (callback) ->
	data.has(TOKEN_KEY, callback)

# Get saved token value
#
# @param {Function} callback callback(error, token)
#
# @note If the key doesn't exist, undefined and no error is returned
#
# @example Get token
#		resin.token.getToken (error, token) ->
#			throw error if error?
#			if token?
#				console.log("My token is: #{token}")
#
exports.getToken = (callback) ->
	data.getText(TOKEN_KEY, callback)

# Remove token from the filesystem
#
# @param {Function} callback callback(error)
#
# @note If the token doesn't exist, no action is performed
#
# @example Clear Token
#		resin.token.clearToken (error) ->
#			throw error if error?
#
exports.clearToken = (callback) ->
	data.has TOKEN_KEY, (hasToken) ->
		if hasToken
			return data.remove(TOKEN_KEY, callback)
		else
			return callback?(null)
