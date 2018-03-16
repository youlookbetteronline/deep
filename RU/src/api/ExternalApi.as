package api 
{
	import com.junkbyte.console.Cc;
	import core.Debug;
	import core.Load;
	import core.Log;
	import core.MultipartURLLoader;
	import core.Post;
	import core.WallPost;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.utils.ByteArray;
	import com.adobe.images.PNGEncoder;	
	import flash.utils.setTimeout;
	import ui.UserInterface;
	import wins.ErrorWindow;
	import wins.SimpleWindow;
	import flash.display.StageDisplayState;
	import wins.StockWindow;
	import wins.Window;
	
	public class ExternalApi 
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
		public static const GAME:uint = 9;
		
	
		public static const FRIEND_BRAG:uint = 10;
		
		public static var postCallback:Function = null;
		public static var onCloseApiWindow:Function = null;
		
		
		public function ExternalApi() 
		{
			
		}
		
		public static function apiScreenshotEvent():void {
			
			switch(App.self.flashVars.social) {
				case 'VK':
				case 'DM':	
					if (ExternalInterface.available){
						ExternalInterface.addCallback("saveScreenshot", saveScreenshot);
						
					}
					break;
				case 'OK':
					App.network.makeScreenshot();
					break;
					
				case 'MM':	
					if (ExternalInterface.available){
						ExternalInterface.addCallback("saveScreenshot", App.network.saveScreenshot);
						ExternalInterface.call("makeScreenshot");
					}
					break
			}
		}
		
		public static function checkID(_callback:Function):void 
		{
			 if (ExternalInterface.available) {
				ExternalInterface.addCallback("getIDCallback", _callback);
				ExternalInterface.call("getID");
			 }
		}
		
		public static function setCloseApiWindowCallback():void {
			if (ExternalInterface.available){
				ExternalInterface.addCallback("onCloseApiWindow", function():void{
					if (onCloseApiWindow != null)
					onCloseApiWindow();
				});
			}	
		}
		
		public static function reset():void{
			
			if (ExternalInterface.available)
			{
				ExternalInterface.call("reset");
			}
		}
		
		public static function logEvent(event:String,value:*,data:*):void{
			
			if (ExternalInterface.available&&(App.self.flashVars.social=='FB'))
			{
				Log.alert('logEvent');
				ExternalInterface.call("logEvent",event,value,data);
			}
		}
		
		public static function addSettingsCallback(callback:Function):void {
			if (ExternalInterface.available)
				ExternalInterface.addCallback("onSettingsChanged", callback);
		}
		public static function showSettingsBox():void{
			if (ExternalInterface.available)
				ExternalInterface.call("showSettingsBox");
		}
		public static function getAppPermission():void{
			if (ExternalInterface.available)
				ExternalInterface.call("getAppPermissions");
		}
		
		public static function checkGroupMember(callback:Function):void {
			if (!ExternalInterface.available)
				return	
			Log.alert('checkGroupMember');
			switch(App.self.flashVars.social) {
				case "VK":
				case 'DM':	
				case "MM":
				case "FS":
					
						ExternalInterface.addCallback("checkGroupMember", callback);
						ExternalInterface.call("isGroupMember");
					break;
				case "OK":
						App.network.checkGroupMember(callback);
					break;
				
			}
		}
		
		public static function checkTargetGroupMember(groupId:String,callback:Function):void
		{
			if (!ExternalInterface.available)
				return	
			Log.alert('checkTargetGroupMember');
			switch(App.social)
			{
				case "VK":
				case 'DM':	
				case "MM":
				case "FS":
						ExternalInterface.addCallback("checkTargetGroupMember", callback);
						ExternalInterface.call("targetGroupMember", groupId);
					break;
				case "OK":
						App.network.checkGroupMember(callback);
					break;
			}
		}
		
		public static function notifyFriend(params:Object):void
		{
			Log.alert('NOTIFY');
			Log.alert(params);
			
			switch(App.social) {
				case 'VK':
				case 'DM':
				//case 'HV':
					if (ExternalInterface.available){
						ExternalInterface.addCallback("updateNotify", function(callback:Boolean = true):void {
							if (params.callback)
								params.callback();
						});
						ExternalInterface.call("notify", params.uid, params.text);
					}
					break;	
				//case 'FB':	
				//case 'NK':	
					//ExternalApi.apiNormalScreenEvent();
					//if (ExternalInterface.available){
						//ExternalInterface.addCallback("updateNotify", function(callback:Boolean = true):void {
							//if (params.callback)
								//params.callback();
						//});
						//ExternalInterface.call("notify", params.uid, params.text, params.type);
					//}
					//break;
				case 'FS':	
					
					ExternalApi.apiNormalScreenEvent();
					if (ExternalInterface.available){
						ExternalInterface.addCallback("updateNotify", function(callback:Boolean = true):void {
							if (params.callback)
								params.callback();
						});
						ExternalInterface.call("notify", params.uid, params.text);
					}
					break;
				case 'AM':	
					Log.alert('NOTIFY AM');
					Log.alert('uid = ' + params.uid);
					ExternalApi.apiNormalScreenEvent();
					if (ExternalInterface.available){
						ExternalInterface.addCallback("updateInvite", function(callback:Boolean = true):void {
							if (!callback)
								return;
							App.user.allreadyInvite[params.uid] = params.uid;
							if (params.callback)
								params.callback();
						});
						ExternalInterface.call("sendInvite", params.uid);
					}
					break;
				//case 'OK':
					/*if (ExternalInterface.available) {
						ExternalInterface.addCallback("updateNotify", function(callback:Boolean = true):void {
							if (params.callback)
								params.callback();
						});
						App.network.showNotificationNew(params.text, null, params.uid);
					}*/
					//WallPost.makePost(WallPost.NOTIFY, {callBack:params.callback } );
					//break;
				//case "MM":
					//if (ExternalInterface.available){
						//ExternalInterface.addCallback("updateNotify", function(callback:Boolean = true):void {
							//if (params.callback)
								//params.callback();
						//});
						//ExternalInterface.call("notify", params.uid, params.text);
					//}
					//WallPost.makePost(WallPost.NOTIFY, {callBack:params.callback } );
						//ExternalApi.apiNormalScreenEvent();
						//App.network.purchase(params);
					//break;
			}
		}
		
		public static function sendmail(data:*):void {
			
			if (ExternalInterface.available)
			{
				ExternalInterface.call("sendmail", data);
			}
		}
		
		public static function saveScreenshot(response:Object):void{
			
			Post.addToArchive('saveScreenshot');
			Log.alert(response);
			
			var screenshot:BitmapData = new BitmapData(App.self.stage.stageWidth, App.self.stage.stageHeight);			
			screenshot.draw(App.self);		
			
		
			switch(App.self.flashVars.social) {
				case 'VK':
				case 'DM':	
					break;
				case 'OK':
					if (screenshot.height > 700) {
						
						var tempBitmap:Bitmap = new Bitmap(screenshot);
						tempBitmap.scaleX = tempBitmap.scaleY = 0.5;
						tempBitmap.smoothing = true;
						
						var cont:Sprite = new Sprite();
						cont.addChild(tempBitmap);
						
						screenshot = new BitmapData(tempBitmap.width, tempBitmap.height);
						screenshot.draw(cont);
						
						cont = null;
						tempBitmap = null;
					}
					
					if (response.hasOwnProperty('error_code')) {
						//var text:String = Locale.__e("flash:1382952379662");
						
						var winSettings:Object = {
							title				:Locale.__e('flash:1382952379692'),
							text				:Locale.__e('flash:1382952379662'),
							buttonText			:Locale.__e('flash:1393576915356'),
							//image				:UserInterface.textures.alert_error,
							image				:Window.textures.errorOops,
							imageX				:-78,
							imageY				: -76,
							textPaddingY        : -18,
							textPaddingX        : -10,
							hasExit             :true,
							faderAsClose        :true,
							faderClickable      :true,
							forcedClosing       :true,
							closeAfterOk        :true,
							bttnPaddingY        :25,
							ok					:function():void {
								//new StockWindow().show();
							}
						};
						new ErrorWindow(winSettings).show();
						
						return;
						//switch(response.error_code) {
							//case 10:
								//text = Locale.__e('flash:1382952379691');
								//break
						//}
						//
						//new SimpleWindow( {
							//text:text,
							//title:Locale.__e('flash:1382952379692'),
							//label:SimpleWindow.ERROR,
							//height:320
						//}).show();
						//
						//return;
					}
					
					break;
			}
			
			var pngStream:ByteArray = PNGEncoder.encode(screenshot);
			
			new SimpleWindow( {
				text:Locale.__e('flash:1382952379693'),
				title:Locale.__e('flash:1382952379694'),
				height:320,
				dialog:true,
				confirm: function():void {
					ExternalInterface.call("makeScreenshot");
					
					sendFile(response.upload_url, pngStream, onScreenshotUploadResponse);
					//Load.sendFile(response.upload_url, pngStream, "image.png", "file1", 'image/jpeg', onScreenshotUploadResponse);
				}
			}).show();
		}
		
		private static function sendFile(url:String, pngStream:ByteArray, callback:Function):void {
			
			var ldr:MultipartURLLoader = new MultipartURLLoader(); 
			ldr.addEventListener(Event.COMPLETE, function(e:Event):void {
				Post.addToArchive('-- SendFile --')
				callback(e);
			});
			ldr.addVariable('url', url);// App.network.wallServer.upload_url);
			ldr.addFile(pngStream, "image.png", "file", 'image/png');
			ldr.load('http://aliens.islandsville.com/iframe/upload.php');
		}
		
		private static function onScreenshotUploadResponse(e:Event):void {
			Post.addToArchive('onScreenshotUploadResponse');
			var response:Object = JSON.parse(e.currentTarget.loader.data);
			Log.alert('onScreenshotUploadResponse: '+e.currentTarget.loader.data);
			
			
			switch(App.self.flashVars.social) {
				case 'VK':
				case 'DM':	
					response['caption'] = Locale.__e('flash:1382952379695', [Config.appUrl]);
					if (ExternalInterface.available)
						ExternalInterface.call("saveToAlbum", response);
					break;
				case 'OK':
					response['caption'] = Locale.__e("flash:1382952379696");
					App.network.saveToAlbum(response);
					break;
			}
		}
		
		public static function apiInviteEvent(params:Object = null, callback:Function = null):void {
			if (!ExternalInterface.available) return;
			
			switch(App.self.flashVars.social) {
				case 'VK':
				case 'DM':
					ExternalInterface.call("showInviteBox");
					break;
				case 'FS':
					ExternalApi.apiNormalScreenEvent();
					ExternalInterface.call("showInviteBox");
					//if(callback)
						ExternalInterface.addCallback("onInviteComplete", callback);
					//ExternalInterface.addCallback("onInviteComplete");
					break;
				case 'YB':
				case 'YBD':
				case 'PL':
				case 'FB':
				case 'MX':
					ExternalApi.apiNormalScreenEvent();
					ExternalInterface.call("showInviteBox");
					//if(callback)
						ExternalInterface.addCallback("onInviteComplete", callback);
					break;
				case 'MM':
					ExternalApi.apiNormalScreenEvent();
					if(params && params.hasOwnProperty('callback'))
						ExternalInterface.call("showInviteBox", { hasCallback:true } );     
					else 
						ExternalInterface.call("showInviteBox");
					break;
				case 'SP':
					Log.alert('Internal showInviteBox');
					ExternalApi.apiNormalScreenEvent();
					ExternalInterface.call("showInviteBox");
					if(params && params.hasOwnProperty('callback'))
						ExternalInterface.addCallback("onInviteComplete", params.callback);
					break;
				case 'YN':
					ExternalApi.apiNormalScreenEvent();
					App.network.invite();
					break;
				case 'NK':
					ExternalApi.apiNormalScreenEvent();
					ExternalInterface.call("showInviteBox", {inviter:App.user.id, msg:Locale.__e('flash:1408696336510')});
					if(params && params.hasOwnProperty('callback'))
						ExternalInterface.addCallback("onInviteComplete", params.callback);
					
					break;
				case 'OK':
					ExternalApi.apiNormalScreenEvent();
					App.network.showInviteBox();
					ExternalInterface.addCallback("onInviteComplete", callback);
					break;
				default:
					
					ExternalApi.apiNormalScreenEvent();
					ExternalInterface.call("showInviteBox"/*, params.msg*/);
					ExternalInterface.addCallback("onInviteComplete", onInvite);
			}
			function onInvite(...args):void {
				if (params && params.hasOwnProperty('callback'))
					params.callback();
			}
		}
		
		public static var tries:int = 0;
		public static function updateBalance(recursive:Boolean = false):void {
			
			Post.send( {
				'ctr':'stock',
				'act':'balance',
				'uID':App.user.id
			}, function(error:*, result:*, params:*):void {
				if (!error && result) {
					var same:Boolean = true;
					tries++;
					for (var sID:* in result){
						if(App.user.stock.count(sID) != result[sID]){
							App.user.stock.put(sID, result[sID]);
							if (sID == Stock.COINS) App.ui.glowing(App.ui.upPanel.coinsIcon, 0xFFFF00);
							else if (sID == Stock.FANT) App.ui.glowing(App.ui.upPanel.fantsIcon, 0xFFFF00);
							same = false;
						}
					}
					if (recursive && same && tries <= 10) {
						setTimeout(function():void {
							updateBalance(true);
						}, 3000);
					}
				}
			});	
			
		}
		
		public static function apiBalanceEvent(params:Object):void {
			
			switch(App.self.flashVars.social) {
				
				case 'PL':
					if (ExternalInterface.available){
						ExternalInterface.call("purchase", params);
					}	
					break;
				case 'FS':
					ExternalApi.apiNormalScreenEvent();
					FSApi.purchase(params);
					break;
				case 'SP':
					ExternalApi.apiNormalScreenEvent();
					SPApi.purchase(params);
					break;			
				case 'FB':
					ExternalApi.apiNormalScreenEvent();
				case 'VK':
				case 'HV':
				case 'DM':
				case 'NK':	
					if (ExternalInterface.available) {
						ExternalApi.apiNormalScreenEvent();
						ExternalInterface.addCallback("updateBalance", function(callback:Boolean = true):void {
							tries = 0;
							updateBalance(true);
							if (callback && params['callback'] != null) {
								params.callback();
							}
						});
						ExternalInterface.call("purchase", params);
					}	
					break;
					
				
				case 'OK':
				case 'YN':
					ExternalApi.apiNormalScreenEvent();
					App.network.purchase(params);
					break;
				case 'YB':
				case 'YBD':
					ExternalApi.apiNormalScreenEvent();
					YBApi.purchase(params);
					break
				case 'AI':
					ExternalApi.apiNormalScreenEvent();
					AIApi.purchase(params);
					break
				case 'MX':
				case "MM":	
					ExternalApi.apiNormalScreenEvent();
					App.network.purchase(params)
					break;
			}
		}
				
		public static function apiPromoEvent(params:Object):void {
			if (!ExternalInterface.available) return;
			
			ExternalApi.apiNormalScreenEvent();
			
			switch(App.self.flashVars.social) {
				case 'NK':	
				case 'VK':
				case 'DM':	
				case 'FB':	
					if (ExternalInterface.available)
					{
						ExternalApi.apiNormalScreenEvent();
						ExternalInterface.addCallback("updateBalance", params.callback);
						ExternalInterface.call("purchase", params);
					}	
					break;
				case 'YB':
				case 'YBD':
					ExternalApi.apiNormalScreenEvent();
					YBApi.purchase(params);
					break;
				case "AI":	
					ExternalApi.apiNormalScreenEvent();
					AIApi.purchase(params);
					break;
				case 'OK':
				case "MM":
				case 'YN':
				case 'MX':				
					App.network.purchase(params);
					break;
				case 'FS':
					FSApi.purchase(params);
					break;
				case 'SP':
					Log.alert('SPPromo Passed');
					SPApi.purchase(params);
					break;
				default:
					ExternalInterface.addCallback("updateBalance", params.callback);
					ExternalInterface.call("purchase", params);
			}
		}
		
		public static function apiSetsEvent(params:Object):void {
			switch(App.social) {
				case 'VK':
				case 'DM':	
					if (ExternalInterface.available)
					{
						ExternalInterface.addCallback("updateBalance", params.callback);
						ExternalInterface.call("purchase", params);
					}	
					break;	
				case 'FB':	
				case 'NK':
			
					ExternalApi.apiNormalScreenEvent();
					if (ExternalInterface.available)
					{
						ExternalInterface.addCallback("updateBalance", params.callback);
						ExternalInterface.call("purchase", params);
					}	
					break;
				case 'OK':
						ExternalApi.apiNormalScreenEvent();
						App.network.purchase(params);
					break;
				case "MM":
						ExternalApi.apiNormalScreenEvent();
						App.network.purchase(params);
						break
				case 'YB':
				case 'YBD':
					ExternalApi.apiNormalScreenEvent();
					YBApi.purchase(params);
					break
				case 'FS':
				case 'MX':
				case 'AI':
				case 'YN':
					ExternalApi.apiNormalScreenEvent();
					App.network.purchase(params);
				break;
				
					
					
			}
		}
		
		public static function onImagePostComplete(data:*, object:Object, callback:Function):void {
			var hasCallback:Boolean = false;
			var response:Object = JSON.parse(data);
			if (callback != null) {
				hasCallback = true;
				addPostCallback(callback);
				object['hasCallback'] = hasCallback;
			}
			ExternalInterface.call("wallPost", object, response);	
		}
		
		
		public static function apiWallPostEvent(type:uint, bitmap:Bitmap, owner_id:String, message:String, sID:uint = 0, callback:Function = null, settings:Object = null):void {
			Log.alert('apiWallPostEvent try');
			if (!ExternalInterface.available) return;
			
			var pngStream:ByteArray = PNGEncoder.encode(bitmap.bitmapData);
			var hasCallback:Boolean = false;
			

			if (App.self.stage.displayState != StageDisplayState.NORMAL&&(App.self.flashVars.social!='OK')) {
				needBackAtFullScreen = true;
			}
			Log.alert('BITMAP SIZE: ' + pngStream.length.toString() + ' ' + bitmap.width + ' ' + bitmap.height);
			switch(App.self.flashVars.social) {
				case 'VK':
					
						{	
							ExternalApi.apiNormalScreenEvent();
							
							var ldr:MultipartURLLoader = new MultipartURLLoader();
							ldr.addEventListener(Event.COMPLETE, function(e:Event):void 
							{
								Log.alert(e.currentTarget.loader);
								var response:Object = JSON.parse(e.currentTarget.loader.data);
								if (ExternalInterface.available)
								{
									if (callback != null) 
									{
										hasCallback = true;
										addPostCallback(callback);
									}
									
									Cc.error('RESPONSEEEEEEEEE' + JSON.stringify(response));
									ExternalInterface.call("wallPost", {owner_id:owner_id, message:message, hasCallback:hasCallback}, response);	
								}
							});
							
							Log.alert('url '+JSON.stringify(App.network));
							Log.alert('pngStream '+JSON.stringify(App.network.wallServer));
							Log.alert('ExternalInterface 2 '+JSON.stringify(App.network.wallServer.upload_url));
					
															
							ldr.addVariable('url', App.network.wallServer.upload_url);
							ldr.addFile(pngStream, "image.png", "file", 'image/png');
							
							Cc.error('RESPONSEEEEEEEEE' + JSON.stringify(ldr));
							ldr.load('https://dp-vk1.islandsville.com/iframe/upload.php');
							
						}
					break;
				case 'FS':
					ExternalApi.apiNormalScreenEvent();
					if (callback != null){
						hasCallback = true;
						addPostCallback(callback);
					}
					FSApi.wallPost({type:type,owner_id:owner_id,msg:message,hasCallback:hasCallback,sID:sID});
					
					break;	
				case 'PL':
					if (callback != null) {
						hasCallback = true;
						addPostCallback(callback);
					}
					PLApi.wallPost({type:type,owner_id:owner_id,msg:message,hasCallback:hasCallback,sID:sID});
					ExternalApi.apiNormalScreenEvent();
					break;
				
				case 'YB':
				case 'YBD':
					if (callback != null) {
						hasCallback = true;
						addPostCallback(callback);
					}
					YBApi.wallPost({type:type,owner_id:owner_id,msg:message,hasCallback:hasCallback,sID:sID});
					ExternalApi.apiNormalScreenEvent();
					break;
				case 'HV':
					HVApi.wallPost( {
						type:type,
						owner_id:owner_id,
						title:Locale.__e('flash:1382952379704'),
						msg:message,
						sID:sID
					});
					if (callback != null) {
						hasCallback = true;
						addPostCallback(callback);
					}
					break;	
				case 'MM':
					if (callback != null) {
						hasCallback = true;
						addPostCallback(callback);
						Log.alert('addPostCallback ' + callback);
					}
					Log.alert('addPostCallback null -');
					ExternalApi.apiNormalScreenEvent();
					App.network.wallPost( {
						type:type,
						owner_id:owner_id,
						bytes:pngStream,
						msg:message,
						hasCallback:hasCallback,
						sID:sID
					});
					break;
				case 'MX':
					if (callback != null) {
						Log.alert('hasCallback MX')
						hasCallback = true;
						addPostCallback(callback);
					}
					MXApi.wallPost({type:type,owner_id:owner_id,msg:message,hasCallback:hasCallback,sID:sID});
					ExternalApi.apiNormalScreenEvent();
					break;
			
				case 'NK':
					ExternalApi.apiNormalScreenEvent();
					if (callback != null) {
						hasCallback = true;
						addPostCallback(callback);
					}
					NKApi.wallPost( {
						type:type,
						owner_id:owner_id,
						bytes:pngStream,
						msg:message,
						sID:sID,
						callback:callback,
						url:settings.url
					});
					break;
					
				case 'OK':
					
					if (callback != null) {
						hasCallback = true;
						addPostCallback(callback);
					}
					Log.alert('OK_OK4')
					App.network.wallPost( {
						type:type,
						owner_id:owner_id,
						bytes:pngStream,
						msg:message,
						sID:sID,
						callback:postCallback,
						url:settings.url
					});
					break;
				
				case 'FB':
					if (callback != null) {
						hasCallback = true;
						addPostCallback(callback);
					}
					ExternalApi.apiNormalScreenEvent();
					App.network.wallPost( {
						type:type,
						owner_id:owner_id,
						bytes:pngStream,
						msg:message,
						hasCallback:hasCallback,
						sID:sID
					});
					break;
			}
		}
		
		
		public static function apiAppRequest(to:Array, message:String, callback:Function = null):void {
			switch(App.self.flashVars.social) {
				case 'FB':
					ExternalApi.apiNormalScreenEvent();
					if (ExternalInterface.available){
						ExternalInterface.call("appRequest", to.splice(0,25).join(","), message, callback);
					}
					break;
			}
		}
		
		public static function addPostCallback(callback:Function):void {
			postCallback = function(response:*):void {
				Post.addToArchive('\n in postCallback:' + JSON.stringify(response));
				callback(response);
				postCallback = null;
				askOpenFullscreen();
			}
			
			Post.addToArchive('\n addPostCallback:');
			ExternalInterface.addCallback("onWallPostComplete", postCallback);
		}
		
		public static function og(act:String, obj:String):void {
			//trace(act +"  "+obj);
			if (ExternalInterface.available){
				ExternalInterface.call("og", act, obj);
			}
		}
		
		public static function onWallPostComplete(response:*):void {
			Cc.log('\n onWallPostComplete: ' + JSON.stringify(response));
		}
		
		public static function askOpenFullscreen():void {
			if (App.user.quests.tutorial && App.user.level < 5) return;
			
			if (!needBackAtFullScreen) return;
			needBackAtFullScreen = false;
			
			new SimpleWindow( {
				title:		Locale.__e('flash:1416219745731'),
				text:		Locale.__e('flash:1416219764268'),
				dialog:		true,
				confirm:	function():void {
					App.self.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				},
				cancel:		function():void {
					//
				}
			}).show();
		}
		
		public static var needBackAtFullScreen:Boolean = false;
		public static function apiNormalScreenEvent():void {
			//Log.alert('apiNormalScreenEvent')
			if (ExternalInterface.available) {
				//Log.alert('apiNormalScreenEvent1 '+App.self.flashVars.social)
				switch(App.self.flashVars.social) {
					case 'VK':
					case 'DM':
						App.self.stage.displayState = StageDisplayState.NORMAL;
						//Log.alert('apiNormalScreenEvent2')
						
							ExternalInterface.addCallback("gotoNormalScreen", function():void {
								App.self.stage.displayState = StageDisplayState.NORMAL;
								//App.map.center();
								//Log.alert('gotoNormalScreen')
							});
						
						break;
					case 'FS':		
					case 'NK':		
					case 'SP':	
					case 'PL':
					case 'FB':
						ExternalInterface.call("gotoNormalScreen");
					case 'OK':
					case 'MM':
					case 'MX':
					case 'YB':
					case 'YBD':
					case 'YN':
					case 'AI':
						App.self.stage.displayState = StageDisplayState.NORMAL;
						break;
				}
			}
		}
		
		public static function gotoScreen():void {
			if (ExternalInterface.available){
				
				switch(App.social) {
					case 'VK':
					case 'DM':	
					case 'PL':
					case 'FB':
					case 'SP':
					case 'FS':
						if(App.self.stage.displayState != StageDisplayState.NORMAL){
							ExternalInterface.call("gotoFullScreen");
						}else {
							ExternalInterface.call("gotoNormalScreen");
						}
					case 'OK':
					case 'MM':
						break;
				}
			}
		}
		
		public static function _6epush(params:Array):void {
			return;
			if (ExternalInterface.available){
				ExternalInterface.call("_6epush", params);
			}
		}
		
		public static function _6push(params:Array):void {
			return;
			if (ExternalInterface.available){
				ExternalInterface.call("_6push", params);
			}
		}
		
		public static function getLeads():void {
			if (ExternalInterface.available){
				ExternalInterface.call("getLeads");
				ExternalInterface.addCallback("onGetLeads", function(show:*):void {
					
				});
			}
		}
		
		public static function openLeads():void {
			if (ExternalInterface.available){
				ExternalInterface.call("openLeads");
			}
		}
		
		public static function getUsersProfile(IDs:Array, callback:Function):void {
			if (ExternalInterface.available){
				var response:Object = { };
				
				
				
				for each(var id:String in IDs){
					response[id] = 0;
				//	Log.alert('onGetProfile_' + String(id));
					var callabck:String = 'onGetProfile_' + id;
					ExternalInterface.addCallback(callabck, function(profile:*):void {
				//	Log.alert('profile');
				//	Log.alert(profile);
						if (profile is String) {
							delete response[profile];
							return;
						}
					//	Log.alert('profile._id')
					//	Log.alert(profile._id)
						response[profile._id] = profile;
						var full:Boolean = true;
						
						for each(var item:* in response) {
						//	Log.alert('response');
							
						//	Log.alert(response);
							
							if (item == 0) {
							//	Log.alert('item');
								//Log.alert(item);
								full = false;
								break;
							}
						}
						if (App.isSocial('AI')) 
						{
							full = true;
							for (var ant:* in response){
						//	Log.alert('response[ant]')
						//	Log.alert(response[ant])
						//	Log.alert('ant')
						//	Log.alert(ant) 
							if (ant == 0) {
							//	Log.alert('item');
								//Log.alert(item);
								full = false;
								break;
							}
							}
						}
						if (full == true) {
							callback(response);
						}
					});
					
					ExternalInterface.call("getPerson", id, callabck);
				}
			}else {
				response = { };
				response[0] = {
					first_name:"fantasy1",
					last_name:"",
					photo: Config.secure + "dreams.islandsville.com/resources/icons/avatars/ava_bear50.jpg",
					_id:"132771"
				};
				response[1] = {
					first_name:"fantasy2",
					last_name:"",
					photo: Config.secure + "dreams.islandsville.com/resources/icons/avatars/ava_bear50.jpg",
					_id:"132772"
				};
				response[2] = {
					first_name:"rooms3",
					last_name:"",
					photo: Config.secure + "dreams.islandsville.com/resources/icons/avatars/ava_bear50.jpg",
					_id:"134471"
				};
				response[3] = {
					first_name:"jjjj",
					last_name:"",
					photo: Config.secure + "dreams.islandsville.com/resources/icons/avatars/ava_bear50.jpg",
					_id:"134472"
				};
				callback(response);
			}
		}
	
		public static function onReedem(e:MouseEvent):void {
			if (ExternalInterface.available){
				ExternalInterface.call("renderGC");
				ExternalInterface.addCallback("onRedeem", function(count:int):void {
					Post.send( {
						'ctr':'stock',
						'act':'giftcard',
						'uID':App.user.id,
						'count':count
					}, function(error:*, result:*, params:*):void {
						if (!error) {
							App.user.stock.add(Stock.FANT, count);
						}
					});
				});
			}			
		}
		
		
		public static var visibleTrialpay:Boolean = false;
		public static function showTrialpay():void {
			if (ExternalInterface.available){
				Post.send( {
					'ctr':'trialpay',
					'act':'visible',
					'uID':App.user.id
				}, function(error:*, result:*, params:*):void {
					if (!error) {
						if (result['visible'] != undefined && result['visible'] == 1) {
							visibleTrialpay = true;
							if(App.ui != null && App.ui['rightPanel'] != undefined){
								App.ui.rightPanel.addFreebie();
							}
							ExternalInterface.call("showTrialpay");
						}
					}
				});
			}		
		}
		
		private static var _prevAllowSounds:Boolean = false;
		public static function pauseGame():void {
			apiNormalScreenEvent();
			
			_prevAllowSounds = SoundsManager.instance.allowSounds;
			SoundsManager._instance.setMusic(false);
			App.self.stage.frameRate = 0;
		}
		
		public static function resumeGame():void {
			App.self.stage.frameRate = 30;
			if (_prevAllowSounds){
				SoundsManager._instance.setMusic(true);
			}
		}
		
		
	}
	
	
}
