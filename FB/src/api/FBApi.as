package api
{
	import core.Log;
	import core.MultipartURLLoader;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.external.ExternalInterface;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.events.Event;
	
	import com.adobe.images.PNGEncoder;
	
	import api.com.adobe.crypto.MD5;
		
	public class FBApi
	{
		public var flashVars:Object;
		
		public static function generateImageURL():String {
			var _name:String = '486x258_'+String(int(Math.random()*9)+1);
			return Config.getUnversionedImage('wallpost/FB/new', _name, 'jpg')
			//return Config.getUnversionedImage('wallpost/FB/', 'test1', 'jpg')
		}
		
		public static var dictionary:Object = {
			
			0: function(sID:uint):Object {
					return{
						title:'',//App.data.storage[sID].title,
						//url:Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
						url:Config.getImage('wallpost/FB', 'postPicGame_fb','jpg')
					}
			},
			// Новая территория
			1: function(e:* = null):Object {
					return{
						title:Locale.__e("flash:1382952379697"),
						url:Config.getImage('wallpost/FB', 'postPicTerritory_fb','jpg')
					}
			},
			2: function(sID:uint):Object {
					return{
						title:Locale.__e("flash:1382952379698"),
						url:App.lang == Config.getImage('wallpost/FB', 'postPicGame_fb','jpg')
					}
			},
			3: function(sID:uint):Object {
					return{
						title:Locale.__e("flash:1382952379699"),
						url:Config.getImage('wallpost/FB', 'postPicGame_fb','jpg')
					}
			},
			//Quest
			4: function(sID:uint):Object {
					return{
						title:Locale.__e("flash:1382952379702"),//1427210653153
						url:generateImageURL()//Config.getImage('wallpost/FB', 'postPicQuest_fb','jpg')
					}
			},
			// Уровень
			5: function(sID:uint):Object {
				return{
					title:Locale.__e("flash:1382952379703"),
					url:Config.getImage('wallpost/FB', 'postPicLevel_fb','jpg')
				}
			},
			6: function(sID:uint):Object {
					return{
						title:Locale.__e("flash:1382952379702"),
						url:Config.getImage('wallpost/FB', 'postPicGame_fb','jpg')
					}
			},
			7: function(qID:uint):Object {
					return{
						title:Locale.__e(App.data.quests[qID].title),
						url:generateImageURL()//Config.getImage('wallpost/FB', 'postPicGame_fb','jpg')
					}	
			},
			// Постройка
			8: function(sID:uint):Object {
					return{
						title:Locale.__e("flash:1428400868944"),
						url:Config.getImage('wallpost/FB', 'postLevelup_fb','jpg')
					}
			},
			13: function(sID:uint):Object {
					return{
						title:'',
						url:Config.getImage('wallpost/FB', 'postPicGame_fb','jpg')
					}
			},
			999: function(sID:uint):Object {
				return{
					title:App.data.storage[sID].title,
					url:Config.getImage('wallpost/FB', 'postPicGame_fb','jpg')
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
			Log.alert(this);
			App.self.onNetworkComplete(this);
		}
		
		public function wallPost(params:Object):void {
			Log.alert('WALLPOST FB');
			Log.alert(params);
			if (params.msg) // unforeseen consequences
				params.msg = (params.msg as String).replace('%s', '');
			if (!FBApi.dictionary[params.type]) params.type = 999;
			var obj:Object = FBApi.dictionary[params.type](params.sID);
			obj.title = params.msg;
			
			if (params.hasOwnProperty('url')) {
				obj['url'] = params.url;
			}
			
			Log.alert(params.type);
			
			if (!App.self.sharePermission) {
				Log.alert('!App.self.sharePermission');
				ExternalInterface.addCallback("onCheckPermission", onCheckPermission);
				ExternalInterface.call("checkPermission");
				return;
			}else {
				ExternalInterface.call("wallPost", App.user.id, params.owner_id, obj.title, params.msg,obj.url, null);
			}	
			
			function onCheckPermission(params:Object):void {
				Log.alert('------onCheckPermission -> ' + params.result);
				if(params.result){
					ExternalInterface.call("wallPost", App.user.id, params.owner_id, obj.title, params.msg, obj.url, null);
				}
			}
		}
	}
}