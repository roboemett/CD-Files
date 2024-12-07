<XMP>
<html>
<head>
<title>Cookie Examples</title>
</head>
<body>
<script language="javascript">
<!-- begin script
//
//  Cookie Functions - Second Helping  (21-Jan-96)
//  Written by:  Bill Dortch, hIdaho Design <bdortch@netw.com>
//  Original location:   http://hidaho.com/cookies/
//  The following functions are released to the public domain.
//
//  1.  The expires parameter is now optional - that is, you can omit
//      it instead of passing it null to expire the cookie at the end
//      of the current session.
//
//  2.  An optional path parameter has been added.
//
//  3.  An optional domain parameter has been added.
//
//  4.  An optional secure parameter has been added.
//
//  For information on the significance of these parameters, and
//  and on cookies in general, please refer to the official cookie
//  spec, at:
//
//      http://www.netscape.com/newsref/std/cookie_spec.html    
//
//
// "Internal" function to return the decoded value of a cookie
//
function getCookieVal (offset) {
  var endstr = document.cookie.indexOf (";", offset);
  if (endstr == -1)
    endstr = document.cookie.length;
  return unescape(document.cookie.substring(offset, endstr));
}

//
//  Function to return the value of the cookie specified by "name".
//    name - String object containing the cookie name.
//    returns - String object containing the cookie value, or null if
//      the cookie does not exist.
//
function GetCookie (name) {
  var arg = name + "=";
  var alen = arg.length;
  var clen = document.cookie.length;
  var i = 0;
  while (i < clen) {
    var j = i + alen;
    if (document.cookie.substring(i, j) == arg)
      return getCookieVal (j);
    i = document.cookie.indexOf(" ", i) + 1;
    if (i == 0) break; 
  }
  return null;
}

//
//  Function to create or update a cookie.
//    name - String object object containing the cookie name.
//    value - String object containing the cookie value.  May contain
//      any valid string characters.
//    [expires] - Date object containing the expiration data of the cookie.  If
//      omitted or null, expires the cookie at the end of the current session.
//    [path] - String object indicating the path for which the cookie is valid.
//      If omitted or null, uses the path of the calling document.
//    [domain] - String object indicating the domain for which the cookie is
//      valid.  If omitted or null, uses the domain of the calling document.
//    [secure] - Boolean (true/false) value indicating whether cookie transmission
//      requires a secure channel (HTTPS).  
//
//  The first two parameters are required.  The others, if supplied, must
//  be passed in the order listed above.  To omit an unused optional field,
//  use null as a place holder.  For example, to call SetCookie using name,
//  value and path, you would code:
//
//      SetCookie ("myCookieName", "myCookieValue", null, "/");
//
//  Note that trailing omitted parameters do not require a placeholder.
//
//  To set a secure cookie for path "/myPath", that expires after the
//  current session, you might code:
//
//      SetCookie (myCookieVar, cookieValueVar, null, "/myPath", null, true);
//
function SetCookie (name, value) {
  var argv = SetCookie.arguments;
  var argc = SetCookie.arguments.length;
  var expires = (argc > 2) ? argv[2] : null;
  var path = (argc > 3) ? argv[3] : null;
  var domain = (argc > 4) ? argv[4] : null;
  var secure = (argc > 5) ? argv[5] : false;
  document.cookie = name + "=" + escape (value) +
    ((expires == null) ? "" : ("; expires=" + expires.toGMTString())) +
    ((path == null) ? "" : ("; path=" + path)) +
    ((domain == null) ? "" : ("; domain=" + domain)) +
    ((secure == true) ? "; secure" : "");
}

//  Function to delete a cookie. (Sets expiration date to current date/time)
//    name - String object containing the cookie name
//
function DeleteCookie (name) {
  var exp = new Date();
  exp.setTime (exp.getTime() - 1);  // This cookie is history
  var cval = GetCookie (name);
  document.cookie = name + "=" + cval + "; expires=" + exp.toGMTString();
}

//
//  Example
//
var expdate = new Date ()
expdate.setTime (expdate.getTime() + (24 * 60 * 60 * 1000)); // 24 hours from now
SetCookie ("FreqGrafxPath", "http://www.his.com/~smithers/freq/", expdate,"/~smithers/freq/")
SetCookie ("coName", "Frequency Graphics", expdate)
SetCookie ("tempvar", "This is a temporary cookie.")
SetCookie ("ubiquitous", "This cookie will work anywhere in this domain",null,"/")
SetCookie ("inBetaOnly", "This cookie will work in the ./beta/ directory",expdate,"/~smithers/freq/beta")
SetCookie ("goner", "This cookie must die!")
document.write (document.cookie + "<br>")
DeleteCookie ("goner")
// end script -->
</script>
</body>
</html>
</XMP>