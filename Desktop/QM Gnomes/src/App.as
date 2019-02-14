package 
{
	import com.adobe.images.BitString;
	import com.flashdynamix.motion.guides.Bezier2D;
	import core.Lang;
	import core.Load;
	import core.Log;
	import core.Numbers;
	import deng.fzip.FZip;
	import deng.fzip.FZipErrorEvent;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.system.SecurityDomain;
	import flash.text.Font;
	import flash.ui.Keyboard;
	import tree.Daylics;
	import tree.Dialog;
	import tree.DropDownListUpdates;
	import tree.ImageButton;
	import tree.LayerX;
	import tree.MissionItem;
	import tree.Missions;
	import tree.Navigator;
	import tree.Node;
	import tree.SearchPanel;
	import tree.UserPanel;
	import tree.Tree;
	import tree.TreeManeger;
	/**
	 * ...
	 * @author ... 
	 */

	[SWF ( width = "900", height = "700", allowsFullScreen = true, backgroundColor = '#22313f') ]
	
	public class App extends Sprite 
	{
		private static var _social:String;
		private static var _userID:String;
		static public var data:Object;
		static public var user:User;
		public static var self:App;
		Security.allowDomain("*");
        Security.allowInsecureDomain("*");
		public static var lang:String = 'ru';		// ru en fr es pl nl jp
		
		/* 
		 * Николай	 		{DM: 159185922, OK:565449872326}
		 * Александра Худ.	{DM: 216968557}
		 * Олег     		{DM: 2111111, VK: 96391814, OK: 575889735345}
		 * Наталья     		{DM: 50545195, OK: 571437926505}
		*/
		
		public static const ID:* = '29060311';
		public static const SERVER:* = 'DM';
		public static const SOCIAL:* = 'DM';
		
		public static var startQest:uint = 2; // 
		public static var blink:String = '558a6f926df26';
		public static var ref:String = "";
		public static var time:int = new Date().time / 1000; 
		public function App():void
		{
			
			if (self){
				throw new Error("Вы не можете создавать экземпляры класса при помощи конструктора. Для доступа к экземпляру используйте Singleton.instance.")
			}else{
				self = this;
			}
			
			//Security.allowDomain("*");
            //Security.allowInsecureDomain("*");
			
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
			
		}
		
		static public function get userID():String 
		{
			return _userID;
		}
		
		static public function set userID(value:String):void 
		{
			_userID = value;
		}
		static public function get social():String 
		{
			return _social;
		}
		
		static public function set social(value:String):void 
		{
			_social = value;
		}
		
		/**
		 * Инициализация приложения
		 * @param	e	событие
		 */
		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			if (stage.loaderInfo.parameters)
				flashVars = stage.loaderInfo.parameters;
			//for (var info:Object in stage.loaderInfo.parameters)
			//{
				//Log.alert(String (info));
				//trace(String (info));
			//}
			stage.scaleMode 	= StageScaleMode.NO_SCALE;
			stage.align 		= StageAlign.TOP_LEFT;
			social = 'DM';
			//trace(Numbers.countProps(stage.loaderInfo.parameters));
			Config.setServersIP(stage);
			loadLang();
		}

		private function loadLang():void {
			Lang.loadLanguage(lang, function():void {
				Load.loadText(Config.getData(lang), onLoad, false);
			});
		}
		private function translateGameData(data:*):void 
		{
			for (var id:* in data) {
				var val:* = data[id];
				if (typeof val == 'object') {
					translateGameData(val);
				}
				else if (typeof val == 'string')
				{
					if (val.indexOf(':') != -1) {
						data[id] = Locale.__e(val);
					}
				}
			}
		}
		private function findAndFormatNumbres():void {
			
			data = toNumber(data);
			
			function toNumber(object:Object):Object {
				for (var s:String in object) {
					if (typeof(object[s]) == 'object') {
						object[s] = toNumber(object[s]);
					}else {
						if (object[s]) {
							var num:Number = Number(object[s]);
							if (!isNaN(num))
								object[s] = num;
						}
					}
				}
				
				return object;
			}
		}
		private function onLoad(_data:*):void
		{
			data = JSON.parse(_data.data);
			//user = new User();
			coloriseUpdates();
			findAndFormatNumbres();
			translateGameData(data);
			questLenght = App.numOfProps(App.data.quests);
			roots = Tree.roots;
			initContent();
			stage.addEventListener(Event.RESIZE, onResize);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
	
		private function coloriseUpdates():void
		{
			for each(var upd:* in data.updates){
				var ss1:int = 0x0000ff;
				var ss2:int = int(0xffff00) / Numbers.countProps(data.updates);
				var ss3:uint = ss1 + ss2 * int(upd.order);
				upd['color'] = ss3;
			}
		}
		
		private function onResize(e:Event = null):void
		{
			if (searchPanel)
				searchPanel.x = stage.stageWidth - searchPanel.width;
			if (userPanel)
				userPanel.x = stage.stageWidth - searchPanel.width - 20 - userPanel.width;
			if (ddl)
				ddl.x = stage.stageWidth - 208;
			if (App.treeManeger.mission && App.treeManeger.mission.parent)
				App.treeManeger.mission.relocate();
			if (App.treeManeger.dialog && App.treeManeger.dialog.parent)
				App.treeManeger.dialog.relocate();
			//backing.width = stage.stageWidth;
			//backing.scaleY = backing.scaleX = stage.stageWidth / backing.bitmapData.width;

		}
		
		private var noNeedSids:Array = new Array(538, 509, 165, 178, 338, 384);
		private function initVectors():void 
		{
			for (var storObj:Object in data.storage)
			{
				var thisObj:Object = data.storage[storObj];
				switch(data.storage[storObj].type)
				{
					case 'Wigwam':
						if (Numbers.getProp(thisObj.price, 0).key == 3)
							continue;
						technoVector[Numbers.getProp(thisObj.outs, 0).key] = {(int(Numbers.getProp(thisObj.price, 0).key)): int(Numbers.getProp(thisObj.price, 0).val) / thisObj.capacity};
						break;
					case 'Table':
						for (var tableF:* in thisObj['in'])
						{
							tableVector[App.data.treasures[App.data.storage[thisObj['in'][tableF]].treasure][App.data.storage[thisObj['in'][tableF]].treasure].item[0] ] = {(int(tableF)): int(1)};
						}
						break;
	 				case 'Twigwam':
						break;
					case 'Animal':
						if (thisObj.visible == 0)
							continue;
						feedsVector[Numbers.getProp(thisObj.outs, 0).key] = {(int(Numbers.getProp(thisObj.require, 0).key)): int(Numbers.getProp(thisObj.require, 0).val)};
						break;
					case 'Resource':
						if (Numbers.countProps(thisObj.require) <= 0)
							continue;
						if (App.data.storage[Numbers.getProp(thisObj.require).key].mtype == 3)
							continue;
						resourcesVector[Numbers.getProp(thisObj.outs).key] = {(int(Numbers.getProp(thisObj.require).key)): int(Numbers.getProp(thisObj.require).val)};
						break;
					case 'Building':
						buildingsVector[storObj] = thisObj.instance.devel[1].obj;
						break;
					case 'Bridge':
						buildingsVector[storObj] = thisObj.instance.devel[1].obj;
						break;
					case 'Port':
						buildingsVector[storObj] = thisObj.instance.devel[1].obj;
						break;
				}
			}
			for each(var craftObj:Object in data.crafting)
			{
				/*if (craftObj.out == 401)
					trace();*/
				var objectItems:Object = new Object();
				if (craftObj.items.hasOwnProperty(62) && craftObj.out != 401)
					continue;	
				if (craftsVector.hasOwnProperty(craftObj.out))
					continue;
				if (noNeedSids.indexOf(craftObj.out) != -1)
					continue;
				/*if (craftObj.count > 1)
				{
					for (var itm:* in craftObj.items)
					{
						itm;
					}
				}
				else*/
				objectItems = craftObj.items;
				objectItems['time'] = craftObj.time;
					
				craftsVector[craftObj.out] = objectItems;
			}
		}
		
		public static var resourcesVector:Object = new Object();
		public static var craftsVector:Object = new Object();
		public static var feedsVector:Object = new Object();
		public static var technoVector:Object = new Object();
		public static var tableVector:Object = new Object();
		public static var buildingsVector:Object = new Object();
		public static function numOfProps (object:Object):int
		{
			var count:int = 0;
			for each (var _item:Object in object)
				count ++;
			return count;
		}
		public static var treeManeger:TreeManeger;
		public static var searchPanel: SearchPanel;
		public static var userPanel: UserPanel;
		private function initContent():void 
		{
			//var quest:Quests = new Quests(data.quests);
			//testTree = quest.__tree;
			//testTree.show();
			
			if (!treeManeger)
				treeManeger = new TreeManeger();
			treeManeger.show();
			searchPanel = new SearchPanel({ caption:"Введите номер или название квеста"});
			searchPanel.x = stage.stageWidth - searchPanel.width;
			addChild(searchPanel);
			
			userPanel = new UserPanel({ caption:"ID игрока"});
			userPanel.x = stage.stageWidth - searchPanel.width - 20 - userPanel.width;
			addChild(userPanel);
			
			drawUpButtons();
			
			
			ddl = new DropDownListUpdates();
			addChild (ddl);
			ddl.y = 42;
			ddl.x = stage.stageWidth - 208;
			initVectors();
			
			navigator = new Navigator(treeManeger.currentTree);
			navigator.y = 40;
			navigator.x = 2;
			addChild(navigator);
		}
		
		public var navigator:Navigator;
		private var bttnNavigate:ImageButton;
		private var bttnSystemFullscreen:ImageButton;
		private var bttnSystemPlus:ImageButton;
		private var bttnSystemMinus:ImageButton;
		private var bttnStatistic:ImageButton;
		private function drawUpButtons():void 
		{
			bttnSystemFullscreen = new ImageButton(Textures.textures.fullscreenBttnBig);
			addChild(bttnSystemFullscreen);
			bttnSystemFullscreen.x = 0;
			bttnSystemFullscreen.y = 3;
			bttnSystemFullscreen.addEventListener(MouseEvent.CLICK, toFullScreen);
			
			bttnSystemPlus = new ImageButton(Textures.textures.systemPlus);
			addChild(bttnSystemPlus);
			bttnSystemPlus.x = 32;
			bttnSystemPlus.y = 3;
			bttnSystemPlus.addEventListener(MouseEvent.CLICK, onPlus);
			
			bttnSystemMinus = new ImageButton(Textures.textures.systemMinus);
			addChild(bttnSystemMinus);
			bttnSystemMinus.x = 64;
			bttnSystemMinus.y = 3;
			bttnSystemMinus.addEventListener(MouseEvent.CLICK, onMinus);
			
			bttnStatistic = new ImageButton(Textures.textures.envelope,{tip:{title:'ВНИМАНИЕ!',	text:'Введите ID пользователя и укадите сеть!'}});
			addChild(bttnStatistic);
			bttnStatistic.x = 96;
			bttnStatistic.y = 3;
			bttnStatistic.addEventListener(MouseEvent.CLICK, onStat);
			
			bttnNavigate = new ImageButton(Textures.textures.navigate,{tip:{title:'Навигатор!',	text:'Вкл./Выкл.'}});
			addChild(bttnNavigate);
			bttnNavigate.x = 126;
			bttnNavigate.y = 3;
			bttnNavigate.addEventListener(MouseEvent.CLICK, onNavigate);
			//bttnStatistic.tip = function():Object {
				//return 
			//}
		}
		private function onNavigate(e:MouseEvent):void 
		{
			if (navigator)
				navigator.show();
		}
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			//if (e.keyCode == Keyboard.F) {
				//toFullScreen();
			//}
			if (e.keyCode == Keyboard.D) 
			{
				if (treeManeger.currentTree)
				{
					if(!Node.playersDrawed){
						Node.playersDrawed = true;
						treeManeger.currentTree.playersOnQuests(true);
					}else{
						treeManeger.currentTree.refreshQuests();
					}
				}
				
			}
			if (e.keyCode == Keyboard.N) 
			{
				if (treeManeger.currentTree)
				{
					if(!Node.playersDrawed){
						Node.playersDrawed = true;
						treeManeger.currentTree.playersOnQuests(false);
					}else{
						treeManeger.currentTree.refreshQuests();
					}
				}
			}
			
			if ( treeManeger )
				treeManeger.onKeyDown(e);
		}

		private function onMouseUp(e:MouseEvent):void 
		{
			treeManeger.startDrag = false;
			if ( !treeManeger.onMouseUp(e) )
				treeManeger.clearWindow();
		}
		private function onMouseDown(e:MouseEvent):void 
		{
			var under:Array =  App.self.getObjectsUnderPoint(new Point(e.stageX, e.stageY));
			for each(var _under:Object in under)
			{
				
				if ((_under.parent.parent) && (_under.parent.parent.parent) && (_under.parent.parent.parent) is DropDownListUpdates)
				{
					treeManeger.startDrag = true;
				}
				
				if ((_under.parent.parent) && (_under.parent.parent.parent) && _under.parent.parent.parent is Daylics)
				{
					treeManeger.startDrag = true;
				}
				if ((_under.parent) && _under.parent is Navigator)
				{
					treeManeger.startDrag = false;
					return;
					
				}
			}
			if ( treeManeger )
				treeManeger.onMouseDown(e);
		}
		private function onMouseWheel(e:MouseEvent):void
		{
			if ( treeManeger )
				treeManeger.onMouseWheel(e);
			
		}
		private function onMouseMove(e:MouseEvent):void 
		{	
			if ( treeManeger )
				treeManeger.onMouseMove(e);
		}
		public static var questLenght:uint;
		private static var _roots:Array;
		public static function set roots(val:Array):void{
			_roots = val;
		}
		public static function get roots():Array{
			return _roots;
		}
		
		public static var ddl:DropDownListUpdates;
		public var flashVars:Object;
		private function toFullScreen (e:MouseEvent = null):void 
		{
			if(App.self.stage.displayState != StageDisplayState.NORMAL){
				App.self.stage.displayState = StageDisplayState.NORMAL;
				onResize();
			}else {
				App.self.stage.displayState = StageDisplayState.FULL_SCREEN;
				onResize();
			}
		}
		
		private function onStat(e:MouseEvent = null):void 
		{
			if (App.treeManeger.daylic)
				App.treeManeger.daylic.dispose();
			if (!userPanel.loadedQinfo)
			{
				userPanel.searchBg.showGlowing(0xFF0000);
				userPanel.comboBox.showGlowing(0xFF0000);
				return;
			}
			App.treeManeger.daylic = new Daylics({'quests':App.treeManeger.currentTree.lastNodes});
			App.self.addChild(App.treeManeger.daylic);
		}
		private function onMinus(e:MouseEvent = null):void 
		{
			/*var perCoord:Point = new Point ( App.self.stage.stageWidth,  App.self.stage.stageHeight);
			if (e.delta < 0)
			{*/
				if (treeManeger.currentTree.scaleY > 0.3)
				{
					treeManeger.currentTree.scaleX = treeManeger.currentTree.scaleY = treeManeger.currentTree.scaleY - 0.1;
					if (!e.ctrlKey)
						treeManeger.saveCoord(- 0.1);
				}
			/*}
			else
			{
				if (currentTree.scaleY < 0.9)
				{
					if (!e.ctrlKey)
						saveCoord(0.1);
					currentTree.scaleX = currentTree.scaleY = currentTree.scaleY + 0.1;
				}
			}
			if (e.ctrlKey)
				showFirst();*/
		}
		
		private function onPlus(e:MouseEvent = null):void 
		{
			if (treeManeger.currentTree.scaleY < 0.9)
			{
				treeManeger.currentTree.scaleX = treeManeger.currentTree.scaleY = treeManeger.currentTree.scaleY + 0.1;
				if (!e.ctrlKey)
					treeManeger.saveCoord(0.1);
			}
		}
		
	}

}