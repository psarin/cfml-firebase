component persistent="true" output="false" accessors="true"
{
	/* properties */

	property name="title" type="String" hint="The notification's title.";
	property name="body" type="String" hint="The notification's body text.";
	property name="image" type="String" hint="Contains the URL of an image that is going to be downloaded on the device and displayed in a notification. JPEG, PNG, BMP have full support across platforms. Animated GIF and video only work on iOS. WebP and HEIF have varying levels of support across platforms and platform versions. Android has 1MB image size limit. Quota usage and implications/costs for hosting image on Firebase Storage: https://firebase.google.com/pricing";

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