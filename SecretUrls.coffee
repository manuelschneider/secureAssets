###*
 * This is a generator for ModSecDownload URLs
 *
 * It requires MD5:
 *     npm install MD5
###
class SecretUrls

    _modSecDownloadSecret: null
    _urlPrefix: null


    constructor: ( modSecDownloadSecret, urlPrefix ) ->
        @_modSecDownloadSecret = modSecDownloadSecret
        @_urlPrefix = urlPrefix
        @_urlPrefix += "/" if @_urlPrefix.substring(@_urlPrefix.length - 1) isnt '/'


    ###*
     * create a ModSecDownload URL to request a secured ressource
     * @param  {callback} cb          the callback to handle the result
     * @param  {path}     ressource   the ressource you want to request relative to the 'secret-root'
     * @return {url}    the complete url including ModSecDownload stuff
    ###
    getUrl: ( cb, ressource ) ->
        timestamp = Math.round((new Date()).getTime() / 1000).toString(16)

        md5 = require("MD5")
        token = md5(@_modSecDownloadSecret + ressource + timestamp)

        cb("#{@_urlPrefix}#{token}/#{timestamp}/#{ressource}")

    ###*
     * create a ModSecDownload URL to request secured ressources
     * @param  {callback} cb          the callback to handle the result
     * @param  {array;contains:path}  ressource   the ressource you want to request relative to the
     *                                            'secret-root'
     * @return {object;keys:name,contains:url}   the complete url including ModSecDownload stuff
    ###
    getUrls: ( cb, ressources ) ->
        urls = {}
        for ressource in ressources
            @getUrl((url) ->
                urls[ressource] = url
                cb(urls) if Object.keys(urls).length is ressources.length
            ,ressource)


    _toHex: (string) ->
        hex = ''
        for i in [0..string.length]
            hex += '' + string.charCodeAt(i).toString(16)
        
        hex




module.exports = SecretUrls