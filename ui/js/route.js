( function () {
  //var menuUrl = "../main-header.html";
  var menuUrl = "../loged-user-header.html";
  var contentUrl = "../main-content.html";
  var mainJsUrl = "js/main.js";
  var jsUrl = "js/user.js";

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
      $.ajax({
        url: jsUrl,
        context: document.body
      });
    });
  });

} )();