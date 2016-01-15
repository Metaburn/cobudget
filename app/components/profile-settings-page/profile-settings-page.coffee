module.exports =
  resolve:
    userValidated: ($auth) ->
      $auth.validateUser()
    membershipsLoaded: ->
      global.cobudgetApp.membershipsLoaded
  url: '/profile_settings?previous_group_id'
  template: require('./profile-settings-page.html')
  controller: (CurrentUser, Dialog, $location, Records, $scope, $stateParams, Toast, $window) ->
    $scope.currentUser = CurrentUser()
    previousGroupId = $stateParams.previous_group_id || CurrentUser().primaryGroup().id
    $scope.changesMade = false

    $scope.back = ->
        $location.search('previous_group_id', null)
        $location.path("/groups/#{previousGroupId}")

    $scope.attemptBack = ->
      if $scope.changesMade
        Dialog.custom
          scope: $scope
          template: require('./discard-changes-dialog.tmpl.html')
          controller: ($mdDialog, $scope) ->
            $scope.cancel = ->
              $mdDialog.cancel()
            $scope.okay = ->
              $mdDialog.cancel()
              $scope.back()
      else
        $scope.back()

    $scope.save = ->
      params = _.pick $scope.currentUser, ['name']
      Records.users.updateProfile(params).then ->
        Toast.show('Profile settings updated!')

    $scope.openChangePasswordDialog = ->
      Dialog.custom
        scope: $scope
        template: require('./change-password-dialog.tmpl.html')
        controller: ($mdDialog, $scope) ->
          $scope.formParams = {}
          $scope.savePassword = ->
            Records.users.updatePassword($scope.formParams)
              .then (res, status) ->
                console.log('res: ', res)
                console.log('status: ', status)
              .catch (err, status) ->
                console.log('err: ', err)
                console.log('status: ', status)
            $mdDialog.cancel()
          $scope.cancel = ->
            $mdDialog.cancel()
