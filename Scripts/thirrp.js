// browser detection
var strUserAgent = navigator.userAgent.toLowerCase( );
var isIE = strUserAgent.indexOf( "msie" ) > -1;
var isNS6 = strUserAgent.indexOf( "netscape6" ) > -1;
var isNS4 = ! isIE && ! isNS6 && parseFloat( navigator.appVersion ) < 5;

// regular expressions
var reValidString;
var reKeyboardChars = /[\x00\x03\x08\x0D\x16\x18\x1A]/;
var reClipboardChars = /[cvxz]/i;


// mask functions
function maskKeyPress( objEvent )
{
	var reValidChars;
	var iKeyCode, strKey, objInput;
	var blnReturn = true;
	
	if ( isIE )
	{
		iKeyCode = objEvent.keyCode;
		objInput = objEvent.srcElement;
		reValidChars = new RegExp( objInput.getAttribute('reValidChars' ) );
		reValidString = new RegExp( objInput.getAttribute('reValidString' ) );
	}
	else
	{
		iKeyCode = objEvent.which;
		objInput = objEvent.target;
		reValidChars = new RegExp( objInput.getAttribute('reValidChars' ) );
		reValidString = new RegExp( objInput.getAttribute('reValidString' ) );
	}
	
	strKey = String.fromCharCode( iKeyCode );

	if ( ! reValidChars.test( strKey ) &&
		! reKeyboardChars.test( strKey ) &&
		! checkClipboardCode( objEvent, strKey ) )
	{
		blnReturn = false;
	}
	else
	{
	
		switch ( objInput.getAttribute( 'pattern' ) )
		{
			case "zip":
				addDashesToZip( strKey, objInput );
				break;
			case "phone":
				addDashesToPhone( strKey, objInput );
				break;
			default:
				break;
		}

	}

	return ( blnReturn );
}  // maskKeyPress

function checkClipboardCode( objEvent, strKey )
{

	if ( isNS6 )
	{
		return ( objEvent.ctrlKey && reClipboardChars.test( strKey ) );
	}
	else
	{
		return ( false );
	}

}  // checkClipboardCode

function isValid( strValue )
{
	return ( 0 == strValue.length || '/null/' == reValidString || reValidString.test( strValue ) );
}  // isValid

function maskChange( objEvent )
{
	var objInput;

	if ( isIE )
	{
		objInput = objEvent.srcElement;
		reValidString = new RegExp( objInput.getAttribute( 'reValidString' ) );
	}
	else
	{
		objInput = objEvent.target;
		reValidString = new RegExp( objInput.getAttribute( 'reValidString' ) );
	}
	
	if ( ! isValid( objInput.value ) )
	{
		objInput.value = objInput.getAttribute( 'validValue' ) || "";
		objInput.focus( );
		objInput.select( );
	}
	else
	{
		objInput.setAttribute( 'validValue', objInput.value );
	}

}  // maskChange

function maskPaste( objEvent )
{
	var strPasteData = window.clipboardData.getData( "Text" );
	var objInput = objEvent.srcElement;
	
	reValidString = new RegExp( objInput.getAttribute('reValidString' ) );
	
	if ( ! isValid( strPasteData ) )
	{
		objInput.focus( );

		return ( false );
	}
}  // maskPaste

function addDashesToZip( strKey, element )
{
	var num_entered = element.value.split( "-" ).join( "" );
	var len = num_entered.length;
	
	if ( strKey == "-" )
	{
		return;
	}
	
	if ( len > 4 )
	{
		element.value = num_entered.substr( 0, 5 ) + "-" + num_entered.substr( 5 );
	}
		
}

function addDashesToPhone( strKey, element )
{
	var num_entered = element.value.split( "-" ).join( "" );
	var len = num_entered.length;
	
	if ( strKey == "-" )
	{
		return ( true );
	}
	
	if ( len == 6 )
	{
		element.value = num_entered.substr( 0, 3 ) + "-" + num_entered.substr( 3, 3 ) + "-" + num_entered.substr( 6 );
	}
	else if ( len == 3 )
	{
		element.value = num_entered.substr( 0, 3 ) + "-" + num_entered.substr( 3 );
	}

}

function formSubmit( e, button )
{
	var key = e.keyCode ? e.keyCode : e.charCode;
	
	if ( 13 == key )
	{
		document.getElementById( button ).click( );

		return ( false );
	}

}  // formSubmit


var pop = document.getElementById('popup');

var xoffset = 15;
var yoffset = 10;

document.onmousemove = function(e) {
  var x, y, right, bottom;
  
  try { x = e.pageX; y = e.pageY; } // FF
  catch(e) { x = event.x; y = event.y; } // IE

  right = (document.documentElement.clientWidth || document.body.clientWidth || document.body.scrollWidth);
  bottom = (window.scrollY || document.documentElement.scrollTop || document.body.scrollTop) + (window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight || document.body.scrollHeight);

  x += xoffset;
  y += yoffset;

  if(x > right-pop.offsetWidth)
    x = right-pop.offsetWidth;
 
  if(y > bottom-pop.offsetHeight)
    y = bottom-pop.offsetHeight;
  
  pop.style.top = y+'px';
  pop.style.left = x+'px';

}

function popup(text) {
  pop.innerHTML = text;
  pop.style.display = 'block';
}

function popout() {
  pop.style.display = 'none';
}
