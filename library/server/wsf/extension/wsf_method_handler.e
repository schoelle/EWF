note

	description: "Conforming handler for any HTTP 1.1 standard method"

	author: "Colin Adams"
	date: "$Date$"
	revision: "$Revision$"

deferred class	WSF_METHOD_HANDLER

feature -- Method

	do_method (a_req: WSF_REQUEST; a_res: WSF_RESPONSE)
			-- Respond to `a_req' using `a_res'.
		require
			a_req_not_void: a_req /= Void
			a_res_not_void: a_res /= Void
		deferred
		ensure
			valid_response_for_http_1_0: is_1_0 (a_req.server_protocol) implies
				valid_response_for_http_1_0 (a_res.status_code)
			empty_body_for_no_content_response: is_no_content_response(a_res.status_code) implies a_res.transfered_content_length = 0 -- Is that the right measure?
		end

feature -- Contract support

	is_1_0 (a_protocol: READABLE_STRING_8): BOOLEAN
			-- Is `a_protocol' (a variant of) HTTP 1.0?
		require
			a_protocol_not_void: a_protocol /= Void
		do
			Result := a_protocol.count >= 8 and then
				a_protocol.substring (1, 8) ~ "HTTP/1.0"
		end

	valid_response_for_http_1_0 (a_status_code: INTEGER): BOOLEAN
			-- Is `a_status_code' a valid response to HTTP 1.0?
		do
			-- 1XX is forbidden

			-- first approximation
			Result := a_status_code >= {HTTP_STATUS_CODE}.ok
		end

	is_no_content_response (a_status_code: INTEGER): BOOLEAN
			-- Is `a_status_code' one that does not permit an entity in the response?
		do
			inspect
				a_status_code
			when {HTTP_STATUS_CODE}.no_content then
				Result := True
			when {HTTP_STATUS_CODE}.reset_content then
				Result := True				
			when {HTTP_STATUS_CODE}.not_modified then
				Result := True
			when {HTTP_STATUS_CODE}.conflict then
				Result := True				
			else
				-- default to False
			end
		end

end

