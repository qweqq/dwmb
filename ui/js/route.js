( function () {

  console.log('bar');

  $.ajax({
    url: "../main-header.html",
    context: document.body
  }).done( function( data ) {
    $( '.menu' ).append( data );

    console.log('foo');
  });

} )();