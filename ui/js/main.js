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
    autoFocus: true,
	onFinishing: function (event, currentIndex)
    {
        return true;
    },
    onFinished: function (event, currentIndex)
    {
        form.submit()
    }
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

  $( '#login_form' ).on('submit', function (ev) {
	  ev.preventDefault()

    var data = {
      data: JSON.stringify({
        username: $( '#username' ).val(),
        password: $( '#password' ).val()
      })
    }

    $.ajax({
      url: '/login',
      data: data,
      type: 'POST'
    }).done( function ( data ) {
		var jsonData = JSON.parse(data)
      if ( jsonData['status'] == 'error' ) {
        console.error(data);
      } else if ( jsonData['status'] == 'ok' ) {
        console.log('logged')
        HELPERS_MODULE.setCookie( 'sessionId', jsonData['session_id'], 1 );
        location.reload();
      }
    })
  } );

   $( '#registration_form' ).on('submit', function (ev) {
	  ev.preventDefault()

    $.ajax({
      url: '/poop',
      data: {
        data: JSON.stringify({
          rfid: '123123',
        })
      },
      type: 'POST',
    }).done(function (data) {
      console.log('pooped')
      
      var jsonData = JSON.parse(data);
      var code = jsonData['code'];
      //~ var code = $( '#codeInputField' ).val();

      var registrationData = {
        data: JSON.stringify({
          username: $( '#usernameLoginInput' ).val(),
          password: $( '#passwordLoginInput' ).val(),
          email: $( '#emailLoginInput' ).val(),
          code: code,
        })
      }

      console.log('code:', code, "registrationData:", registrationData);

      $.ajax({
        url: '/register',
        data: registrationData,
        type: 'POST'
      }).done( function ( data ) {
        var jsonData = JSON.parse(data)
        if ( jsonData['status'] == 'error' ) {
          console.error(data);
        } else if ( jsonData['status'] == 'ok' ) {
          var tmp = JSON.parse(registrationData.data);

          // dumb way to login
          $('#username').val(tmp['username']);
          $('#password').val(tmp['password']);
          $('#login_form').submit();
        }
      })
    })

	});

})();

(function () {

  setInterval(function(){
    $.ajax({
      url: '/status'
    }).done( function ( json ) {
      var jsonData = $.parseJSON( json );
      var slots = jsonData['slots'];

      for ( var i = 0; i < slots.length; i++ ) {
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
