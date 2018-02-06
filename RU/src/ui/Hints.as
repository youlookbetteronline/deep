package ui
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.utils.setTimeout;
	import flash.utils.Timer;
	import units.Unit;
	import wins.Window;
	public class Hints
	{
		public static const ADD_MATERIAL:int 		= 1;
		public static const ADD_EXP:int 			= 2;
		public static const REMOVE_MATERIAL:int 	= 3;
		public static const ALERT:int 				= 4;
		public static const ENERGY:int 				= 5;
		public static const TEXT_RED:int			= 6;
		public static const BANKNOTES:int			= 7;
		public static const GEM:int			        = 8;
		public static const COINS:int			    = 9;
		
		public static var delay:uint				= 500;
		public static var flightDist:int			= -80;
		
		public static function getSettings(ID:int):Object {
			
			var settings:Object = {}
			switch(ID)
			{
				// материалы
				case Hints.ADD_MATERIAL:
					settings = {
							color				:0xf6f4c4,// 0xFFDC39,
							borderColor 		:0x372322// 0x6D4B15
						};
					break;
					// + опыт
				case Hints.ADD_EXP:
					settings = {
							color				:0xf8fd7c,// 0xCC99FF, 
							borderColor 		:0x684913// 0x330000
						};
					break;
					// - монеты
				case Hints.REMOVE_MATERIAL:
					settings = {
						//color				:0xfedb38,// 0xD21E27,
						//borderColor 		:0x6d4b15// 0x510000
						color				:0xc5ecfd,// 0xFFDC39,
						borderColor 		:0x262478// 0x6D4B15
					};
					break;
					// alert
				case Hints.ALERT:
					settings = {
						color				: 0xeb4e2f,//0xE4454E,
						borderColor 		: 0x5f231b//0x510000
					};
					break;
					// energy
				case Hints.ENERGY:
					settings = {
						color				:0xb4e8f5,// 0x6FB7D2,
						borderColor 		:0x00415c// 0x142F8B
					};
					break;
					// energy
				case Hints.TEXT_RED:
					settings = {
						color				: 0xD21E27,
						borderColor 		: 0x510000
					};
					break;
					// add banknotes	
				case Hints.BANKNOTES:
					settings = {
						color				: 0x7fb4fa,//0xA3D637,
						borderColor 		: 0x382662
					};
					break;	
				case Hints.GEM:
					settings = {
						color				: 0xc5ecfd,//0xc7f78e,//0xA3D637,
						borderColor 		: 0x262478//0x40680b
					};
					break;	
				case Hints.COINS:
					settings = {
						color				: 0xfcd619,//0xA3D637,
						borderColor 		: 0x733504
					};
					break;	
			}
			
				settings["borderSize"] 		= 4;
				settings["fontBorderGlow"] 	= 4;
				
				return settings;
		}
		
		public static function plus(sID:uint, count:uint, position:Point, _delay:Boolean = false, layer:Sprite = null, timeOut:int = 0):void
		{
			var settings_Numbs:Object;
			var settings_Text:Object;
			var hasTitle:Boolean = true;
						
			switch(App.data.storage[sID].view)
			{
				case "diamond":
					settings_Numbs 	= getSettings(Hints.GEM);
					settings_Text	= getSettings(Hints.GEM);
					break;
				case "Material":
					settings_Numbs 	= getSettings(Hints.ADD_MATERIAL);
					settings_Text	= getSettings(Hints.ADD_MATERIAL);
					break;
				case "energy":
				//	hasTitle = false;
					settings_Numbs 	= getSettings(Hints.ENERGY);
					settings_Text	= getSettings(Hints.ENERGY);
					break;
				case "perl":
				//	hasTitle = false;
					settings_Numbs 	= getSettings(Hints.COINS);
					settings_Text 	= getSettings(Hints.COINS);
					break;
				case "experience":
				//	hasTitle = false;
					settings_Numbs 	= getSettings(Hints.ADD_EXP);
					settings_Text 	= getSettings(Hints.ADD_EXP);
					break;
				case "ether":
				//	hasTitle = false;
					settings_Numbs 	= getSettings(Hints.ENERGY);
					settings_Text 	= getSettings(Hints.ENERGY);
					break;
				default:
					settings_Numbs 	= getSettings(Hints.ADD_MATERIAL);
					settings_Text 	= getSettings(Hints.ADD_MATERIAL);
					break
			}
			
			settings_Numbs['text'] =  "+" + count;
			//settings_Numbs['icon'] =  App.data.storage[sID].view;
			if(hasTitle)
				settings_Text['text'] =  App.data.storage[sID].title;
			
			settings_Numbs['fontSize'] = 24;
			settings_Numbs['textAlign'] = 'right';
			settings_Text['fontSize'] = 16;
			settings_Text['textAlign'] = 'left';
			
			if (timeOut > 0)
				setTimeout(function():void {new Hint([settings_Numbs, settings_Text], _delay, position, layer); }, timeOut);
			else
				new Hint([settings_Numbs, settings_Text], _delay, position, layer);
		}
		
		public static function minus(sID:uint, price:uint, position:Point, _delay:Boolean = false, layer:Sprite = null, timeOut:int = 0,params:Object = null):void
		{
			if (price < 1)
				return;
			var settings_Numbs:Object;
			var settings_Text:Object;
			if(!Window.isOpen)
				position = new Point(App.user.hero.x * App.map.scaleX + App.map.x, (App.user.hero.y - App.user.hero.height + 50) * App.map.scaleY + App.map.y);
			
			if (params && params.hasOwnProperty('personage'))
				position = new Point(params.personage.x * App.map.scaleX + App.map.x, (params.personage.y - params.personage.height + 50) * App.map.scaleY + App.map.y);
			switch(sID)
			{
				case Stock.FANTASY:
					settings_Numbs 	= getSettings(Hints.ENERGY);
					settings_Text	= getSettings(Hints.ENERGY);
					break;
				case Stock.COINS:
					settings_Numbs 	= getSettings(Hints.COINS);
					settings_Text 	= getSettings(Hints.COINS);
					break;
				case Stock.FANT:
					settings_Numbs 	= getSettings(Hints.GEM);
					settings_Text 	= getSettings(Hints.GEM);
					break;
				case Stock.EXP:
					settings_Numbs 	= getSettings(Hints.ADD_EXP);
					settings_Text 	= getSettings(Hints.ADD_EXP);
					break;
				default:
					settings_Numbs 	= getSettings(Hints.REMOVE_MATERIAL);
					settings_Text 	= getSettings(Hints.REMOVE_MATERIAL);
					break
			}
			
			settings_Numbs['text'] =  "-" + price;
			settings_Numbs['icon'] =  App.data.storage[sID].view;
			//if (sID != Stock.COINS) 
			//{
				//settings_Text['text'] =  App.data.storage[sID].title;
			//}
			
			
			settings_Numbs['fontSize'] = 24;
			settings_Numbs['textAlign'] = 'right';
			settings_Text['fontSize'] = 16;
			settings_Text['textAlign'] = 'left';
			
			if (timeOut > 0)
				setTimeout(function():void {new Hint([settings_Numbs, settings_Text], _delay, position, layer); }, timeOut);
			else
			 new Hint([settings_Numbs, settings_Text], _delay, position, layer);
		}
		
		public static function text(text:String, type:int, position:Point, _delay:Boolean = false, layer:Sprite = null):void
		{
			var settings_Text:Object = getSettings(type);
					
			settings_Text['text'] =  text;
			settings_Text['fontSize'] = 16;
			settings_Text['textAlign'] = 'left';
			
			new Hint([settings_Text], _delay, position, layer);
		}
		
		public static function buy(target:*):void
		{
			if (!(target is Unit)) return;
			
			var counter:int = 0;
			var price:Object = Payments.itemPrice(target.sid);
			
			for (var sid:* in price) {
				var point:Point = new Point(target.x*App.map.scaleX + App.map.x, target.y*App.map.scaleY + App.map.y);
				Hints.minus(sid, price[sid], point, false, null, counter);
				counter += 500;
			}
		}
		
		public static function plusAll(data:Object, position:Point, layer:Sprite):void
		{
			var count:uint = 0;
			var counter:int = 0;
			var sID:*;
			
			for(sID in data){    
				count = data[sID];
				Hints.plus(sID, count, position, false, layer, counter);
				counter += 500;
			}
		}

	}
}

	import com.greensock.easing.Strong;
	import core.Load;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import com.greensock.*
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.Timer;
	import wins.Window;
	import ui.Hints;
	
	internal class Hint extends Sprite
	{
		private var container:Sprite = new Sprite();
		private var bitmap:Bitmap;
		private var hintsLayer:Sprite;
		private var timer:Timer
		private var position:Point
		
		public function Hint(labels:Array, delay:Boolean, position:Point, layer:Sprite = null)
		{
			this.position = position;
			
			if (layer) 
				hintsLayer = layer;
			else	
				hintsLayer = App.self.tipsContainer;
				
			createLabels(labels);
			createIcon(labels);
			draw();
			
			//if (delay == false)
			//{
				//init();
			//}
			//else
			if (!labels[0].icon)
			{
				timer = new Timer(Hints.delay, 1);
				timer.addEventListener(TimerEvent.TIMER, onComplete);
				timer.start();
			}
			mouseEnabled = false;
			mouseChildren = false;
		}
		
		private function init():void
		{
			move();
			this.x = position.x;
			this.y = position.y;
			hintsLayer.addChild(this);
		}
		
		private function draw():void
		{
			var bitmapData:BitmapData = new BitmapData(container.width, container.height, true, 0x00000000);
			var mt:Matrix = new Matrix();
			mt.translate(0, container.height/2);
			bitmapData.draw(container, mt);
			bitmap = new Bitmap(bitmapData);
			bitmap.smoothing = true;
			addChild(bitmap);
			bitmap.x = -bitmap.width / 2;
			container = null;
		}
		
		private function move():void
		{
			TweenLite.to(bitmap, 4, { y:Hints.flightDist, onComplete:moveComplete, ease:Strong.easeOut } );
			TweenLite.to(this, 2, { alpha:0, ease:Strong.easeIn } );
		}	
		
		private function onComplete(e:TimerEvent):void
		{
			timer.removeEventListener(TimerEvent.TIMER, onComplete);
			init();
		}
		
		private var X:int = 0;
		private function createLabels(labels:Array):void
		{
			//var X:int = 0;
			var Y:int = 0;
			for each(var label:Object in labels)
			{
				var textLabel:TextField = Window.drawText(
									label.text, 
									label);
					textLabel.x = X;				
					
					textLabel.width  = textLabel.textWidth + 4;
					textLabel.height = textLabel.textHeight + 4;
					
					textLabel.y = -textLabel.height / 2;
					
				container.addChild(textLabel);
				X += textLabel.width;
			}
		}
		
		private var preloader:Preloader;
		private function createIcon(labels:Array):void
		{
			var Y:int = 0;
			for each(var label:Object in labels)
			{
				if (label.icon && container)
				{
					Load.loading(
						Config.getIcon('Material', label.icon),
						function(data:Bitmap):void
						{
							var bitmap:Bitmap = new Bitmap(data.bitmapData);
							Size.size(bitmap, 26, 26);
							bitmap.smoothing = true;
							bitmap.x = X;
							bitmap.y = -bitmap.height / 2;
							if (container)
							{
								container.addChild(bitmap);
							}
							timer = new Timer(Hints.delay, 1);
							timer.addEventListener(TimerEvent.TIMER, onComplete);
							timer.start();
						}
					);
				}
			}
		}
		
		private function moveComplete():void
		{
			if(hintsLayer.contains(this)){
				hintsLayer.removeChild(this);
			}
		}
	}

