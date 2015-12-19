var HELPERS_MODULE = (function () {
  return {
    switchOnSlot: function ( indexOfSlot ) {
      console.log('yiss');
      $( "#board1 [data-id='" + indexOfSlot + "']" ).addClass( 'on' );
    },
    switchOffSlot: function ( indexOfSlot ) {
      console.log('noo');
      $( "#board1 [data-id='" + indexOfSlot + "']" ).removeClass( 'on' );
    }
  }
})();