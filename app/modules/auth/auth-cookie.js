var recase = require('recase').create({})

/* @ngInject */
module.exports = function ($cookieStore) {

  var authCookie = {}

  authCookie.get = function () {
    var rawAuthCookie = $cookieStore.get('user');
    return recase.camelCopy(rawAuthCookie)
  };

  authCookie.put = function (authCookie) {
    var rawAuthCookie = recase.snakeCopy(authCookie);
    $cookieStore.put('user', rawAuthCookie);
  }

  authCookie.del = function () {
    $cookieStore.remove('user');
  }

  return authCookie;
}
