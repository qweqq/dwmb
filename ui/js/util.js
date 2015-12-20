var HELPERS_MODULE = {
  removeError: function ( indexOfSlot ) {
    var slot = $( "#board1 [data-id='" + indexOfSlot + "']" );

    if ( slot.hasClass( 'error' ) ) {
      slot.removeClass( 'error' );
    }
    document.getElementById( "alarm" ).pause();

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
    document.getElementById( "alarm" ).play();

    $( '#freeSlots' ).html( $( '#board1 .light:not(.on):not(.error)' ).length );
  },
  setCookie: function ( cname, cvalue, exdays ) {
    var d = new Date();
    d.setTime(d.getTime() + ( exdays*24*60*60*1000 ));

    var expires = "expires="+d.toUTCString();
    document.cookie = cname + "=" + cvalue + "; " + expires;
  },
  getCookie: function ( cname ) {
    var name = cname + "=";
    var ca = document.cookie.split(';');
    for(var i=0; i<ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0)==' ') c = c.substring(1);
        if ( c.indexOf(name) == 0 ) return c.substring(name.length,c.length);
    }
    return "";
  },
  checkCookie: function ( cname ) {
    var cookie = this.getCookie( cname );
    
    return cookie !== "";
  },
  deleteCookie: function ( cname ) {
    this.setCookie( cname, '', 0 )
  }
};