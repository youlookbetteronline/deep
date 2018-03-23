package api
{
	import api.com.odnoklassniki.core.*;
	import api.com.odnoklassniki.events.*;
	import api.com.odnoklassniki.Odnoklassniki;
	import api.com.odnoklassniki.net.*;
	import api.com.odnoklassniki.sdk.users.Users;
	import api.com.odnoklassniki.sdk.friends.Friends;
	import api.com.odnoklassniki.sdk.photos.Photos;
	import core.Load;
	import core.Log;
	import core.Post;
	import flash.external.ExternalInterface;
	import flash.system.Security;
	import flash.utils.setTimeout;
	import flash.events.Event;
	
	
		
	public class OKApi
	{
			
		public var flashVars:Object;
		public var profile:Object = { };
		public var appFriends:Array = [];
		public var allFriends:Array = [];
		public var friends:Object = { };
		public var otherFriends:Object = null;
		public var wallServer:String;
		public var albums:Object;
		public var mainAlbum:Object;
		
		private var queue:Vector.<Array> = new Vector.<Array>;
		private var executing:Boolean = false;
		
		public var friendsData:Array = new Array();

		public var usersUids:Array = new Array();
		
		private var album:String = null;
		
		private var apiObject:Object;
		private var callback:Function = null;
		private var wallPostObject:Object = null;
		
		public var callsLeft:int = 0;
		
		public static function generateImageURL():String {
			var _name:String = '460x360_'+String(int(Math.random()*4)+1);
			return Config.getUnversionedImage('wallpost/460x360', _name)
		}
		
		public var dictionary:Object = {
			0: function(sID:uint):Object {
					return{
						title:'',//App.data.storage[sID].title,
						url:Config.getUnversionedIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
					}
			},
			1: function(e:* = null):Object { //Zone
					return{
						title:Locale.__e("flash:1382952379697"),
						url:Config.getUnversionedImage('wallpost', 'Post_territory')
					}
			},
			8: function(sID:uint):Object { //Level
					return{				
						title:Locale.__e("flash:1382952379703"),
						url:Config.getUnversionedImage('wallpost', 'Post_level')
					}
			},
			7: function(qID:uint):Object { //Quest
					return{				
						title:Locale.__e(App.data.quests[qID].description),
						//url:Config.getQuestIcon('icons', App.data.personages[App.data.quests[qID].character].preview)
						//url:Config.getUnversionedImage('wallpost', 'Post_achiev')
						url:generateImageURL()
					}	
			},
			6: function(sID:uint):Object { //Promo
					return{								
						//title:Locale.__e("flash:1382952379702"),
						url:Config.getUnversionedImage('wallpost', 'Post_promo')
					}
			},
			
			
			
			2: function(sID:uint):Object {
					return{				
						title:Locale.__e("flash:1382952379698"),
						//url:Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
						url:Config.getUnversionedImage('mail', 'promo')
					}
			},
			3: function(sID:uint):Object {
					return{								
						title:Locale.__e("flash:1382952379699"),
						//url:Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
						url:Config.getUnversionedImage('mail', 'promo')
					}
			},
			4: function(sID:uint):Object {
					return{								
						title:Locale.__e("flash:1382952379700"),
						//url:Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
						url:Config.getUnversionedImage('mail', 'promo')
					}
			},
			5: function(sID:uint):Object {
					return{								
						title:Locale.__e("flash:1382952379701"),
						//url:Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
						url:Config.getUnversionedImage('mail', 'promo')
					}
			},
			
			9: function(sID:uint):Object {
					return{				
						title:Locale.__e("flash:1398776058888", [App.data.storage[sID].title]),
						//url:Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
						url:Config.getUnversionedImage('mail', 'promo', 'jpg')
					}
			}
		}
		
		//public static const OTHER:uint = 0;
		//public static const NEW_ZONE:uint = 1;
		//public static const GIFT:uint = 2;
		//public static const ASK:uint = 3;
		//public static const ANIMAL:uint = 4;
		//public static const BUILDING:uint = 5;
		//public static const PROMO:uint = 6;
		//public static const QUEST:uint = 7;
		//public static const LEVEL:uint = 8;
		//public static const GAME:uint = 9;
	
		/**
		 * Конструктор
		 * @param	flashVars	переменные Одноклассники
		 */
		public function OKApi(flashVars:Object)
		{
			this.flashVars = flashVars;
			Log.alert('OKApi');
			ExternalInterface.addCallback("setNetwork", setNetwork);
			ExternalInterface.call('getNetwork');
		}
		
		public function setNetwork(params:Object):void
		{
			Log.alert('setNetwork');
			Log.alert(params);
			
			appFriends 	= params['appuids'];
			friends 	= params['friends'];
			profile 	= params['profile'];
			allFriends 	= params['alluids'];
			
			Log.alert('complete');
			App.self.onNetworkComplete(this);
		}
		public static var showInviteCallback:Function = null;
		
		public function refreshMoney():void {
			Post.send( {
				'ctr':'stock',
				'act':'balance',
				'uID':App.user.id
			}, function(error:*, result:*, params:*):void {
				if(!error && result){
					for (var sID:* in result){
						App.user.stock.put(sID, result[sID]);
					}
				}
			});	
		}
	
		public function makeScreenshot():void {
			setPermissionsOn('PHOTO CONTENT', continueMakeScreenshot);
		}
		
		public function continueMakeScreenshot(e:* = null):void 
		{
			Log.alert('continueMakeScreenshot');
			Log.alert('album '+album);
			if (album == null) {
				createAlbums();
			}else {
				Odnoklassniki.callRestApi('photosV2.getUploadUrl', onGetUploadUrl, {aid:album}, "JSON", "POST");
			}
		}
		
		public function setPermissionsOn(perm:String, _callback:Function):void {
			Odnoklassniki.callRestApi('users.hasAppPermission', onCheckPermissions, { uid:App.user.id, ext_perm:perm }, 'JSON', "POST");
			function onCheckPermissions(response:*):void {
				
				if (response == false)
				{
					callback = _callback
					Odnoklassniki.showPermissions(perm);
				}
				else
				{
					callback = null
					_callback();
				}
			}
		}
		
		public function createAlbums(params:Object=null):void {
			Odnoklassniki.callRestApi('photos.createAlbum', function(aid:*):void {
				Log.alert('photos.createAlbum');
				Log.alert(aid);
				album = aid;
				Odnoklassniki.callRestApi('photosV2.getUploadUrl', onGetUploadUrl, {aid:album, count: 1}, "JSON", "POST");
			}, { title:Locale.__e("flash:1382952379705"), type:"public" }, "JSON", "POST");
		}
		
		
		
		public function onGetUploadUrl(response:Object):void {
			Log.alert('onGetUploadUrl');
			Log.alert(response);

			if (wallPostObject != null) {
				Security.loadPolicyFile("http://up.odnoklassniki.ru/crossdomain.xml");
				Photos.upload([wallPostObject.file], function(response:Object):void { 
					for (var photo:* in response.photos) {
						Log.alert(photo);
						Odnoklassniki.callRestApi('photosV2.commit', function(response:*):void {
							Log.alert(response);
							wallPostObject = null;
						}, { photo_id:photo, token:response.photos[photo].token, comment:wallPostObject.msg }, "JSON", "POST");
					}
					Log.alert('Photos.upload complete');
				}, response.upload_url , App.user.id, album);
							
			} else {
				ExternalApi.saveScreenshot(response);
			}
			
		}
		
		private function onUploadComplete(e:Event):void {
			
		}
		
		private function onWallpostUploadResponse(e:Event):void {
			var response:Object = JSON.parse(e.currentTarget.loader.data);		
			response['caption'] = wallPostObject.msg;
			saveToAlbum(response);
			wallPostObject = null;
		}
		
		public function saveToAlbum(response:Object):void
		{
			Log.alert('saveToAlbum: '+response.photos);
			for (var photo:* in response.photos) {
				Log.alert(photo);
				Odnoklassniki.callRestApi('photosV2.commit', function(response:*):void {
						Log.alert(response);	
					}, { photo_id:photo, token:response.photos[photo].token, comment:response['caption'] }, "JSON", "POST");
				break;
			}
		}

		public function showInviteBox():void
		{
			//Odnoklassniki.showInvite(Locale.__e('flash:1382952379702'));
			ExternalInterface.call("showInvite", Locale.__e('flash:1382952379702', [Config.appUrl]));
		}
		
		
		public function getCallsLeft():void {
			return;
			Log.alert('getCallsLeft');
			//setPermissionsOn('PUBLISH TO STREAM', function():void { } );
				
			Odnoklassniki.callRestApi('users.getCallsLeft', function(response:*):void { 
				Log.alert(response);
				return;
				/*if (response[0].available == false) 
					callsLeft = 0;
				else
					callsLeft = response[0].callsLeft;
					
				Log.alert('callsLeft: '+callsLeft);	*/
					
			}, { uid:App.user.id, methods:'stream.publish'}, "JSON", "POST");
		}
		
		public function showNotification(params:Object):void {
			if (params.type == ExternalApi.ASK ||
				params.type == ExternalApi.GIFT)
				return;
				
			var obj:Object = dictionary[params.type](params.sID);
		
			Odnoklassniki.showNotification(obj.title);
		}
		
		//public function wallPostOld(params:Object):void {
			//
			//Log.alert(params);
			//
			////if (params.type == ExternalApi.ASK || params.type == ExternalApi.GIFT)
				////return;
			////switch(params.type) {
				////case ExternalApi.ASK:
				////case ExternalApi.GIFT:
				////case ExternalApi.FRIEND_BRAG:
				////	return;
				////break;
			////}
				//
			//var obj:Object = dictionary[params.type](params.sID);
			//var url:String = obj.url.replace(Config.secure +  Config._resIP, "");
			//
			//Log.alert('wallPOST');
			//Log.alert(Config.secure);
			//Log.alert(Config._resIP);
			//
			////Log.alert(url);
			////Log.alert(params.type);
			//
			////var attach:Object = {
				////"caption":Locale.__e('flash:1408696652412'),//params.msg,
				////"media":[{"href":params.url,"src":url,"type":"image"}]
			////};
			//
			//wallPostObject = { 
				//file: params.bytes,
				//msg : params.msg + " " + params.url				
			//};
			//
			//var callback:Function = function(response:Object):void {
				//
				//Log.alert('onGetUploadUrl ' + response);
//
				//if (wallPostObject != null) {
					//Security.loadPolicyFile("http://up.odnoklassniki.ru/crossdomain.xml");
					//Photos.upload([wallPostObject.file], function(response:Object):void { 
						//for (var photo:* in response.photos) {
							//Log.alert(photo);
							//Odnoklassniki.callRestApi('photosV2.commit', function(response:*):void {
								//Log.alert(response);
								//wallPostObject = null;
							//}, { photo_id:photo, token:response.photos[photo].token, comment:wallPostObject.msg }, "JSON", "POST");
						//}
						//Log.alert('Photos.upload complete');
					//}, response.upload_url , App.user.id, album);
								//
				//} else {
					//ExternalApi.saveScreenshot(response);
				//}
				//
				//if (params.callback != null && !response.error_code) 
					//params.callback(response);
			//}
			//
			//
			//setPermissionsOn('PHOTO CONTENT', function() : void {
				//if (album == null) {
					//createAlbums();
				//}else {
					//Odnoklassniki.callRestApi('photosV2.getUploadUrl', callback/*onGetUploadUrl*/, {aid:album}, "JSON", "POST");
				//}
			//});
			//
			//return;
			///*
			//var request : Object = {method : "stream.publish", uid : params['owner_id'], message : params.msg, attachment:JSON.stringify(attach)};
			////var request : Object = {method : "stream.publish", uid : params['owner_id'], message : obj.title, attachment:JSON.stringify(attach)};
			//request = Odnoklassniki.getSignature(request, false);
			//
			//callback = function(e:* = null):void {
				//
				////Log.alert(e.data);
				////Log.alert(e.method);
				////Log.alert('__onWallPostPublished');	
				//
				//request['resig'] = e.data;
				//if (params.callback != null) 
						//params.callback(e.data);
				//
				//Odnoklassniki.callRestApi('stream.publish', function(response:*):void { 
					//Log.alert(response);
					//
				//}, request, "JSON", "POST");
			//}
			//
			//ExternalApi.apiNormalScreenEvent();
			//Odnoklassniki.showConfirmation('stream.publish', params.msg, request['sig']);*/
		//}
		
		public function wallPost(params:Object):void 
		{
			Log.alert('WALLPOST');
			Log.alert(params);
			
			params.msg = params.msg.replace(/http[^ ]+/, "");
			
			params['hash'] = Config.appUrl;
			
			var hashIndex:int = params.msg.indexOf('#oneoff');
			if (hashIndex >= 0) {
				params.hash = 'oneoff=' + params.msg.substr(hashIndex + 7, 13);
			}
			
			var obj:Object = dictionary[params.type](params.sID);
			var url:String = obj.url;//.replace('http://' + Config._resIP, "");
			if (String(obj.title).length > 64 ) // не дает посить с названием большим чем 64 символа
			{
				params.msg = obj.title + '\n' + params.msg;
				obj.title = Log.alert('flash:1472726979622');
			}
			var attach:Object = {
				'title':obj.title,
				'text': params.msg,
				'image':url,
				'action': Config.appUrl,
				'mark': Config.appUrl
			}
			Log.alert(attach);	
			if (ExternalInterface.available)
			{	
				ExternalInterface.call("post", attach);
			}	
		}
		
		public function showNotificationNew(txt:String, uid:String = ""):void
		{
			Odnoklassniki.showNotification(txt, uid);
		}
		
		public function checkGroupMember(callback:Function):void {
			//Odnoklassniki.callRestApi('group.getUserGroupsV2', function(response:*):void { 
				//Log.alert(response);
				//if (response.groups != null)
				//{
					//for each(var obj:* in response.groups) {
						//if (obj.groupId == '52619439636668') 
						//{
							//callback(1);
							//return;
						//}
					//}
				//}
				//callback(0);
					//
			//}, {uid:App.user.id}); 
			//callback(1);
			if (ExternalInterface.available)
			{
				ExternalInterface.addCallback("onCheckGroupMember", callback);
				ExternalInterface.call("checkGroupMember");
			}
			else
			{
				callback(0);
			}
		}
		
		
		public function showConfirmationCallback(e:*):void {
			Log.alert('showConfirmationCallback:')
		}
		
		public function onWallPostPublished(response:*):void {
			Log.alert('onWallPostPublished');
			Log.alert(response);
		}	
		
		public function purchase(object:Object):void
		{
			callback = object.callback;
			
			
			var params:Object = {};
			
			if (object.money == "Coins")
			{
				//Odnoklassniki.showPayment(
					//Locale.__e('flash:1382952379707',[object.count]), 
					//Locale.__e('flash:1382952379708'), 
					//object.item, 
					//int(object.votes), 
					//null, 
					//null, 
					//'ok', 
					//'true'
				//);
				
				params["name"] = Locale.__e('flash:1382952379707', [object.count]);
				params["description"] = Locale.__e('flash:1382952379708');
				params["code"] = object.item;
				params["price"] = int(object.votes);
				params["options"] = null;
				params["attributes"] = null;
				params["currency"] = "ok",
				params["callback"] = "true";
			}
			else if (object.money == "Reals") 
			{
				//Odnoklassniki.showPayment(
					//Locale.__e('flash:1382952379709',[object.count]), 
					//Locale.__e('flash:1382952379708'), 
					//object.item, 
					//int(object.votes), 
					//null,
					//null, 
					//'ok', 
					//'true'
				//);
				
				params["name"] = Locale.__e('flash:1382952379709',[object.count]);
				params["description"] = Locale.__e('flash:1382952379708');
				params["code"] = object.item;
				params["price"] = int(object.votes);
				params["options"] = null;
				params["attributes"] = null;
				params["currency"] = "ok",
				params["callback"] = "true";
			}
			else if (object.money == "promo") 
			{
				//Odnoklassniki.showPayment(
					//object.title,
					//'',
					//object.item,
					//int(object.votes),
					//null, 
					//null, 
					//'ok', 
					//'true'
				//);
				
				params["name"] = object.title;
				params["description"] = "";
				params["code"] = object.item;
				params["price"] = int(object.votes);
				params["options"] = null;
				params["attributes"] = null;
				params["currency"] = "ok",
				params["callback"] = "true";
			}
			else if (object.money == "sets") 
			{
				//Odnoklassniki.showPayment(
					//Locale.__e(object.title),
					//'',
					//object.item,
					//int(object.votes),
					//null, 
					//null, 
					//'ok', 
					//'true'
				//);
				
				params["name"] = object.title;
				params["description"] = "";
				params["code"] = object.item;
				params["price"] = int(object.votes);
				params["options"] = null;
				params["attributes"] = null;
				params["currency"] = "ok",
				params["callback"] = "true";
			}
			else if (object.money == "bigsale") 
			{
				//Odnoklassniki.showPayment(
					//object.title,
					//object.description || '',
					//object.item,
					//int(object.votes),
					//null, 
					//null, 
					//'ok', 
					//'true'
				//);
				
				params["name"] = object.title;
				params["description"] = object.description || "";
				params["code"] = object.item;
				params["price"] = int(object.votes);
				params["options"] = null;
				params["attributes"] = null;
				params["currency"] = "ok",
				params["callback"] = "true";
			}
			if (object.money == "Energy") 
			{
				//Odnoklassniki.showPayment(
					//object.title,
					//object.description || '',
					//object.item,
					//int(object.votes),
					//null, 
					//null, 
					//'ok', 
					//'true'
				//);
				
				params["name"] = object.title;
				params["description"] = object.description || "";
				params["code"] = object.item;
				params["price"] = int(object.votes);
				params["options"] = null;
				params["attributes"] = null;
				params["currency"] = "ok",
				params["callback"] = "true";
			}
			
			if (ExternalInterface.available)
			{
				ExternalInterface.addCallback("updateBalance", function():void {
					if (callback != null)
					{
						callback();
					}
						
					Post.send( {
						'ctr':'stock',
						'act':'balance',
						'uID':App.user.id
					}, function(error:*, result:*, params:*):void {
						if(!error && result){
							for (var sID:* in result){
								App.user.stock.put(sID, result[sID]);
							}
						}
					});
				});
				ExternalInterface.call("showPayment", params);
			}
		}
	}
}