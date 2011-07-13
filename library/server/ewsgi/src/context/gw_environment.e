note
	description: "[
	
		Interface for a request environment
		It includes CGI interface and a few extra values that are usually valuable
		
		See http://ken.coar.org/cgi/draft-coar-cgi-v11-03.txt

		2.2. Basic Rules

		   The following rules are used throughout this specification to
		   describe basic parsing constructs.
		   
			alpha         = lowalpha | hialpha
			alphanum      = alpha | digit
			lowalpha      = a | b | c | d | e | f | g | h
							| i | j | k | l | m | n | o | p
							| q | r | s | t | u | v | w | x
							| y | z
			hialpha       = A | B | C | D | E | F | G | H
							| I | J | K | L | M | N | O | P
							| Q | R | S | T | U | V | W | X
							| Y | Z
			digit         = 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7
							| 8 | 9
			hex           = digit | A | B | C | D | E | F | a
							| b | c | d | e | f
			escaped       = % hex hex
			OCTET         = <any 8-bit sequence of data>
			CHAR          = <any US-ASCII character (octets 0 - 127)>
			CTL           = <any US-ASCII control character
							(octets 0 - 31) and DEL (127)>
			CR            = <US-ASCII CR, carriage return (13)>
			LF            = <US-ASCII LF, linefeed (10)>
			SP            = <US-ASCII SP, space (32)>
			HT            = <US-ASCII HT, horizontal tab (9)>
			NL            = CR | LF
			LWSP          = SP | HT | NL
			tspecial      = ( | ) | "@" | , | ; | : | \ | "
							| / | [ | ] | ? | < | > | { | }
							| SP | HT | NL
			token         = 1*<any CHAR except CTLs or tspecials>
			quoted-string = ( " *qdtext " ) | ( "<" *qatext ">")
			qdtext        = <any CHAR except %" and CTLs but including LWSP>
			qatext        = <any CHAR except "<", ">" and CTLs but including LWSP>
			mark          = - | _ | . | ! | ~ | * | ' | ( | )
			unreserved    = alphanum | mark
			reserved      = ; | / | ? | : | @ | & | = | $ | , 
			uric          = reserved | unreserved | escaped

		   Note that newline (NL) need not be a single character, but can
		   be a character sequence.

		3.2. The Script-URI

		   The 'Script-URI' is defined as the URI of the resource
		   identified by the metavariables. Often, this URI will be the
		   same as the URI requested by the client (the 'Client-URI');
		   however, it need not be. Instead, it could be a URI invented
		   by the server, and so it can only be used in the context of
		   the server and its CGI interface.
		   
		   The Script-URI has the syntax of generic-RL as defined in
		   section 2.1 of RFC 1808 [7], with the exception that object
		   parameters and fragment identifiers are not permitted:
		   
			<scheme>://<host><port>/<path>?<query>

		   The various components of the Script-URI are defined by some
		   of the metavariables (see section 4 below);
		   
			script-uri = protocol "://" SERVER_NAME ":" SERVER_PORT enc-script
						 enc-path-info "?" QUERY_STRING

		   where 'protocol' is obtained from SERVER_PROTOCOL,
		   'enc-script' is a URL-encoded version of SCRIPT_NAME and
		   'enc-path-info' is a URL-encoded version of PATH_INFO. See
		   section 4.6 for more information about the PATH_INFO
		   metavariable.
		   
		   Note that the scheme and the protocol are not identical; for
		   instance, a resource accessed via an SSL mechanism may have a
		   Client-URI with a scheme of "https" rather than "http".
		   CGI/1.1 provides no means for the script to reconstruct this,
		   and therefore the Script-URI includes the base protocol used.
	]"
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

deferred
class
	GW_ENVIRONMENT

inherit
	GW_VARIABLES [STRING_8]

	ITERABLE [STRING_8]

feature -- Access

	table: HASH_TABLE [STRING, STRING]
			-- These variables are specific to requests made with HTTP.
			-- Interpretation of these variables may depend on the value of
			-- SERVER_PROTOCOL.
			--
			-- Environment variables with names beginning with "HTTP_" contain
			-- header data read from the client, if the protocol used was HTTP.
			-- The HTTP header name is converted to upper case, has all
			-- occurrences of "-" replaced with "_" and has "HTTP_" prepended to
			-- give the environment variable name. The header data may be
			-- presented as sent by the client, or may be rewritten in ways which
			-- do not change its semantics. If multiple headers with the same
			-- field-name are received then they must be rewritten as a single
			-- header having the same semantics. Similarly, a header that is
			-- received on more than one line must be merged onto a single line.
			-- The server must, if necessary, change the representation of the
			-- data (for example, the character set) to be appropriate for a CGI
			-- environment variable.
			--
			-- The server is not required to create environment variables for all
			-- the headers that it receives. In particular, it may remove any
			-- headers carrying authentication information, such as
			-- "Authorization"; it may remove headers whose value is available to
			-- the script via other variables, such as "Content-Length" and
			-- "Content-Type".
			--
			-- For convenience it might also include the following CGI entries
		deferred
		end

feature -- Access: table

	new_cursor: HASH_TABLE_ITERATION_CURSOR [STRING_8, STRING_8]
			-- Fresh cursor associated with current structure
		do
			create Result.make (table)
		end

feature -- Common Gateway Interface - 1.1       8 January 1996

	auth_type: detachable STRING
			-- This variable is specific to requests made via the "http"
			-- scheme.
			--
			-- If the Script-URI required access authentication for external
			-- access, then the server MUST set the value of this variable
			-- from the 'auth-scheme' token in the request's "Authorization"
			-- header field. Otherwise it is set to NULL.
			--
			--  AUTH_TYPE   = "" | auth-scheme
			--  auth-scheme = "Basic" | "Digest" | token
			--
			-- HTTP access authentication schemes are described in section 11
			-- of the HTTP/1.1 specification [8]. The auth-scheme is not
			-- case-sensitive.
			--
			-- Servers MUST provide this metavariable to scripts if the
			-- request header included an "Authorization" field that was
			-- authenticated.
		deferred
		end

	content_length: detachable STRING
			-- This metavariable is set to the size of the message-body
			-- entity attached to the request, if any, in decimal number of
			-- octets. If no data are attached, then this metavariable is
			-- either NULL or not defined. The syntax is the same as for the
			-- HTTP "Content-Length" header field (section 14.14, HTTP/1.1
			-- specification [8]).
			--
			--  CONTENT_LENGTH = "" | 1*digit
			--
			-- Servers MUST provide this metavariable to scripts if the
			-- request was accompanied by a message-body entity.
		deferred
		end

	content_length_value: INTEGER
			-- Integer value related to `content_length"
		deferred
		end

	content_type: detachable STRING
			-- If the request includes a message-body, CONTENT_TYPE is set to
			-- the Internet Media Type [9] of the attached entity if the type
			-- was provided via a "Content-type" field in the request header,
			-- or if the server can determine it in the absence of a supplied
			-- "Content-type" field. The syntax is the same as for the HTTP
			-- "Content-Type" header field.
			--
			--  CONTENT_TYPE = "" | media-type
			--  media-type   = type "/" subtype *( ";" parameter)
			--  type         = token
			--  subtype      = token
			--  parameter    = attribute "=" value
			--  attribute    = token
			--  value        = token | quoted-string
			--
			-- The type, subtype, and parameter attribute names are not
			-- case-sensitive. Parameter values MAY be case sensitive. Media
			-- types and their use in HTTP are described in section 3.7 of
			-- the HTTP/1.1 specification [8].
			--
			-- Example:
			--
			--  application/x-www-form-urlencoded
			--
			-- There is no default value for this variable. If and only if it
			-- is unset, then the script MAY attempt to determine the media
			-- type from the data received. If the type remains unknown, then
			-- the script MAY choose to either assume a content-type of
			-- application/octet-stream or reject the request with a 415
			-- ("Unsupported Media Type") error. See section 7.2.1.3 for more
			-- information about returning error status values.
			--
			-- Servers MUST provide this metavariable to scripts if a
			-- "Content-Type" field was present in the original request
			-- header. If the server receives a request with an attached
			-- entity but no "Content-Type" header field, it MAY attempt to
			-- determine the correct datatype, or it MAY omit this
			-- metavariable when communicating the request information to the
			-- script.
		deferred
		end

	gateway_interface: STRING
			-- This metavariable is set to the dialect of CGI being used by
			-- the server to communicate with the script. Syntax:
			--
			--  GATEWAY_INTERFACE = "CGI" "/" major "." minor
			--  major             = 1*digit
			--  minor             = 1*digit
			--
			-- Note that the major and minor numbers are treated as separate
			-- integers and hence each may be more than a single digit. Thus
			-- CGI/2.4 is a lower version than CGI/2.13 which in turn is
			-- lower than CGI/12.3. Leading zeros in either the major or the
			-- minor number MUST be ignored by scripts and SHOULD NOT be
			-- generated by servers.
			--
			-- This document defines the 1.1 version of the CGI interface
			-- ("CGI/1.1").
			--
			-- Servers MUST provide this metavariable to scripts.
			--
			-- The version of the CGI specification to which this server
			-- complies.  Syntax:
			--
			--  GATEWAY_INTERFACE =  "CGI" "/" 1*digit "." 1*digit
			--
			-- Note that the major and minor numbers are treated as separate
			-- integers and that each may be incremented higher than a single
			-- digit.  Thus CGI/2.4 is a lower version than CGI/2.13 which in
			-- turn is lower than CGI/12.3. Leading zeros must be ignored by
			-- scripts and should never be generated by servers.
		deferred
		end

	path_info: STRING assign update_path_info
			-- The PATH_INFO metavariable specifies a path to be interpreted
			-- by the CGI script. It identifies the resource or sub-resource
			-- to be returned by the CGI script, and it is derived from the
			-- portion of the URI path following the script name but
			-- preceding any query data. The syntax and semantics are similar
			-- to a decoded HTTP URL 'path' token (defined in RFC 2396 [4]),
			-- with the exception that a PATH_INFO of "/" represents a single
			-- void path segment.
			--
			--  PATH_INFO = "" | ( "/" path )
			--  path      = segment *( "/" segment )
			--  segment   = *pchar
			--  pchar     = <any CHAR except "/">
			--
			-- The PATH_INFO string is the trailing part of the <path>
			-- component of the Script-URI (see section 3.2) that follows the
			-- SCRIPT_NAME portion of the path.
			--
			-- Servers MAY impose their own restrictions and limitations on
			-- what values they will accept for PATH_INFO, and MAY reject or
			-- edit any values they consider objectionable before passing
			-- them to the script.
			--
			-- Servers MUST make this URI component available to CGI scripts.
			-- The PATH_INFO value is case-sensitive, and the server MUST
			-- preserve the case of the PATH_INFO element of the URI when
			-- making it available to scripts.
		deferred
		end

	path_translated: detachable STRING
			-- PATH_TRANSLATED is derived by taking any path-info component
			-- of the request URI (see section 6.1.6), decoding it (see
			-- section 3.1), parsing it as a URI in its own right, and
			-- performing any virtual-to-physical translation appropriate to
			-- map it onto the server's document repository structure. If the
			-- request URI includes no path-info component, the
			-- PATH_TRANSLATED metavariable SHOULD NOT be defined.
			--
			--
			--  PATH_TRANSLATED = *CHAR
			--
			-- For a request such as the following:
			--
			--  http://somehost.com/cgi-bin/somescript/this%2eis%2epath%2einfo
			--
			-- the PATH_INFO component would be decoded, and the result
			-- parsed as though it were a request for the following:
			--
			--  http://somehost.com/this.is.the.path.info
			--
			-- This would then be translated to a location in the server's
			-- document repository, perhaps a filesystem path something like
			-- this:
			--
			--  /usr/local/www/htdocs/this.is.the.path.info
			--
			-- The result of the translation is the value of PATH_TRANSLATED.
			--
			-- The value of PATH_TRANSLATED may or may not map to a valid
			-- repository location. Servers MUST preserve the case of the
			-- path-info segment if and only if the underlying repository
			-- supports case-sensitive names. If the repository is only
			-- case-aware, case-preserving, or case-blind with regard to
			-- document names, servers are not required to preserve the case
			-- of the original segment through the translation.
			--
			-- The translation algorithm the server uses to derive
			-- PATH_TRANSLATED is implementation defined; CGI scripts which
			-- use this variable may suffer limited portability.
			--
			-- Servers SHOULD provide this metavariable to scripts if and
			-- only if the request URI includes a path-info component.
		deferred
		end

	query_string: STRING
			-- A URL-encoded string; the <query> part of the Script-URI. (See
			-- section 3.2.)
			--
			--  QUERY_STRING = query-string
			--  query-string = *uric

			-- The URL syntax for a query string is described in section 3 of
			-- RFC 2396 [4].
			--
			-- Servers MUST supply this value to scripts. The QUERY_STRING
			-- value is case-sensitive. If the Script-URI does not include a
			-- query component, the QUERY_STRING metavariable MUST be defined
			-- as an empty string ("").
		deferred
		end

	remote_addr: STRING
			-- The IP address of the client sending the request to the
			-- server. This is not necessarily that of the user agent (such
			-- as if the request came through a proxy).
			--
			--  REMOTE_ADDR  = hostnumber
			--  hostnumber   = ipv4-address | ipv6-address

			-- The definitions of ipv4-address and ipv6-address are provided
			-- in Appendix B of RFC 2373 [13].
			--
			-- Servers MUST supply this value to scripts.
		deferred
		end

	remote_host: detachable STRING
			-- The fully qualified domain name of the client sending the
			-- request to the server, if available, otherwise NULL. (See
			-- section 6.1.9.) Fully qualified domain names take the form as
			-- described in section 3.5 of RFC 1034 [10] and section 2.1 of
			-- RFC 1123 [5]. Domain names are not case sensitive.
			--
			-- Servers SHOULD provide this information to scripts.
		deferred
		end

	remote_ident: detachable STRING
			-- The identity information reported about the connection by a
			-- RFC 1413 [11] request to the remote agent, if available.
			-- Servers MAY choose not to support this feature, or not to
			-- request the data for efficiency reasons.
			--
			--  REMOTE_IDENT = *CHAR
			--
			-- The data returned may be used for authentication purposes, but
			-- the level of trust reposed in them should be minimal.
			--
			-- Servers MAY supply this information to scripts if the RFC1413
			-- [11] lookup is performed.
		deferred
		end

	remote_user: detachable STRING
			-- If the request required authentication using the "Basic"
			-- mechanism (i.e., the AUTH_TYPE metavariable is set to
			-- "Basic"), then the value of the REMOTE_USER metavariable is
			-- set to the user-ID supplied. In all other cases the value of
			-- this metavariable is undefined.
			--
			--  REMOTE_USER = *OCTET
			--
			-- This variable is specific to requests made via the HTTP
			-- protocol.
			--
			-- Servers SHOULD provide this metavariable to scripts.
		deferred
		end

	request_method: STRING
			-- The REQUEST_METHOD metavariable is set to the method with
			-- which the request was made, as described in section 5.1.1 of
			-- the HTTP/1.0 specification [3] and section 5.1.1 of the
			-- HTTP/1.1 specification [8].
			--
			--  REQUEST_METHOD   = http-method
			--  http-method      = "GET" | "HEAD" | "POST" | "PUT" | "DELETE"
			--                     | "OPTIONS" | "TRACE" | extension-method
			--  extension-method = token
			--
			-- The method is case sensitive. CGI/1.1 servers MAY choose to
			-- process some methods directly rather than passing them to
			-- scripts.
			--
			-- This variable is specific to requests made with HTTP.
			--
			-- Servers MUST provide this metavariable to scripts.
		deferred
		end

	script_name: STRING
			-- The SCRIPT_NAME metavariable is set to a URL path that could
			-- identify the CGI script (rather than the script's output). The
			-- syntax and semantics are identical to a decoded HTTP URL
			-- 'path' token (see RFC 2396 [4]).
			--
			--  SCRIPT_NAME = "" | ( "/" [ path ] )
			--
			-- The SCRIPT_NAME string is some leading part of the <path>
			-- component of the Script-URI derived in some implementation
			-- defined manner. No PATH_INFO or QUERY_STRING segments (see
			-- sections 6.1.6 and 6.1.8) are included in the SCRIPT_NAME
			-- value.
			--
			-- Servers MUST provide this metavariable to scripts.
		deferred
		end

	server_name: STRING
			-- The SERVER_NAME metavariable is set to the name of the server,
			-- as derived from the <host> part of the Script-URI (see section
			-- 3.2).
			--
			--  SERVER_NAME = hostname | hostnumber
			--
			-- Servers MUST provide this metavariable to scripts.
		deferred
		end

	server_port: INTEGER
			-- The SERVER_PORT metavariable is set to the port on which the
			-- request was received, as used in the <port> part of the
			-- Script-URI.
			--
			--  SERVER_PORT = 1*digit
			--
			-- If the <port> portion of the script-URI is blank, the actual
			-- port number upon which the request was received MUST be
			-- supplied.
			--
			-- Servers MUST provide this metavariable to scripts.
		deferred
		end

	server_protocol: STRING
			-- The SERVER_PROTOCOL metavariable is set to the name and
			-- revision of the information protocol with which the request
			-- arrived. This is not necessarily the same as the protocol
			-- version used by the server in its response to the client.
			--
			--  SERVER_PROTOCOL   = HTTP-Version | extension-version
			--                      | extension-token
			--  HTTP-Version      = "HTTP" "/" 1*digit "." 1*digit
			--  extension-version = protocol "/" 1*digit "." 1*digit
			--  protocol          = 1*( alpha | digit | "+" | "-" | "." )
			--  extension-token   = token
			--
			-- 'protocol' is a version of the <scheme> part of the
			-- Script-URI, but is not identical to it. For example, the
			-- scheme of a request may be "https" while the protocol remains
			-- "http". The protocol is not case sensitive, but by convention,
			-- 'protocol' is in upper case.
			--
			-- A well-known extension token value is "INCLUDED", which
			-- signals that the current document is being included as part of
			-- a composite document, rather than being the direct target of
			-- the client request.
			--
			-- Servers MUST provide this metavariable to scripts.
		deferred
		end

	server_software: STRING
			-- The SERVER_SOFTWARE metavariable is set to the name and
			-- version of the information server software answering the
			-- request (and running the gateway).
			--
			--  SERVER_SOFTWARE = 1*product
			--  product         = token [ "/" product-version ]
			--  product-version = token

			-- Servers MUST provide this metavariable to scripts.
		deferred
		end

feature -- HTTP_*

	http_accept_charset: detachable STRING
			-- Contents of the Accept-Charset: header from the current request, if there is one.
			-- Example: 'iso-8859-1,*,utf-8'.
		deferred
		end

	http_accept_encoding: detachable STRING
			-- Contents of the Accept-Encoding: header from the current request, if there is one.
			-- Example: 'gzip'.
		deferred
		end

	http_accept_language: detachable STRING
			-- Contents of the Accept-Language: header from the current request, if there is one.
			-- Example: 'en'.
		deferred
		end

	http_connection: detachable STRING
			-- Contents of the Connection: header from the current request, if there is one.
			-- Example: 'Keep-Alive'.
		deferred
		end

	http_host: detachable STRING
			-- Contents of the Host: header from the current request, if there is one.
		deferred
		end

	http_referer: detachable STRING
			-- The address of the page (if any) which referred the user agent to the current page.
			-- This is set by the user agent.
			-- Not all user agents will set this, and some provide the ability to modify HTTP_REFERER as a feature.
			-- In short, it cannot really be trusted.
		deferred
		end

	http_user_agent: detachable STRING
			-- Contents of the User-Agent: header from the current request, if there is one.
			-- This is a string denoting the user agent being which is accessing the page.
			-- A typical example is: Mozilla/4.5 [en] (X11; U; Linux 2.2.9 i586).
			-- Among other things, you can use this value to tailor your page's
			-- output to the capabilities of the user agent.
		deferred
		end

	http_authorization: detachable STRING
			-- Contents of the Authorization: header from the current request, if there is one.
		deferred
		end

feature -- Extra

	request_uri: STRING
			-- The URI which was given in order to access this page; for instance, '/index.html'.
		deferred
		end

	orig_path_info: detachable STRING
			-- Original version of `path_info' before processed by Current environment
		deferred
		end

feature {GW_REQUEST} -- Element change

	set_orig_path_info (s: STRING)
			-- Set ORIG_PATH_INFO to `s'
		require
			s_attached: s /= Void
		deferred
		ensure
			same_orig_path_info: orig_path_info ~ variable ({GW_ENVIRONMENT_NAMES}.orig_path_info)
		end

	unset_orig_path_info
			-- Unset ORIG_PATH_INFO
		deferred
		ensure
			unset: not has_variable ({GW_ENVIRONMENT_NAMES}.orig_path_info)
		end

	update_path_info (a_path_info: like path_info)
			-- Updated PATH_INFO
		deferred
		ensure
			same_path_info: path_info ~ variable ({GW_ENVIRONMENT_NAMES}.path_info)
		end

invariant
	server_name_not_empty: not server_name.is_empty
	server_port_set: server_port /= 0
	request_method_attached: request_method /= Void
	path_info_attached: path_info /= Void
	query_string_attached: query_string /= Void
	remote_addr_attached: remote_addr /= Void

	path_info_identical: path_info ~ variable ({GW_ENVIRONMENT_NAMES}.path_info)

;note
	copyright: "2011-2011, Eiffel Software and others"
	license: "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Eiffel Software
			5949 Hollister Ave., Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Website http://www.eiffel.com
			Customer support http://support.eiffel.com
		]"
end
