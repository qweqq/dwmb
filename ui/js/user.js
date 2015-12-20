(function () {

  $( '#profileButton' ).on( 'click', function () {
    var profileInfo = $( '#profileInfo' );
    var userInfoEdit = $( '#userInfoEdit' );

    userInfoEdit.hide();
    profileInfo.toggle();

    $( '#editProfileButton' ).on( 'click', function () {
      profileInfo.hide();

      userInfoEdit.show();
      $( '#saveProfileChanges' ).on( 'click', function () {
        userInfoEdit.hide();
      } )
    } );
  } );

})();

(function () {
  var sessionId = getCookie('sessionId');

  $.ajax({
    url: '/user_info',
    data: '{sessionId: "' + sessionId + '"}'
  }).done();
})();