package api
{
	import core.Log;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.events.Event;
	
	import com.adobe.images.JPGEncoder;
	
		
	public class FBApi
	{
		public var flashVars:Object;
		
		public var dictionary:Object = {
			
			0: function(sID:uint):Object {
					return{
						title:'',//App.data.storage[sID].title,
						url:Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
					}
			},
			// Новая территория
			1: function(e:* = null):Object {
					return{
						title:Locale.__e("flash:1382952379697"),
						url:Config.getImage('mail', 'totemZone')
					}
			},
			2: function(sID:uint):Object {
					return{
						title:Locale.__e("flash:1382952379698"),
						url:Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
					}
			},
			3: function(sID:uint):Object {
					return{
						title:Locale.__e("flash:1382952379699"),
						url:Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
					}
			},
			4: function(sID:uint):Object {
					return{
						title:Locale.__e("flash:1382952379700"),
						url:Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
					}
			},
			// Постройка
			5: function(sID:uint):Object {
					return{
						title:Locale.__e("flash:1428400868944"),
						url:Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
					}
			},
			6: function(sID:uint):Object {
					return{
						title:Locale.__e("flash:1382952379702"),
						url:Config.getImage('mail', 'totemAchive')
					}
			},
			7: function(qID:uint):Object {
					return{
						title:Locale.__e(App.data.quests[qID].title),
						url:Config.getImage('mail', 'totemQuest')
					}	
			},
			// Уровень
			8: function(sID:uint):Object {
				return{
					title:Locale.__e("flash:1382952379703"),
					url:Config.getImage('mail', 'totemLevelup')
				}
			},
			999: function(sID:uint):Object {
				return{
					title:App.data.storage[sID].title,
					url:Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
				}
			}
		}
		
		public var appFriends:Array = [];
		public var allFriends:Array = [];
		public var otherFriends:Object = {};
		public var profile:Object = { };
		public var friends:Object = { };
		public var albums:Object = { };
		public var currency:Object = { };
		

		public function FBApi(flashVars:Object)
		{
			Log.alert('Init FB API');
			this.flashVars = flashVars;
			if (ExternalInterface.available){
				ExternalInterface.addCallback("initNetwork", onNetworkComplete);
				ExternalInterface.call("initNetwork");
			}else {
				App.self.onNetworkComplete( {
					profile:flashVars.profile,
					appFriends:flashVars.appFriends
				});
			}
		}
		
		
		private function onNetworkComplete(data:*):void {
			for (var prop:String in data) {
				if(this[prop] != null)
					this[prop] = data[prop];
			}
			App.self.onNetworkComplete(this);
		}
		
		
		public function wallPost(params:Object):void {
			Log.alert('WALLPOST');
			Log.alert(params);
			
			if (!dictionary[params.type]) params.type = 999;
			var obj:Object = dictionary[params.type](params.sID);
				
			if (ExternalInterface.available)
				ExternalInterface.call("wallPost", App.user.id, params.owner_id, obj.title, params.msg, obj.url, null);
			
		}
	}
}