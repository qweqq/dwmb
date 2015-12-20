var HELPERS_MODULE = (function () {
  return {
    switchOnSlot: function ( indexOfSlot ) {
      var slot = $( "#board1 [data-id='" + indexOfSlot + "']" );
      
      if ( !slot.hasClass( 'on' ) ) {
        slot.addClass( 'on' );
      }

      var slotsNumber = $( '#freeSlots' ).html();
      $( '#freeSlots' ).html( parseInt( slotsNumber ) - 1 );
    },
    switchOffSlot: function ( indexOfSlot ) {
      var slot = $( "#board1 [data-id='" + indexOfSlot + "']" );

      if ( slot.hasClass( 'on' ) ) {
        slot.removeClass( 'on' );
      }

      var slotsNumber = $( '#freeSlots' ).html();
      $( '#freeSlots' ).html( parseInt( slotsNumber ) + 1 );
    },
    switchToError: function ( indexOfSlot ) {
      this.switchOnSlot();

      $( "#board1 [data-id='" + indexOfSlot + "']" ).addClass( 'error' );
    }
  }
})();