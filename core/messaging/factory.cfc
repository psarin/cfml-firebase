component extends="firebase.client" {

	import firebase.messaging.actions.*;

	public function init(struct accountInfo){
		super.init(argumentCollection = arguments);
		this.messagingUrl = arguments?.messagingUrl?:"https://fcm.googleapis.com/v1/projects/#this.projectName#/messages";
		this.topicsUrl = arguments?.topicsUrl?:"https://iid.googleapis.com/iid/v1";
		
		variables.messaging = new messaging(factory = this);
		variables.topics = new topics(factory = this);
		return this;
	}

	public function messaging(){
		return variables.messaging.init(argumentCollection = arguments);
	}

	public function topics(){
		return variables.topics.init(argumentCollection = arguments);
	}
}