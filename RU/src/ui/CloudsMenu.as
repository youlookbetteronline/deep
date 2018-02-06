package ui 
{
	import astar.AStarNodeVO;
	import buttons.ImageButton;
	import buttons.ImagesButton;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.utils.clearInterval;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.setInterval;
	import units.Animal;
	import units.AnimationItem;
	import units.Field;
	import units.Tree;
	import wins.SimpleWindow;
	import wins.Window;
	/**
	 * ...
	 * @author ...
	 */
	public class CloudsMenu extends LayerX 
	{
		public static var isMove:Boolean = false;
		
		public var settings:Object = {scaleIcon:0.6};
		public var target:*;
		public var iconBttn:ImagesButton;
		public var sID:int;
		public var progressContainer:Sprite = new Sprite();
		public var slider:Sprite = new Sprite();
		public var startTime:int;
		public var endTime:int;
		public var isBttnOff:Boolean;
		
		protected var underBtmData:BitmapData;
		protected var isProgress:Boolean;
		protected var stopedProgress:Boolean;
		
		private var container:Sprite = new Sprite();
		private var onEvent:Function;
		private var checkStock:Boolean;
		private var isDispose:Boolean;
		private var isEff:Boolean;
		private var icon_dX:int = 0;
		private var icon_dY:int = 0;
		private var back_dY:int = 0;
		private var interval:int = 0;
		private var startInterval:int = 0;
		
		public function CloudsMenu(onEvent:Function, target:*, sID:int, settings:Object = null) 
		{
			if (settings != null) {
				for (var obj:* in settings) {
					if(settings[obj] != null)
						this.settings[obj] = settings[obj];
				}
			}
			this.target = target;
			this.onEvent = onEvent;
			this.sID = sID;
			
			if (sID != 2 && !this.settings.scaleIcon)
			{
				if (!sID == App.data.storage[App.user.worldID].cookie[0]) 
				{
					settings.scaleIcon = 1;
				}else 
				{
					settings.scaleIcon = 1;
				}
				
			};
		}
		
		private function addEnergy():void {
			var aime:AnimationItem = new AnimationItem();
			addChild(aime);
			aime.scaleX = aime.scaleY = 1;
		}
	
		public function create(nameBtmData:String, backgroundIsNeeded:Boolean = true):void
		{
			if (nameBtmData == 'productBacking2') {
				icon_dX = 0;
				icon_dY = 0;
			}else if (nameBtmData == "productBacking"){
				icon_dX = 0;
				icon_dY = -8;
			}
			
			icon_dY = -5;
			
			underBtmData = Window.textures[nameBtmData];
			
			if (!backgroundIsNeeded) 
			{
				underBtmData = new BitmapData(20, 20, true, 0x00000000);
			}
			addProgressBar();

			Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onLoadIcon);
		}
		
		public function addProgressBar():void
		{
			var bgProgress:Bitmap = new Bitmap(Window.textures.productionProgressBarBacking);
			progressContainer.addChild(bgProgress);
			bgProgress.x = -bgProgress.width / 2;
			bgProgress.y = -16;
			progressContainer.addChild(slider);
			slider.x = bgProgress.x + 3;
			slider.y = bgProgress.y + 3;
			
			addChild(progressContainer);
			progressContainer.visible = false;
		}
		
		public function onLoadIcon(obj:Object):void 
		{
			if (isDispose) return;
			iconBttn = new ImagesButton( underBtmData, obj.bitmapData, { 
				description		:"",
				params			: { },
				building:(settings.building)?true:false
			}, settings.scaleIcon);
			
			if (settings.scaleBttn){
				iconBttn.bitmap.scaleX = iconBttn.bitmap.scaleY = settings.scaleBttn;
				iconBttn.bitmap.filters = [new GlowFilter(0x0a4069, .7, 5, 5, 2)];
			}
			
			iconBttn.name = 'iconMenu';
			iconBttn.addEventListener(MouseEvent.MOUSE_DOWN, onClick);
			iconBttn.addEventListener(MouseEvent.MOUSE_MOVE, mMove);
			position();
			
			if (stopedProgress) {
				doIconEff();
			}
			
			addChild(iconBttn);
			
			if (settings.offIcon)
				iconBttn.visible = false;
		}
		public function position():void {
			if (!iconBttn) return;
			iconBttn.x = -underBtmData.width * iconBttn.bitmap.scaleX / 2;
			iconBttn.y = -underBtmData.height + (underBtmData.height - underBtmData.height * iconBttn.bitmap.scaleX) + back_dY;
			iconBttn.iconBmp.x = iconBttn.bitmap.x + (iconBttn.bitmap.width - iconBttn.iconBmp.width) / 2 + icon_dX * iconBttn.bitmap.scaleX;
			iconBttn.iconBmp.y = iconBttn.bitmap.y + (iconBttn.bitmap.height - iconBttn.iconBmp.height) / 2 + icon_dY * iconBttn.bitmap.scaleX;
		}
		
		public function changeUnderBitmapData(nameBtmData:String, isOff:Boolean):void
		{
			isBttnOff = isOff;
			underBtmData = Window.textures[nameBtmData];
			if (iconBttn) {
				iconBttn.bitmap.bitmapData = underBtmData;
			}
		}
		
		public function setProgress(_startTime:int, _endTime:int):void
		{
			startTime = _startTime;
			endTime = _endTime;
			App.self.setOnTimer(progress);
			progressContainer.visible = true;
			isProgress = true;
			back_dY = -18;
			position();
			
			if (iconBttn)
				iconBttn.buttonMode = iconBttn.mouseEnabled = false;
		}
		
		public function stopProgress():void
		{
			App.self.setOffTimer(progress);
			if (!progressContainer)
				return;
			isProgress = false;
			stopedProgress = true;
			progressContainer.visible = false;
			if (iconBttn) 
				iconBttn.buttonMode = iconBttn.mouseEnabled = true;
			doIconEff();
		}
		
		public function doIconEff():void
		{
			if (stopedProgress) 
			{
				if (iconBttn) 
				{
					iconBttn.y += 30;	
				}	
			}
			if(iconBttn)
				iconBttn.visible = true;
				
			if (settings.offIcon)
				settings.offIcon = false;
			
			var _scale:Number = 0.8;
			var _effScale:Number = 0.7;
			if (target is Field){
				_scale = 0.5;
				_effScale = 0.6;
			}
			if (target is Animal){
				_scale = 0.5;
				_effScale = 0.6;
			}
			
			if (sID == Stock.COINS) {
				_scale = 0.5;
			}
			
			if (settings.scaleIcon)
				_scale = settings.scaleIcon;
				
				
			if (settings.scaleDone)
				_scale = settings.scaleDone;
			
			if (iconBttn && !isEff) {
				isEff = true;
				
				if (target is Tree) {
					_effScale = 0.7;
				}
				addGlow(Window.textures.glowingBackingNew, 0, _effScale - .3);
				iconBttn.iconScale = _scale;
				iconBttn.bitmap.visible = false;
			}
		}
		
		public function addGlow(bmd:BitmapData, layer:int, scale:Number = 1):void
		{
			var btm:Bitmap = new Bitmap(bmd);
			container = new Sprite();
			container.addChild(btm);
			btm.scaleX = btm.scaleY = scale;
			btm.smoothing = true;
			btm.x = -btm.width / 2;
			btm.y = -btm.height / 2;
			
			addChildAt(container, layer);
			
			isEff = true;
			container.mouseChildren = false;
			container.mouseEnabled = false;
			
			container.x = iconBttn.x + iconBttn.width / 2;
			container.y = iconBttn.y + iconBttn.height / 2;
			
			this.startGlowing();
			
			var that:* = this;
			startInterval = setInterval(function():void {
				clearInterval(startInterval);
				interval = setInterval(function():void {
					that.pluck();
				}, 10000);
			}, int(Math.random() * 3000));
		}
		
		protected function progress():void 
		{
			var totalTime:int = endTime-startTime;
			var curTime:int = endTime - App.time;
			var timeForSlider:int = totalTime - curTime;
			
			if (timeForSlider < 0) timeForSlider = 0;
			
			UserInterface.slider(slider, timeForSlider, totalTime, "productionProgressBar", true);
			if (timeForSlider >= totalTime) {
				stopProgress();
			}
		}
		
		private function mMove(e:MouseEvent):void {
			App.map.untouches();
			e.stopImmediatePropagation();
			e.stopPropagation();
		}
		
		public function onClick(e:MouseEvent):void
		{
			if (App.user.quests.tutorial) {
				if (App.user.quests.currentTarget == target) {
					target.click();
					//App.tutorial.hide();
					target.hideGlowing();
				}
				return;
			}
			if (target && target['coords'])
			{
				if (App.user.useSectors && target.hasOwnProperty('homeCoords'))
				{
					var node1:AStarNodeVO = App.map._aStarNodes[target.homeCoords.x][target.homeCoords.z];
					
					if (!node1.sector.open)
					{
						new SimpleWindow( {
							title:Locale.__e("flash:1474469531767"),
							label:SimpleWindow.ATTENTION,
							text:Locale.__e('flash:1495607052980') + " " + target.info.title,
							confirm:function():void
							{
								node1.sector.fireNeiborsReses();
							}
						}).show();
						return;
					}
				}
			}
			
			if (onEvent != null && !target.ordered) {
				onEvent();
			}
				
			e.stopPropagation();
			e.stopImmediatePropagation();
		}
		
		public function show():void
		{
			target.addChild(this);
		}
		
		public function dispose():void
		{
			clearInterval(interval);
			clearInterval(startInterval);
			
			isDispose = true;
			if (iconBttn) {
				this.removeEventListener(MouseEvent.MOUSE_DOWN, onClick);
				this.removeEventListener(MouseEvent.MOUSE_MOVE, mMove);
				iconBttn.dispose();
				iconBttn = null;
			}
			
			App.self.setOffTimer(progress);
			
			if (slider && slider.parent && slider.parent.contains(slider)) 
				slider.parent.removeChild(slider);
			slider = null;
			underBtmData = null;
			
			if(progressContainer && contains(progressContainer))removeChild(progressContainer);
				progressContainer = null;
			
			onEvent = null;
			
			if (this && this.parent) this.parent.removeChild(this);
			target = null;
			clearVariables();
		}
		
		public function clearVariables():void {
			var self:* = this;
			var description:XML = describeType(this);
			var variables:XMLList = description..variable;
			for each(var variable:XML in variables) {
				var ss:String = variable.@type;
				if(variable.@type == '*')
				{
					self[variable.@name] = null;
					continue;
				}
				var classType:Class
				try{
					classType = getDefinitionByName(variable.@type) as Class;
				}catch (e:Error){
					self[variable.@name] = null;
					continue;
				}
				switch(classType){
					case Sprite:
						if (self[variable.@name]){
							self[variable.@name].removeChildren();
							self[variable.@name] = null;
						}
						break;
					default:
						self[variable.@name] = null;
				}
			}
		}
	}
}