component name="client" hint="Base Component providing high level functionality common to different FB modules" {

	/**
	 * Initialization function
	 *
	 * @accountInfo Firebase private key from https://console.firebase.google.com/project/[project-name]/settings/serviceaccounts/adminsdk
	 * @adminKeys Server key from https://console.firebase.google.com/project/[project-name]/settings/cloudmessaging
	 */	
	public client function init(required struct accountInfo, required struct adminKeys){
		// Variables scope is private
		variables.accountInfo = arguments.accountInfo;
		variables.adminKeys = arguments.adminKeys;

		// This scope is public
		this.projectName = arguments.accountInfo?.project_id;

		return this;
	}

	/**
	 * Retrieves existing or gets a new authentication token based on type needed
	 *
	 * @tokenName is the type of token needed
	 */	
	private struct function retrieveTokenInfo(string tokenName = null){
		var isValid = false;

		var tokenInfo;
		// Check to see if we have an existing one
		if (!isNull(Application.tokens) && !isNull(Application.tokens[tokenName])){
			tokenInfo = Application.tokens[tokenName];
		}

		// If so, then check to see if still valid / has not expired
		if (!isNull(tokenInfo) && !isNull(tokenInfo.expires_at)){
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

	/**
	 * Constructs and sends off http request
	 *
	 * @context is the component that is calling this function
	 * @method is http method needed
	 * @urlToUse is the fully constructed URL to which to submit this request
	 * @params is a struct of key:value pairs to send as parameters in the http request
	 */	
	public struct function http(
		required component context, 
		string method = "PUT", 
		required string urlToUse,
		struct params = {}){

		// Get the most current (and hopefully valid!) auth token
		var tokenToUse = retrieveTokenInfo(arguments.context?.tokenName);
		
		var httpService = new http(method = "#arguments.method#", url = "#arguments.urlToUse#", encodeUrl="no");
		if (not compareNoCase(arguments.method, 'POST')){
			httpService.addParam(name = "Authorization", type = "header", value = "#tokenToUse?.http_auth_string#");
			httpService.addParam(name = "Content-Type", type = "header", value = "application/json");
			httpService.addParam(type="body", value="#serializeJson(arguments.params)#");
		}else{
			httpService.addParam(name = "Authorization", type = "header", value = "#httpAuthToken(arguments.context?.tokenName)#");
			if (!isNull(arguments.params)){
				var keys = structKeyArray(arguments.params)
				for (var keyIndex=1; keyIndex lte arrayLen(keys); keyIndex++){
					var key = keys[keyIndex];
					httpService.addParam(name = "#key#", type = "formField", value = "#arguments.params[key]#");
				}
			}
		}

		return httpService.send().getPrefix();
	}
}