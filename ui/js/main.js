(function () {

  $( '#board1 .light' ).on( 'click', function ( ev ) {

    var slot = $( ev.target );
    var slotId = slot.attr( 'data-id' );

    if ( slot.hasClass( 'on' ) ) {
      HELPERS_MODULE.switchOffSlot( slotId );
    } else {
      HELPERS_MODULE.switchOnSlot( slotId );
    }

  });

})();