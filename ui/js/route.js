( function () {

  var menuUrl;
  var jsUrl;

  if ( HELPERS_MODULE.checkCookie( 'sessionId' ) ) {
    menuUrl = "../loged-user-header.html";
    jsUrl = "js/user.js";
  } else {
    menuUrl = "../main-header.html";
  }

  var mainJsUrl = "js/main.js";
  var contentUrl = "../main-content.html";

  $.ajax({
    url: menuUrl,
    context: document.body
  }).done( function( data ) {
    $( '.menu' ).append( data );

    $.ajax({
      url: contentUrl,
      context: document.body
    }).done( function( data ) {
      $( '.content-container' ).append( data );

      $.ajax({
        url: mainJsUrl,
        context: document.body
      });

      if ( jsUrl != 'undefined' ) { 
        $.ajax({
          url: jsUrl,
          context: document.body
        });
      }
    });
  });

} )();