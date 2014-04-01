How to secure assets in an angular app
==========================================

> **DISCLAIMER:** This is no official documentation, just an idea. Plz open an issue if you think it's flawed, and tell me why :)

## The initial situation

I believe it is generally a good idea to put serverside code behind a nice api and build the app completely in the client. Because it seperates concerns and decouples what doesn't belong together, which allows reusing complete services and enables better scalability and maintainability.

*Basic Setting:* I've got a nice angular app which uses [swangular](https://github.com/manuelschneider/swangular) to connect with a clean swagger-enabled REST service.

*Problem:* How do I secure my images or the sensible parts of my markup?

## possible solutions

I see 3 possible solutions for this problem:

  1. pull the assets in the service
  2. use basic auth
  3. use lightys fabulous [mod_secdownload](http://redmine.lighttpd.net/projects/1/wiki/Docs_ModSecDownload)

### pull the assets in the service

In my opinion this is just ugly. I don't want to do a webserver's job in my API, just to enforce some access controls. Developer's sensitivities aside, if you like torturing your ops, try and scale this.

### use basic auth

Basically you'd have to create a service which returns the basic-auth credentials *after* the user authorized. This service would have to manage the credentials for the assets webserver(s). Although this doable, it can get quite complicated and you need *some* connection between your assets webserver(s) and your application's service, which puts restrictions on ops and scalability.

### use lightys fabulous [mod_secdownload](http://redmine.lighttpd.net/projects/1/wiki/Docs_ModSecDownload)

This is my favourite. You need a service (see `SecretUrls.coffee` for an example implementation in coffeescript) which shares a secret with your assets webserver(s). No connection required, the only thing to do is to generate the temporary URLs based on a shared secret, some timestamp and the ressource you have to access.

#### integration with angular

Get temporary URLs for the assets in the controller, after the user entered some credentials and use them
in your templates.

##### the controller

    angular.module('superApp')
        .controller('MainCtrl', function ($scope, Swangular) {
            $scope.whenSecretEntered = function () {
                Swangular.addAuth('userid', $scope.userData.secret, 'header');
                Swangular.superService.apis.assets.getUrls({
                    path: Object.keys($scope.userData.restrictedUrls).join(',')
                }, function (data) {
                    $scope.userData.restrictedUrls = data.obj;
                    $scope.$apply();
                });
            };

            if (!$scope.userData) {
                $scope.userData = {
                    secret: null,
                    restrictedUrls: {
                        '/images/xxx.png': null,
                        '/contents/diary.html': null
                    }
                };
            }
        });

##### images

Just use the ng-src property:

    <div ng-controller="MainCtrl">
        <img ng-src='{{userData.restrictedUrls["/images/xxx.png"]}}' alt="" />
    </div>

##### markup (angular partials)

I found it simplest to create a 'proxy' partial:

    <div ng-include='userData.restrictedUrls["/contents/diary.html"]'></div>

This can be used with $ngRoute instead of the real partial and only works if the call to assets.getUrls() returned a valid URL for the real template.

Make sure your server for the restricted assets is whitelistet:

    angular.module('superApp')
        .config(function ($sceDelegateProvider) {
            $sceDelegateProvider.resourceUrlWhitelist([
                // Allow same origin resource loads.
                'self',
                // Allow loading from our assets domain.  Notice the difference between * and **.
                'https://localhost:9080/**'
            ]);
        });
