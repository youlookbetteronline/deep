package ui 
{
	import buttons.MoneyButton;
	import com.greensock.TweenLite;
	import core.Numbers;
	import core.Size;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.text.TextField;
	import flash.utils.clearInterval;
	import units.Animal;
	import wins.Window;
	
	public class AnimalCloud extends CloudsMenu
	{
		public static const MODE_NEED:int = 1;
		public static const MODE_DONE:int = 2;
		public static const MODE_CRAFTING:int = 3;
		public static const MODE_HUNGRY:int = 4;
		public static const MODE_NEED_WATER:int = 5;

		private var mode:int;		
		private var countTxt:TextField;		
		private var dellOnClick:Boolean = false;		
		private var countItems:int;
		private var level:int = 0;
		private var enough:Boolean = false;
		private var fID:int;
		private var closeInterval:int;
		
		public var speedUp:MoneyButton;
		
		public function AnimalCloud(onEvent:Function, target:*, sID:int, _mode:int, _settings:Object = null) 
		{			
			fID = sID;
			mode = _mode;
			this.level = _settings.level;
			switch(mode) 
			{
				case MODE_NEED_WATER:
				case MODE_DONE:
					if (App.data.storage[sID].hasOwnProperty('devel') && App.data.storage[sID].level != null)
					{
						if (level == 0)
						{
							for (var sde:* in App.data.storage[sID].outs)
								{
									sID = sde;
									break;							
								}
						}
						else
						{
							for (var sdev:* in App.data.storage[sID].devel.req[level].out)
							{
								sID = sdev;
								break;
							}
						}
					}
					else
					{
						for (var sd:* in App.data.storage[sID].outs)
						{
							if (((sd == Stock.COINS || sd == 175) && App.self.getLength(App.data.storage[sID].outs) > 1))
							{
								
							}else 
							{
								sID = sd;
								break;	
							}						
						}
					}
				break;
			case MODE_NEED:
					
					if (App.data.storage[sID].hasOwnProperty('devel') && App.data.storage[sID].level != null)
					{
						if (level == 0)
						{
							for (var sdev0:* in App.data.storage[sID].require)
							{
								sID = sdev0;
								break;
							}
						}
						else
						{
							if (target && target.fneed)
							{
								sID = Numbers.firstProp(target.fneed).key;
							}
							else
							{
								for (var sdev2:* in App.data.storage[sID].devel.req[level].fneed)
								{
									sID = sdev2;
									break;
								}
							}
							
						}
					}
					else
					{
						if (target.fneed && (Numbers.countProps(target.info.require) > 1))
							sID = Numbers.firstProp(target.fneed).key;
						else
						{
							for (var sd2:* in App.data.storage[sID].require)
							{
								sID = sd2;
								break;
							}
						}
					}
				break;
			}
			super(onEvent, target, sID, _settings);
			
			if (target.type == 'Fplant' && mode == MODE_NEED || mode == MODE_CRAFTING)
			{
				App.self.addEventListener(AppEvent.ON_MAP_CLICK, onEventClose);
				App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onChangeStock);
			}
			
			if (mode == MODE_CRAFTING)
			{
				drawBttn();
			}
		}
		
		private function onChangeStock(e:AppEvent):void 
		{
			drawCount();
		}
		
		private function onEventClose(e:AppEvent = null):void 
		{
			clearInterval(closeInterval);			
			TweenLite.to(this, 0.5, {alpha:0, onComplete:function():void{if(target && target.cloudAnimal)target.cloudAnimal = null; dispose();}});
		}
		
		override public function create(nameBtmData:String, backgroundIsNeeded:Boolean = true):void
		{
			super.create(nameBtmData, true);
		}
		
		override public function onLoadIcon(obj:Object):void 
		{
			if (target == null) return;
			
			if (mode == MODE_HUNGRY)
			{
				var objHungry:Object = { };
				settings.scaleIcon = .5;
				super.onLoadIcon(objHungry);
				//Size.size(iconBttn, 55, 55); 
				iconBttn.iconBmp.y -= 8;
			}else{
				
				if(mode == MODE_NEED){
					//settings.scaleIcon = .35;
					super.onLoadIcon(obj);
					//Size.size(iconBttn, 55, 55); 
					iconBttn.iconBmp.y -= 4;
				}else{
					super.onLoadIcon(obj);
				}
				drawCount();
				if (mode == MODE_DONE)
					doIconEff();
				if (mode == MODE_NEED_WATER) 
				{
					var colorTransform:ColorTransform = new ColorTransform(0.5, 0.5, 0.5);
					//Size.size(iconBttn, 55, 55); 
					iconBttn.iconBmp.y += 5;
				}					
				if (mode == MODE_CRAFTING)
				{
					iconBttn.visible = false;
					speedUp.x = progressContainer.x - speedUp.bottomLayer.width / 2;
					speedUp.y = progressContainer.y - speedUp.height - 19;
				}
			}
		}
		
		private function drawBttn():void 
		{
			speedUp = new MoneyButton( {
				title:'',
				countText:'',
				width:88,
				height:44,
				shadow:true,
				fontCountSize:30,
				fontSize:16,
				type:"green",
				radius:14,
				bgColor:[0xa8f84a, 0x74bc17],
				bevelColor:[0xcdfb97, 0x5f9c11],
				fontBorderColor:0x4d7d0e,
				fontCountBorder:0x40680b
			});
			
			addChild(speedUp);
			speedUp.textLabel.visible = false;
			speedUp.coinsIcon.x = 0;
			speedUp.countLabel.x = speedUp.coinsIcon.x + speedUp.coinsIcon.width + 1;
			speedUp.countLabel.y += 1;			
			speedUp.addEventListener(MouseEvent.CLICK, onAcselereatEvent);
			updateSpeedUpBttn();
		}
		
		private function onAcselereatEvent(e:MouseEvent):void 
		{
			target.onBoostEvent(priceBttn);
		}
		
		public function drawCount():void
		{
			if (!iconBttn)
				return;
			if (mode == MODE_NEED) {
				
				if (countTxt && contains(countTxt)) 
					removeChild(countTxt);
				countTxt = null;
				
				var count:int;
				
				if (App.data.storage[fID].hasOwnProperty('devel') && App.data.storage[fID].level != null && !target.fneed)
				{
					if (level == 0)
					{
						for (var outdev0:* in App.data.storage[fID].require) 
						{ 
							count = App.data.storage[fID].require[outdev0]
							break;
						}
					}
					else
					{
						for (var outdev:* in App.data.storage[fID].devel.req[level].fneed)
						{
							count = App.data.storage[fID].devel.req[level].fneed[outdev];
							break;
						}
					}
				}
				else
				{
					if (target.fneed)
						count = Numbers.firstProp(target.fneed).val;
						
					else
					{
						for (var out:* in App.data.storage[fID].require) { 
							count = App.data.storage[fID].require[out]
							break;
						}
					}
				}
				var settings:Object = {
					color:0xffffff,
					borderColor:0x1d2740,
					textAlign:"center",
					autoSize:"left",
					fontSize:24
				}
				var _req:Object = App.data.storage[fID].require;
				if (App.data.storage[fID].hasOwnProperty('devel') && level != 0)
				{
					if (target.fneed)
						_req = target.fneed;
					else
						_req = App.data.storage[fID].devel.req[level].fneed
					
				}
				else if (target.fneed && (Numbers.countProps(target.info.require) > 1))
					_req = target.fneed;
				if (!App.user.stock.checkAll(_req)) {
					settings['color'] = 0xef7563;
					settings['borderColor'] = 0x623126;
				}				
				countTxt = Window.drawText('x' + String(count), settings);
				countTxt.x = iconBttn.x + iconBttn.width - countTxt.textWidth - 10;
				countTxt.y = iconBttn.y + iconBttn.height - countTxt.textHeight - 18;
				addChild(countTxt);
			}
			
			iconBttn.tip = function():Object { return { title:App.data.storage[sID].title, text:App.data.storage[sID].description }; }			
		}
		
		override public function setProgress(_startTime:int, _endTime:int):void
		{
			if (App.user.mode == User.GUEST)
				return;
			
			super.setProgress(_startTime, _endTime);
			updateSpeedUpBttn();
		}
		
		private var priceSpeed:int = 0;
		private var priceBttn:int = 0;
		
		override protected function progress():void 
		{
			super.progress();
			updateSpeedUpBttn();
		}
		
		private function updateSpeedUpBttn():void 
		{
			priceSpeed = App.data.storage[sID].speedup;
			
			if (speedUp && priceBttn != priceSpeed && priceSpeed != 0) {
				priceBttn = priceSpeed;
				speedUp.count = String(priceSpeed);
			}
		}
		
		override public function stopProgress():void
		{
			super.stopProgress();
			if (speedUp) {
				removeBttn();
			}
		}
		
		private function removeBttn():void 
		{
			speedUp.removeEventListener(MouseEvent.CLICK, onAcselereatEvent);
			speedUp.dispose();
			speedUp = null;
		}
		
		override public function dispose():void
		{
			clearInterval(closeInterval);
			if (mode == MODE_NEED || mode == MODE_CRAFTING) 
			{
				App.self.removeEventListener(AppEvent.ON_MAP_CLICK, onEventClose);
				App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, onChangeStock);
			}
			if (speedUp) {
				removeBttn();
			}
			super.dispose();
			if (countTxt && contains(countTxt)) removeChild(countTxt);
			countTxt = null;
		}
		
		public function getMode():int
		{
			return mode;
		}		
	}
}