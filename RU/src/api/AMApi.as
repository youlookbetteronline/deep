package api 
{
	import core.Log;
	import flash.external.ExternalInterface;
	public class AMApi 
	{
		
		public var flashVars:Object;
		public var appFriends:Array = [];
		public var allFriends:Array = [];
		public var otherFriends:Object = {};
		public var profile:Object = { };
		public var friends:Object = { };
		public var albums:Object = { };
		public var currency:Object = { };
		

		public function AMApi(flashVars:Object)
		{
			Log.alert('Init AM API');
			this.flashVars = flashVars;
			if (ExternalInterface.available)
			{
				ExternalInterface.addCallback("initANetwork", onInitNetwork);
				ExternalInterface.call("initNetwork");
			}else {
				App.self.onNetworkComplete( {
					profile:flashVars.profile,
					appFriends:flashVars.appFriends
				});
			}
		}
		
		
		private function onInitNetwork(data:*):void {
			Log.alert('onInitNetwork');
			Log.alert(data);
			for (var prop:String in data) {
				if(this[prop] != null)
					this[prop] = data[prop];
			}
			Log.alert(this);
			App.self.onNetworkComplete(this);
		}
		
		
		public function wallPost(params:Object):void {
			Log.alert('WALLPOST');
			Log.alert(params);
			
			//if (!dictionary[params.type]) params.type = 999;
			//var obj:Object = dictionary[params.type](params.sID);
				
			//if (ExternalInterface.available)
				//ExternalInterface.call("wallPost", App.user.id, params.owner_id, obj.title, params.msg, obj.url, null);
			
		}
	}

}