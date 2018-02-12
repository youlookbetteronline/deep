package  
{
	import adobe.utils.CustomActions;
	import astar.AStarNodeVO;
	import buttons.Button;
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.ImagesButton;
	import com.adobe.images.BitString;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.easing.Circ;
	import com.greensock.easing.Cubic;
	import com.greensock.easing.Linear;
	import com.greensock.loading.core.DisplayObjectLoader;
	import com.greensock.plugins.BezierPlugin;
	import com.greensock.plugins.BezierThroughPlugin;
	import com.greensock.plugins.TintPlugin;
	import com.greensock.plugins.TweenPlugin;
	import core.IsoConvert;
	import core.Load;
	import core.Post;
	import fl.transitions.easing.Strong;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.GradientType;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.PixelSnapping;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import ui.Cursor;
	import units.Decor;
	import units.Walkgolden;
	import wins.ShopWindow;
	//import ui.AnimalIcon;
	import ui.BitmapLoader;
	import ui.UnitIcon;
	import ui.UserInterface;
	import units.Animal;
	import units.Anime;
	import units.Box;
	import units.Building;
	import units.Field;
	import units.Hero;
	//import units.Mayor;
	import units.Personage;
	import units.Pet;
	import units.Plant;
	import units.Resource;
	//import units.Sphere;
	import units.Techno;
	import units.Unit;
	import units.WUnit;
	import units.WorkerUnit;
	import wins.AchivementMsgWindow;
	import wins.AlertWindow;
	import wins.Building.ActivateBuildingWindow;
	import wins.BuildingConstructWindow;
	import wins.CharactersWindow;
	import wins.ConstructWindow;
	import wins.HelpWindow;
	import wins.DialogWindow;
	import wins.FactoryWindow;
	import wins.InfoWindow;
	import wins.LevelUpWindow;
	import wins.MessageWindow;
	import wins.ProductionWindow;
	import wins.QuestWindow;
	import wins.RecipeWindow;
	import wins.SelectAnimalWindow;
	import wins.SpeedWindow;
	import wins.Window;
	
	
	public class QuestsRules {
		
		[Embed(source="intro.swf", mimeType="application/octet-stream")]
        private static var SwfClass:Class;
		
		private static const DIALOG1:uint = 1;
		private static const DIALOG2:uint = 2;
		private static const DIALOG3:uint = 3;
		private static const DIALOG4:uint = 4;
		private static const materialTargets:Object = {
			5:{}
		};
		
		private static var deliganseTexture:Object;	
		private static var circuit:Unit;			// Юнит для контура, чтоб показать где ставить здания
		
		public static var underMouse:Array;
		App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, changeTargets);
		public static var qID:uint;
		public static var mID:uint;
		private static var firstStart:Boolean = true;
		public static function getQuestRule(qID:*, mID:* = null):void {
			
			if (!Map.ready)
				return;
			App.map.allSorting();
			/*if (firstStart) {
				firstStart = false;
				switch(qID) 
				{
					case 2:
						prepare2();
						break;
					case 4:
						prepare4();
						break;
					case 6:
						prepare6();
						break;
					case 7:
						prepare7();
						break;
				}
			}*/
			
			QuestsRules.qID = qID;
			QuestsRules.mID = mID;
			
			if(qID != 12)
				clear();
			
			switch(qID) 
			{
				case 1:
				case 189:
				case 190:
				case 191:
					quest2_1();
					break;
				case 2:
					quest2_5();
					break;
				case 4:
					if (mID == 1)
						quest4_5();
					else if (mID == 2)
					{
						quest4_6();
						lastQuestWindowOpen = 0;
					}
					break;
					
					break;
				case 5:
					if (mID == 1)
						quest5_0();
					else if (mID == 2)
						quest5_2();
					break;
				case 7:
					if (mID == 1)
						quest7_1();
					else if (mID == 2)
					{
						quest7_2();
						//lastQuestWindowOpen = 0;
					}
					break;
				case 116:
					if (mID == 1)
						quest116();
					else if (mID == 2)
						quest116_2();
					break;
				case 12:
					if (mID == 1)
						quest12();
					else if (mID == 2){
						quest12_2();
					}
						
					break;
				case 135:
					if (mID == 1)
						quest135_1();
					else if (mID == 2)
						quest135_2();
					break;
				case 19:
					if (mID == 1)
						quest19_1();
					else if (mID == 2)
						quest19_2();
					break;
				case 8:
					if (mID == 1)
						quest8_1();
					else if (mID == 2)
						quest8_2();
					break;
				case 132:
					quest132();
					break;
				case 9:
					if (mID == 1)
						quest9_1();
					else if (mID == 2)
						quest9_2();
					else if (mID == 3)
						quest9_3();
					break;
				case 59:
					quest59();
					break;
				case 21:
				case 162:
					quest162();
					break;
			}
			
			/*addMessageSkip(116);
			addMessageSkip(6);
			addMessageSkip(8);*/
			
			if (App.user.quests.isFinish(2))
			{
				//SoundsManager.instance.setMusic(true);
				SoundsManager.instance.addAmbience();
				SoundsManager.instance.playMusic();
			}
			if (App.user.quests.isFinish(12))
			{
				//SoundsManager.instance.setMusic(true);
				SoundsManager.instance.addAmbience();
				SoundsManager.instance.playMusic();
			}
			
			
		}
		
		/**
		 * 
		 */
		/*private static var listenResize:Boolean;
		private static function onResize(... args):void {
			
			if (skipButton) {
				skipButton.x = App.self.stage.stageWidth * 0.5 - skipButton.width * 0.5;
				skipButton.y = App.self.stage.stageHeight - skipButton.height - 30;
			}
			
		}*/
		
		/**
		 * Добавить сообщение в исключение для отсрочки отображения
		 */
		public static function addMessageSkip(qID:uint):void {
			if (App.user.quests.skipMessages.indexOf(qID) == -1)
				App.user.quests.skipMessages.push(qID);
		}
		public static function removeMessageSkip(qID:uint):void {
			while (App.user.quests.skipMessages.indexOf(qID) >= 0)
				App.user.quests.skipMessages.splice(App.user.quests.skipMessages.indexOf(qID), 1);
		}
		
		
		
		/**
		 * Задать фокус на точку карты
		 */
		public static function focusOnCell(x:int, y:int, onComplete:Function = null, speed:Number = 1):void {
			App.map.focusedOn(IsoConvert.isoToScreen(x, y, true), false, onComplete, speed > 0 ? true : false, null, true, speed);
		}
		
		/**
		 * Проверить или есть на что сфокусироваться на карте
		 */
		public static function mapFocus():Boolean 
		{
			for (var i:int = 0; i < targets.length; i++) 
			{
				if (targets[i] is Unit) 
				{
					App.map.focusedOn(targets[i], false, null, false);
					return true;
				}
			}
			
			if (place) {
				App.map.focusedOn(place, false, null, false);
				return true;
			}
			
			return false;
		}
		
		/**
		 * Задать позицию и поворота персонажа
		 */
		public static function unitTo(unit:WUnit, rotate:uint = 0, cell:int = -1, row:int = -1):void 
		{
			if (cell >= 0 && row >= 0) 
			{
				unit.placing(cell, 0, row);
				unit.cell = cell;
				unit.row = row;
			}
			
			if (unit.framesFlip != rotate) 
			{
				if (rotate == 1) 
				{
					unit.framesFlip = rotate;
					unit.sign = -1;
					unit.bitmap.scaleX = -1;
				}else
				{
					unit.framesFlip = rotate;
					unit.sign = 1;
					unit.bitmap.scaleX = 1;
				}
			}
			
			if (unit.textures)
				unit.update();
		}
		
		/**
		 * Задать позицию персонажа
		 */
		public static function get hero():Hero {
			return App.user.hero;
		}
		/*public static function get pet():Pet {
			return App.user.pet;
		}*/
		private static var __worker:Techno;
		public static function get worker():Techno {
			if (!__worker) __worker = Map.findUnit(8, 1);
			return __worker;
		}
		/*private static var __worker:Techno;
		public static function get worker():Techno {
			if (!__worker) __worker = Map.findUnit(106, 1);
			return __worker;
		}*/
		private static var __johny:Walkgolden;
		public static function get johny():Walkgolden {
			if (!__johny) __johny = Map.findUnit(Walkgolden.JOHNY, 4);
			return __johny;
		}
		private static var __debris_johny:Decor;
		public static function get debris_johny():Decor {
			if (!__debris_johny) __debris_johny = Map.findUnit(689, 171);
			return __debris_johny;
		}
		private static var __crill:Building;
		public static function get crill():Building {
			if (!__crill) __crill = Map.findUnit(499, 4);
			return __crill;
		}
		/*private static var __coyote:Unit;
		public static function get coyote():Unit {
			if (!__coyote) __coyote = Map.findUnit(128, 3);
			return __coyote;
		}
		private static var __box:Box;
		public static function get box():Box {
			if (!__box) __box = Map.findUnit(179, 1);
			return __box;
		}*/
		
		private static var __focused:Boolean;
		public static function get focused():Boolean 
		{
			return __focused;
		}
		
		public static function set focused(val:*):void 
		{
			__focused = val;
		}
		
		/**
		 * Трясти
		 */
		public static function shake(object:DisplayObject, time:Number = 0.5, dispersion:uint = 4):void 
		{
			var originX:int = object.x;
			var originY:int = object.y;
			var startTime:uint = getTimer(); 
			
			TweenLite.to(object, time, { onUpdate:function():void {
				var time:Number = 1 - (getTimer() - startTime) * 0.001 / 0.5;
				object.x = originX + time * dispersion * Math.random();
				object.y = originY + time * dispersion * Math.random();
			}, onComplete:function():void {
				object.x = originX;
				object.y = originY;
			}} );
		}
		
		
		/**
		 * Затемнить через черный фон
		 */
		private static var fader:Sprite;
		public static function fade(onComplete:Function, alpha:Number = 1, time:Number = 1, color:uint = 0):void {
			
			if (!fader)
				fader = new Sprite();
			
			if (!App.self.contextContainer.contains(fader)) App.self.contextContainer.addChildAt(fader, 0);
			fader.alpha = 1 - alpha;
			fader.graphics.clear();
			fader.graphics.beginFill(color, 1);
			fader.graphics.drawRect(0, 0, Capabilities.screenResolutionX, Capabilities.screenResolutionY);
			fader.graphics.endFill();
			TweenLite.to(fader, time, { alpha:alpha, onComplete:complete} );
			
			function complete():void {
				if (alpha == 0) fader.visible = false;
				if (onComplete != null)
					onComplete();
			}
		}
		
		
		/**
		 * Затемнить через прозрачность
		 */
		public static function fademove(onPrepare:Function, onComplete:Function, time:Number = 1):void {
			
			var bitmapData:BitmapData = new BitmapData(App.self.stage.stageWidth, App.self.stage.stageHeight, false);
			try {
				bitmapData.draw(App.self.stage);
			}catch(e:Error) {}
			
			var bitmap:Bitmap = new Bitmap(bitmapData);
			App.self.contextContainer.addChild(bitmap);
			
			if (onPrepare != null)
				onPrepare();
			
			TweenLite.to(bitmap, time, {alpha:0, onComplete:function():void {
				App.self.contextContainer.removeChild(bitmap);
				bitmap = null;
				
				if (onComplete != null)
					onComplete();
			}});
		}
		
		
		
		/**
		 * Может быть нажата (кнопка, иконка)
		 */
		private static var targetAnyway:Unit;
		private static var targets:Array = [];
		public static function cantPress(target:*):Boolean 
		{
			
			if (targetAnyway) 
			{
				clear();
				
				targetAnyway.hideGlowing();
				targetAnyway.stopBlink();
				targetAnyway.hidePointing();
				targetAnyway.click();
				targetAnyway = null;
			}
			else if (underMouse) 
			{
				var find:Boolean;
				var index:int;
				for (var i:int = 0; i < underMouse.length; i++) 
				{
					var object:* = underMouse[i];
					while (object.parent) 
					{
						index = targets.indexOf(object);
						if (index != -1) {
							if ((object.hasOwnProperty('click') && (object.click is Function)) || object is Zone) 
							{
								
								// Особый случай для грядок
								if ((object is Field) && !object.ordered && !object.plant)
									targets.splice(index);
								//if(object is Zone)	
									//trace();//App.user.world.showOpenZoneWindow(object.sID);
								//else
									object.click();
								focusClear();
								
								find = true;
							}
						}
						
						if (find)
							break;
						
						object = object.parent;
					}
					
					if (find)
						break;
				}
				
				if (find && object) 
				{
					
					/*if ((object is Building) || (object is Field) || (object is Box)) 
					{
						trace('CLICK CLEAR:', getQualifiedClassName(object));
						targets.splice(targets.indexOf(object), 1);
					}*/
				}
				underMouse = null;
			}
			
			var conditionable:Boolean;
			var key:Array = (target && target.name) ? target.name.split('.') : null;
			if (key && key.length >= 3) 
			{
				switch(key[0]) 
				{
					case 'mission':
						if (App.user.quests.isOpen(int(key[1])) && App.user.quests.isFirstOpenMission(int(key[1]), int(key[2])))
							conditionable = true;
						break;
				}
			}
			var tarArr:Array = new Array('LevelUpWindow_okBttn', 'tmw_okBttn', 'prodItem', 'boost', 'construct_bttn', 'QuestRewardWindow_okBttn', 'DialogWindow_okBttn', 'sp_fullscreen', 'sp_panel', 'sp_sound', 'sp_music', 'bttn_shop_item_find', 'mission', 'seach_bttn', 'bttn_home');
			
			//if (App.user.quests.tutorial && tarArr.indexOf(target.name) == -1 && targets.indexOf(target) == -1 && target is Fog)
			//{
				//trace();
			//}
			
			if (App.user.quests.tutorial && tarArr.indexOf(target.name) == -1 && (targets.indexOf(target) == -1 /*|| (target.parent && targets.indexOf(target.parent) == -1)*/) && !conditionable) 
			{
				if (!find /*&& !(target.parent is AnimalIcon)*/)
					focusTarget();
				if (target is Fog && targets[0] is Fog)
				{
					App.user.world.showOpenZoneWindow(935);
				}
				return true;
			}
			
			
			focusClear();
			
			return false;
		}
		
		public static function addTarget(... args):void 
		{
			
			if (args.length > 0) 
			{
				for (var i:int = 0; i < args.length; i++) 
				{
					var target:* = args[i];
					
					if (target != null) 
					{
						if (targets.indexOf(target) != -1)
							continue;
						
						trace('Target ADD:', qID, getQualifiedClassName(target));
						targets.push(target);
						
						if (target is Unit && target.icon)
							targets.push(target.icon);
						
						if (target is Unit)
							checkGlowing(target);
					}
				}
			}
		}
		public static function getTargtes():Array 
		{
			return targets;
		}
		
		
		/**
		 * Фокусировка
		 */
		private static var focusedTarget:*;
		private static var maskCont:Sprite;
		private static var fosusTween:TweenLite;
		private static var focusListener:Function;
		public static function focusTarget():void {
			
			var i:int;
			var target:*;
			var window:*;
			
			// Прерывание фокуса если чтото висит на миши
			/*if (App.map.moved) {
				focusClear();
				return;
			}*/
			
			// Прерывание фокуса если окно открывается
			for (i = 0; i < App.self.windowContainer.numChildren; i++) 
			{
				window = App.self.windowContainer.getChildAt(i) as Window;
				if (window && window.opened && !(window is ShopWindow)) 
				{
					focusClear();
					return;
				}
			}
			
			// Определение открытого окна
			for (i = 0; i < App.self.windowContainer.numChildren; i++) {
				window = App.self.windowContainer.getChildAt(i) as Window;
				if (window && window.opened) break;
			}
			// Работа с квестовым окном
			if (window is QuestWindow) {
				var questWindow:QuestWindow = window as QuestWindow;
				for (i = 0; i < questWindow.missions.length; i++) {
					if (questWindow.missions[i].helpBttn && questWindow.missions[i].helpBttn.__hasGlowing) {
						target = questWindow.missions[i].helpBttn;
						break;
					}else if (questWindow.missions[i].substructBttn && questWindow.missions[i].substructBttn.__hasPointing) {
						target = questWindow.missions[i].substructBttn;
						break;
					}
				}
			}
			
			// Работа с окнами LevelUpWindow DialogWindow MessageWindow
			if (window is LevelUpWindow || window is DialogWindow || window is MessageWindow) 
			{
				target = window.okBttn;
			}
			
			/*if (window is ActivateBuildingWindow) {
				target = window._confirmButton;
			}*/
			
			if (targets.length) 
			{
				for (i = 0; i < targets.length && !target; i++) 
				{
					if (targets[i] is LayerX && targets[i].parent && targets[i].__hasPointing)
						target = targets[i];
				}
				
				if (place) 
				{
					target = place;
				}
			}
			
			if (!target || focusedTarget == target || !target.parent || (target is Unit && target.ordered)) return;
			focusedTarget = target;
			
			focusTargetAtPoint(focusedTarget);
			
		}
		private static function focusTargetAtPoint(target:LayerX):void 
		{
			
			if (maskCont) 
			{
				maskCont.removeChildren();
				App.self.stage.removeChild(maskCont);
				maskCont = null;
			}
			
			if (fosusTween)
				fosusTween.kill();
			
			if (focusListener != null)
				App.self.setOffEnterFrame(focusListener);
			
			var radius:int = Math.max(target.width, target.height);
			var offset:Point = new Point();
			
			if (target is Field)
				offset.y = -40;
			if (App.map.moved == null )
			{
				if (focusedTarget is ImagesButton)
					App.map.focusedOnCenter(hero, false);
				else
					App.map.focusedOnCenter(target, false);
			}
			
			/*var point:Point = target.localToGlobal(new Point());
			var bounds:Object = target.getBounds(target);
			
			point.x += bounds.width * 0.5 + bounds.left;
			point.y += bounds.height * 0.5 + bounds.top;*/
			
			maskCont = new Sprite();
			maskCont.mouseChildren = false;
			maskCont.mouseEnabled = false;
			App.self.stage.addChild(maskCont);
			
			var fader:Sprite = new Sprite();
			fader.graphics.beginFill(0x000000, 0.5);
			fader.graphics.drawRect(0, 0, App.self.stage.stageWidth, App.self.stage.stageHeight);
			fader.graphics.endFill();
			maskCont.addChild(fader);
			
			fader.cacheAsBitmap = true;
			
			radius *= .75;
			
			var circle:Shape = new Shape();
			circle.graphics.beginFill(0, 1);
			circle.graphics.drawCircle(0, 0, radius);
			circle.graphics.endFill();
			circle.scaleX = 1.5;
			circle.scaleY = 1.5;
			circle.filters = [new BlurFilter(20, 20)];
			fader.addChild(circle);
			circle.blendMode = BlendMode.ERASE;
			
			fosusTween = TweenLite.to(circle, 0.5, { scaleX:1, scaleY:1 } );
			
			var listener:Function = function(e:Event = null):void {
				var point:Point;
				if (target.hasOwnProperty('coords'))
				{
					point = new Point();
					var _pnt:Object =  IsoConvert.isoToScreen(target['coords'].x + target['cells'] / 2, target['coords'].z + target['rows'] / 2, true);
					point.x = _pnt['x'] + App.map.x;
					point.y = _pnt['y'] + App.map.y - radius / 3;
				}else{
					point = target.localToGlobal(new Point());
					var bounds:Object = target.getBounds(target);
					
					point.x += bounds.width * 0.5 + bounds.left + offset.x;
					point.y += bounds.height * 0.5 + bounds.top + offset.y;
				}
				circle.x = point.x ;
				circle.y = point.y ;
			}
			
			App.self.setOnEnterFrame(listener);
			focusListener = listener;
			
		}
		public static function focusClear():void 
		{
			if (maskCont) {
				maskCont.removeChildren();
				App.self.stage.removeChild(maskCont);
				maskCont = null;
			}
			
			if (focusListener != null) 
			{
				App.self.setOffEnterFrame(focusListener);
				focusListener = null;
			}
			
			focusedTarget = null;
		}
		
		
		
		/**
		 * 
		 */
		private static var timeouts:Vector.<int> = new Vector.<int>;
		private static var tweens:Vector.<TweenLite> = new Vector.<TweenLite>;
		private static function addTimeout(value:int):void 
		{
			timeouts.push(value);
		}
		private static function addTween(value:TweenLite):void 
		{
			tweens.push(value);
		}
		
		
		/**
		 * Очистка
		 */
		private static var currentTimeout:int;
		private static var currentTween:TweenLite;
		public static function clear():void 
		{
			
			// Очистка тайм-аутов
			while (timeouts.length)
				clearTimeout(timeouts.shift());
			
			// Очистка твинов
			while (tweens.length) {
				var tween:TweenLite = tweens.shift();
				tween.kill();
				tween = null;
			}
			
			focusClear();
			//clearPoint();
			
			while (content.length) {
				var unit:Sprite = content.shift();
				if (unit.parent)
					unit.parent.removeChild(unit);
			}
			
			while (targets.length) {
				var target:* = targets.shift();
				if (target is LayerX && !(target is Button)) {
					target.hideGlowing();
					target.stopBlink();
					target.hidePointing();
				}
				trace('Target CLEAR:', qID, getQualifiedClassName(target));
			}
		}
		private static var content:Vector.<Sprite> = new Vector.<Sprite>;
		
		/**
		 * 
		 */
		private static var dialogList:Array;
		private static var dialogCallback:Function;
		private static var dialogTarget:Unit;		// На ком висит диалог
		private static var dialogTimeout:uint;		// 
		public static function startDialog(type:*, onComplete:Function = null):void 
		{
			var __dialogs:Object = JSON.parse(App.data.options.TutorialText);
			if (!__dialogs.hasOwnProperty(type)) 
			{
				onComplete();
				return;
			}
			
			dialogList = __dialogs[type];
			
			dialogCallback = onComplete;
			
			App.self.stage.addEventListener(MouseEvent.CLICK, nextDialog, false,10000);
			
			nextDialog();
		}
		
		public static function nextDialog(... args):void 
		{
			
			if (dialogTimeout) 
			{
				clearTimeout(dialogTimeout)
				dialogTimeout = 0;
			}
			
			if (dialogTarget) 
			{
				dialogTarget.clearIcon();
				dialogTarget = null;
			}
			
			if (!dialogList || dialogList.length == 0) 
			{
				App.self.stage.removeEventListener(MouseEvent.CLICK, nextDialog, false);
				if (dialogCallback != null) dialogCallback();
				dialogCallback = null;
				dialogList = null;
				return;
			}
			
			var dialog:Object = dialogList.shift();
			var time:Number = dialog.time || 3;
			var bColor:uint = 0xffffff;
			var heigh:int = 0;
			var text:String;
			
			if (dialog.hasOwnProperty('hero')) 
			{
				dialogTarget = hero;
				text = dialog.hero;
				heigh = 55;
				bColor = 0x11243e;
			}else if (dialog.hasOwnProperty('johny'))
			{
				dialogTarget = johny;
				text = dialog.johny;
				heigh = 55;
				bColor = 0x602c87;
			}else if (dialog.hasOwnProperty('debris_johny'))
			{
				dialogTarget = debris_johny;
				text = dialog.debris_johny;
				bColor = 0x602c87;
			}
			
			if (!dialogTarget) {
				nextDialog();
				return;
			}
			
			dialogTarget.drawIcon(UnitIcon.DIALOG, 0, 0, 
			{
				fadein:			true,
				hidden:			true,
				hiddenTimeout:	time * 1000,
				text:			Locale.__e(text),
				iconDY:			-10,
				textSettings:	
					{
						color:			0xfffef4,
						borderColor:	bColor,
						textAlign:		'center',
						autoSize:		'center',
						fontSize:		24,
						shadowSize:		1.5
					}
			}, 0, 0, -heigh);
			dialogTimeout = setTimeout(nextDialog, time * 1000);
			
		}
		
		/**
		 * Ожидание 
		 */
		private static var waitOldTargetsList:Array;
		private static var waitTimeout:uint;
		public static function waitTarget(callback:Function = null):void 
		{
			
			if (!waitOldTargetsList) waitOldTargetsList = [];
			waitOldTargetsList.length = 0;
			
			for (var i:int = 0; i < targets.length; i++) 
			{
				waitOldTargetsList.push(targets[i]);
			}
			
			clearInterval(waitTimeout);
			waitTimeout = setInterval(waiting, 25);
			
			trace('BeginWait');
			
			function waiting():void 
			{
				for (var i:int = 0; i < targets.length; i++) 
				{
					if (waitOldTargetsList.indexOf(targets[i]) == -1) 
					{
						checkGlowing(targets[i]);
						
						if (callback != null) callback();
						
						waitOldTargetsList.push(targets[i]);
						clearInterval(waitTimeout);
						
						trace('EndWait');
						
						return;
					}
				}
			}
		}
		
		
		
		public static function checkGlowing(target:*):void 
		{
			if (!target) return;
			
			if (target is Unit) {
				//target.showGlowing();
				target.startBlink();
				
				if (target.sid == 499) {	// Станция фильтрации
					target.showPointing('top', -target.width * 0.5, -target.height * 0.55 - 70);
					//target.showGlowing();
				}else if (target.sid == 526) {	// Колодец
					target.showPointing('top', -target.width * 0.5, -target.height * 0.6 + 40);
					//target.showGlowing();
				}else if (target.sid == 689) {	// Обломки
					target.showPointing('top', -196* 0.5, -117 * 0.6 + 70);
					//target.showGlowing();
				}else{
					target.showPointing('top', -target.width * 0.5, -target.height * 0.6);
					//target.showGlowing();
				}
			}
			
			if (target is Field) 
			{
				target.stopBlink;
				//target.hidePointing;
			}
			
			if (target is Plant && target.field) 
			{
				//target.field.showGlowing();
				target.field.startBlink();
				target.field.showPointing('top', -target.field.width * 0.5, -70);
			}
			if (target is ImageButton) 
			{
				target.showGlowing();
				target.showPointing('top', -2, 16, target.parent);
			}
		}
		
		
		
		/**
		 * 
		 */
		public static function manageWindow(type:Class):void 
		{
			var i:int;
			var param1:Boolean;
			var param2:Boolean;
			var target:*;
			var productionWindow:ProductionWindow;
			var recipeWindow:RecipeWindow;
			var activateBuildingWindow:ActivateBuildingWindow;
			var constructWindow:ConstructWindow;
			var manageTimeout:uint;
			
			manageTimeout = setInterval(manage, 200);
			
			trace('ManageSTART', qID, mID);
			
			function manage():void 
			{
				if (type == ProductionWindow) 
				{
					if (!param1) 
					{
						productionWindow = Window.isClass(type);
						if (productionWindow) 
						{
							for (i = 0; i < productionWindow.productionItems.length; i++) 
							{
								if (productionWindow.productionItems[i].itemIcon && productionWindow.productionItems[i].itemIcon) 
								{
									target = productionWindow.productionItems[i].itemIcon;
									addTarget(target);
									param1 = true;
								}
							}
						}
					}
					
					if (!param2) 
					{
						recipeWindow = Window.isClass(RecipeWindow);
						if (recipeWindow) 
						{
							target = recipeWindow.outItem.recipeBttn;
							addTarget(target);
							target = recipeWindow.outItem.recipeBttn;
							addTarget(target);
							param2 = true;
						}
					}
					
					if (param1 && param2) 
					{
						stopManage();
					}
				}
				
				if (type == ActivateBuildingWindow) 
				{
					activateBuildingWindow = Window.isClass(type);
					if (activateBuildingWindow) 
					{
						activateBuildingWindow._confirmButton.showGlowing();
						activateBuildingWindow._confirmButton.showPointing('bottom', 0, 100, activateBuildingWindow._confirmButton.parent)
						target = activateBuildingWindow._confirmButton;
						addTarget(target);
						stopManage();
					}
				}
				
				if (type == ConstructWindow) 
				{
					constructWindow = Window.isClass(type);
					/*if (constructWindow) {
						constructWindow.upgBttn.showGlowing();
						constructWindow.upgBttn.showPointing('bottom', 0, 100, constructWindow.upgBttn.parent);
						target = constructWindow.upgBttn;
						addTarget(target);
						stopManage();
					}*/
				}
			}
			function stopManage():void 
			{
				trace('ManageSTOP', qID, mID);
				clearInterval(manageTimeout);
			}
		}
		
		/**
		 * ожидание исполнения условия (compare)
		 */
		public static function compare(callback:Function, compare:Function, timeout:uint = 200):void 
		{
			var interval:int = setInterval(function():void 
			{
				if (!compare()) return;
				clearInterval(interval);
				callback();
			}, timeout);
		}
		
		private static var place:LayerX;
		public static function setPoint(x:int, z:int, size:int = 80):void 
		{
			clearPoint();
			
			var object:Object = IsoConvert.isoToScreen(x, z, true);
			
			place = new LayerX();
			place.graphics.beginFill(0x89d93c, 0.4);
			place.graphics.drawEllipse(-size, -size * 0.5 + 8, size * 2, size * 1.16);
			place.graphics.endFill();
			place.x = object.x;
			place.y = object.y;
			
			App.map.mLand.addChild(place);
			App.map.focusedOn(place);
			place.showPointing('top', -size, -35);
		}
		
		public static function setRect(x:int, z:int, size1:int = 10, size2:int = 25):void 
		{
			clearPoint();
			
			var object:Object = IsoConvert.isoToScreen(x, z, true);
			var object1:Object = IsoConvert.isoToScreen(x + size1, z, true);
			var object2:Object = IsoConvert.isoToScreen(x + size1, z + size2, true);
			var object3:Object = IsoConvert.isoToScreen(x, z + size2, true);
			
			place = new LayerX();
			place.graphics.beginFill(0x89d93c , .4);
			place.graphics.moveTo(0, 0);  
			place.graphics.lineTo(object1.x - object.x, object1.y - object.y); 
			place.graphics.lineTo(object2.x - object.x, object2.y - object.y); 
			place.graphics.lineTo(object3.x - object.x, object3.y - object.y);  
			place.graphics.lineTo(0, 0); 
			//place.graphics.drawEllipse(-size1, -size1 * 0.5 + 8, size1 * 2, size1 * 1.16);
			place.graphics.endFill();
			//place.graphics.drawRect(0, 0, size, size);
			place.x = object.x;
			place.y = object.y;
			
			App.map.mLand.addChild(place);
			App.map.focusedOn(place);
			place.showPointing('top', -75, 45);
		}
		
		public static function clearPoint():void 
		{
			if (!place) return;
			
			place.hidePointing();
			if (place.parent) place.parent.removeChild(place);
			place = null;
		}
		
		public static function windowUpdateBlocker(className:String, params:Object = null):Boolean
		{
			switch (className)
			{
				case 'TravelWindow':
					return (!(App.user.quests.isOpen(133) || App.user.quests.isFinish(133)) && App.map.id == User.HOME_WORLD && !Config.admin);
					break;
				case 'ShipWindow':
					return (!(App.user.quests.isOpen(132) || App.user.quests.isFinish(132)) && App.map.id == User.HOME_WORLD && !Config.admin);
					break;
				default:
					return false;
			}
		}
		
		private static var lastQuestWindowOpen:int = 0;
		private static var lastMissionOpen:int = 0;
		private static function openQuestWindow(id:uint, lastWin:Boolean = true):void 
		{
			if (!lastWin)
			{
				lastQuestWindowOpen = 0;
				//lastMissionOpen = 0;
			}
			if (App.self.windowContainer.numChildren > 0) 
			{
				setTimeout(openQuestWindow, 250, id, lastWin);
				return;
			}
			
			if (App.user.quests.isFinish(id) ) 
			{
				App.user.quests.continueTutorial();
				//lastQuestWindowOpen = 0;
			}else if (lastQuestWindowOpen == id /*&& lastMissionOpen == mID*/) 
			{
				// При поиске на карте если focusOn не отработает, в targets добавиться target раньше чем нужно
				setTimeout(function():void 
				{
					App.user.quests.helpEvent(App.user.quests.currentQID, App.user.quests.currentMID);
				}, 100);
			}else 
			{
				lastQuestWindowOpen = id;
				//lastQuestWindowOpen = mID;
				App.user.quests.openWindow(id);
			}
		}
		
		private static function externalDialog(type:int, onComplete:Function = null):void
		{
			return;
			
			var __dialogs:Object = JSON.parse(App.data.options.TutorialText);
			if (!__dialogs.hasOwnProperty(type)) 
			{
				onComplete();
				return;
			}
			
			dialogList = __dialogs[type];
			
			//dialogCallback = onComplete;
			var externalString:String = '';
			for each(var ins:Object in dialogList)
			{
				for (var pers:String in ins)
				{
					if (pers != 'time' && pers != 'girl')
					{
						if (externalString != '')
							externalString += '\n';
						externalString += getPersID(pers) + ':' + ins[pers];
						//break;
					}
				}
			}
			showExternalDialog(externalString, onComplete);
			function getPersID(view:String):int
			{
				var res:int = 7;
				switch (view)
				{
					case 'worker':
						res = 6;
						break;
					case 'hero':
						res = 7;
						break;
				}
				return res;
			}
		}
		
		private static function showExternalDialog(dialog:String, callback:Function = null):void {
			new DialogWindow( {
				dialog:			dialog,
				callback:		callback
			}).show();
		}
		
		
		
		// Самое место чтото догрузить
		public static var circles:BitmapLoader;
		private static function loadResources():void {
			
			Load.loading(Config.getSwf('Tutorial', (App.user.sex == 'f') ? 'sad_woman' : 'sad_man'), function(... args):void { } );
			
			// Круги на воде
			circles = new BitmapLoader(Config.getImage('tutorial', 'tutorialCirclesOnLake'));
			circles.x = 2099;
			circles.y = 1200;
			//circles.transform.colorTransform = new ColorTransform(1, 1, 1, 1, 255);
			var index:int = App.map.getChildIndex(App.map.bitmap);
			App.map.addChildAt(circles, index + 1);
			
		}
		
		
		
		private static var loaded:Boolean;
		public static function startOnTutorialReady(callback:Function = null):void {
			
			if (!App.user.quests.tutorial) {
				if (callback != null)
					callback();
				
				return;
			}
			
			compare(function():void {
				
				loaded = true;
				
				if (callback != null)
					callback();
				
			}, function():Boolean {
				return (!firstStart && Load.queueLength == 0);
			});
		}
		
		
		
		private static var skipButton:Button;
		private static var nextStepCallback:Function;
		private static function addSkipButton(nextStep:Function = null, x:int = 0, y:int = 0):void 
		{
			if (!skipButton) 
			{
				skipButton = new Button( {
					width:		180,
					height:		46,
					caption:	Locale.__e('flash:1429716360253'),
					name:		'tmw_okBttn'
				});
				skipButton.addEventListener(MouseEvent.CLICK, onSkip);
				App.self.faderContainer.addChild(skipButton);
				
				setInterval(function():void {
					if (skipButton && App.self.windowContainer.numChildren > 0) {
						skipButton.visible = false;
					}
				}, 500);
			}
			
			skipButton.x = App.self.stage.stageWidth * 0.5 - skipButton.width * 0.5;
			skipButton.y = App.self.stage.stageHeight - skipButton.height - 30;
			
			if (App.self.windowContainer.numChildren == 0) 
			{
				skipButton.visible = true;
				skipButton.alpha = 0;
				addTween(TweenLite.to(skipButton, 1, { alpha:1 }));
			}
			
			if (x != 0) skipButton.x = x;
			if (y != 0) skipButton.y = y;
		}
		private static function hideSkipButton():void 
		{
			if (!skipButton) return;
			skipButton.visible = false;
		}
		
		private static function changeTargets(e:AppEvent):void 
		{
			switch(qID) 
			{
				case 5:	//Колодец
					if (mID == 1)
					{
						var ruins:* = Map.findUnit(481, 727);
						if (ruins == null)
							quest5_1_1();
					}
					break;
				case 12:	//Станция фильтрации
					if (mID == 2)
					{
						if (crill.level == 0)
						{
							var bones:* = Map.findUnit(429, 436);
							if (bones == null)
								quest12_1_1();
						}
					}
					break;
				case 116:	//Станция фильтрации
					if (mID == 1 || mID == 2)
					{
						var crillG:Building = Map.findUnit(499, 3);
						if (crillG && crillG.guestDone)
						{
							targets.push(App.ui.bottomPanel.bttnMainHome);
							App.ui.bottomPanel.bttnMainHome.showGlowing();
							App.ui.bottomPanel.bttnMainHome.showPointing('top', 0, 10, App.ui.bottomPanel.bttnMainHome.parent);
						}
					}
					break;
				
				}
		}
		
		private static function loadTutorMaterials():void
		{
			Load.loading(Config.getSwf("Decor", "octopus_ruins"), function(data:*):void {
				trace('loaded');
			});
		}
		
		private static function drawCircle(target:LayerX, dy:int = 0):void 
		{
			if (maskCont) 
			{
				maskCont.removeChildren();
				App.self.stage.removeChild(maskCont);
				maskCont = null;
			}
			
			if (fosusTween)
				fosusTween.kill();
			
			if (focusListener != null)
				App.self.setOffEnterFrame(focusListener);
			
			var radius:int = Math.max(target.width, target.height);
			var offset:Point = new Point();
			
			if (target is Field)
				offset.y = -40;
			
			maskCont = new Sprite();
			maskCont.mouseChildren = false;
			maskCont.mouseEnabled = false;
			App.self.stage.addChild(maskCont);
			
			fader = new Sprite();
			fader.graphics.beginFill(0x062042, 1);
			fader.graphics.drawRect(0, 0, App.self.stage.stageWidth, App.self.stage.stageHeight);
			fader.graphics.endFill();
			maskCont.addChildAt(fader, 0);
			
			fader.cacheAsBitmap = true;
			
			var circle:Shape = new Shape();
			circle.graphics.beginFill(0, 1);
			circle.graphics.drawCircle(0, 0, radius * 1.1);
			circle.graphics.endFill();
			circle.scaleX = 1.5;
			circle.scaleY = 1.5;
			circle.filters = [new BlurFilter(80, 80, 3)];
			fader.addChild(circle);
			circle.blendMode = BlendMode.ERASE;
			
			fosusTween = TweenLite.to(circle, 0.5, { scaleX:1, scaleY:1 } );
			var bounds:Object = target.getBounds(target);
			
			var listener:Function = function(e:Event = null):void 
			{
				var point:Point = target.localToGlobal(new Point());
				
				
				point.x += bounds.width * 0.5 + bounds.left + offset.x;
				point.y += bounds.height * 0.5 + bounds.top + offset.y - dy;
				
				circle.x = point.x;
				circle.y = point.y;
			}
			
			App.self.setOnEnterFrame(listener);
			focusListener = listener;
			setTimeout(function():void 
			{
				fosusTween = TweenLite.to(circle, 0.5, { scaleX:3, scaleY:3, onComplete:function():void {
						maskCont.removeChild(fader);
					}});
			},5000);
		}
		
		private static var loader:Loader = new Loader();
		private static var rectangle:Shape = new Shape();
		private static function quest2_1():void 
		{
			SoundsManager._instance.setMusic(false);
			App.ui.visible = false;
			App.map.visible = false;
			//var gfgf:* = Config.getSwf("Tutorial", "intro");
			
			var swfBytes:ByteArray = new SwfClass();
            //var laoder:Loader = new Loader();
            loader.loadBytes(swfBytes);
			
			//var loadURL:URLRequest = new URLRequest(gfgf);
			//loader.load(loadURL);
			App.self.faderContainer.addChild(loader);
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, movieComplete);
			App.self.stage.addEventListener(Event.RESIZE, onRefreshPosition);
			
			maskCont = new Sprite();
			maskCont.mouseChildren = false;
			maskCont.mouseEnabled = false;
			App.self.stage.addChild(maskCont);
			
			fader = new Sprite();
			fader.graphics.beginFill(0x062042, 1);
			fader.graphics.drawRect(0, 0, App.self.stage.stageWidth, App.self.stage.stageHeight);
			fader.graphics.endFill();
			maskCont.addChildAt(fader, 0);
			
			fader.cacheAsBitmap = true;
			
			rectangle = new Shape();
			rectangle.graphics.beginFill(0x062042, 1);
			rectangle.graphics.drawRect(0, 0, 900 - 40, 700 - 40);
			rectangle.graphics.endFill();
			rectangle.filters = [new BlurFilter(20, 20, 2)];
			fader.addChild(rectangle);
			rectangle.blendMode = BlendMode.ERASE;
			rectangle.x = (App.self.stage.stageWidth - rectangle.width) / 2;
			rectangle.y = (App.self.stage.stageHeight - rectangle.height) / 2;
			
			
			addSkipButton();
		}
		
		private static function onSkip(e:MouseEvent):void 
		{
			clear();
			if (loader && mc)
			{
				mc.removeEventListener(Event.ENTER_FRAME, checkIsLast);
				if (maskCont) 
				{
					maskCont.removeChildren();
					App.self.stage.removeChild(maskCont);
					maskCont = null;
				}
				if(fader){
					fader = null;
				}
				hideSkipButton();
				Triggers.send(Triggers.SHOW_NP);
				App.self.dispatchEvent(new AppEvent(AppEvent.SHOWN_NEWSPAPER));
				App.self.faderContainer.removeChild(loader);
				
				addTimeout(setTimeout(function():void 
				{
					App.ui.visible = true;
					App.map.visible = true;
					
					setTimeout(function():void 
					{
						Triggers.send(Triggers.SHOW_HERO);
						hero.restCount = 1;
						hero.setRest();
						if (App.user.personages.length > 0)
							App.map.focusedOn(App.user.hero, false, null, false);
						var dText:String = Locale.__e('flash:1482320101248');
						if (App.user.sex == 'f'){
							dText = Locale.__e('flash:1482498273270');
						}
						setTimeout(function():void 
						{
							hero.drawIcon(UnitIcon.DIALOG, 0, 0, {
								fadein:			true,
								hidden:			true,
								hiddenTimeout:	3 * 1000,
								text:			dText,
								iconDY:			-10,
								textSettings:	{
									color:			0xffffff,
									borderColor:	0x3d395c,
									textAlign:		'center',
									autoSize:		'center',
									fontSize:		24,
									shadowSize:		1.5
								}
							}, 0, 0, -100);
							setTimeout(function():void 
							{
								quest2_3();
								SoundsManager._instance.setMusic(true);
								App.ui.systemPanel.bttnSystemMusic.alpha = 1;
							}, 4000);
						}, 2000);
							
					},1000);
				}, 1000));
			}
			
		}
		
		private static function onRefreshPosition(e:Event = null):void 
		{
			mc.x = (App.self.stage.stageWidth - 900) / 2;
			mc.y = (App.self.stage.stageHeight - 700) / 2;
			if (fader)
			{
				fader.graphics.beginFill(0x062042);
				fader.graphics.drawRect(0, 0, App.self.stage.stageWidth, App.self.stage.stageHeight);
				fader.graphics.endFill();
			}
			if (newsp)
			{
				newsp.x = (App.self.stage.stageWidth - newsp.width) / 2 + 537 / 2;
				newsp.y = (App.self.stage.stageHeight - newsp.height) / 2 + 670 / 2;
			}
			if (rectangle)
			{
				rectangle.x = (App.self.stage.stageWidth - rectangle.width) / 2;
				rectangle.y = (App.self.stage.stageHeight - rectangle.height) / 2;
			}
			if (skipButton && mc) 
			{
				skipButton.x = App.self.stage.stageWidth * 0.5 - skipButton.width * 0.5;
				skipButton.y = mc.y + 630;
			}
		}
		private static var mc:MovieClip;
		private static function movieComplete(event:Event):void 
		{
			Triggers.send(Triggers.LOAD_INTRO);
			
			mc = MovieClip(loader.content);
			mc.addEventListener(Event.ENTER_FRAME, checkIsLast);
			onRefreshPosition();
			drawDialog(1);
			addTimeout(setTimeout(function():void 
			{
				drawDialog(2);
			}, 2000));
			onRefreshPosition();
		}
		
		private static function drawDialog(number:int = 1, time:int = 6000):void
		{
			var dialogSprite:Sprite = new Sprite();
			
			var personagePreview:String = 'tutorRadio';
			var text:String = Locale.__e("flash:1481039413695");
			var back:Bitmap = Window.backing(330, 160, 50, 'tipWindowUp');
			
			if (number == 2)
			{
				text = Locale.__e("flash:1481039530413");
				
				if (App.user.sex == 'm')
					personagePreview = 'tutorBoy';
				else
					personagePreview = 'tutorGirl';
			}
			
			var personageIcon:Bitmap = new Bitmap(Window.textures[personagePreview]);
			
			personageIcon.x = back.x + back.width - personageIcon.width / 2;
			personageIcon.y = back.y + (back.height - personageIcon.height) / 2;
			if (number == 2)
				personageIcon.x = back.x - personageIcon.width / 2;
				
			addTimeout(setTimeout(function():void 
			{
				dialogSprite.addChild(back);
				
				var dialodText:TextField = Window.drawText(text, 
				{
					fontSize	:28,
					width		:260,
					textAlign	:'center',
					color		:0x51300f,
					borderColor	:0xf2e6cc,
					multiline	:true,
					wrap		:true
				});
				dialodText.x = back.x + 10;
				dialodText.y = back.y + (back.height - dialodText.height) / 2;
				if (number == 2)
				{
					dialodText.x = back.x + back.width - dialodText.width - 10;
				}
				dialogSprite.addChild(personageIcon);
				
				dialogSprite.addChild(dialodText);
				if (number == 1)
				{
					dialogSprite.x = 30;
					dialogSprite.y =  - dialogSprite.height * 2 - 60;
				}else{
					dialogSprite.x = 960 - 384 - 30;
					dialogSprite.y = - dialogSprite.height * 2;
				}
				mc.addChild(dialogSprite);
				TweenLite.to(dialogSprite, 1.2, { y:((number == 1) ? 30 : 90)});
				
				addTimeout(setTimeout(function():void 
				{
					TweenLite.to(dialogSprite, 1.2, { alpha: 0, onComplete:function():void {
						mc.removeChild(dialogSprite);
					}});
					
				}, time));
			}, 2000));
		}
		
		private static var newsp:Sprite = new Sprite();
		private static function checkIsLast(e:Event):void
		{
			if (mc.currentFrame == 400)
			{
				if (maskCont) 
				{
					maskCont.removeChildren();
					App.self.stage.removeChild(maskCont);
					maskCont = null;
				}
				Triggers.send(Triggers.SHOW_NP);
				App.self.dispatchEvent(new AppEvent(AppEvent.SHOWN_NEWSPAPER));
				fader = new Sprite();
				
				fader.graphics.beginFill(0x062042);
				fader.graphics.drawRect(0, 0, App.self.stage.stageWidth, App.self.stage.stageHeight);
				fader.graphics.endFill();
				
				App.self.faderContainer.addChildAt(fader, 0);
				App.self.faderContainer.removeChild(loader);
				
				hideSkipButton();
				var bitmap:Bitmap = new Bitmap(Window.textures.newspaper);
				
				newsp.addChild(bitmap);
				
				bitmap.x = -bitmap.width / 2;
				bitmap.y = -newsp.height / 2;
				var btmp:String = 'titleEng';
				switch(App.lang){
					case 'ru': btmp = 'titleRus'; break;
					case 'de': btmp = 'titleGer'; break;
					default: btmp = 'titleEng'; break;
				}
				var newsText:Bitmap = new Bitmap(Window.textures[btmp]);
				newsText.x = bitmap.x + (bitmap.width - newsText.width) / 2 - 15;
				newsText.y = bitmap.y + 188 - newsText.height;
				newsp.addChild(newsText);
				newsText.alpha = 0;
				
				newsp.x = (App.self.stage.stageWidth - newsp.width) / 2 + bitmap.width / 2;
				newsp.y = (App.self.stage.stageHeight - newsp.height) / 2 + bitmap.height / 2;
				
				newsp.scaleX = newsp.scaleY = .2;
				App.self.faderContainer.addChild(newsp);
				TweenLite.to(newsp, 2, { rotation:1440, scaleX:1, scaleY:1, ease:Strong.easeOut, onComplete:function():void {
					TweenLite.to(newsText, 1.4, { alpha:1 });
					App.ui.visible = true;
					App.map.visible = true;
					
					addTimeout(setTimeout(function():void 
					{
						TweenLite.to(newsp, 2, { alpha:0 ,onComplete:function():void {
							App.self.faderContainer.removeChild(newsp);
							App.self.faderContainer.removeChild(fader);
							drawCircle(hero, 50);
							Triggers.send(Triggers.SHOW_HERO);
							hero.setRest();
							if (App.user.personages.length > 0)
								App.map.focusedOn(App.user.hero, false, null, false);
							var dText:String = Locale.__e('flash:1482320101248');
							if (App.user.sex == 'f'){
								dText = Locale.__e('flash:1482498273270');
							}
							setTimeout(function():void 
							{
								hero.drawIcon(UnitIcon.DIALOG, 0, 0, {
									fadein:			true,
									hidden:			true,
									hiddenTimeout:	4 * 1000,
									text:			dText,
									iconDY:			-10,
									textSettings:	{
										color:			0xffffff,
										borderColor:	0x3d395c,
										textAlign:		'center',
										autoSize:		'center',
										fontSize:		24,
										shadowSize:		1.5
									}
								}, 0, 0, -100);
								setTimeout(function():void 
								{
									quest2_3();
									SoundsManager._instance.setMusic(true);
									App.ui.systemPanel.bttnSystemMusic.alpha = 1;
								}, 5000);
							}, 2000);
							
						}});
					}, 1800));
				}});
				mc.removeEventListener(Event.ENTER_FRAME, checkIsLast);
			}
		}
		
		private static function quest2_3():void 
		{
			if(App.self.stage)
				App.self.stage.removeEventListener(Event.RESIZE, onRefreshPosition);
			clear();
			
			hero.framesType = Personage.WALK;
			focusOnCell(98, 106);
			hero.initMove(97, 107, function():void 
			{
				hero.framesType = Personage.STOP;
				startDialog(1, function():void{
					App.user.quests.silentRead(1);
				});
			});
			
		}
		
		private static function quest2_5():void 
		{
			addTimeout(setTimeout(function():void 
			{
				addTarget(debris_johny);
			}, 500));
		}
		
		private static function quest2_6():void {
			clear();
			
			hideSkipButton();
			
			TweenLite.to(App.ui.systemPanel, 0.5, { alpha:1, y:65 } );
			TweenLite.to(App.ui.upPanel, 0.5, { y:0 } );
			TweenLite.to(App.ui.leftPanel, 0.5, { x:0 } );
			TweenLite.to(App.ui.bottomPanel, 0.5, { y:0 } );
			// ATTANTION!!!
			SoundsManager.instance.setMusic(true);
			SoundsManager.instance.addAmbience();
			SoundsManager.instance.playMusic();
			App.user.quests.skipMessages.push(6);
			
			var unit:* = Map.findUnit(143, 932);
			addTimeout(setTimeout(function():void 
			{
				targetAnyway = unit
			}, 500));
			
			setTimeout(function():void {
				hero.alpha = 1;
				
				unit.startBlink();
				unit.showPointing('top', -35, -30);
				
				App.self.addEventListener(MouseEvent.CLICK, onClick);
				App.user.quests.silentRead(128);
			}, 500);
			
			function onClick(e:MouseEvent):void {
				App.self.removeEventListener(MouseEvent.CLICK, onClick);
				App.map.mTreasure.removeChildren();
			}
		}
		
		private static function quest4_5():void 
		{
			clear();
			hero.initMove(92, 109, function():void {
				hero.framesType = Personage.STOP;
				unitTo(hero, 0);
			});
			johny.initMove(92, 102, function():void {
				johny.framesType = Personage.STOP;
				unitTo(johny, 1);
			});
			
			addTimeout(setTimeout(function():void 
			{
				openQuestWindow(4);
			
				waitTarget();
			}, 500));
			
			var fishbone:* = Map.findUnit(408, 425);
			
			targets.push(fishbone);
		}
		
		private static function quest4_6():void {
			clear();
			hero.initMove(92, 105, function():void {
				hero.framesType = Personage.STOP;
				unitTo(hero, 0);
			});
			johny.initMove(92, 102, function():void {
				johny.framesType = Personage.STOP;
				unitTo(johny, 1);
			});
			var stone:* = Map.findUnit(210, 1);
			
			addTarget(stone);
		}
		
		private static function quest5_0():void 
		{
			clear();
			openQuestWindow(5);
			waitTarget();
		}
		
		public static function quest5_1():void 
		{
			clear();
			
			hero.initMove(91, 110, function():void 
			{
				hero.framesType = Personage.STOP;
				unitTo(hero, 0);
			});
			var ruins:* = Map.findUnit(481, 727);
			targets.push(ruins);
			if (ruins)
			{
				ruins.startBlink();
				ruins.showPointing('top', -95, 10);
			}
		}
		
		public static function quest5_1_1():void 
		{
			clear();
			
			hero.initMove(91, 110, function():void 
			{
				hero.framesType = Personage.STOP;
				unitTo(hero, 0);
			});
			
			var well:* = Map.findUnit(526, 1);
			targets.push(well);
			
			if (well)
			{
				well.startBlink();
				well.showPointing('top', -145, -110);
			}
		}
		
		private static function quest5_2():void 
		{
			clear();
			openQuestWindow(5);
			
			waitTarget(function():void {
				manageWindow(ProductionWindow);
			});
		}
		private static var currentMID:uint = 0;
		private static function quest7_1():void 
		{
			clear();	
			
			addTimeout(setTimeout(function():void 
			{
				openQuestWindow(7);
				waitTarget();
			}, 500));
			
			var elodeya:* = Map.findUnit(231, 202);
			targets.push(elodeya);
		}
		
		private static var winCounter:int = 0;
		private static function quest7_2():void 
		{
			clear();
			if (winCounter <= 0)
				lastQuestWindowOpen = 0;
		
			var sponge:* = Map.findUnit(493, 728);
			addTarget(sponge);
			winCounter++;
		}
		
		private static function quest116():void 
		{
			openQuestWindow(116);
		}
		
		private static var beenInMayorWorld:Boolean; 
		public static function quest116_1():void 
		{
			Window.closeAll();
			beenInMayorWorld = false;
			var timeout:int = 30;
			
			App.self.setOnEnterFrame(enterFrame);
			
			function enterFrame(e:Event):void {
				if (App.self.windowContainer.numChildren == 0) {
					if (App.user.mode == User.OWNER) {
						if (beenInMayorWorld) {
							App.self.setOffEnterFrame(enterFrame);
						}else{
							selectMayorIcon();
						}
					}
					
					if (App.user.mode == User.GUEST && Map.ready && App.owner && App.ui && App.ui.bottomPanel) {
						if (!beenInMayorWorld && timeout < 0) 
						{
							beenInMayorWorld = true;
							quest116_3();
						}
						timeout--;
					}
				}
			}
			
			
			function selectMayorIcon():void {
				for (var i:int = 0; i < App.ui.bottomPanel.friendsPanel.friendsItems.length; i++) {
					if (App.ui.bottomPanel.friendsPanel.friendsItems[i].uid == '1') {
						var mayorIcon:* = App.ui.bottomPanel.friendsPanel.friendsItems[i];
						
						if (App.user.mode == User.GUEST) {
							if (mayorIcon.__hasGlowing) {
								mayorIcon.hideGlowing();
								mayorIcon.hidePointing();
							}
							return;
						}
						
						addTarget(mayorIcon);
						
						if (mayorIcon.__hasGlowing) return;
						mayorIcon.showGlowing();
						mayorIcon.showPointing("top", -0, 0, mayorIcon, "", null, false);
					}
				}
			}
		}
		public static function quest116_2():void 
		{
			if (App.user.mode != User.GUEST)
			{
				quest116_1();
			}
		}
		
		
		public static function quest116_3():void 
		{
			clear();
			hero.initMove(24, 23, function():void {
				hero.framesType = Personage.STOP;
				unitTo(hero, 0);
			});
			
			var crill:Building = Map.findUnit(499, 3);
			addTarget(crill)
		}
		
		//Домой от друга
		private static function quest12():void 
		{
			App.self.setOnEnterFrame(enterFrame);
			var checked:Boolean = false;
			function enterFrame(e:Event):void 
			{
				if (!checked)
				{
					if (App.user.mode == User.GUEST) 
					{
						setTimeout(function():void 
						{
							/*if (App.user.mode == User.GUEST)
							{
								Travel.goHome();
							} */
								//Travel.onVisitEvent(User.HOME_WORLD);
						}, 8000);
					}else
					{
						checked = true;
						quest12_1();
					}
				}
			}
		}
		private static var building:Building;
		private static function quest12_1():void {
			clear();
			focusOnCell(98, 106);
			openQuestWindow(12);
			waitTarget();
			
			compare(function():void 
			{
				setPoint(88, 122, 150);
				focusOnCell(88, 123, function():void 
				{
					App.map.sorted.push(building);
					App.map.sorting();
					
					setTimeout(function():void 
					{
						if (!building.formed) 
						{
							building.startMoving();
							App.map.moved = building;
							Map.X = 151;
							Map.Z = 131;
						}
						App.map.sorted.push(building);
						App.map.allSorting();
						
						// Если пользователь 8 сек. не будет ставить его, то он поставится сам
						setTimeout(function():void 
						{
							if (App.map.moved != building) return;
							building.placing(88, 0, 122);
							building.move = false;
							building = null;
						}, 8000);
					}, 200);
				}, 0.5);
			}, function():Boolean 
			{
				if (App.map.moved) 
				{
					building = App.map.moved as Building;
					
					if (building.textures) 
					{
						building.stopMoving();
						building.placing(88, 0, 122);
					}else 
					{
						building = null;
					}
				}
				return Boolean(building);
			}, 100);
		}
		
		public static function quest12_1_1():void 
		{
			focusOnCell(92, 120);
			hero.initMove(92, 120, function():void 
			{
				hero.framesType = Personage.STOP;
				unitTo(hero, 1);
			});
			addTarget(crill);
		}
		public static function quest12_1_2():void 
		{
			clear();
			
			focusOnCell(92, 120);
			
			hero.initMove(92, 120, function():void 
			{
				hero.framesType = Personage.STOP;
				unitTo(hero, 1);
				
				johny.initMove(97, 103, function():void 
				{
					johny.framesType = Personage.STOP;
				});
			});
		}
		
		private static function quest12_2():void 
		{
			clear();
			clearPoint();
			
			focusOnCell(88, 120);
			openQuestWindow(12);
			waitTarget();
			if (crill)
			{
				crill.startPointing();
				crill.startBlink();
			}
		}
		
		public static function quest12_2_1():void 
		{
			clear();
			if (crill)
			{
				crill.hidePointing();
				crill.stopBlink();
			}
			hero.initMove(86, 93, function():void 
			{
				hero.framesType = Personage.STOP;
				unitTo(hero, 0);
			});
			
			johny.initMove(97, 103, function():void 
			{
				johny.framesType = Personage.STOP;
				unitTo(johny, 1);
			});
			
			focusOnCell(86, 93);
			
			var bones:* = Map.findUnit(429, 436);
			targets.push(bones);
			if (bones)
			{
				bones.startBlink();
				bones.showPointing('top', -18, 5);
			}
			if (!bones)
			{
				if (crill)
				{
					focusOnCell(88, 123);
					crill.showPointing('top', -crill.width * 0.5 - 30, -crill.height * 0.55 - 70);
					crill.startBlink();
				}
			}
		}
		
		public static function quest12_2_2():void 
		{
			clear();
			if (crill)
			{
				crill.hidePointing();
				crill.stopBlink();
			}
			focusOnCell(89, 100);
			
			hero.initMove(90, 110, function():void 
			{
				hero.framesType = Personage.STOP;
				unitTo(hero, 0);
			});
			
			johny.initMove(97, 103, function():void 
			{
				johny.framesType = Personage.STOP;
				unitTo(johny, 1);
			});
			
			focusOnCell(90, 110);
			
			var aktinia:* = Map.findUnit(748, 330);
			
			targets.push(aktinia);
			
			if (aktinia)
			{
				aktinia.startBlink();
				aktinia.showPointing('top', -25, 20);
			}
		}
		
		public static function quest135_1():void 
		{
			clear();
			hero.initMove(90, 120, function():void 
			{
				hero.framesType = Personage.STOP;
				unitTo(hero, 0);
			});
			
			focusOnCell(90, 120);
			
			openQuestWindow(135);
			
			waitTarget(function():void {
				manageWindow(ProductionWindow);
			});
			targets.push(crill);
		}
		public static function quest135_2():void 
		{
			clear();
			hero.initMove(91, 118, function():void 
			{
				hero.framesType = Personage.STOP;
				unitTo(hero, 0);
			});
			
			focusOnCell(90, 120);
			
			openQuestWindow(135);
			
			waitTarget(function():void {
				manageWindow(ProductionWindow);
			});
			
			targets.push(crill);
		}
		
		public static function quest19_1():void 
		{
			clear();
			Window.closeAll();			
			openQuestWindow(19);
			waitTarget();
		}
		
		public static function quest19_2():void 
		{
			clear();
			Window.closeAll();
			if(lastQuestWindowOpen != 0)
				lastQuestWindowOpen = 0;
				
			openQuestWindow(19);
			waitTarget();
		}
		
		public static function quest8_1():void 
		{
			clear();
			
			openQuestWindow(8);
			waitTarget(function():void {
				manageWindow(QuestWindow);
			});
		}
		
		public static function quest8_2():void 
		{
			clear();
			
			openQuestWindow(8);
			waitTarget();
		}
		private static var isStartDialog:Boolean = false;
		public static function quest132():void 
		{
			clear();
				
			openQuestWindow(132);
			waitTarget();
			isStartDialog = true;
		}
		
		private static var field:Field;
		public static var counter:int = 0;
		public static function quest9_1():void 
		{
			clear();
			if (isStartDialog)
			{
				focusOnCell(77, 118);
				hero.initMove(77, 118, function():void 
				{
					hero.framesType = Personage.STOP;
					hero.drawIcon(UnitIcon.DIALOG, 0, 0, {
						fadein:			true,
						hidden:			true,
						hiddenTimeout:	4000,
						text:			Locale.__e('flash:1482499530633'),
						iconDY:			-10,
						textSettings:	{
							color:			0xffffff,
							borderColor:	0x3d395c,
							textAlign:		'center',
							autoSize:		'center',
							fontSize:		24,
							shadowSize:		1.5
						}
					}, 0, 0, -80);
					setTimeout(function():void 
					{
						focusOnCell(89, 113);
						hero.initMove(89, 113, function():void 
						{
							hero.framesType = Personage.STOP;
						});
						isStartDialog = false;
						quest9_1();			
						
					}, 2000);
				});
				
			}else
			{
				if (counter == 0)
				{
					quest9_1_1();
				}else
				{
					clear();
					var fields:Array = Map.findFieldUnits([76]);
					if (App.map.moved) 
					{
						fields.length--;
					}
					if (fields.length == 0)
					{
						setRect(92, 109, 4, 4);
					}else if (fields.length == 1)
					{
						setRect(96, 109, 4, 4);
					}else if (fields.length == 2)
					{
						setRect(92, 113, 4, 4);
					}else if (fields.length == 3)
					{
						setRect(96, 113, 4, 4);
					}
				}
			}
		}
		
		public static function quest9_1_1():void 
		{
			clear();
			openQuestWindow(9);
			waitTarget();
			focusOnCell(97, 106);
			
			johny.initMove(89, 110, function():void 
			{
				johny.framesType = Personage.STOP;
				unitTo(johny, 1);
			});
		}
		
		public static function quest9_2():void 
		{
			clearPoint();
			if (App.map.moved) 
			{
				addTarget(App.ui.bottomPanel.bttnCursor);
				App.ui.bottomPanel.bttnCursor.showGlowing();
				App.ui.bottomPanel.bttnCursor.showPointing('top', 0, 10, App.ui.bottomPanel.bttnCursor.parent);
			}else
			{
				quest9_2_1();
			}
			
		}
		
		public static function quest9_2_1():void 
		{
			clear();
			App.ui.bottomPanel.bttnCursor.hideGlowing();
			App.ui.bottomPanel.bttnCursor.hidePointing();
			if(lastQuestWindowOpen != 0)
				lastQuestWindowOpen = 0;
			
			setTimeout(function():void {
				openQuestWindow(9);
				waitTarget(function():void
				{
					var counter:int = 0;
					var fields:Array = Map.findFieldUnits([76]);
					for each(var fld:* in fields)
					{
						if (counter > 0)
						{
							fld.hidePointing();
							fld.hideGlowing();
							fld.stopBlink();
							fld.touch = false;
						}
						counter++;
					}
				});
				
				if(lastQuestWindowOpen != 0)
					lastQuestWindowOpen = 0;
			}, 1300);
			
			
		}
		
		public static function quest9_3():void 
		{
			clear();
			
			openQuestWindow(9);
			waitTarget(function():void
			{
				var counter:int = 0;
				var fields:Array = Map.findFieldUnits([76]);
				for each(var fld:* in fields)
				{
					if (counter > 0)
					{
						fld.hidePointing();
						fld.hideGlowing();
						fld.stopBlink();
						fld.touch = false;
					}
					
					if (!fld.plant)
					{
						fld.hidePointing();
						fld.hideGlowing();
						fld.stopBlink();
						fld.touch = false;
					}
					
					if(fld.plant)
						counter++;
				}
			});
			
			App.ui.bottomPanel.clearCursor();
			
		}
		
		public static function quest59():void 
		{
			clear();
			openQuestWindow(59);
			waitTarget();
		}
		public static function quest162():void 
		{
			clear();
			setTimeout( function():void{
				App.user.quests.tutorial = false;
				App.ui.upPanel.addBonusOnline();
			}, 500);
			//Window.closeAll();
			
			setTimeout( function():void{
				if(App.ui.leftPanel.questsPanel.icons.length > 0){
					App.ui.leftPanel.questsPanel.icons[0].showGlowing();
					App.ui.leftPanel.questsPanel.icons[0].showPointing('right', -20, 0, App.ui.leftPanel.questsPanel.icons[0].parent); // focusedOnQuest(59);
				}
				if(App.ui.leftPanel.questsPanel.icons.length > 1){
					App.ui.leftPanel.questsPanel.icons[1].showGlowing();
					App.ui.leftPanel.questsPanel.icons[1].showPointing('right', -4, 0, App.ui.leftPanel.questsPanel.icons[0].parent); 
				}
			}, 60);
		}
	}
}
