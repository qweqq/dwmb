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
        $( this ).hide();
      } else {
        if ( loginForm.css( 'display' ) !== 'none' ) {
          loginForm.hide();
        }

        $( this ).show();
        $( '.steps.clearfix' ).hide();
        $( '.title:not(.current)' ).hide();

        function showCurrent() {
          $( '.title.current' ).show();
          $( '.title:not(.current)' ).hide();
        }
        $( "[href='#next']" ).on( 'click', showCurrent);
        $( "[href='#previous']" ).on( 'click', showCurrent);
      }
    });
  });

  $( '#login' ).on( 'click', function ( ev ) {
    loginForm.toggle( function () {
      if ( $( this ).css( 'display' ) === 'none' ) {
        $( this ).hide();
      } else {
        if ( registrationForm.css( 'display' ) !== 'none' ) {
          registrationForm.hide();
        }

        $( this ).show();
      }
    });
  });

})();

(function () {

  /*setInterval(function(){
    $.ajax({
      url: '/status_all'
    }).done( function ( json ) {
      var jsonData = $.parseJSON( json );
      var slots = jsonData['slots'];

      for ( var i = 0; i < slots.length; i++ ) {
        if ( slots[i] === 'on' ) {
          HELPERS_MODULE.switchOnSlot( i );
        } else if ( $( "[data-id='" + i + "']" ).hasClass( 'on' ) ) {
          HELPERS_MODULE.switchOffSlot( i );
        }
      }      
    } )
  }, 1000);*/

  var lights = [ 'on', 'off', 'off', 'on', 'on', 'off', 'on', 'off' ];

  for ( var i = 0; i < lights.length; i++ ) {
    if ( lights[i] === 'error' ) {
      HELPERS_MODULE.switchToError( i );
    } else if ( lights[i] === 'on' ) {
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