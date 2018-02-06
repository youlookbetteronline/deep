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
	
		
	public class HVApi
	{
		
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
				
		public function HVApi()
		{
		
		}
		
		
		public static function purchase(params:Object):void
		{
			
			if (ExternalInterface.available) {
				Log.alert('spendMoney Ana')	
				ExternalInterface.addCallback("spendMoney", function():void {
				Log.alert('spendMoney')	
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
				
				var money:String = "";
				switch(params.money) {
					case "Coins":
							money = "1";
						break;
					case "promo":
							money = "3";
						break;
					case "Sets":
							money = "4";
						break;
					case "bigsale":
							money = "5";
						break;
					default:
							money = "2";
						break;
				}
				
				var result:Array = params.item.split("_");
				if(money == '5'){
					params.sid = money + '' + result[2] + '' + result[1];
				}else {
					params.sid = money + result[1];
				}
				ExternalInterface.call("purchase", params);
			}
		}
		
		public static function wallPost(params:Object):void {
			
			var obj:Object = dictionary[params.type](params.sID);
			var url:String = obj.url;
			
			if (ExternalInterface.available)
				ExternalInterface.call("wallPost", params.msg, url);
		}
		
	}		
		
}