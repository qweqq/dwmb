var HELPERS_MODULE = (function () {
  return {
    switchOnSlot: function ( indexOfSlot ) {
      $( "#board1 [data-id='" + indexOfSlot + "']" ).addClass( 'on' );

      var slotsNumber = $( '#freeSlots' ).html();
      $( '#freeSlots' ).html( parseInt( slotsNumber ) - 1 );
    },
    switchOffSlot: function ( indexOfSlot ) {
      $( "#board1 [data-id='" + indexOfSlot + "']" ).removeClass( 'on' );

      var slotsNumber = $( '#freeSlots' ).html();
      $( '#freeSlots' ).html( parseInt( slotsNumber ) + 1 );
    }
  }
})();