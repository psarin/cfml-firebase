component persistent="true" output="false" accessors="true"
{
	/* properties */

	property name="headers" type="Struct" hint='HTTP request headers defined in Apple Push Notification Service. 
                                                Refer to APNs request headers for supported headers, 
                                                e.g. "apns-priority": "10". An object containing a list of "key": value pairs. 
                                                Example: { "name": "wrench", "mass": "1.3kg", "count": "3" }.';
	property name="payload" type="Struct" hint="APNs payload as a JSON object, including both aps dictionary and custom payload. 
                                                See Payload Key Reference. 
                                                If present, it overrides google.firebase.fcm.v1.Notification.title and google.firebase.fcm.v1.Notification.body.";
//	property name="fcm_options" fieldtype="one-to-one" cfc="fcm_options" hint="Options for features provided by the FCM SDK for iOS.";

    public function init()
    {
        for (var key in arguments) {
            if (StructKeyExists(arguments, key)) {
                var newVal = arguments[key];
                if (!isStruct(newVal) and (newVal eq "''" or newVal eq '""' or newVal eq "" or IsNull(newVal))) {
                    newVal = null;
				}
				if (isJson(newVal)){
					newVal = deserializeJson(newVal);
				}
                if (!isStruct(newVal) and isDate(newVal)){
                    variables[key] = new orrms.server.utils.moment(newVal).getDateTime();
            	} else {
               	 	variables[key] = newVal;
            	}
        	}
    	}

    	return this;
	}

	public function values(){
		var properties = getMetaData().properties;
		var values = {};
		for (var a=1; a lte arrayLen(properties); a++){
			var prop = properties[a];
			if (!isNull(variables[prop.name])){
				values['#prop.name#'] = variables[prop.name];
			}
		}
		return values;
	}
}