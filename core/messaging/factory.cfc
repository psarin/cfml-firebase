component name="factory" extends="firebase.client" hint="Instantiated component that holds references to various FB modules" {

	/**
	 * Initialization function
	 *
	 * @accountInfo Firebase private key from https://console.firebase.google.com/project/[project-name]/settings/serviceaccounts/adminsdk
	 * @adminKeys Server key from https://console.firebase.google.com/project/[project-name]/settings/cloudmessaging
	 */	
	public factory function init(required struct accountInfo, required struct adminKeys){

		super.init(argumentCollection = arguments);

		// Relevant modules control the URL needed but we set up some defaults here
		this.messagingUrl = arguments?.messagingUrl?:"https://fcm.googleapis.com/v1/projects/#this.projectName#/messages";
		this.topicsUrl = arguments?.topicsUrl?:"https://iid.googleapis.com/iid/v1";
		
		variables.messaging = new firebase.messaging.actions.messaging(factory = this);
		variables.topics = new firebase.messaging.actions.topics(factory = this);

		return this;
	}

	/**
	 * Return private reference to messaging module
	 */	
	public messaging function messaging(){
		return variables.messaging.init(argumentCollection = arguments);
	}

	/**
	 * Return private reference to topics module
	 */	
	public topics function topics(){
		return variables.topics.init(argumentCollection = arguments);
	}
}