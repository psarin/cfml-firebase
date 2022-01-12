component {

	import firebase.messaging.models.*;

    public function init(){
		if (isNull(variables.factory)){
			variables.factory = arguments.factory?:new firebase.factory(arguments);
		}

		this.tokenName = "server";
		this.topicsUrl = arguments?.topicsUrl?:variables.factory.topicsUrl;

		return this;
	}

	public function subscribeTokenToTopic
    (
        String topic,
        Array tokens = []
    ){
		var result = variables.factory.http(argumentCollection = {
																	context: this,
																	method: 'POST', 
																	urlToUse: this.topicsUrl & ":batchAdd", 
																	params: {to: "/topics/#topic#", registration_tokens: tokens}
																 });

		if (!isNull(result) && (result['status_code'] eq 201 || result['status_code'] eq 200)){
			result = deserializeJson(result.fileContent)?.results;
            result.map((val, index, arr) => {
                val.token = tokens[index];
                return val;
            });
		} else if (!isNull(result) && result['status_code'] gte 400 ){
            writeDump(var=result);
		}
		
		return result;
	}

	public function unsubscribeTokenToTopic
    (
        String topic,
        Array tokens = []
    ){

		var result = variables.factory.http(argumentCollection = {
			context: this,
			method: 'POST', 
			urlToUse: this.topicsUrl & ":batchRemove", 
			params: {to: "/topics/#topic#", registration_tokens: tokens}
		 });

		if (!isNull(result) && (result['status_code'] eq 201 || result['status_code'] eq 200)){
			result = deserializeJson(result.fileContent)?.results;
            result.map((val, index, arr) => {
                val.token = tokens[index];
                return val;
            });
		} else if (!isNull(result) && result['status_code'] gte 400 ){
            writeDump(var=result);
		}
		
		return result;
	}

}