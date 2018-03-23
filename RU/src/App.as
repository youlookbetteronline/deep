package
{
	import api.AIApi;
	import api.AMApi;
	import api.ExternalApi;
	import api.FBApi;
	import api.MXApi;
	import api.MailApi;
	import api.OKApi;
	import api.VKApi;
	import api.flashVarsGenerator;
	import atm.Troops;
	import com.demonsters.debugger.MonsterDebugger;
	import com.jac.mouse.MouseWheelEnabler;
	import com.junkbyte.console.Cc;
	import com.sociodox.theminer.TheMiner;
	import core.CookieManager;
	import core.IsoConvert;
	import core.Lang;
	import core.Load;
	import core.Log;
	import core.Post;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.Capabilities;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.system.SecurityDomain;
	import flash.system.System;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import hlp.ConsoleCommands;
	import strings.Strings;
	import ui.Blocker;
	import ui.ChatField;
	import ui.ContextMenu;
	import ui.Cursor;
	import ui.HelpPanel;
	import ui.SunRay;
	import ui.Tips;
	import ui.UnitIcon;
	import ui.UserInterface;
	import ui.WishList;
	import units.Animal;
	import units.Box;
	import units.Bubbles;
	import units.Decor;
	import units.Lantern;
	import units.Monster;
	import units.Pigeon;
	import units.Techno;
	import units.Unit;
	import units.WaitPlate;
	import utils.BonusHelper;
	import utils.ErrorManager;
	import utils.InviteHelper;
	import utils.LocaleHelper;
	import utils.MapPresets;
	import utils.ObjectsContent;
	import utils.Saver;
	import utils.TopHelper;
	import utils.UnitsHelper;
	import wins.AskWindow;
	import wins.BanksWindow;
	import wins.BigsaleWindow;
	import wins.BonusBankWindow;
	import wins.BonusLackWindow;
	import wins.BonusVisitingWindow;
	import wins.BubbleActionWindow;
	import wins.BubbleInputWindow;
	import wins.BubbleSimpleWindow;
	import wins.DailyFriendsWindow;
	import wins.DayliBonusWindow;
	import wins.FreeGiftsWindow;
	import wins.InformerWindow;
	import wins.ItemsWindow;
	import wins.JoinGroupWindow;
	import wins.LevelUpWindow;
	import wins.ReferalRewardWindow;
	import wins.SalesWindow;
	import wins.SimpleWindow;
	import wins.TopResultWindow;
	import wins.TravelWindow;
	import wins.Window;
	import wins._6WBonusWindow;
	import wins.ggame.GGameWindow;
	//import starling.core.Starling;
	[SWF ( width = "900", height = "700", allowsFullScreen = true, backgroundColor = '#042238') ]
	
	public class App extends Sprite 
	{
		public static var _data:Object;
		public static var user:User;
		public static var owner:Owner;
		public static var map:Map;
		public static var ui:UserInterface;
		public static var wl:WishList = new WishList();
		public static var console:Console;
		public static var network:*;
		public static var invites:Invites;
		public static var _fontScale:Number = 1;
		private static var _social:String;
		public static var ref:String = "";
		public static var ref_link:String = "";
		
		public static var blink:String = "";
		public static var oneoff:String = "";
		public static var mail:String = "";
		
		public static var tips:Tips;
		
		public static var time:int = new Date().time / 1000;
		public static var slackTime:int = 0;
		public static var serverTime:int = time;
		public static var midnight:int = 0; 
		public static var nextMidnight:int = 0;
		
		public var windowContainer:Sprite;
		public var contextContainer:Sprite;
		public var tipsContainer:Sprite;
		public var faderContainer:Sprite;
		
		static public var reserveFont:Font;	
		public static var defaultFont:Font;	
		
		public var complete:Boolean = false;
		
		public var mapCompleted:Boolean = false;
		public var introCompleted:Boolean = false;
		
		public var deltaX:int 		= 0;
		public var deltaY:int 		= 0;
		public var moveCounter:int 	= 0;
		
		public var fakeMode:Boolean = false;
		public var constructMode:Boolean = false;
		
		public var flashVars:Object;
		public var frameCallbacks:Vector.<Function> = new Vector.<Function>();
		public var timerCallbacks:Vector.<Function> = new Vector.<Function>();
		
		public var touched:Vector.<*> = new Vector.<*>();
		
		private var prevTime:Number;
		private var fader:Sprite;
		public var fps:Number;
		
		public var timer:Timer;
		private var _timer:Timer = new Timer(60);
		
		public var preloader:* = null;
		public var changeLoader:Function = null;
		public var hideLoader:Function = null;
		
		public var intro:* = null;
		
		public static var self:App;
		private var old_seconds:uint = 0;
		//private var starlingEntity:Starling;
		
		
		Security.allowDomain("*");
        Security.allowInsecureDomain("*");
		
		[Embed(source="fonts/BRUSH-N.TTF_18_12.TTF",  fontName = "font",  mimeType = "application/x-font-truetype", fontWeight="normal", fontStyle="normal", advancedAntiAliasing="true", embedAsCFF="false")]
		//[Embed(source="fonts/meiryob.ttc",  fontName = "font",  mimeType = "application/x-font-truetype", fontWeight="normal", fontStyle="normal", advancedAntiAliasing="true", embedAsCFF="false")]
		private static var font:Class;
		
		[Embed(source = "fonts/arial.ttf", fontName = "arial",  mimeType = "application/x-font-truetype", fontWeight = "normal", fontStyle = "normal", advancedAntiAliasing = "true", embedAsCFF = "false")]
		public static var arial:Class;
		
		public static const VERSION:String = '13.01.1';
		
		/* 	
		 * Oleg  		{DM: 29060311, FB: 973881489414432}
		 * Tonya     		{DM: 83730403, FB: 830321993812336}
		 * Katya QA			{DM: 473082136, VK: 473082136, OK: 591572354588, MM: 4809123519620259436, FS: 93523010, FB: 109458176544397}
		 * Якита     		{DM: 145579072, FB:640899449454407}
		 * Sasha     		{DM: 437526134, FB:1850121798639095}
		 * Nypko Nyp		{VK: 217827748}
		 * Carinachca		{VK: 413309776}
		 * Гномер    		{DM: 96391814, FB:1201908849877177
							 SP: 288515432894543642,		AM:7537684}
		*/

		public static const ID:* = '29060311';//'30035157';// '774242479407105';
		public static const SERVER:* = 'DM';
		public static const SOCIAL:* = 'DM';	
		public static var lang:String = 'ru'; //de en es fr it nl pl pt tr ru
		
		public static function get data():Object
		{
			return _data;
		}
		public static function set data(_value:Object):void
		{
			//trace('data seted');
			_data = _value;
		}
		public function App():void 
		{
			if (self)
			{
				throw new Error("Вы не можете создавать экземпляры класса при помощи конструктора. Для доступа к экземпляру используйте Singleton.instance.")
			}else{
				self = this;
			}
			
			Security.allowDomain("*");
            Security.allowInsecureDomain("*");
			reserveFont = new arial();
			
			Cc.config.style.channelsColor = 0xFFFFFF;
			Cc.startOnStage(this, '`1q');
			Cc.commandLine = true;			
			Cc.config.commandLineAllowed = true;
			Cc.width = 700;
			Cc.height = 600;
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);	
		}
		
		/**
		 * Инициализация приложения
		 * @param	e	событие
		 */
		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			//this.initUncaughtErrorEvents();
			tips = new Tips();
			
			stage.scaleMode 	= StageScaleMode.NO_SCALE;
			stage.align 		= StageAlign.TOP_LEFT;
			
			
			if (stage.loaderInfo.parameters.hasOwnProperty('viewer_id'))
				flashVars = stage.loaderInfo.parameters;
			else if (stage.loaderInfo.parameters.hasOwnProperty('logged_user_id')){
				flashVars = stage.loaderInfo.parameters;
				flashVars['viewer_id'] = flashVars['logged_user_id'];
			}else
				flashVars = flashVarsGenerator.take(App.ID.toString());
				
			Log.alert('flashVars');
			Log.alert(flashVars);
			Cc.log('____________flashVars_______________')
			Cc.log(flashVars)
			
			this.addEventListener(AppEvent.ON_GAME_COMPLETE, onGameComplete);
			this.addEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			
			MouseWheelEnabler.init(stage);
			
			//Грузим окна в кеш
			for (var param:* in flashVars) {
				Cc.log(param + ":		" + flashVars[param]);
			}
			
			if (flashVars.hasOwnProperty('secure'))
				Config.setSecure(flashVars.secure+"//");
			
			if (flashVars.hasOwnProperty('ref'))
				App.ref = flashVars.ref;
			
			if (flashVars.hasOwnProperty('blink'))
				App.blink = flashVars['blink'];
			
			if (flashVars.hasOwnProperty('mail'))
				App.mail = flashVars['mail'];	
			
			if (flashVars.hasOwnProperty('versionInterface'))
				Config.versionInterface = flashVars['versionInterface'];	
			
			if (flashVars.hasOwnProperty('versionImages'))
				Config.versionImages = flashVars['versionImages'];	
			
			if (flashVars.hasOwnProperty('versionObjects'))
				Config.versionObjects = flashVars['versionObjects'];	
			
			//if (flashVars.hasOwnProperty('oneoff'))
				//App.oneoff = flashVars['oneoff'];
			
			if (flashVars.hasOwnProperty('testMode')) {
				Config.testMode = flashVars.testMode;
				Config.resServer = flashVars['viewer_id'] % 2;
			}
			
			console = new Console();
			
			Config.setServersIP(stage.loaderInfo.parameters);
			Log.alert('Узнали IP');
			Log.alert(flashVars);
			
			contextContainer = new Sprite();
			windowContainer = new Sprite();
			tipsContainer = new Sprite();
			faderContainer = new Sprite();
			
			contextContainer.name = "context";
			
			addChild(contextContainer);
			addChild(windowContainer);
			addChild(tipsContainer);
			addChild(faderContainer);
			
			
			fader = new Sprite();
				
			fader.graphics.beginFill(0x042238);
			fader.graphics.drawRect(0, 0, App.self.stage.stageWidth, App.self.stage.stageHeight);
			fader.graphics.endFill();
			
			faderContainer.addChild(fader);
			
			
			if (flashVars.hasOwnProperty('lang'))
				lang = flashVars.lang;
				
			
			if (Capabilities.playerType == 'StandAlone') {
				if (!font)  return;
				Font.registerFont(font);
				//loadLang();
				
				flashVars['connection'] = 'vk1.islandsville.com';
			}/*else { 
				if (!flashVars['font'])
					flashVars['font'] = 'font';
				
				if (flashVars.hasOwnProperty('font')) {
					//loadLang();
					loadFont(Config.getSwf('Font',flashVars['font']));
				}
			}*/
			
			this.addEventListener(AppEvent.ON_USERDATA_COMPLETE, checkLoadComplete);
			
			if (flashVars['social']) {
				connectToNetwork(flashVars.social);
			}else{
				connectToNetwork('FB');
			}
			
			//создать объект для связи со слоем Starling
			//starlingEntity = new Starling(StarlingLink, stage, new Rectangle(0, 0, 1280, 1024));
			//starlingEntity.start();
			ConsoleCommands.enableSlashCommands();
			
			Lang.loadLanguage(lang, function():void {
				Log.alert('DEEP: Locale complete!');
				checkLoadComplete();
			} );
			Load.loadText(Config.getData(), function(text:String):void {
				Log.alert('DEEP: Data complete!');
				data = JSON.parse(text);
				checkLoadComplete();
			}, true );
			Load.loading(Config.getInterface('windows2'), function(data:*):void {
				Log.alert('DEEP: Windows complete!');
				Window.textures = data;
				checkLoadComplete();
			}, 0, false, 
			function(progress:Number):void {
				if (changeLoader != null) changeLoader('wins', progress);
			});
			Load.loading(Config.getInterface('panels2'), function(data:*):void {
				Log.alert('DEEP: Panels complete!');
				UserInterface.textures = data;
				checkLoadComplete();
			}, 0, false/*,  function(progress:Number):void {
				if (changeLoader != null) changeLoader('ui', progress);
			} */ );
			
			//addChild(new TheMiner());
			//MonsterDebugger.initialize(this);
		}
		
		/*private function initUncaughtErrorEvents() : void
		{
			this.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR,this.onUncaughtError);
			loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR,this.onUncaughtError);
			stage.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR,this.onUncaughtError);
			stage.loaderInfo.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR,this.onUncaughtError);
			stage.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR,this.onUncaughtError);
		}
		  
		private function onUncaughtError(param1:UncaughtErrorEvent) : void
		{
			ErrorManager.onUncaughtError(param1);
		}*/
		
		/*public function resizeStarling():void
		{
			StarlingLink.self.reAddMapTile();
			StarlingLink.self.mapTile.resize();
		}
		
		public function get sEntity():Starling
		{
			return starlingEntity;
		}*/

		private function loadFont(url:String):void 
		{  
			var context:LoaderContext;
			if (!ExternalInterface.available){
				context = new LoaderContext(true);
			}else{
				context = new LoaderContext( true, new ApplicationDomain( ApplicationDomain.currentDomain ), SecurityDomain.currentDomain );
			}
			
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onFontLoad);  
			loader.load(new URLRequest(url), context);
        }
		
        public function onFontLoad(event:Event):void {
			var FontLibrary:Class = event.target.applicationDomain.getDefinition('AppFont') as Class;
			
			font = FontLibrary['font'];
            Font.registerFont(font);
			defaultFont = new font();
		}
		
		public function rewriteDescriptions():void 
		{
			//var counter:int = 0;
			for each(var item:* in data.storage)
			{
				if (item.hasOwnProperty('usedefdescr') && item.usedefdescr)
					continue;
				if (item.type == 'Golden' || item.type == 'Walkgolden' || item.type == 'Tribute')
				{
					LocaleHelper.rewriteGoldenDescription(item);
				}
			}
		}
		public function checkLoadComplete(... args):void 
		{
			if (!App.data || !Lang.DICTIONARY || !UserInterface.textures || !Window.textures || !user || !user.data) return;
			
			this.removeEventListener(AppEvent.ON_USERDATA_COMPLETE, checkLoadComplete);
			
			user.onLoad(0, user.data, null);
			
			//Triggers.send(Triggers.LOAD_GAME);
			
			// Banlist
			if (App.data.banlist != null && App.data.banlist[flashVars['viewer_id']] != undefined && App.data.banlist[flashVars['viewer_id']].inban) {
				fader.visible = false;
				new SimpleWindow( {
					title: Locale.__e('flash:1488209351781'),
					label:	SimpleWindow.ATTENTION,
					text:	Locale.__e('flash:1382952379712', [App.data.banlist[flashVars['viewer_id']].message]),
					popup:	true
				}).show();
				
				if (hideLoader != null)
					hideLoader();
				
				return;
			}
			
			dispatchEvent(new AppEvent(AppEvent.ON_GAME_COMPLETE));
		}
		
		private function translateGameData(data:*):void {
			for (var id:* in data) {
				var val:* = data[id];
				if (typeof val == 'object') {
					translateGameData(val);
				}else if(typeof val == 'string'){
					if (val.indexOf(':') != -1) {
						data[id] = Locale.__e(val);
					}
				}
			}
		}
		
		/**
		 * Событие завершения загрузки данных об игре
		 * @param	data	данные игры
		 */
		public var friendsPermission:Boolean	= true;
		public var sharePermission:Boolean		= true;
		private function onGameLoad():void 
		{
			var hasUserFriends:Boolean = false;
			if (App.social == "FB" && stage.loaderInfo.parameters.hasOwnProperty('perms')) {
				var perms:Object = JSON.parse(stage.loaderInfo.parameters.perms);
				for each (var perm:Object in perms) {
					if (perm.permission == "user_friends") {
						if (perm.status == 'declined')
							friendsPermission = false;  // <-- Нет разрешения на друзей
							
						hasUserFriends = true;
						break;
					}
					
					if (perm.permission == "publish_actions") {
						if (perm.status == 'declined')
							sharePermission = false;  // <-- Нет разрешенияна на доступ к странице! 
					}
				}
			}
			if (!hasUserFriends)
				friendsPermission = false;
			
			UnitsHelper.loadTexture();
			//Console.addLoadProgress('storage загружен');
			//data = JSON.parse(_data);
			//social = flashVars['social'];
			translateGameData(data);
			
			rewriteDescriptions();
			
			//Формируем коллекции
			for(var sID:* in data.storage){
				var item:Object = data.storage[sID];
				if (item.type == 'Collection'){
					for (var itm:* in item.reward)
					{
						if (App.data.storage[itm].mtype != 3)
							ObjectsContent.creward.push(itm);
					}
					item['materials'] = [];	
					for(var mID:* in data.storage){
						var material:Object = data.storage[mID];
						if (material.collection == sID) {
							item.materials.push(mID);
						}
					}
				}
				
				
				if (item.type == 'Lands') {
					if (User.inUpdate(sID))
						World.worlds.push(sID);
				}
			}
			
			//Деньги берем конкретно для сети
			data.money = data.money[social] || {};
			
			//removeNotInUpdates()
			
			/*if (App.lang == 'jp') {
				_fontScale = 0.7;
				tips.init();
			}*/
			
			//Включаем таймер
			timer = new Timer(1000);
			timer.start();
			timer.addEventListener(TimerEvent.TIMER, onTimerEvent);
			
			checkUpdates();
			checkCraftingExclude();
		}
		
		/*private function removeNotInUpdates():void 
		{
			for (var bulk:* in App.data.bulkset) {
				var inUpdate:Boolean = true;
				for (var itm:* in App.data.bulkset[bulk].items) 
				{
					if (!User.inUpdate(itm)) 
					{
						inUpdate = false;
					}
				}
				if (!inUpdate) 
				{
					delete(App.data.bulkset[bulk]);
				}	
			}
			
		}*/
		
		private function checkCraftingExclude():void {
			for(var sID:* in data.crafting) {
				var item:Object = data.crafting[sID];
				if (item.hasOwnProperty('exclude') && (item.exclude is Array) && item.exclude.indexOf(social) != -1)
					delete data.crafting[sID];
				
			}
		}
		
		private function connectToNetwork(type:String):void {
			
			if (!ExternalInterface.available) {
				
				onNetworkComplete({
					profile:flashVars.profile,
					appFriends:flashVars.appFriends,
					wallServer:flashVars.wallServer,
					otherFriends:flashVars.otherFriends
				});
				
				if (App.social == 'FB') {
					App.network['currency'] = {
						'usd_exchange_inverse': 1,
						'user_currency': 'RUR'
					}
				}
				
				return;
			}
			
			Log.alert('STARTING NETWOTK');
			
			ExternalInterface.addCallback("updateBalance", function():void {
				ExternalApi.tries = 0;
				ExternalApi.updateBalance(true);
			});
			ExternalInterface.addCallback("openBank", function():void {
				if (App.user.quests.tutorial) return;
				if (!Window.hasType(BanksWindow))
					new BanksWindow().show();
			});
			ExternalInterface.addCallback("openGifts", function():void {
				if (App.user.quests.tutorial) return;
				if (!Window.hasType(FreeGiftsWindow))
					new FreeGiftsWindow().show();
			});
			
			switch(type) {
				case 'AI':
					
					ExternalInterface.addCallback('openPayments', Payments.getHistory);
					network = new AIApi(flashVars);
					break;
				case 'MX':
				case 'MXD':
					
					ExternalInterface.addCallback('openPayments', Payments.getHistory);
					network = new MXApi(flashVars);
					
					break;
				case 'SP':
				case 'FS':
				case 'HV':
				case 'NK':
				case 'YBD':
				case 'YB':
				case 'PL':
				case 'YB':
				case 'NN':
					
					ExternalInterface.addCallback("initNetwork", onNetworkComplete);
					ExternalInterface.call("initNetwork");
					
					ExternalInterface.addCallback("showInviteBox", function(e:*):void {
						showInviteCallback({data:e.users.toString()});	
					});
					ExternalInterface.addCallback("pauseGame", ExternalApi.pauseGame);
					ExternalInterface.addCallback("resumeGame", ExternalApi.resumeGame);
					ExternalInterface.addCallback('openPayments', Payments.getHistory);
					
					break;
					
				case 'AM':
					network = new AMApi(flashVars);
					ExternalInterface.addCallback("openAskWindow", function():void {
						if (!Window.hasType(AskWindow)){
							InviteHelper.inviteOther();
						}
					});
					break;
				case 'VK':
				case 'DM':
					
					ExternalInterface.addCallback("openAskWindow", function():void {
						if (!Window.hasType(AskWindow)){
							InviteHelper.inviteOther();
						}
							/*new AskWindow(AskWindow.MODE_NOTIFY_2, { 
								title:Locale.__e('flash:1407159672690'), 
								inviteTxt:Locale.__e("flash:1407159700409"), 
								desc:Locale.__e("flash:1430126122137"),
								itemsMode:5
								},  function(uid:String):void {
									sendPost(uid);
									Log.alert('uid '+uid);
							}).show();*/
					});
					ExternalInterface.addCallback("initNetwork", function(data:Object):void {
						new VKApi(App.self.flashVars, data, onNetworkComplete);
					});
					
					ExternalInterface.call("initNetwork");
					
					break;
				case 'OK': 
						Console.addLoadProgress('OK: logged_user_id = ' + flashVars['logged_user_id']);
						
						if(flashVars['logged_user_id'] != undefined){
							network = new OKApi(flashVars);
							ExternalInterface.addCallback("showInviteBox", function():void {
								network.showInviteBox();
							});
						}					
					break;
				case 'MM':
					
					network = new MailApi(flashVars);
					ExternalInterface.addCallback("showInviteBox", function(e:*):void {
						if (e.data == null && e.data == 'null' && e.status !='closed') {
							//Log.alert('Not ready '+e);
						}else {
							showInviteCallback({data:(e.data.toString())});	
						}
					});
					
					break;
				case 'FB': 
					ExternalInterface.addCallback("openInbox", function():void {
						if (App.user.quests.tutorial) return;
						new FreeGiftsWindow( {
							mode:FreeGiftsWindow.TAKE
						}).show();
					});
					
					network = new FBApi(flashVars);
					
					break;
			}
		}
		
		public function onInviteComplete(data:*):void
		{
			Log.alert('onInviteComplete');
			Log.alert(data);
			if (data.to)
			{
				var _fIDs:String = '';
				for each(var _fID:* in data.to)
				{
					_fIDs+=_fID+','
				}
				_fIDs = _fIDs.slice(0, _fIDs.length - 1);
				Log.alert('_fIDs: ' + _fIDs);
				
				Post.send( {
					ctr:'user',
					act:'setinvite',
					uID:App.user.id,
					fID:_fIDs
				},function(error:*, data:*, params:*):void {
					if (error) {
						Errors.show(error, data);
						return;
					}
				});
				
			}
			
			Log.alert('onInviteEnd');
		}
		
		/*public function showInviteCallback(e:*):void {
			Log.alert('showInviteCallback');
			Log.alert(e.data);
			Post.addToArchive('FREEBIE');
			Post.send( {
				ctr:'user',
				act:'setinvite',
				uID:App.user.id,
				fID:e.data
			},function(error:*, data:*, params:*):void {
				if (error) {
					Errors.show(error, data);
					return;
				}
			});
		}*/
		public function showInviteCallback(e:*):void {
			Log.alert('showInviteCallback');
			Log.alert(e);
			Post.addToArchive('FREEBIE');
			Post.send( {
				ctr:'user',
				act:'setinvite',
				uID:App.user.id,
				fID:e
			},function(error:*, data:*, params:*):void {
				if (error) {
					Errors.show(error, data);
					return;
				}
			});
		}
		
		public function sendPost(uid:*):void {
		var message:String = Strings.__e("FreebieWindow_sendPost", [Config.appUrl]);
		var bitmap:Bitmap = new Bitmap(Window.textures.iPlay, "auto", true);
		
		if (bitmap != null) {
			ExternalApi.apiWallPostEvent(ExternalApi.GIFT, bitmap, String(uid), message, 0, null, {url:Config.appUrl});// , App.ui.bottomPanel.removePostPreloader);
			}
		}
		
		public function sendPostWake():void {
			var message:String = Strings.__e("WakeUp_sendPost", [Config.appUrl]);
			var bitmap:Bitmap = new Bitmap(Window.textures.iPlay, "auto", true);
		
			if (bitmap != null) {
				Log.alert('ExternalApi.apiWallPostEvent +');
				ExternalApi.apiWallPostEvent(ExternalApi.PROMO, bitmap, String(App.owner.id), message, 0, onPostComplete, {url:Config.appUrl});
			}
				
		}
	
		public function onPostComplete(result:*):void {
		Log.alert('Alert +' + result);
		if (App.social == "MM" && result.status != "publishSuccess")
				return;
		
		
		switch(App.social) {
			case "VK":
			case "DM":
					if (result != null && result.hasOwnProperty('post_id')) {
					
					Post.send( {
								ctr:'friends',
								act:'alert',
								uID:App.user.id,
								fID:App.owner.id
							},function(error:*, data:*, params:*):void {
								if (error) {
									Errors.show(error, data);
									return;
								}
								App.ui.upPanel.hideWakeUpPanel();
								if (data !=null&&data.hasOwnProperty('bonus')&&data.bonus!={}) 
								{
									new BonusVisitingWindow( { bonus:data.bonus, wakeUpBonus:true } ).show();
									App.user.friends.data[App.owner.id].alert = App.time;
								}
							});
					}
				break;
			case "OK":
			case "MM":
			case "FB":
			case "NK":
					if (result != null && result != "null") {
						Post.send( {
								ctr:'friends',
								act:'alert',
								uID:App.user.id,
								fID:App.owner.id
							},function(error:*, data:*, params:*):void {
								if (error) {
									Errors.show(error, data);
									return;
								}
								App.ui.upPanel.hideWakeUpPanel();
								if (data !=null&&data.hasOwnProperty('bonus')&&data.bonus!={}) 
								{
									new BonusVisitingWindow( { bonus:data.bonus, wakeUpBonus:true } ).show();	
									App.user.friends.data[App.owner.id].alert = App.time;
								}
							});
					}
				break;
			case "FS":
			
						if (result) {
							Post.send( {
								ctr:'friends',
								act:'alert',
								uID:App.user.id,
								fID:App.owner.id
							},function(error:*, data:*, params:*):void {
								if (error) {
									Errors.show(error, data);
									return;
								}
								App.ui.upPanel.hideWakeUpPanel();
								if (data !=null&&data.hasOwnProperty('bonus')&&data.bonus!={}) 
								{
									new BonusVisitingWindow( { bonus:data.bonus, wakeUpBonus:true } ).show();	
									App.user.friends.data[App.owner.id].alert = App.time;
								}
							});
						}
				break;	
				
			
		}
	
		}
		

		public function onNetworkComplete(data:Object):void {
			Log.alert("DEEP: onNetworkComplete!");
			Log.alert(data);
			
			network = data;
			
			social = flashVars['social'];
			
			/*if (flashVars['viewer_id'] == '50545195')
				user = new User('1');
			else*/
				user = new User(flashVars['viewer_id']);
				
				
			//проверка на подмену ID в flashvars в консоли браузера
			//if (App.isSocial('FB', 'VK', 'OK', 'ML', 'FS') && ExternalInterface.available) {
				//ExternalApi.checkID(createUser)
			//} else {
				//createUser({id:flashVars['viewer_id']})
			//}	
		}
		
		public function createUser(result:Object):void
		{
			 if(result.id == flashVars['viewer_id'])
			  user = new User(flashVars['viewer_id']);
			 else
			  Log.alert('Nice try')
		}
		
		public function getLength(o:Object):uint {
			var length:uint = 0;
			for (var s:* in o)
				length++;
			
			return length;
		}
		
		public function toObject(a:Array):Object {
			var o:Object = new Object();
			for(var i:int = 0; i < a.length; i++) {
				if (a[i] != null) {
					o[i] = a[i];
				}
			}
			
			return o;
		}
		
		private function onMapComplete(e:AppEvent):void {
			this.removeEventListener(AppEvent.ON_MAP_COMPLETE, onMapComplete);
			
			checkGameStart();
			
			if (!App.user.quests.tutorial) {
				showOffers();
				InformerWindow.init();
			} else {
				App.self.addEventListener(AppEvent.ON_FINISH_TUTORIAL, showOffers);
			}
			
			for each(var item:* in App.user._6wbonus) {
				var bonus:Object = App.data.bonus[item['campaign']] || null;
				if (bonus) {
					new _6WBonusWindow( { bonus:bonus } ).show();
					if (App.social == 'FB')
						ExternalApi._6epush([ "_event", { event: "gain", item: "edm_bonus" } ]);
				}
			}
			
			//App.blink = 'b58a46ddd5ca1a';
			checkBlink();
			if (!App.user.quests.isTutorial && App.oneoff.length > 0)
				user.takeBonus();
			
			if(App.user.trialpay != null){
				for each(var trialpay:Object in App.user.trialpay){
					Load.loading(Config.getImage('promo/images', 'crystals'), function(data:*):void {
						new SimpleWindow( {
							'label':SimpleWindow.CRYSTALS,
							'title': Locale.__e('flash:1382952379735'),
							'text': Locale.__e('flash:1384418596313', [int(trialpay[3])])
						}).show();
					});
				}
			}
			
			if (App.mail.length > 0 && !App.user.quests.isTutorial) {
				if(App.user.mbonus.hasOwnProperty(App.mail) &&  App.user.mbonus[App.mail] > App.time){
					for each(bonus in App.data.bonus) {
						if (bonus.uniq && bonus.uniq == App.mail) {
							new ReferalRewardWindow( {
								title:Locale.__e('flash:1428323663397'),
								mode:'mail', 
								id:App.mail, 
								bonus:bonus.reward
							}).show();
						}
					}
				}
			}
			
		}
		
		private function checkBlink():void 
		{
			if (!App.user.quests.isTutorial && App.data.hasOwnProperty('blinks') && App.data.blinks.hasOwnProperty(App.blink)) 
			{
				var bbonus:Object = App.data.blinks[App.blink]; 
				if (bbonus.start < App.time && bbonus.start + bbonus.duration * 3600 > App.time && !App.user.blinks.hasOwnProperty(App.blink)) 
				{
					new ReferalRewardWindow( {
						title	:Locale.__e("flash:1382952379793"),
						mode	:'blink', 
						id		:App.blink, 
						bonus	:App.data.blinks[App.blink].bonus
					}).show();
				}
			}
		}	
		private function showOffers(e:AppEvent = null):void {	
			showOfferWindow();
			showBigSaleWindow();
			//showDealSpot();
		}
		
		private function showDealSpot():void {
			if(App.social == 'FB' && ExternalInterface.available){
				ExternalInterface.addCallback('setDealSpot', function(url:String):void {
					
					Load.loading(url, function(data:*):void {
						App.ui.leftPanel.createDealSpot(data);
					});
				});
				ExternalInterface.call('getDealSpot');
			}
		}
		
		private function showBigSaleWindow():void {
			var sales:Array = [];
			var sale:Object;
			for (var sID:* in App.data.bigsale) {
				sale = App.data.bigsale[sID];
				if(sale.social == App.social)
					sales.push({sID:sID, order:sale.order, sale:sale});
			}
			sales.sortOn('order');
			for each(sale in sales) {
				if (App.time > sale.sale.time && App.time < sale.sale.time + sale.sale.duration * 3600) {
					BigsaleWindow.startAction(sale.sID, sale.sale);
					break;
				}
			}
		}
		
		private function showOfferWindow():void 
		{
			App.self.removeEventListener(AppEvent.ON_FINISH_TUTORIAL, showOfferWindow);
			if ((App.data.money != null && App.data.money.enabled && App.data.money.date_to > App.time) || (App.user.money > App.time)) {
				if (App.user.quests.tutorial) return;
				
				if (!App.isSocial('SP')) {
					new BanksWindow().show();
				}
			}
		}
		
		public static var octopusPers:Decor;
		
		private function initMap():void	
		{
			map.visible = true;
			
			user.addPersonag();
			map.center();
			
			dispatchEvent(new AppEvent(AppEvent.ON_GAME_COMPLETE));
			Troops.init(); 
			Lantern.init();
			//Rabbit.init();
			SoundsManager.instance.loadSounds();
			
			if (!App.user.quests.tutorial)
			{
				BonusHelper.checkLack();
				
				if(App.user.bonus == 0 && App.user.level > 3) 
					new DayliBonusWindow().show();
				TopHelper.checkRewards();
				Pigeon.checkNews();	
				
				App.user.quests.checkFreebie();
				
				if (App.time < Events.timeOfComplete)
					setTimeout(Box.generateEventBox, 5000);
				
				//checkOnGiftsBox();
			}
			/*var octopusSID:uint = 500000;
			var info:Object = { type:'Tutorial', view:'octopus_ruins' };
			App.data.storage[octopusSID] = info;
			
			octopusPers = new Decor( { sid:octopusSID, id:1, x:100, z:100 } );*/
		}
		private function checkGameStart():void
		{
			faderContainer.removeChild(fader);
			//return;
			initMap();
			//App.user.stock.checkSystem();
			//App.self.setOnTimer(App.user.stock.checkEnergy);
			user.quests.openMessages();
			user.quests.continueTutorial();
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			if (hideLoader != null) 
			{
				hideLoader();
				Log.alert('hideLoader')
			}
		}
		
		private function onGameComplete(e:AppEvent):void 
		{
			
			removeEventListener(AppEvent.ON_GAME_COMPLETE, onGameComplete);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
			stage.addEventListener(Event.MOUSE_LEAVE, mouseLeave);
			stage.addEventListener(Event.FULLSCREEN, onFullscreen);
			stage.addEventListener(MouseEvent.MOUSE_OUT, onOutStage);
			
			stage.addEventListener(Event.RESIZE, onResize);
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			onGameLoad();
			
			ExternalApi.setCloseApiWindowCallback();
			//
			//invites = new Invites();
			//invites.init();
			//
			if (App.isJapan())
			{
				Payments.getHistory(false);
			}
			
			if (Invites.externalPermission) 
			{
				invites = new Invites();
				invites.init(function():void {});
			}
			
			
			//Загрузка карты
			map = new Map(user.worldID, user.units);
			map.visible = false;
			
			
			// Интерфейс
			ui = new UserInterface();
			addChildAt(ui, getChildIndex(windowContainer));
			App.ui.onLoad();
			
			var fishes:Bitmap = new Bitmap(Window.textures.loading);
			fishes.x = (fader.width - fishes.width) / 2
			fishes.y = (fader.height - fishes.height) / 2
			fader.addChild(fishes);
			
			var loadText:TextField = Window.drawText(Locale.__e("flash:1481102592306"), 
			{
				fontSize:44,
				color:0xf8ff3a,
				borderColor: 0x6f3904,
				multiline: true,
				wrap:true,
				textAlign:"center",
				width: fishes.width
			});
			
			loadText.x = fishes.x + (fishes.width - loadText.width) / 2
			loadText.y = fishes.y + fishes.height - loadText.textHeight - 20;
			fader.addChild(loadText);
			
			user.friends.showHelpedFriends();
			user.friends.showZzzFriends();			
			
			App.user.checkDaysleft();
			App.user.stock.checkSystem();
			App.self.setOnTimer(App.user.stock.checkEnergy);
			
			checkNews();
			Events.init();
			
			//Connection.init();
			
			//TargerMover.instance.addEvents(stage);
		}
		
		public function checkTargetGroup(_groudId:String):void
		{
			var member:Boolean = false;
			ExternalApi.checkTargetGroupMember(_groudId, function(resonse:*):void {
				Log.alert('check Target Group Member Callback: ' + JSON.stringify(resonse));
				member = true;
			});
			setTimeout(function():void {
				if (!member)
					Log.alert('Not check Target Group Member');
			}, 5000);
			
		}
		
		public function checkGroup():void
		{
			if (App.isJapan())
				return;
			//var member:Boolean = false;
			ExternalApi.checkGroupMember(function(resonse:*):void {
				Log.alert('check Group Member Callback: ' + JSON.stringify(resonse));
				//if (JSON.stringify(resonse) is Boolean)
					//member = Boolean(JSON.stringify(resonse));
				//else
					//member = Boolean(int(JSON.stringify(resonse)));
				onCheckGroupMember(int(JSON.stringify(resonse)));
			});
			//setTimeout(function():void {
				//
			//}, 5000);
		}
		
		public function onCheckGroupMember(val:int):void
		{
			if (Boolean(val) == true)
				Log.alert('You is a member!');
			else
				Log.alert('You is not a member!');
					
			if (Boolean(val) == false)
			{
				App.user.storageRead('groupInvite');
				if (int(App.user.storageRead('groupInvite')) == 0 && !App.user.quests.tutorial /*&& App.user.worldID == User.HOME_WORLD*/) 
				{
					Log.alert('not group member');
					//App.ui.bottomPanel.addCommunityButton();
					//App.ui.rightPanel.addCommunityButton();
					new JoinGroupWindow().show();
				}
			}
		}
		
		private function showBulks():void {
			for (var bulkID:* in data.bulks) {
				var bulk:Object = data.bulks[bulkID];
				if (bulk.social.hasOwnProperty(App.social)) {
					new SalesWindow( {
						action:bulk,
						pID:bulkID,
						mode:SalesWindow.BULKS,
						width:670,
						title:Locale.__e('flash:1385132402486')
					}).show();
					return;
				}
			}
		}
		
		private function mouseLeave(e:Event):void
		{
			cursorOut = true;
			moveCounter = 0;
		}
		
		private function onMouseWheel(e:MouseEvent):void 
		{
			if (App.ui && App.ui.systemPanel && !App.user.quests.tutorial && !UserInterface.over && !Window.isOpen) 
			{
				App.ui.systemPanel.onMouseWheel(e);
			}
			
			App.self.dispatchEvent(new AppEvent(AppEvent.ON_WHEEL_MOVE));
		}
		
		private function onFullscreen(e:Event):void 
		{
			setTimeout(function():void { mouseLeave(e) }, 10);
			ExternalApi.gotoScreen();
		}
		
		private function onOutStage(e:MouseEvent):void 
		{
			if (!(e.stageX > 0 && e.stageX < stage.stageWidth && e.stageY > 0 && e.stageY < stage.stageHeight)) 
			{
				mouseLeave(e);
			}
		}
		
		private var _isPaused:Boolean = false;
		public function pause():void
		{
			_isPaused = true;
		}
		
		public function resume():void
		{
			_isPaused = false;
		}
		
		/**
		 * Добавление функции обратного вызова на событие EnterFrame
		 * @param	callback	функция обратного вызова
		 */
		//public var enterFrameTargets:Object = {functions:new Vector.<Function>, targets:new Vector.<DisplayObject>};
		public var enterFrameHandlers:Vector.<Function> = new Vector.<Function>;
		public function setOnEnterFrame(callback:Function):void 
		{
			if (enterFrameHandlers.indexOf(callback) > -1) 
				return;
			enterFrameHandlers.push(callback);
			/*if (target)
			{
				enterFrameTargets.functions[enterFrameTargets.functions.length] = callback;
				enterFrameTargets.targets[enterFrameTargets.targets.length] = target;
			}*/
		}
		
		/**
		 * Удаление функции обратного вызова с события EnterFrame
		 * @param	callback	функция обратного вызова
		 */
		public function setOffEnterFrame(callback:Function):void 
		{
			if (enterFrameHandlers.indexOf(callback) == -1)
				return;
			enterFrameHandlers.splice(enterFrameHandlers.indexOf(callback), 1);
		}
		
		/*public function setOnEnterFrame(callback:Function):void 
		{
			addEventListener(Event.ENTER_FRAME, callback);
		}
		public function setOffEnterFrame(callback:Function):void 
		{
			removeEventListener(Event.ENTER_FRAME, callback);
		}*/
		
		/**
		 * Событие EnterFrame
		 * @param	e	объект события
		 */
		private function onEnterFrame(e:Event):void 
		{
			getFps(e);
			for (var i:int = enterFrameHandlers.length - 1; i > -1; i--) {
				//if (i >= enterFrameHandlers.length)
					//break;
				/*if (enterFrameTargets.functions.indexOf(enterFrameHandlers[i]) > -1 && !enterFrameTargets.targets[enterFrameTargets.functions.indexOf(enterFrameHandlers[i])])
				{
					trace('has Callback from ' + enterFrameTargets.targets[enterFrameTargets.functions.indexOf(enterFrameHandlers[i])]);
				}*/
				if (enterFrameHandlers[i] != null) {
					enterFrameHandlers[i].call(null, e);
				}else {
					enterFrameHandlers.splice(i, 1);
					i ++;
				}
			}
			if (_isPaused)
				return;
		}
		
		public function setOnTimer(callback:Function):void 
		{
			if (timerCallbacks.indexOf(callback) == -1)
				timerCallbacks.push(callback);
		}

		public function setOffTimer(callback:Function):void 
		{
			var index:int = timerCallbacks.indexOf(callback);
			
			if (index != -1)
			{
				timerCallbacks[index] = null;
			}
		}
		
		/*private function onTimerEvent(e:TimerEvent):void {
			time += 1;
			
			for (var i:int = 0; i < timerCallbacks.length; i++ ) {
				if(timerCallbacks[i] != null){
					timerCallbacks[i].call();
				}
			}
			for (i = 0; i < timerCallbacks.length; i++ ) {
				if(timerCallbacks[i] == null){
					delete timerCallbacks[i];
				}
			}
		}*/
		
		private var date:Date;
		private var date2:Date;
		private var diff:int = 0;
		private var last:int = getTimer();
		
		private function onTimerEvent(e:TimerEvent):void 
		{
			time += 1;
			slackTime ++;

			for (var i:int = 0; i < timerCallbacks.length; i++ ) 
			{
				if (timerCallbacks[i] != null)
				{
					timerCallbacks[i].call();
				}
			}
			for (i = 0; i < timerCallbacks.length; i++ ) 
			{
				if (timerCallbacks[i] == null)
				{
					delete timerCallbacks[i];
				}
			}

			// Компенсатор времени
			if (date) date2 = date;
			date = new Date();
			
			if (date && date2) 
			{
				diff += date.getTime() - date2.getTime() - 1000;
				if (diff > 1000) 
				{
					time += 1;
					diff -= 1000;
					last = getTimer();
				}
			}
		}
		override public function addChild(child:DisplayObject):DisplayObject 
		{
			trace('added');
			return super.addChild(child);
		}
		
		/**
		 * Событие перемещения мыши
		 * @param	e	объект события
		 */
		//public var isMapMove:Boolean = false;
		public var cursorOut:Boolean = false;
		public var mapMoving:Boolean = false;
		public var dontTouchMap:Boolean = false;
		private function onMouseMove(e:MouseEvent):void 
		{
			
			if (!map)
				return;
			dontTouchMap = false;
			if (ItemsWindow.isOpen)
				return;
			if (e.buttonDown == true)
				moveCounter++;
				
			if (e.buttonDown == true && moveCounter > 2 && !Window.isOpen && !cursorOut && !Animal.isMove && !Techno.isMove) 
			{
				/*if (App.user.quests.track && !(map.moved != null && map.moved is Wigwam) || Missionhouse.windowOpened) 
				{
					moveCounter = 0;
					return;
				}*/
				//resizeStarling();
				e.updateAfterEvent();
				if(user.quests.tutorial)
					QuestsRules.focusClear();
					
				mapMoving = true;
				
				var dx:int = e.stageX - deltaX;
				var dy:int = e.stageY - deltaY;
				
				deltaX = e.stageX;
				deltaY = e.stageY;
				
				map.redraw(dx, dy);
				
				tips.relocate();
				HelpPanel.hideAll();
				
			}else
			{
				var target:* = e.target;
				var _target:* = e.target;
				UserInterface.over = false;
				if (!(target is Unit || target is Monster || target is Map)) 
				{
					while (target.parent != null) 
					{
						if (target is SunRay)
						{
							break;
						}
						if (target is ChatField)
						{
							map.untouches();
							target = target.parent;
							dontTouchMap = true;
							break;
						}
						
						if (target is Blocker)
						{
							map.untouches();
							target = target.parent;
							dontTouchMap = true;
							break;
						}
						
						if (target.parent is UnitIcon)
						{
							map.untouches();
							target = target.parent;
							dontTouchMap = true;
							break;
						}
						
						if (target.parent is UserInterface || target is HelpPanel || target.parent is HelpPanel || target.parent is ContextMenu)
						{
							UserInterface.over = true;
							map.untouches();
							break;
						}
						
						target = target.parent;
					}
				}
				
				var point:Object = IsoConvert.screenToIso(map.mouseX, map.mouseY, true);
				
				Map.X = point.x>0?point.x:0;
				Map.Z = point.z>0?point.z:0;
				Map.X = Map.X < Map.cells?Map.X:Map.cells - 1;
				Map.Z = Map.Z < Map.rows?Map.Z:Map.rows - 1;
							
				target = e.target;
				
				if(App.map._aStarNodes){
					if (App.map._aStarNodes[Map.X][Map.Z].z != 0 && App.map._aStarNodes[Map.X][Map.Z].open == false && !Window.isOpen && !UserInterface.over)
					{
						/*if (target.parent && ((target.parent.parent &&(target.parent.parent is UserInterface)) || (target.parent.parent.parent &&(target.parent.parent.parent is UserInterface)) ))
						{
							Cursor.init();
						}
						else
						{*/
							//if(target is Map)
						Cursor.type = 'locked';	
						//}
						
						/*if (Window.isOpen || UserInterface.over) 
						{
							//Cursor.type = 'default';
							Cursor.init();
						}*/
						//return;
					}
					else if (Cursor.type == 'locked')
					{
						Cursor.init();
					}
				}
				
				if(!UserInterface.over && !Window.isOpen && !dontTouchMap){
					map.touches(e);
					if (map.touched && map.touched.length > 0) {
						target = map.touched[0];
					}/*else {
						if (Cursor.plant) {
							if (Field.exists == false && !App.map.moved) {
								var unit:Unit;
								unit = Unit.add( { sid:277 } );
								unit.move = true;
								App.map.moved = unit;
							}
							Cursor.plant.visible = true;
						}
					}*/
				}
				if (!map.moved) {
					if (UserInterface.over || Window.isOpen) {
						if (_target is Fog)
							return;
						tips.show(_target as DisplayObject);
					}else if ((target is Unit || target is Monster || target is WaitPlate) && target.touch ) {
						tips.show(target as DisplayObject);
					}else {
						tips.hide();
					}
				}else {
					tips.hide();
				}
			}
		}
		
		/**
		 * Событие нажатия кнопки мыши	
		 * @param	e	объект события
		 */
		public function onMouseDown(e:MouseEvent):void {
			if (!map)
				return;
			moveCounter = 0;
			slackTime = 0;
			cursorOut = false;
			deltaX = e.stageX;
			deltaY = e.stageY;
			dispatchEvent(new AppEvent(AppEvent.ON_MOUSE_DOWN));
			if (!map.touched)
				return;
			for (var i:int = 0; i < map.touched.length; i++ ) {
				if (map.touched[i] is Unit/* || map.touched[i] is Techno*/) {
					map.touched[i].onDown();
					break;
				}
			}
		}
		public var timerDecor:uint = 0;
		
		/**
		 * Событие отпускания кнопки мыши
		 * @param	e	объект события
		 */
		public function onMouseUp(e:MouseEvent):void {
			if (!map)
				return;
			//moveCounter = 0;
			cursorOut = false;
			//isMapMove = false;
			if (dontTouchMap)
				return;
				
			App.self.mapMoving = false;
			
			if (UserInterface.over) {
				//UserInterface.over = false;
				return;
			}
			
			if (Cc.visible)
				return;
			
			if (Window.isOpen || ItemsWindow.isOpen/* || Cursor.type == 'locked'*/) return;
			
			if (moveCounter < 4) {
				if (map.moved != null) {
					if (!map.moved.canInstall()){
						return;
					}
					
					map.moved.move = false;
					
					if (map.moved && !map.moved.formed && map.moved.multiple == true && Unit.lastUnit != null) {
						if (App.data.storage[Unit.lastUnit.sid].type == 'Decor') 
						{
							
							Cursor.loading = true;
							timerDecor = setTimeout(function():void {
								Cursor.loading = false;
								Unit.addMore();
							}, 1000)
							//Unit.addMore();
						}
						else
						{
							Unit.addMore();
						}
					}else {
						map.moved = null;
					}
					
				}else if (map.touched.length > 0) {
					map.touch();
				}else {
					map.click();
				}
			}
			else
			{
				SoundsManager.instance.soundReplace();
			}
			
			dispatchEvent(new AppEvent(AppEvent.ON_MOUSE_UP));
		}
		
		/**
		 * Событие нажатия кнопки клавиатуры
		 * @param	e	объект события
		 */
		public var openZone:Boolean = false;
		private function onKeyUp(e:KeyboardEvent):void 
		{
			if (!Config.admin)
				return;
			
			if (e.keyCode == Keyboard.Z && openZone)
			{
				openZone = false;
			}
		}
		private var fav:Boolean = false;
		private function onKeyDown(e:KeyboardEvent):void 
		{
			
			/*if (e.charCode == Keyboard.F2)
			{
				Cc.add(	
			}*/
			
			/*if (e.charCode == 100) 
			{
				if (e.ctrlKey) 
				{
					App.console.openDebug();
				}
			}*/
			
			if (e.keyCode == Keyboard.ENTER)
			{
				if (App.user.mode == User.PUBLIC && !ChatField.self)
				{
					ChatField.show();
				}
			}
			
			//Раскрыть на весь экран
			if (e.keyCode == Keyboard.P && e.ctrlKey) 
			{
				App.ui.systemPanel.onScreenshotEvent();
			}
			if (e.keyCode == Keyboard.F && e.ctrlKey) 
			{
				App.ui.systemPanel.onFullscreenEvent();				
			}
			
			
			if (e.keyCode == Keyboard.U && e.ctrlKey) 
			{
				if(App.ui.visible){
					App.ui.visible = false;
				}else{
					App.ui.visible = true;
				}
			}
			
			if (!Config.admin || Window.isOpen)
				return;
			
			if (e.keyCode == Keyboard.L)
			{
				//App.network.saveScreenshot();
				/*var list:Array = [];
				var listString:String = '';
				for each (var quest:* in App.data.quests)
				{
					
					if (quest.type == 1)
					{
						if (list.indexOf(quest.character) == -1)
							list.push(quest.character);
					}
				}
				
				for each(var pers:* in list)
				{
					listString+= 'ID: ' + pers + ', name: ' + App.data.personages[pers].name + ';' + '\n'
				}
				trace(listString);*/
				/*new BubbleInputWindow({
					title		:Locale.__e('flash:1517330407319'),
					maxLength	:80
				}).show();
				if (Config.admin)
					trace();*/
				/*var length:int = 0
				for each(var act:* in App.data.actions)
				{
					if (act.hasOwnProperty('price') && act.price.hasOwnProperty('SP'))
						length++
					
				}
				trace();*/
				/*var result:String = ''
				for each(var tr:* in App.data.storage)
				{
					if (tr.type == 'Tribute' && tr.hasOwnProperty('reset') && tr.reset != '' && tr.reset != '0')
					{
						result+= tr.sID + '\n'
					}
				}
				trace(result);*/
				
			}
			
			if (e.keyCode == Keyboard.L && e.ctrlKey) {
				//Treasures.convertToObject('friendalert');
				MapPresets.generateMapResources(App.map.saveMap);
				//new MinistockWindow({}).show();
				//App.map.disposeUnits();
				//App.map.dispose();
				//App.map = null;
				/*var list:String = '';
				for each(var cr:* in App.data.crafting)
				{
					if (cr.out)
					{
						if (User.getUpdate(cr.out) == '')
							list += App.data.storage[cr.out].title + ' ' + App.data.storage[cr.out].sID + '\n';
					}
				}
				trace(list);*/
				
				//Window.hasType(TravelWindow);
				//trace('upd' + ' ' + User.getUpdate(1573));
				/*var list:String = '';
				for each(var item:* in App.data.storage)
				{
					if (item.backview && item.backview != '')
						list += item.title + ' ' + item.sID + '\n';
				}
				trace(list);*/
				/*if (!fav)
				{
					App.ui.bottomPanel.friendsPanel.searchFriends("", ObjectsContent.ASKCONTENT)
					fav = true
				}
				else
				{
					App.ui.bottomPanel.friendsPanel.searchFriends("")
					fav = false
				}*/
			}
			
			if (e.keyCode == Keyboard.K)
			{
				if (!App.user.auction.windowOpened)
					App.user.auction.openAuctionWindow();
				else
				{
					App.user.auction.closeAuctionWindow();
					App.user.auction.openAuctionWindow();
				}
			}
			
			if (e.keyCode == Keyboard.M && e.ctrlKey) 
			{
				Load.clearAllCache();
				//Load.loading(Config.getSwf('Techno', 'squidassas'), function(data:*):void{
					//data;
				//});
				//trace('free: '+  System.freeMemory/ (1024*1024));
				//trace('total: ' + System.totalMemory/ (1024*1024));
				//trace('privateMemory: ' + System.privateMemory/ (1024*1024));
				//trace('current: ' + (System.totalMemory - System.freeMemory)/ (1024*1024));
			}
			
			
			if (e.keyCode == Keyboard.E && e.ctrlKey && e.altKey) 
			{
				var resStr:String = "";
				for each(var quest:* in App.data.quests)
				{
					for (var dr:* in quest.dream)
					{
						if (quest.dream[dr] != '' && App.data.storage[quest.dream[dr]].type != 'Lands' && !quest.tutorial )
						{
							resStr = resStr + quest.ID + ' '
							break;
						}
						
					}
				}
				trace(resStr);
				//new GGameWindow().show();
			}
			
			if (e.keyCode == Keyboard.S) 
			{
				if (App.map){
					App.map.sorting();
					App.map.allSorting();
				}
			}
			
			if (e.keyCode == Keyboard.D && e.ctrlKey && e.altKey) 
			{
				Post.send( {
					ctr:		'user',
					act:		'load',
					uID:		App.user.id,
					wID:		App.map.id,
					items:		JSON.stringify({1275:1}),
					f:			'1'
				}, function(error:int, data:Object, params:Object):void{
					if (error) 
						return;
					App.user.ministock.items = [];
					App.user.ministock.level = 1;
				})
			}
					
			if (e.keyCode == 109 && e.ctrlKey && e.shiftKey && e.altKey) 
			{
				if (Window.hasType(SimpleWindow))
					Window.closeAll();
				var wind:SimpleWindow = new SimpleWindow({
					title: 			'Опс! Ошибка',
					text: 			'',
					width:			380,
					hasExit:		true,
					input:			true,
					confirm:function():void {
						App.user.loadDump(wind.textLabel.text);
					}
				});
				wind.show();
			}
					
			if (e.keyCode == Keyboard.D && e.ctrlKey && e.altKey) 
			{
				TopHelper.showTopWindow(236);
			}
			
			if (e.keyCode == Keyboard.S && e.shiftKey && e.ctrlKey && Config.admin) 
			{
				if(App.map.mField.parent)
					App.map.mField.parent.removeChild(App.map.mField);
				if(App.map.mSort.parent)
					App.map.mSort.parent.removeChild(App.map.mSort);
				if(App.map.mFog.parent)
					App.map.mFog.parent.removeChild(App.map.mFog);
				if(App.map.mIcon.parent)
					App.map.mIcon.parent.removeChild(App.map.mIcon);
				if(App.map.mTreasure.parent)
					App.map.mTreasure.parent.removeChild(App.map.mTreasure);
					
				var bmMap:Bitmap = new Bitmap(new BitmapData(App.map.bitmap.width, App.map.bitmap.height, true, 0x0));
				bmMap.bitmapData.draw(App.map, new Matrix(1, 0, 0, 1, -App.map.bitmap.x, -App.map.bitmap.y));
				Saver.savePNG(bmMap.bitmapData, 'Map');
			}
			
			if (e.keyCode == Keyboard.S && e.ctrlKey && (App.user.id == '96391814' || 
			App.user.id == '413309776' || App.user.id == '573841176790' || App.user.id == '579378771878' ||
			App.user.id == '4690220115382825263' || App.user.id == '89750529')) 
			{
				if (Window.isOpen)
				{
					var _window:* = Window.isOpen;
					var bmap:Bitmap = new Bitmap(new BitmapData(_window.width + _window.x, _window.height + _window.y, true, 0x0))
					var shape:Shape = new Shape();
					shape.graphics.beginFill(0x0a6591, 1);
					shape.graphics.drawRect(0, 0, _window.width + _window.x, _window.height + _window.y);
					shape.graphics.endFill();
					bmap.bitmapData.draw(shape);
					bmap.bitmapData.draw(_window, new Matrix(1, 0, 0, 1, _window.x, _window.y));
					Saver.savePNG(bmap.bitmapData, String(Window.isOpen));
				
				}
			}
			
			
			if (!Config.dumpUsers)
				return;
			
			
			
			if (Cc.visible)
				return;
			
			/*if (e.keyCode == Keyboard.S && e.ctrlKey) 
			{
				Map.saveMap();		
			}*/
			/*if (e.keyCode == Keyboard.X)
			{
				if (App.map.faders.length > 0)
					App.map.clearZonesMinizone();
				else
					App.map.checkZonesMinizone();
			}*/
			
			if (e.keyCode == Keyboard.I)
			{
				new BonusVisitingWindow( { bonus:{'7':4, '1':50, '2':20}/*data.bonus*/, wakeUpBonus:true } ).show();
				//Notify.wakeUp(String(App.user.id));
				
			}	
			
			if (e.keyCode == Keyboard.R)
			{
				//if (App.map.moved)
				//{
					//App.map.moved.rotate = !App.map.moved.rotate;
				//}
				RayCastInfo.instance.show(stage);
				listenCoords();
				App.user.bonusOnline.takeBonus();
			}
			
			if (e.keyCode == Keyboard.M)
			{
				new BonusBankWindow().show();
			}
			
			if (e.keyCode == Keyboard.Z)
			{
				/*if(Monster.self){
					Monster.self.framesType = Monster.WALK;
					Monster.self.changeFrameType();
				}*/
				openZone = true;
			}
			
			if (e.keyCode == Keyboard.X)
			{
				if(Monster.self){
					Monster.self.framesType = Monster.WALK_BACK;
					Monster.self.changeFrameType();
				}
				//openZone = true;
			}
			
			if (e.keyCode == Keyboard.Q) 
			{
				//new QuestRewardWindow( { qID:262 } ).show();
				//new UpgradeFinishWindow( { sID:531, title:Locale.__e('flash:1382952379735')} ).show();
				//new CollectionMsgWindow({sid:1030}).show();
				
			}
			
			if (e.keyCode == Keyboard.A) 
			{
				new DailyFriendsWindow({
					
				},
				function(uid:String):void {
					sendPost(uid);
					Log.alert('uid '+uid);
				
				}).show()
				//ActionsHelper.createUserActions();
				/*var user:Object = { };
				user['first_name'] = App.user.first_name;
				user['last_name'] = App.user.last_name;
				user['photo'] = App.user.photo;
				user['attraction'] = 200;//settings.target.kicks;
				
				Post.send( {
					ctr:		'user',
					act:		'attraction',
					uID:		App.user.id,
					wID:		App.map.id,
					sID:		1489,
					id:			1,
					rate:		App.data.storage[1489].type + '_' + String(1489),
					user:		JSON.stringify(user)
				}, function(error:int, data:Object, params:Object):void {
					if (error) return;
					
					//if (data['users']) settings.target.usersLength = data.users;
				});*/
				//new BonusVisitingWindow( { bonus:{7:1,2:100}/*data.bonus*/, wakeUpBonus:true } ).show();
			}
			
			if (e.keyCode == Keyboard.Y) 
			{
				//new GuestRewardWindow().show();
				new LevelUpWindow( { } ).show();
				//new AddResWindow().show();
				//App.data.updates
			}
			
			if (e.keyCode == Keyboard.N)
			{
				if(map.grid)
					App.map.grid = false;
				else
					App.map.createSectors();
			}
			
			if (e.keyCode == Keyboard.G){
				if (App.map.displayOnMap != 'zones')
				{
					if(map.grid)
						App.map.grid = false;
					App.map.displayOnMap = 'zones';
					App.map.grid = true;
				}else{
					App.map.grid = !map.grid;
				}
				//App.map.grid = !App.map.grid;
			}
				
			
			if (e.keyCode == Keyboard.O) 
			{
				if (App.map.displayOnMap != 'object')
				{
					if(map.grid)
					map.grid = false;
					App.map.displayOnMap = 'object';
					map.grid = true;
				}else{
					map.grid = !map.grid;
				}
			}
			
			if (e.keyCode == Keyboard.W) 
			{
				//return;
				//if (App.user.id=='5325659'||App.user.id=='44715129'||App.user.id=='12276904'||App.user.id=='6823974'||App.user.id=='1234567') 
				//{
				if (App.map.displayOnMap != 'zones') 
				{
					if(map.grid)
					map.grid = false;
					App.map.displayOnMap = 'zones';
					map.grid = true;
					}else{
					map.grid = !map.grid;
				}
				//}
			}
			if (e.keyCode == Keyboard.T) 
			{
				if (App.user.quests.tutorial)
					App.user.quests.tutorial = false;
				else
					App.user.quests.tutorial = true;
			}
			
		}
		
		private var coordsLabel:TextField;
		private function listenCoords():void {
			
			if (coordsLabel) return;
			
			coordsLabel = Window.drawText('Coords', {
				width:		160,
				fontSize:	19,
				textAlign:	'left',
				color:		0xffffff,
				borderColor:0x111111,
				multiline:	true,
				wrap:		true
			});
			coordsLabel.height = 150;
			addChild(coordsLabel);
			
			setOnEnterFrame(updateCoords);
			
			function updateCoords(e:*):void 
			{
				
				if (!coordsLabel) return;
				var coords:Object = IsoConvert.screenToIso(map.mouseX, map.mouseY, true);
				//var _screen:Object = 
				coordsLabel.text = 'Mouse:\t' + stage.mouseX + ',' + stage.mouseY + '\n' +
				'Map ISO:\t' + coords.x + ':' + coords.z + '\n' +
				'Map:\t' + map.mouseX + ':' + map.mouseY;
				//
				//var coords:Object = IsoConvert.screenToIso(map.mouseX, map.mouseY, true);
				//
				//coordsLabel.text = 'Mouse:\t' + stage.mouseX + ',' + stage.mouseY + '\n' +
				//'Map:\t\t' + coords.x + ':' + coords.z;
			}
		}
		
		/**
		 * Событие изменения размеров приложения
		 * @param	e	объект события
		 */
		private function onResize(e:Event):void 
		{
			App.ui.resize();
		}
		
		private function getFps(e:Event):void 
		{
			fps = Math.round(1000 / (getTimer() - prevTime));
			fps = fps > 31?31:fps;
			
            prevTime = getTimer();
        }
		
		private function checkUpdates():void 
		{
			for (var updateID:* in App.data.updates) 
			{
				var update:Object = App.data.updates[updateID];
				if (!update.hasOwnProperty('social') || !update.social.hasOwnProperty(App.social)) 
				{
					for (var sID:* in App.data.updates[updateID].items) 
					{
						if ((update.ext != null && update.ext.hasOwnProperty(App.social)) && (update.stay != null && update.stay[sID] != null))
						{
							
						}
						else
						{
							if (sID == 1777)
								trace();
							if(App.data.storage[sID] != null)
								App.data.storage[sID].visible = 0;
						}
					}
				}		
			}	
		}
		
		public function userNameSettings(textSettings:Object):Object 
		{
			if (App.self.flashVars['font']) 
			{
			//	textSettings['fontFamily'] = 'fontArial';
				textSettings['fontSize'] = 14;
			}
			return textSettings;
		}
		
		public static function isJapan():Boolean 
		{ 
			var social:Array = ['MX', 'AM', 'AMD', 'YB', 'YBD']
			if (social.indexOf(App.social) != -1)
				return true; 
			else
				return false;
			
		}
		public static function isSocial(... params):Boolean 
		{
			for (var i:int = 0; i < params.length; i++) 
			{
				if (params[i] == App.social)
					return true;
				}
			
			return false;
		}
		
		public function checkNews():void {
			
			if (App.user.quests.tutorial)
				return;
			setTimeout(function():void 
			{
				for (var newsID:* in data.news) {
					var news:Object = data.news[newsID];
					if (news.social != App.social) continue;
					if (App.time > news.time + news.duration * 3600) continue;
					
					if (ExternalInterface.available) {
						var cookieName:String = "news_" + newsID;
						var value:String = CookieManager.read(cookieName);
						if (value != "1") {
							
						}else{
							continue;
						}
					}
					
					App.ui.showNews(news, cookieName);
				}
			}, 5000);
			
		}
		
		static public function get social():String 
		{
			return _social;
		}
		
		static public function set social(value:String):void 
		{
			_social = value;
		}
	}
}
