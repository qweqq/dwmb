(function () {

  var form = $("#registration_form");

/*
  form.validate({
    errorPlacement: function errorPlacement(error, element) {
      element.before(error);
    },
    rules: {
      confirm: {
          equalTo: ""
      }
    }
  });*/

  form.children("div").steps({
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

  $( '#login_submit' ).on( 'click', function () {
    var json = {
      data: {
        username: $( '#username' ).val(),
        password: $( '#password' ).val()
      }
    }

    $.ajax({
      url: '/login',
      data: json,
      type: 'POST'
    }).done( function ( data ) {
      if ( jsonData['status'] == 'error' ) {
        ev.preventDefault();
      } else if ( jsonData['status'] == 'ok' ) {
        HELPERS_MODULE.setCookie( 'sessionId', jsonData['session_id'], 1 );
      }
    })
  } );

})();

(function () {

  setInterval(function(){
    $.ajax({
      url: '/status'
    }).done( function ( json ) {
      var jsonData = $.parseJSON( json );
      var slots = jsonData['slots'];

      for ( var i = 0; i < slots.length; i++ ) {
        console.log(slots[i])

        if ( slots[i] === 'error' ) {
          HELPERS_MODULE.switchToError( i );
        } else if ( slots[i] === 'off' ) {
          HELPERS_MODULE.removeError( i );
          HELPERS_MODULE.switchOnSlot( i );
        } else if ( $( "[data-id='" + i + "']" ).hasClass( 'on' ) ) {
          HELPERS_MODULE.removeError( i );
          HELPERS_MODULE.switchOffSlot( i );
        }
      }
    } )
  }, 1000);

})();

