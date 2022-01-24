component name="messaging"{

	import firebase.messaging.models.*;

    public function init(){
		if (isNull(variables.factory)){
			variables.factory = arguments.factory?:new firebase.factory(arguments);
		}

		this.tokenName = "oauth2";
		this.messagingUrl = arguments?.messagingUrl?:variables.factory.messagingUrl;

		return this;
	}

	public function send(
		String name,
		Struct data,
		Struct notification,
		Struct apns,
		String token,
		String topic,
		String condition
	){

		if (!isNull(arguments?.notification)){
			arguments.notification = new notification().init(argumentCollection = arguments.notification);
		}
		if (!isNull(arguments?.apns)){
			arguments.apns = new apns().init(argumentCollection = arguments.apns);
		}

		var instance = new firebase.messaging.models.message().init(argumentCollection = arguments);

		var result = variables.factory.http(argumentCollection = {
			context: this,
			method: 'POST', 
			urlToUse: this.messagingUrl & ":send",
			params: { message: instance }
		 });

		if (!isNull(result) && (result['status_code'] eq 201 || result['status_code'] eq 200)){
			result =  deserializeJson(result.fileContent);
		} else if (!isNull(result) && (result['status_code'] gte 400 and result['status_code'] lt 500)){
			result =  deserializeJson(result.fileContent);
		} else {
			writeDump(var=result);
		}
		
		return result;
	}

}