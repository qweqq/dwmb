(function () {

  $("#registration_form div").steps({
    headerTag: "h3",
    bodyTag: "section",
    transitionEffect: "slideLeft",
    autoFocus: true
  });

  var loginForm = $( '#login_form' );
  var registrationForm = $( '#registration_form' );

  $( '#register' ).on( 'click', function ( ev ) {
    registrationForm.toggle( function () {
      if ( $( this ).css( 'display' ) === 'none' ) {
        $( this ).prop( 'hidden', 'hidden' );
      } else {
        if ( loginForm.prop( 'display' ) != 'none' ) {
          loginForm.prop( 'hidden', 'hidden' );
        }

        $( this ).removeProp( 'hidden' );
      }
    });
  });

  $( '#login' ).on( 'click', function ( ev ) {
    loginForm.toggle( function () {
      if ( $( this ).css( 'display' ) === 'none' ) {
        $( this ).prop( 'hidden', 'hidden' );
      } else {
        if ( registrationForm.css( 'display' ) != 'none' ) {
          registrationForm.prop( 'hidden', 'hidden' );
        }

        $( this ).removeProp( 'hidden' );
      }
    });
  });

})();

(function () {

  var lights = [ 'on', 'off', 'off', 'on', 'on', 'off', 'on', 'off' ];

  for ( var i = 0; i < lights.length; i++ ) {
    if ( lights[i] === 'on' ) {
      HELPERS_MODULE.switchOnSlot( i );
    } else if ( $( "[data-id='" + i + "']" ).hasClass( 'on' ) ) {
      HELPERS_MODULE.switchOffSlot( i );
    }
  }

/*  $( '#board1 .light' ).on( 'click', function ( ev ) {

    var slot = $( ev.target );
    var slotId = slot.attr( 'data-id' );

    if ( slot.hasClass( 'on' ) ) {
      HELPERS_MODULE.switchOffSlot( slotId );
    } else {
      HELPERS_MODULE.switchOnSlot( slotId );
    }

  });*/

})();