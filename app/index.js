global.jQuery = require('jquery')
global._ = require('lodash')
global.moment = require('moment')

require('angular')
require('angular-ui-router')
require('angular-sanitize/angular-sanitize')
require('angular-cookie')
require('ng-token-auth')
require('angular-aria')
require('angular-animate')
require('angular-material')
require('angular-messages')
require('ng-focus-if')
require('angular-autoselect')

if (process.env.NODE_ENV != 'production') {
  global.localStorage.debug = "*"
}

/* @ngInject */
global.cobudgetApp = angular.module('cobudget', [
  'ui.router',
  'ng-token-auth',
  'ngMaterial',
  'ngMessages',
  'ipCookie',
  'focus-if',
  'badwing.autoselect'
])
.constant('config', require('app/configs/app'))

require('app/configs/auth.coffee')

require('app/routes.coffee')
require('app/angular-record-store.coffee')

var concatenify = require('concatenify')
concatenify('./controllers/*.{js,coffee}')
concatenify('./records-interfaces/*.{js,coffee}')
concatenify('./models/*.{js,coffee}')
concatenify('./filters/*.{js,coffee}')
concatenify('./services/*.{js,coffee}')

require('./boot.coffee')