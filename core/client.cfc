component{

	public function init(struct accountInfo, struct adminKeys){
		// Variables scope is private
		variables.accountInfo = arguments.accountInfo;
		variables.adminKeys = arguments.adminKeys;

		// This scope is public
		this.projectName = arguments.accountInfo?.project_id;

		return this;
	}

	private function retrieveTokenInfo(tokenName){
		var isValid = false;
		// Check to see if we have an existing one
		var tokenInfo;
		if (!isNull(Application.tokens) && !isNull(Application.tokens[tokenName])){
			tokenInfo = Application.tokens[tokenName];
		}

		if (!isNull(tokenInfo) && !isNull(tokenInfo.expires_at)){
			// If so, then check to see if still valid
			var expiresAt = dateDiff("s", Now(), tokenInfo.expires_at);
			if (expiresAt > (5*60) ){
				isValid = true;
			}
		}

		// If none exists, or token has expired, get a new one
		if (isNull(tokenInfo) || !isValid){

			switch(tokenName){			
				case 'server':
					tokenInfo.token_type = "key";
					tokenInfo.access_token = variables.adminKeys['serverKey'];
					tokenInfo.expires_at = dateAdd("s", 3600, Now());
					tokenInfo.http_auth_string = "#tokenInfo.token_type#=#tokenInfo.access_token#";

					break;
				case 'oauth2':
				default:
					var oauth2Factory = new firebase.auth.googleapis.oauth2();
					tokenInfo = oauth2Factory.generateTokenInfo(variables.accountInfo);
					tokenInfo.expires_at = dateAdd("s", tokenInfo.expires_in, Now());
					tokenInfo.http_auth_string = "#tokenInfo.token_type# #tokenInfo.access_token#";
				}

			Application.tokens[tokenName] = tokenInfo;
		}
		return tokenInfo;
	}

	public function http(context, method, urlToUse, params){

		var tokenToUse = retrieveTokenInfo(arguments.context?.tokenName);
		
		var httpService = new http(method = "#arguments.method#", url = "#arguments.urlToUse#", encodeUrl="no");
		if (not compareNoCase(method, 'POST')){
			httpService.addParam(name = "Authorization", type = "header", value = "#tokenToUse?.http_auth_string#");
			httpService.addParam(name = "Content-Type", type = "header", value = "application/json");
			httpService.addParam(type="body", value="#serializeJson(params)#");
		}else{
			httpService.addParam(name = "Authorization", type = "header", value = "#httpAuthToken(arguments.context?.tokenName)#");
			if (!isNull(params)){
				var keys = structKeyArray(params)
				for (var a=1; a lte arrayLen(keys); a++){
					var key = keys[a];
					httpService.addParam(name = "#key#", type = "formField", value = "#arguments.params[key]#");
				}
			}
		}

		return httpService.send().getPrefix();
	}
}