package api
{
	import com.adobe.crypto.HMAC;
	import com.adobe.crypto.SHA1;
	import core.Log;
	import core.Post;
	import flash.external.ExternalInterface;
	
	public class MXApi
	{
	
		public var flashVars:Object;
		private var keys:Array = [
		
		'e0d915471776788fdb058878450943476062c9d2',
		'66bce39d7ac3a1f0d8b90d02e1b03aba8178ee56'
		
					];
		
		public static var dictionary:Object = {
			
			0: function(sID:uint):Object {
					return{
						title:'',//App.data.storage[sID].title,
						url:Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
					}
			},
			1: function(e:* = null):Object {
					return{
						title:Locale.__e("flash:1382952379697"),
						url:Config.getImage('mail', 'zone')
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
			5: function(sID:uint):Object {
					return{								
						title:Locale.__e("flash:1382952379701"),
						url:Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview)
					}
			},
			6: function(sID:uint):Object {
					return{								
						title:Locale.__e("flash:1382952379702"),
						url:Config.getImage('mail', 'promo', 'jpg')
					}
			},
			7: function(qID:uint):Object {
					return{				
						title:Locale.__e(App.data.quests[qID].description),
						url:Config.getQuestIcon('icons', App.data.personages[App.data.quests[qID].character].preview)
					}	
			},
			8: function(sID:uint):Object {
					return{				
						title:Locale.__e("flash:1382952379703"),
						url:Config.getImage('mail', 'promo', 'jpg')
					}
			}
		}
						
		public var appFriends:Array = [];
		public var profile:Object = { };
		public var friends:Object = { };
		public var otherFriends:Object = null;
		
		private var apiObject:Object;
		
		//data.friends["18090249874169842929"] = { };
		//App.network['friends'] = { "18090249874169842929": { "aka":"", "level":"50", "sex":"f", "energy":5, "fill":0, "uid":"18090249874169842929", "first_name":"Анна", "last_name":"Чистилина", "photo":"http://avt.appsmail.ru/mail/umkapost4/_avatar50" }};
		
		public function MXApi(flashVars:Object)
		{
			this.flashVars = flashVars;
			if(ExternalInterface.available){
				ExternalInterface.addCallback("initNetwork", onNetworkComplete);
				ExternalInterface.call("initNetwork");
			}else{
				onNetworkComplete( {
					appFriends:flashVars.appFriends,
					profile: { }
				});
			}
		}
		
		public function onNetworkComplete(data:Object):void {
			
			appFriends = takeFriendsUids(data.appFriends)
			this.profile = data.profile;
			friends = data.friends;
			Log.alert('MXApi: onNetworkComplete');
			Log.alert({appFriends:appFriends});
			Log.alert({allData:data});
			App.self.onNetworkComplete(this);
		}
		
		
		private function takeFriendsUids(data:Array):Array {
			var result:Array = [];
			Log.alert('MXApi: takeFriendsUids');
			var L:int = data.length;
			for (var i:int = 0; i < L; i++) {
				if((data[i] is Array || data[i] is Object) && data[i].hasOwnProperty('uid')){
					result.push(String(data[i].uid));
					friends[data[i].uid] = data[i];
				}else{
					result.push(String(data[i]));
					friends[data[i]] = data[i];
				}
			}
			
			return result;
		}
		
		
		public function purchase(params:Object):void
		{
			if (ExternalInterface.available){
				ExternalInterface.addCallback("updateBalance", function():void {
					
					if (params.callback != null)
						params.callback();
						
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
				
				var name:String = "";
				var money:String = "";
				
				switch(params.money) {
					
					case "Coins":
							name = App.data.storage[Stock.COINS].title;
							money = "1";
						break;
					
					case "promo":	
							name = params.description;
							money = "3";
						break;
						
					case "sets":	
							name = params.title;
							money = "4";
						break;
					
					case "bigsale":	
							name = params.title;
							money = "5";
						break;
					
					case "luckybag":	
							name = params.title;
							money = "7";
						break;
						
					default:
							name = App.data.storage[Stock.FANT].title;
							money = "2";
						break;	
				}
					
				var result:Array = params.item.split("_");
				var SKU_ID:String;
				if(money == '5'){
					SKU_ID = money + '' + result[2] + '' + result[1];
				}else {
					SKU_ID = money + result[1];
				}
				
				//////////////////////////// chamele0n
				if (!('handler' in App.self.flashVars)) {
					App.self.flashVars.handler = 'http://t-mx.islandsville.com/app/api/MX/MXPayment.php';					
				}				
				if (!('testMode' in App.self.flashVars)) {
					App.self.flashVars.testMode = 1;
				}
				Log.alert('testMode: '+App.self.flashVars.testMode);
				var sig:Array = [
					'callback_url=' + encodeURIComponent(App.self.flashVars.handler),
					'inventory_code=' + SKU_ID,
					'is_test=' + (int(App.self.flashVars.testMode) == 1 ? 'true' : 'false'),
					'item_id=' + SKU_ID,
					'item_price=' + params.votes
				];
				
				var _string:String = encodeURIComponent(sig.join('&'));
				var _key:String = keys[int(App.self.flashVars.testMode)] + '&';
				//var SIGNATURE:String = HMAC.hash2(_key, _string, SHA1);
				//////////////////////////////
				
				
				var obj:Object = {
					info: {
						type: params.money,
						count: params.count,
						string: _string
					},
					pay: {
						amount: params.votes,
						signature: HMAC.hash2(_key, _string, SHA1),
						item_id: SKU_ID,
						is_test: (int(App.self.flashVars.testMode) == 1 ? 'true' : 'false'),
						code: params.item,
						url: App.self.flashVars.handler
					}
				}
				
				ExternalInterface.call("purchase", obj);
			}
		}
		
		
		public static function wallPost(params:Object):void {
			
			var obj:Object = dictionary[params.type](params.sID);
			var url:String = obj.url;
				
			if (ExternalInterface.available) {
				Log.alert('wallPost');
				ExternalInterface.call("wallPost", {uid:App.user.id, oid:params.owner_id, title:params.msg, msg:obj.title,hasCallback:params.hasCallback});
			}	
		}
		
	
		
	}		
		
}