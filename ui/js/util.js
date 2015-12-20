var HELPERS_MODULE = (function () {
  return {
    switchOnSlot: function ( indexOfSlot ) {
      var slot = $( "#board1 [data-id='" + indexOfSlot + "']" );

      if ( !slot.hasClass( 'on' ) ) {
        slot.addClass( 'on' );
      }

      $( '#freeSlots' ).html( $( '#board1 .light:not(.on)' ).length );
    },
    switchOffSlot: function ( indexOfSlot ) {
      var slot = $( "#board1 [data-id='" + indexOfSlot + "']" );

      if ( slot.hasClass( 'on' ) ) {
        slot.removeClass( 'on' );
      }

      $( '#freeSlots' ).html( $( '#board1 .light:not(.on)' ).length );
    },
    switchToError: function ( indexOfSlot ) {
      this.switchOnSlot();

      $( "#board1 [data-id='" + indexOfSlot + "']" ).addClass( 'error' );
    }
  }
})();