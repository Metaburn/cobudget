var _ = require('lodash')
var debug = require('debug')('login');

var loginModal = require('./login-modal');
var forgotLoginModal = require('./forgot-login-modal');
var forgotConfirmedModal = require('./forgot-confirmed-modal');
var resetLoginModal = require('./reset-login-modal');

/* @ngInject */
module.exports = function ($modal, authModel, AuthService, $state, $stateParams, $location) {

  var login = {};

  login.authModal = null;

  login.openModal = function (modal, callback) {
    debug("opening modal", modal)

    if (!_.isNull(login.authModal)) {
      debug("dismissing previous modal", login.authModal);
      login.authModal.dismiss();
      login.authModal = null;
    }

    login.authModal = $modal.open(modal);

    login.authModal.result.then(function (result) {
      login.authModal = null;
      callback(null, result);

    }, function (err) {
      login.authModal = null;
      callback(err);
    });
  };

  login.closeModal = function () {
    debug("closing modal");
    login.authModal.close()
  };

  var loginOpen = false;
  login.openLogin = function () {

    // don't open login if in reset login flow
    if (authModel.resetPasswordToken) {
      return;
    }

    if (loginOpen) { return; }
    debug("opening login modal");
    loginOpen = true;

    login.openModal(
      loginModal()
    , function (err, result) {
      // TODO why is this being called
      // after forgot login modal?
      debug("login modal callback", err, result);

      loginOpen = false;
      if (err) { return handleError(err); }
    })
  };

  login.openForgotLogin = function () {
    debug("opening forgot login modal");

    login.openModal(
      forgotLoginModal()
    , function (err, user) {
      debug("forgot login modal callback", err, user);
      if (err) { return handleError(err); }

      // if didn't actually reset, return
      if (!user) { return; }

      debug("opening forgot confirmed modal");
      login.openModal(
        forgotConfirmedModal({
          user: user,
        })
      , function (err) {
        debug("forgot confirmed modal callback", err);
        if (err) { return handleError(err); }
      })
    });
  };

  login.openResetLogin = function () {
    debug("opening reset login modal");

    login.openModal(
      resetLoginModal()
    , function (err, user) {
      debug("reset login modal callback", err, user);
      
      // unset reset password token
      authModel.unset('resetPasswordToken')

      $state.transitionTo(
        $state.current,
        _.extend($stateParams, {
          reset_password_token: undefined,
        }),
        {
          reload: true,
          inherit: true,
          notify: true,
        }
      )

      if (err) { return handleError(err); }
    });
  };

  login.logout = AuthService.logout.bind(AuthService)

  authModel.on("not-authenticated", login.openLogin);
  authModel.on("session-timeout", login.openLogin);

  authModel.on("change:resetPasswordToken", handleResetToken);
  handleResetToken();

  function handleResetToken () {
    if (authModel.resetPasswordToken) {
      login.openResetLogin();
    }
  }

  function handleError (err) {
    if (err !== "backdrop click" && err !== "escape key press") {
      // handle error
      $modal.open(
        require('app/modules/error-modal')({ error: err })
      );
    }
  }

  return login;
};
