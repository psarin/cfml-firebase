component {

    // get Google Identity token (different than Firebase auth token)
    // this can be used for multiple google apps

	// webAPIKey is from https://console.firebase.google.com/project/[project-name]/settings/general -> General -> Web API Key

	public function getAccessTokenInfo(service_json, webAPIKey){

		// get the timestamp in UTC
		variables.timestampUTC = dateDiff("s", CreateDate(1970,1,1), dateConvert("Local2UTC", now()));

		//generate jwt 
		variables.jwt_header = {
			'alg': 'RS256'
		};
		variables.jwt_header = serializeJSON(variables.jwt_header);
		variables.jwt_header = toBase64(variables.jwt_header);

		variables.jwt_claim = {
			'iss': service_json.client_email,
			'sub': service_json.client_email,
			'aud': 'https://identitytoolkit.googleapis.com/google.identity.identitytoolkit.v1.IdentityToolkit',
			'iat': timestampUTC,
			'exp': (timestampUTC + 3600),
            'uid': service_json.client_id
		};
		variables.jwt_claim = serializeJSON(variables.jwt_claim);
		variables.jwt_claim = toBase64(variables.jwt_claim);

		variables.jwt = variables.jwt_header & '.' & variables.jwt_claim;


		//sign jwt

		// variables.keyText = reReplace( service_json.private_key, "[\\n]*-+(BEGIN|END) PRIVATE KEY[^-]*-+(?:\\s|\\r|\\n)+", "", "all" );
		variables.keyText = reReplace( service_json.private_key, "(?:\s|\r|\n*-)+(BEGIN|END) PRIVATE KEY[^-]*-+(?:\s|\r|\n)*-", "", "all" );
		
		variables.keyText = Replace( keyText, "\n", "", "all" );
		variables.keyText = trim( keyText );
		variables.privateKeySpec = createObject( "java", "java.security.spec.PKCS8EncodedKeySpec" )
			.init(binaryDecode( variables.keyText, "base64" ));
		
		variables.privateKey = createObject( "java", "java.security.KeyFactory" )
			.getInstance( javaCast( "string", "RSA" ) )
			.generatePrivate( privateKeySpec );

		variables.signer = createObject( "java", "java.security.Signature" )
			.getInstance( javaCast( "string", 'SHA256withRSA' ));

		variables.signer.initSign( variables.privateKey );
		variables.signer.update( charsetDecode( variables.jwt, "utf-8" ) );
		variables.signedBytes = signer.sign();
		variables.signedBase64 = toBase64(signedBytes);

		// tenantId should be left out if not multiple tenants for your app
		// variables.tenantId = ""; 

		variables.jwt_signed = variables.jwt & '.' & variables.signedBase64;

		var httpAuthService = new http(method = "POST", url = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithCustomToken?key=#webAPIKey#", encodeUrl="no");
		// tenantId should be left out if not multiple tenants for your app
		// httpAuthService.addParam(name = "tenantId", type = "formField", value = "");
		httpAuthService.addParam(name = "token", type = "formField", value = "#variables.jwt_signed#");
        httpAuthService.addParam(name = "returnSecureToken", type = "formField", value = "true");

		// writeDump(httpAuthService.send().getPrefix());

		var authToken;
		try{
			var result = httpAuthService.send().getPrefix();
			if (!isNull(result) && result.status_code == 200){
				authToken = deserializeJson(result.fileContent);
			}

		}catch (any e){
			writeDump(var=e);
			return;
		}

		return authToken;
	}

}