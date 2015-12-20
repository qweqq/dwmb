var HELPERS_MODULE = (function () {
  return {
    removeError: function ( indexOfSlot ) {
      var slot = $( "#board1 [data-id='" + indexOfSlot + "']" );

      if ( !slot.hasClass( 'error' ) ) {
        slot.addClass( 'error' );
      }

      $( '#freeSlots' ).html( $( '#board1 .light:not(.on):not(.error)' ).length );  
    },
    switchOnSlot: function ( indexOfSlot ) {
      var slot = $( "#board1 [data-id='" + indexOfSlot + "']" );

      if ( !slot.hasClass( 'on' ) ) {
        slot.addClass( 'on' );
      }

      $( '#freeSlots' ).html( $( '#board1 .light:not(.on):not(.error)' ).length );
    },
    switchOffSlot: function ( indexOfSlot ) {
      var slot = $( "#board1 [data-id='" + indexOfSlot + "']" );

      this.removeError( indexOfSlot );

      if ( slot.hasClass( 'on' ) ) {
        slot.removeClass( 'on' );
      }

      $( '#freeSlots' ).html( $( '#board1 .light:not(.on):not(.error)' ).length );
    },
    switchToError: function ( indexOfSlot ) {
      this.switchOnSlot();

      $( "#board1 [data-id='" + indexOfSlot + "']" ).addClass( 'error' );

      $( '#freeSlots' ).html( $( '#board1 .light:not(.on):not(.error)' ).length );
    }
  }
})();