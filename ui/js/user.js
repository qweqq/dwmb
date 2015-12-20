(function () {

  $( '#profileButton' ).on( 'click', function () {
    var profileInfo = $( '#profileInfo' );
    var userInfoEdit = $( '#userInfoEdit' );

    userInfoEdit.hide( 'fast' );
    profileInfo.toggle( 'fast' );

    $( '#editProfileButton' ).on( 'click', function () {
      profileInfo.hide();

      userInfoEdit.show( 'fast' );
      $( '#saveProfileChanges' ).on( 'click', function () {
        userInfoEdit.hide( 'fast' );
      } )
    } );
  } );

  $( '#logoutButton' ).on( 'click', function () {
    HELPERS_MODULE.setCookie('sessionId', '');
    location.reload()
  } );

})();

(function () {
  setInterval(function() {
    var sessionId = HELPERS_MODULE.getCookie('sessionId');

    var userData = {
      data: JSON.stringify({
        session_id: sessionId
      })
    };
    
    $.ajax({
      url: '/user_info',
      data: userData,
      type: 'POST'
    }).done( function ( data ) {
      var jsonData = $.parseJSON( data );

      if ( jsonData['status'] == 'not checked' ) {
        $( '.bike-board' ).hide( 'fast' );
      } else if ( jsonData['status'] == 'ok' ) {
        $( '.bike-board' ).show( 'fast' );

        $( '#slotNumber' ).html( jsonData['slot'] );
      }
    });
  }, 1000);
})();
