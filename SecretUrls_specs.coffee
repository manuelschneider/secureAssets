assert = require("should")
SecretUrls = require("../dist/lib/SecretUrls")


describe 'SecretUrls', ->
    it "is a function", ->
        SecretUrls.should.be.type("function")

    describe "when instanciated", ->
        instance = new SecretUrls("secret", "http://example.com/secret/")

        it "returns an url with a token when `getUrl` is called", (done) ->
            instance.getUrl((res) ->
                res.should.be.type("string").and.startWith("http://example.com/secret/")
                    .and.endWith("/pics/privateImage.png")
                    .and.match(/^http:\/\/example\.com\/secret\/[0-9a-f]+\/[0-9a-f]+\/pics\/privateImage\.png$/)
                done()
            , 'pics/privateImage.png')


        it "returns an array of urls with tokens when `getUrls` is called", (done) ->
            instance.getUrls((result) ->
                result.should.be.type('object').and.have.keys([
                    'pics/privateImage.png',
                    'res/index.js'
                ])
                result.should.have.property("pics/privateImage.png")
                    .startWith("http://example.com/secret/")
                    .and.endWith("/pics/privateImage.png")
                    .and.match(/^http:\/\/example\.com\/secret\/[0-9a-f]+\/[0-9a-f]+\/pics\/privateImage\.png$/)
                result.should.have.property("res/index.js")
                    .startWith("http://example.com/secret/")
                    .and.endWith("/res/index.js")
                    .and.match(/^http:\/\/example\.com\/secret\/[0-9a-f]+\/[0-9a-f]+\/res\/index\.js$/)
                done()
            ,[
                'pics/privateImage.png',
                'res/index.js'
            ])


