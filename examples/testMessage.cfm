<cfscript>
    /** 
     * 
     * Test script to push notifications to firebase.
     *
     * Uses firebase proxy library in core/*
     * 
     * If no valid access token exists, library gets and saves token to Application scope.
     * Then using token and message, it sends to Firebase.
     * 
     * Response from Firebase is output at end of script. If successful, result (filecontent)
     * should contain a "name" (messageid) of the message Firebase just created.
     * 
     **/

    /**
     * 
     * NOTE: you need to the add the following mapping to root level Application.cfc
     * for this to work so it knows location of firebase library
     * this.mappings["/firebase"] = getDirectoryFromPath(getCurrentTemplatePath()) & "/api/firebase";
     * 
     **/

    /**
     * 
     * NOTE: you need to download the private key and save it in the `config` directory.
     * 
     * firebase.json is the private key downloaded from
     * https://console.firebase.google.com/project/[project-name]/settings/serviceaccounts/adminsdk
     * 
     **/
    accountInfo = deserializeJson(fileRead('/config/firebase.json'));

    /**
     * 
     * NOTE: you need to get the server key and save it in the `config` directory to a file called
     * `server.json` with content { "serverKey": "INSERT_SERVER_KEY_HERE", "webAPIKey": "INSERT_WEBAPI_KEY_HERE"}
     * 
     * Server key is from https://console.firebase.google.com/project/[project-name]/settings/cloudmessaging
     * 
     **/
    adminKeys = deserializeJson(fileRead('/config/server.json'));

	factoryHelper = new firebase.messaging.factory(accountInfo, adminKeys);
	messagingHelper = factoryHelper.messaging();

    /** 
     * 
     * Registration tokens can be obtained for mobile devices and desktop browsers. 
     * 
     * Use getToken() function on mobile devices and save them to your datastore for future reference. 
     * 
     * For desktop, you can get a vapidKey from 
     * https://console.firebase.google.com/project/[project-name]/settings/cloudmessaging -> Web Push Certificates -> Generate key pair
     * 
     * Documentation at https://firebase.google.com/docs/cloud-messaging/js/client#configure_web_credentials_with_fcm
     * 
     **/

    sendToRegistrationTokens = [
        // List of registration tokens
        "dqHlWmRR30tEs26Hf0VWGc:APA91bFWmwMNFZMZECkLEXWaPVBKBkgZgzL5UxfFdeoeXojcIviTurwnGbGKrruiJpulL-f8sDD4iHxwkkobHcBnfzP8RhT2svB73z9rTGTyGOFcdmgoj5-ky0xAqA_Hv9YJm3qxfkUD",
        // Pankaj iPhone
        "d0J870-gj0QgvZe6IV0i1K:APA91bEamDqikGqa9KlR-KbGf9bJeXXWLTXktq_L78JTTYqGaOkhhRt9f9R1OeK9vPf8mh9cT4FzPBeXnDjszXSGymrrUcBH2tB6bw1RlDoUs5GsvWwvRRZCLqZFCjaDpXdhBmWbUjRU",
    ];
    
	```<h1>Create new message</h1>```

    // Fill in the items that need to be filled in!
    // Note: APNS and android stuff needs models to be created

    messageTemplate = {
        // name: "Friendly Conversation",
        data: {
                type: "this is a custom key value pair",
                value: serializeJson({
                    random: 10,
                    note: "structs need to be serialized!"
                })
               },
        notification: { title: 'New example message at #datetimeformat(Now(), 'HH:nn')#!', body: 'This message was sent using the cfml-firebase library.'},
        // apns: {
        //     headers: {},
        //     payload: {},
        // },

        // token: sendToRegistrationToken,
        // topic: topic
    };

    // Best to add title & body to data block so it can be accessed by background message handler on mobile
    messageTemplate.data.title = messageTemplate.notification.title;
    messageTemplate.data.body = messageTemplate.notification.body;


	```<h1>Send the message</h1>```

    for( sendToRegistrationToken in sendToRegistrationTokens){
        messageTemplate.token = sendToRegistrationToken;

        // Create a message using the information above
        // Could just use the Struct but using ORM will make it more extensible in the future
        message = new firebase.messaging.models.message().init(argumentCollection = messageTemplate);
    
        ```<h1>Sending message to registrationToken <cfoutput>#sendToRegistrationToken#</cfoutput></h1>```
        result = messagingHelper.send(argumentCollection = messageTemplate);
    
        ```<h1>Output result from send</h1>```
        // See what Firebase has to say.
        writeDump(var=result);
    }

    ```<cfoutput><h1>End of test</h1></cfoutput>```

</cfscript>