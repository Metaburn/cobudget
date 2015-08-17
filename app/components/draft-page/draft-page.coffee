module.exports = 
  url: '/groups/:groupId/drafts/:draftId'
  template: require('./draft-page.html')
  controller: ($scope, Records, $stateParams, $location) ->
    window.scrollHeight = 0;

    groupId = parseInt $stateParams.groupId
    draftId = parseInt $stateParams.draftId

    Records.groups.findOrFetchById(groupId).then (group) ->
      $scope.group = group

    Records.buckets.findOrFetchById(draftId).then (draft) ->
      $scope.draft = draft
      Records.comments.fetchByBucketId(draftId)

    $scope.back = ->
      $location.path("/groups/#{groupId}")

    $scope.showFullDescription = false

    $scope.readMore = ->
      $scope.showFullDescription = true

    $scope.showLess = ->
      $scope.showFullDescription = false

    $scope.newComment = Records.comments.build(bucketId: draftId)

    $scope.createComment = ->
      $scope.newComment.save()
      $scope.newComment = Records.comments.build(bucketId: draftId)

    return