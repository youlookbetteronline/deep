package core 
{
	import api.ExternalApi;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import strings.Strings;
	import ui.UserInterface;
	import units.Building;
	import units.Trade;
	import units.Unit;
	import wins.Window;
	/**
	 * ...
	 * @author 
	 */
	public class WallPost 
	{
		public static const OTHER:uint = 0;
		public static const NEW_ZONE:uint = 1;
		public static const GIFT:uint = 2;
		public static const ASK:uint = 3;
		public static const ANIMAL:uint = 4;
		public static const BUILDING:uint = 5;
		public static const PROMO:uint = 6;
		public static const QUEST:uint = 7;
		public static const LEVEL:uint = 8;
		public static const INSTANCE_INVATE:uint = 9;
		public static const INSTANCE_INVATE_ALL:uint = 10;
		public static const GAME:uint = 11;
		public static const FRIEND_BRAG:uint = 12;
		public static const BFFREMIND:uint = 13;
		public static const ACHIVE:uint = 14;
		public static const NOTIFY:uint = 15;
		public static const TREE_INVITE:uint = 16;
		public static const CASTLE_INVITE:uint = 17;
		public static const FAIR_INVITE:uint = 18;
		public static const HAPPY_INVITE:uint = 19;
		public static const HAPPY_SHARE:uint = 20;
		public static const HAPPY_VALENTINE_SHARE:uint = 20;
		public static const COMET:uint = 21;
		public static const CLOUD:uint = 22;
		
		public function WallPost() 
		{
			
		}
		
		private static var randomKey:String;
		public static function onPostComplete(result:*):void {
				if (!result || result == 'null') return;
				
				if (App.social == "ML" && result.status != "publishSuccess")
					return;
				
				Post.statisticPost(Post.STATISTIC_WALLPOST);
			
				Post.send( {
					ctr:	'oneoff',
					act:	'set',
					uID:	App.user.id,
					id:		randomKey
				}, function(error:int, data:Object, params:Object):void {});
			}
		
		public static function makePost(type:int, settings:Object = null):void//type:int, sid:int = 0, fid:int = 0, btm:Bitmap = null):void
		{
			if (App.isSocial('SP')) return;
			
			var message:String;
			var back:Sprite = new Sprite();
			var front:Sprite = new Sprite();
			
			var material:Object;
			
			var gameTitle:Bitmap;
			var bmd:BitmapData;
			var bitmap:Bitmap;
			
			var imgSp:Sprite;
			
			var cont:Sprite = new Sprite();
			
			var funcTitle:Function = function():void {
				gameTitle = new Bitmap(Window.textures.logo, "auto", true);
				back.addChild(gameTitle);
				gameTitle.x = -gameTitle.width/2;
				gameTitle.y = bitmap.height - 34;
			}
			
			var getBuilding:Function = function():Building
			{
				var arr:Array = Map.findUnits([settings.sid]);
					
				if (arr.length == 0) return null;
				
				var building:Building = arr[0];
				return building;
			}
			
			var addBackToImage:Function = function(_cont:Sprite, width:Number, height:Number):void
			{
				var sp:Sprite = new Sprite();
				sp.graphics.beginFill(0xffffff);
				sp.graphics.drawRect(0, 0, width, height);
				sp.graphics.endFill();		
				_cont.addChildAt(sp, 0);
				
				back.x = (width - back.width)/2 + back.width / 2;
				back.y = (_cont.height - back.height)/2;
			}
			
			var buildImage:Function = function(btmd:BitmapData, _scale:Number = 0.8, btm:Bitmap = null):void
			{
				if(btmd)
					bitmap = new Bitmap(btmd);
				else if (btm)
					bitmap = btm;
					
				if(bitmap){
					bitmap.scaleX = bitmap.scaleY = _scale;
					bitmap.smoothing = true;
					back.addChild(bitmap);
					bitmap.x = -bitmap.width / 2;
					
					funcTitle();
					
					cont.addChild(back);
					
					back.x = back.width / 2;
					
					//if(App.social == 'OK'){
						addBackToImage(cont, 492, 364);
						//var _width:Number = cont.width;
						//var _height:Number = cont.height;
						//var koef:Number = 0;
						//if (_height > 492/*_width*/) {
							//koef = _height / _width;
							//if (koef > 1.35) {
								//_width = int(_height * 1.35);//int(_width * (koef - 0.35));
								//addBackToImage(cont, _width, _height);
							//}
						//}else {
							//koef = _width / _height;
							//if (koef > 1.35) {
								//_height = int(_width * 1.35);//int(_height * (koef - 0.35));
								//addBackToImage(cont, _width, _height);
							//}
						//}
					//}
					
					
					bmd = new BitmapData(cont.width, cont.height, false);
					bmd.draw(cont);
					back = null;
					cont = null
				}
			}
			
			randomKey = Config.randomKey;
			var linkType:String = '?ref=';
			if (App.isSocial('DM','VK','ML')) linkType = '#';
			var url:String = Config.appUrl + linkType + 'oneoff' + randomKey + 'z';
			
			if(settings.hasOwnProperty('sid')){
				if (!App.data.storage[settings.sid].title) {
					App.data.storage[settings.sid].title = 'default';
				}
			}
			switch(type) {
				
				case HAPPY_SHARE:
				case HAPPY_VALENTINE_SHARE:
					message = Strings.__e('Happy_share', [App.data.storage[settings.sid].title, url]);
					if (type == HAPPY_VALENTINE_SHARE) message = Strings.__e('Happy_valentine_share', [App.data.storage[settings.sid].title, url]);
					
					ExternalApi.apiWallPostEvent(ExternalApi.BUILDING, new Bitmap(settings.bmd), settings.uid, message, settings.sid, onPostComplete, {url:''});// , App.ui.bottomPanel.removePostPreloader);
				break;
				case HAPPY_INVITE:
					message = Strings.__e('Happy_invite',[App.data.storage[settings.sid].title, url]);
					if (App.social == "FB" || App.social == 'NK'){
						ExternalApi.notifyFriend( { uid:[settings.uid], text:message, type:'instance' } );
						return;
					}	
					ExternalApi.apiWallPostEvent(ExternalApi.BUILDING, new Bitmap(settings.bmd), settings.uid, message, settings.sid, onPostComplete, {url:url});// , App.ui.bottomPanel.removePostPreloader);
				break;
				case CASTLE_INVITE:
					message = Strings.__e('Castle_invite', [App.data.storage[settings.sid].title, /*Config.appUrl*/url]);//поменять надпись
					if (App.social == "FB" || App.social == 'NK'){
						ExternalApi.notifyFriend( { uid:[settings.uid], text:message, type:'instance' } );
					return;
					}	
					imgSp = getBuilding().bitmapContainer;
					imgSp.alpha = 1;
					buildImage(Zone.snapClip(imgSp, 2));
					
					ExternalApi.apiWallPostEvent(ExternalApi.BUILDING, new Bitmap(bmd), settings.uid, message, settings.sid, onPostComplete, {url:url});// , App.ui.bottomPanel.removePostPreloader);
				break;
				case FAIR_INVITE:
					message = Strings.__e('Fair_invite', [App.data.storage[settings.sid].title, /*Config.appUrl*/url]);//поменять надпись
					
					if (App.social == "FB" || App.social == 'NK'){
						ExternalApi.notifyFriend( { uid:[settings.uid], text:message, type:'instance' } );
						return;
					}	
						
					imgSp = getBuilding().bitmapContainer;
					imgSp.alpha = 1;
					buildImage(Zone.snapClip(imgSp, 2));
					
					ExternalApi.apiWallPostEvent(ExternalApi.BUILDING, new Bitmap(bmd), settings.uid, message, settings.sid, onPostComplete, {url:url});// , App.ui.bottomPanel.removePostPreloader);
				break;
				
				
				case TREE_INVITE:
					message = Strings.__e('Instance_invite',[App.data.storage[settings.sid].title, /*Config.appUrl*/url]);//поменять надпись
					
					if (App.social == "FB" || App.social == 'NK'){
						ExternalApi.notifyFriend({uid:[settings.uid], text:message, type:'instance'});
					}else{	
						imgSp = getBuilding().bitmapContainer;
						imgSp.alpha = 1;
						buildImage(Zone.snapClip(imgSp, 2));
						
						ExternalApi.apiWallPostEvent(ExternalApi.BUILDING, new Bitmap(bmd), settings.uid, message, settings.sid, onPostComplete, { url:url } );// , App.ui.bottomPanel.removePostPreloader);
					}
				break;
			case INSTANCE_INVATE:
					message = Strings.__e('Instance_invite', [App.data.storage[settings.sid].title, /*Config.appUrl*/url]);//поменять надпись
					
					if (App.social == "FB" || App.social == 'NK'){
						ExternalApi.notifyFriend({uid:[settings.uid], text:message, type:'instance'});
					}else{	
						imgSp = getBuilding().bitmapContainer;
						imgSp.alpha = 1;
						buildImage(Zone.snapClip(imgSp, 2));
						
						ExternalApi.apiWallPostEvent(ExternalApi.BUILDING, new Bitmap(bmd), settings.uid, message, settings.sid, onPostComplete, { url:url } );// , App.ui.bottomPanel.removePostPreloader);
					}
				break;
				case INSTANCE_INVATE_ALL:
					message = Strings.__e('Instance_invite_all',[App.data.storage[settings.sid].title, /*Config.appUrl*/url]);//поменять надпись
					
					imgSp = getBuilding().bitmapContainer;
					imgSp.alpha = 1;
					buildImage(Zone.snapClip(imgSp, 2));
					//buildImage(getBuilding().bitmap.bitmapData);
					
					
					//if (App.ui && App.ui.bottomPanel)
						//App.ui.bottomPanel.addPostPreloader();
					//App.self.addChild(new Bitmap(bmd));
					ExternalApi.apiWallPostEvent(ExternalApi.BUILDING, new Bitmap(bmd), App.user.id, message, settings.sid, onPostComplete, {url:url});// , App.ui.bottomPanel.removePostPreloader);
				break;
				case OTHER:
					
				break;
				case NEW_ZONE:
					message = Strings.__e('World_openZonePost',[App.data.storage[settings.sid].title, /*Config.appUrl*/url]);
					
					buildImage(UserInterface.textures.territory);
					
					//if (App.ui && App.ui.bottomPanel)
						//App.ui.bottomPanel.addPostPreloader();
					//App.self.addChild(new Bitmap(bmd));
					ExternalApi.apiWallPostEvent(ExternalApi.NEW_ZONE, new Bitmap(bmd), App.user.id, message, 0, onPostComplete, {url:url});// , 0, App.ui.bottomPanel.removePostPreloader);
				break;
				case GIFT:
					material = App.data.storage[settings.sid];
					message = Strings.__e('Gifts_send', [material.title, Config.appUrl]);
					
					bitmap = new Bitmap(Gifts.generateGiftPost(Load.getCache(Config.getIcon(material.type, material.preview))));
					
					//if (App.ui && App.ui.bottomPanel)
						//App.ui.bottomPanel.addPostPreloader();
					if(App.social == 'FB')
						ExternalApi.apiAppRequest([String(settings.fid)], message);// , App.ui.bottomPanel.removePostPreloader);
					else if (App.social == 'FS') {
						ExternalApi.notifyFriend( { uid:settings.fid, text:message, callback:onPostComplete, type:'gift' } );
					}else{
						if (bitmap != null)
							ExternalApi.apiWallPostEvent(ExternalApi.GIFT, bitmap, String(settings.fid), message, settings.sid, onPostComplete, {url:Config.appUrl});// , App.ui.bottomPanel.removePostPreloader);
					}
					
					//App.self.addChild(bitmap);
				break;
				case ASK:
					material = App.data.storage[settings.sid];
					message = Strings.__e('Gifts_ask', [App.user.first_name, App.user.last_name, material.title, Config.appUrl/*url*/]); 
					
					bitmap = new Bitmap(Gifts.generateGiftPost(Load.getCache(Config.getIcon("Material", material.preview))));
					
					//if (App.ui && App.ui.bottomPanel)
						//App.ui.bottomPanel.addPostPreloader();
					if (bitmap != null) {
						//App.self.addChild(bitmap);
						ExternalApi.apiWallPostEvent(ExternalApi.ASK, bitmap, String(settings.fID), message, settings.sid, onPostComplete, {url:Config.appUrl});// , App.ui.bottomPanel.removePostPreloader);
					}
				break;
				case ANIMAL:
					
				break;
				case BUILDING:
					message = Strings.__e('AUnit_makePost',[App.data.storage[settings.sid].title, /*Config.appUrl*/url]);
					
					var target:* = getBuilding();
					target.state = (target as Building).DEFAULT;
					imgSp = target.bitmapContainer;
					imgSp.alpha = 1;
					buildImage(Zone.snapClip(imgSp, 2));
					//buildImage(getBuilding().bitmap.bitmapData);
					
					//if (App.ui && App.ui.bottomPanel)
						//App.ui.bottomPanel.addPostPreloader();
					//App.self.addChild(bitmap);
				
					ExternalApi.apiWallPostEvent(ExternalApi.BUILDING, new Bitmap(bmd), App.user.id, message, settings.sid, onPostComplete, {url:url});// , App.ui.bottomPanel.removePostPreloader);
				break;
				case PROMO:
					
				break;
				case QUEST:
					if(App.social == "OK")
						message = Strings.__e('QuestRewardWindow_onTellEvent', [settings.quest.title, /*Config.appUrl*/'']); 
					else
						message = Strings.__e('QuestRewardWindow_onTellEvent', [settings.quest.title, /*Config.appUrl*/url]); 
					
					var img:Bitmap = new Bitmap();
					img = Load.getCache(Config.getQuestIcon("preview", App.data.personages[settings.quest.character].preview));
					if (img) {
						buildImage(null, 0.5, img);
					}else {
						gameTitle = new Bitmap(Window.textures.logo, "auto", true);
						back.addChild(gameTitle);
						gameTitle.x = 0;
						bmd = new BitmapData(Math.max(10, gameTitle.width), back.height);
						bmd.draw(back);
					}
					
					//if (App.ui && App.ui.bottomPanel)
						//App.ui.bottomPanel.addPostPreloader();
					//App.self.addChild(new Bitmap(bmd));
					ExternalApi.apiWallPostEvent(ExternalApi.QUEST, new Bitmap(bmd), App.user.id, message, settings.qID, onPostComplete, {url:url});// , App.ui.bottomPanel.removePostPreloader);
				break;
			case LEVEL:
					Log.alert('makepost LEVEL passed');
					message = Strings.__e('LevelUpWindow_onTellBttn', [int(App.user.level), /*Config.appUrl*/url]);
					
					//if (App.ui && App.ui.bottomPanel)
						//App.ui.bottomPanel.addPostPreloader();
						
					var callBack:Function = null;
					if (settings.callBack != null)
						callBack = settings.callBack;
					
					ExternalApi.apiWallPostEvent(ExternalApi.LEVEL, settings.btm, App.user.id, message, 0, callBack, {url:url});// , 0, App.ui.bottomPanel.removePostPreloader);
				break;
				case GAME:
					//message = Strings.__e('LevelUpWindow_onTellBttn', [int(App.user.level), Config.appUrl]);
					message = Locale.__e("flash:1406550052096", [/*Config.appUrl*/url]);
					bitmap = new Bitmap(Window.textures.gameWallPost);
					
					var callBackGame:Function = null;
					
					if (settings.callBack)
						callBackGame = settings.callBack
					
					ExternalApi.apiWallPostEvent(ExternalApi.LEVEL, bitmap, App.user.id, message, 0, callBackGame, {url:url});
				break;
				case FRIEND_BRAG://похвалится опытом
					message = Locale.__e('flash:1406723363332',[Config.appUrl]);
					//message = Locale.__e("flash:1406550052096");
					bitmap = new Bitmap(Window.textures.winnerFury);
					
					
					ExternalApi.apiWallPostEvent(ExternalApi.LEVEL/*FRIEND_BRAG*/, bitmap, settings.uid, message, 0, onPostComplete, {url:url});
				break;
				case BFFREMIND:
					message = Locale.__e("flash:1406791895058", [/*Config.appUrl*/url]);
					bitmap = new Bitmap(Window.textures.gameWallPost);
					
					
					ExternalApi.apiWallPostEvent(ExternalApi.PROMO, bitmap, settings.fID, message, 0, onPostComplete, {url:url});
				break;
				case ACHIVE:
					message = Strings.__e("Achivement_sendPost", [settings.title, url]);
					bitmap = new Bitmap(UserInterface.textures.theGame, "auto", true);
					
					if (bitmap != null) {
						ExternalApi.apiWallPostEvent(ExternalApi.PROMO, bitmap, String(App.user.id), message, 0, onPostComplete, {url:url});
					}
				break;
				case NOTIFY:
					//message = Strings.__e('LevelUpWindow_onTellBttn', [int(App.user.level), Config.appUrl]);
					message = Locale.__e("flash:1407155160192", [/*Config.appUrl*/url]);
					bitmap = new Bitmap(Window.textures.gameWallPost);
					
					callBackGame = null;
					
					if (settings.callBack)
						callBackGame = settings.callBack;
					
					ExternalApi.apiWallPostEvent(ExternalApi.LEVEL, bitmap, App.user.id, message, 0, callBackGame, {url:url});
				break;
				case COMET:
					message = Locale.__e("flash:1428999037483", [settings.count, Config.appUrl]);
					
					callBackGame = null;
					
					if (settings.callBack)
						callBackGame = settings.callBack;
					
					ExternalApi.apiWallPostEvent(COMET, new Bitmap(settings.bmd), App.user.id, message, settings.sid, callBackGame, {url:url});
				break;
				case CLOUD:
					message = Locale.__e("flash:1438173104578", [settings.count, Config.appUrl]);
					
					callBackGame = null;
					
					if (settings.callBack)
						callBackGame = settings.callBack;
					
					ExternalApi.apiWallPostEvent(CLOUD, new Bitmap(settings.bmd), App.user.id, message, settings.sid, callBackGame, {url:url});
				break;
			}
			
			
		}
		
	}

}