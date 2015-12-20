( function () {
  //var menuUrl = "../main-header.html";
  var menuUrl = "../loged-user-header.html";
  var contentUrl = "../main-content.html";
  var jsUrl = "js/main.js";

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
        url: jsUrl,
        context: document.body
      });
    });
  });

} )();