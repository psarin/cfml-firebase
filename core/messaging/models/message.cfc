component persistent="true" output="false" accessors="true"
{
	/* properties */

    // TODO: Create android.cfc and fcm_options.cfc with correct parameters

	property name="name" type="String" hint="The identifier of the message sent, in the format of projects/*/messages/{message_id}.";
    property name="data" type="Struct" hint="Arbitrary key/value payload. The key should not be a reserved word ('from', 'message_type', or any word starting with 'google' or 'gcm').";

	property name="notification" fieldtype="one-to-one" cfc="notification" hint="Basic notification template to use across all platforms.";
//  property name="android" fieldtype="one-to-one" cfc="android" hint="Android specific options for messages sent through FCM connection server.";
	property name="apns" fieldtype="one-to-one" cfc="apns" hint="Apple Push Notification Service specific options.";
//	property name="fcm_options" fieldtype="one-to-one" cfc="fcm_options" hint="Template for FCM SDK feature options to use across all platforms.";

	property name="token" type="String" hint="Registration token to send a message to.";
	property name="topic" type="String" hint="Topic name to send a message to, e.g. weather. Note: /topics/ prefix should not be provided.";
	property name="condition" type="String" hint="Condition to send a message to, e.g. 'foo' in topics && 'bar' in topics.";

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
                    variables[key] = new firebase.utils.moment(newVal).getDateTime();
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