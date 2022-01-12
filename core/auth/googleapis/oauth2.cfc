component {
    
	// From https://stackoverflow.com/questions/53622202/creating-jwt-in-coldfusion-for-google-service-account
	public function generateTokenInfo(service_json){

		// get the timestamp in UTC
		variables.timestampUTC = dateDiff("s", CreateDate(1970,1,1), dateConvert("Local2UTC", now()));

		//generate jwt 
		variables.jwt_header = {
			'alg': 'RS256',
			'typ': 'JWT'
		};
		variables.jwt_header = serializeJSON(variables.jwt_header);
		variables.jwt_header = toBase64(variables.jwt_header);

		variables.jwt_claim = {
			'iss': service_json.client_email,
			'scope': 'https://www.googleapis.com/auth/firebase.messaging',
			'aud': 'https://www.googleapis.com/oauth2/v4/token',
			'iat': timestampUTC,
			'exp': (timestampUTC + 3600)    
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

		variables.jwt_signed = variables.jwt & '.' & variables.signedBase64;

		var httpAuthService = new http(method = "POST", url = "https://www.googleapis.com/oauth2/v4/token");
		httpAuthService.addParam(name = "grant_type", type = "formField", value = "urn:ietf:params:oauth:grant-type:jwt-bearer");
		httpAuthService.addParam(name = "assertion", type = "formField", value = "#variables.jwt_signed#");

		// writeDump(httpAuthService.send().getPrefix());

		var authToken;
		try{
			var result = httpAuthService.send().getPrefix();
			if (!isNull(result) && result.status_code >= 200 && result.status_code < 400){
				authToken = deserializeJson(result.fileContent);
			}

		}catch (any e){
			writeDump(var=e);
			return;
		}

		return authToken;
	}    
}