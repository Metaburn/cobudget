null

### @ngInject ###
global.cobudgetApp.factory 'AuthenticateUser', (Records, ipCookie, Toast, $location, $stateParams, $q, $auth) ->
  () ->
    deferred = $q.defer()

    if ipCookie('currentUserId')
      Records.memberships.fetchMyMemberships()
        .then (data) ->
          if groupId = parseInt($stateParams.groupId)
            if !(_.find data.groups, (group) -> group.id == groupId) 
              Toast.show('The group you were trying to access is private')
              ipCookie.remove('initialRequestPath')
              $location.path('/')
              deferred.reject()
          if bucketId = parseInt($stateParams.bucketId)
            bucket = Records.buckets.findOrFetchById(bucketId).then (bucket) ->
              userIsMemberOfBucketGroup = _.find data.groups, (group) ->
                group.id == bucket.groupId
              if !userIsMemberOfBucketGroup
                Toast.show('The bucket you were trying to access is private')
                ipCookie.remove('initialRequestPath')
                $location.path('/')
                deferred.reject()
        .catch (data) ->
          Toast.show('Please log in to continue')
          $location.path('/')
          deferred.reject()
          
        deferred.resolve()
    else
      ipCookie('initialRequestPath', $location.path())
      Toast.show('You must sign in to continue')
      $location.path('/')
      deferred.reject()

    return deferred.promise