# cfml-firebase
A simple CFML mini-SDK for accessing the Firebase REST API

---

# Quick start
## Use Firebase Cloud Messaging to send a message

1. Get keys
   * Download private key and save as `config/firebase.json`
   * Get admin server API key and save in `config/server.json` (see below for format)
   * (optional) Get web API key and save in `config/server.json` (see below for format)
2. Import keys and convert to structs
   ```javascript
    accountInfo = deserializeJson (fileRead('/config/firebase.json'));
    adminKeys = deserializeJson (fileRead('/config/server.json'));
   ```
3. Instantiate the library with keys
    ```javascript
        factoryHelper = new firebase.messaging.factory(accountInfo, adminKeys);
        messagingHelper = factoryHelper.messaging();
    ```

4. Get a list of device registration tokens to which you want to send messages
   * Mobile --> getToken() on device, send to your console or server
   * Desktop --> generate a vapidKey from https://console.firebase.google.com/project/[project-name]/settings/cloudmessaging -> Web Push Certificates -> Generate key pair, and exchange for registration token using getToken() using Javascript (or other) library

5. Create the message you want to send per template on Firebase Messaging
    ```javascript
        messageTemplate = {
            data:
                {
                    info: "the data object is a custom key value pair",
                    value: serializeJson(
                        {
                            random: 10,
                            note: "structs need to be serialized!"
                        })
                },

            notification:
                {
                    title: 'New example message at #datetimeformat(Now(), 'HH:nn')#!',
                    body: 'This message was sent using the cfml-firebase library.'
                },

            // apns: {
            //     headers: {},
            //     payload: {},
            // },

            token: "ONE_REGISTRATION_TOKEN_HERE",
        };
    ```

  1. Send the message
        ```javascript
            result = messagingHelper.send(argumentCollection = messageTemplate);

            // See what Firebase has to say.
            writeDump(var=result);
        ```

# More info on obtaining keys

## Private key
  * Download the private key from https://console.firebase.google.com/project/[project-name]/settings/serviceaccounts/adminsdk (usually called `firebase.json`)

    ```json
    {
        "type": "service_account",
        "project_id": "project-name",
        "private_key_id": "alphanumeric_key",
        "private_key": "-----BEGIN PRIVATE KEY-----\nKEYINFOHERE\n-----END PRIVATE KEY-----\n",
        "client_email": "firebase-adminsdk-email@[project-name].iam.gserviceaccount.com",
        "client_id": "numeric_client_id",
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
        "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
        "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/[firebase-adminsdk-email]%40[project-name].iam.gserviceaccount.com"
    }
    ```

## Admin server and web API keys

* Server key is from https://console.firebase.google.com/project/[project-name]/settings/cloudmessaging
    * Used for topic subscription
* Web API key is from https://console.firebase.google.com/project/[project-name]/settings/general -> General -> Web API Key
    * Used for Google Identity Services

* Save these to a file called `server.json` in the `config` directory using format below.
    ```json
    {
        "serverKey": "alpha_numeric_server_key",
        "webAPIKey": "alpha_numeric_webapi_key"
    }
    ```
# Project structure
* `config/`
  * Where config / settings files are located (e.g., private key, server key)
* `core/`
  * `auth/`
    * `googleapis/`
      * Files to construct various Google tokens (e.g., oauth2, identitytoolkit)
  * `messaging/`
    * `actions/`
      * Components with methods corresponding to Firebase API (e.g. message send, topic subscribe)
    * `models/`
      * ORM corresponding to message / topic structure per Firebase reference
* `examples/`
  * Examples for sending messages, subscribing/unsubscribing from topics
---

# References / Additional reading
1. Any questions / issues can be posted on https://dev.lucee.org
2. [Discussion on Firebase API Authentication Token](https://dev.lucee.org/t/firebase-api-authentication-token/9172) on https://dev.lucee.org/
3. [firebase-cfml](https://github.com/timmaybrown/firebase-cfml) - CFML REST Wrapper for Firebase
4. [oauth2](https://github.com/coldfumonkeh/oauth2) - A ColdFusion CFC to manage authentication using the OAuth2 protocol
## LICENSE

>**The MIT License (MIT)**
>
>Copyright (c) 2024 Pankaj Sarin and contributors
>
>Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
>
>The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
>
>THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

**What does that mean?**

It means you can use this library pretty much any way you like. You can fork it. You can include it in a proprietary product, sell it, and not give us a dime. Pretty much the only thing you can't do is hold us accountable if anything goes wrong.