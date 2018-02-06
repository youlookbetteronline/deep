package wins 
{
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	/**
	 * ...
	 * @author ...
	 */
	public class TimerMapsWindow extends Window 
	{
		private var _item:TimerMap;
		private var _listSprite:Sprite = new Sprite();
		
		
		public function TimerMapsWindow(settings:Object=null) 
		{
			settings['content']			= Travel.synopticMaps;		 	
			settings['hasPaginator'] 	= false;
			settings['background'] 		= 'paperScroll';
			settings['width'] 			= 445;
			settings['height'] 			= 160 + (85 * settings.content.length);
			settings['fontColor']		= 0xffffff;
			settings['fontBorderColor'] = 0x085c10;
			settings['borderColor'] 	= 0x085c10;
			settings['shadowColor'] 	= 0x085c10;
			settings['fontSize'] 		= 40;
			settings['fontBorderSize'] 	= 2;
			settings['shadowSize'] 		= 2;
			settings['title'] 			= Locale.__e('flash:1505815918561');
			super(settings);
		}
		
		override public function drawTitle():void
		{
			super.drawTitle();
			drawRibbon();
			titleLabel.y += 20;
			titleBackingBmap.y += 18;
		}
		
		override public function drawExit():void
		{
			super.drawExit();
			exit.x -= 5;
			exit.y -= 13;
		}
		
		override public function drawBody():void
		{
			var separator:Bitmap = Window.backingShort(330, "dividerLine");
			separator.x = (settings.width - separator.width) / 2;
			separator.y = 55;
			
			var dY:int = 10 + (80 * settings.content.length);
			var background:Shape = new Shape();
			background.graphics.beginFill(0xfef8e6, .7);
			background.graphics.drawRect(0, 0, 310, dY);
			background.y = 55;
			background.x = (settings.width - background.width) / 2;
			background.graphics.endFill();
			background.filters = [new BlurFilter(15, 0, 4)];
			
			var separator2:Bitmap = Window.backingShort(330, "dividerLine");
			separator2.x = (settings.width - separator2.width) / 2;
			separator2.y = dY + 55;
			
			bodyContainer.addChild(background);
			bodyContainer.addChild(separator);
			bodyContainer.addChild(separator2);
			
			titleLabel.y += 10;
			exit.y -= 20;
			var Y:int = 0;
			for (var i:int = 0; i < settings.content.length; i++)
			{
				_item = new TimerMap(settings.content[i]);
				_listSprite.addChild(_item);
				_item.y = Y;
				Y += 85;
			}
			_listSprite.x = 50;
			_listSprite.y = 75;
			
			bodyContainer.addChild(_listSprite);
		}
	}
}

import core.Load;
import core.Numbers;
import core.Size;
import flash.display.Bitmap;
import flash.text.TextField;
import wins.Window;

internal class TimerMap extends LayerX
{
	private var _sid:int;
	private var _icon:Bitmap = new Bitmap();
	private var _title:TextField;
	private var _needHours:String;
	private var _needDay:String;
	private var _needMounth:String;
	
	private var serverDate:Date
	private var dateOffset:int = 0;	
	private var currDay:int;
	private var currMounth:int;
	private var currYear:int;
	private var land:*;
	
	public function TimerMap(sid:int)
	{
		serverDate = new Date();
		serverDate.setTime(App.time * 1000);
		currDay = serverDate.getDate();
		currMounth = serverDate.getMonth() + 1;
		currYear = serverDate.getFullYear();
		this._sid = sid;
		this.land = App.data.storage[sid];
		
		tip = function():Object 
			{
				var _bitmap:Bitmap = new Bitmap();
				var _bitmap2:Bitmap = new Bitmap();
				if (land.charge)
				{
					var tipContent:Array = [];
					tipContent = Numbers.objectToArraySidCount(land.charge);
					
					if (tipContent[0])
					{
						Load.loading(Config.getIcon(App.data.storage[Numbers.firstProp(land.charge).key].type, App.data.storage[Numbers.firstProp(land.charge).key].preview), 
							function(data:Bitmap):void
							{
								_bitmap.bitmapData = data.bitmapData;
								Size.size(_bitmap, 30, 30);
						});
						var count1:String = Numbers.firstProp(land.charge).val + '/' + String(App.user.stock.count(Numbers.firstProp(land.charge).key));
					}
					
					if (tipContent[1])
					{
						Load.loading(Config.getIcon(App.data.storage[Numbers.lastProp(land.charge).key].type, App.data.storage[Numbers.lastProp(land.charge).key].preview), 
							function(data:Bitmap):void
							{
								_bitmap2.bitmapData = data.bitmapData;
								Size.size(_bitmap2, 30, 30);
						});
						var count2:String = Numbers.lastProp(land.charge).val + '/' + String(App.user.stock.count(Numbers.lastProp(land.charge).key));
					}
					
					return {
						title:land.title,
						//text:Locale.__e("flash:1502272421325",App.data.storage[Numbers.firstProp(land.charge).key].title),
						count1:count1,
						count2:count2,
						icon:_bitmap,
						icon2:_bitmap2
					};
				}
				else
				{
					return {
						title:App.data.storage[Numbers.firstProp(land.charge).key].title,
						text:App.data.storage[Numbers.firstProp(land.charge).key].description,
						timer:false
					};	
				}
			};
		
		draw();
	}
	
	private function draw():void 
	{
		_title = Window.drawText(App.data.storage[_sid].title, {
			fontSize	:24,
			color		:0xffffff,
			borderColor	:0x6e411e,
			textAlign	:"center",
			wrap		:true,
			multiline	:true,
			width		:100
		})
		addChild(_title);
		
		Load.loading(Config.getIcon(App.data.storage[_sid].type, App.data.storage[_sid].preview), onLoad) 
		
		var availableText:TextField = Window.drawText(needMounth+', '+needDay,{
			fontSize	:24,
			color		:0xffffff,
			borderColor	:0x6e411e,
			textAlign	:"center",
			wrap		:true,
			multiline	:true,
			textAlign	:'left',
			width		:130
		})
		
		availableText.x = 210;
		//availableText.y = _title.y + (_title.height - availableText.height) / 2;
		addChild(availableText);
		
		var availableText2:TextField = Window.drawText(needHours+':00',{
			fontSize	:26,
			color		:0xfede33,
			borderColor	:0x6e411e,
			textAlign	:"center",
			wrap		:true,
			multiline	:true,
			textAlign	:'left',
			width		:110
		})
		
		availableText2.x = availableText.x + (availableText.width - availableText2.width) / 2;
		availableText2.y = availableText.y + availableText.height - 5;
		addChild(availableText2);
	}
	
	private function onLoad(data:*):void 
	{
		_icon.bitmapData = data.bitmapData;
		Size.size(_icon, 75, 75);
		_icon.smoothing = true;
		_icon.x = 120;
		_icon.y = _title.y + (_title.height - _icon.height) / 2;
		addChild(_icon);
	}
	
	private function get needDay():String
	{
		var nDay:int
		var futureDay:Vector.<int> = new Vector.<int>;
		var allDays:Vector.<int> = new Vector.<int>;
		for (var _day:* in land.available)
		{
			allDays.push(int(_day));
		}
		allDays.sort(Array.NUMERIC);
		for(var day:* in land.available)
		{
			if (day > currDay)
				futureDay.push(day);
		}
		futureDay.sort(Array.NUMERIC);
		if (futureDay.length > 0)
			nDay = futureDay[0];
		else
		{
			nDay = allDays[0]
		}
		_needDay = String(nDay)
		return _needDay;
	}
	
	private function get needMounth():String
	{
		var futureDay:Vector.<int> = new Vector.<int>;
		for(var day:* in land.available)
		{
			if (day > currDay)
				futureDay.push(day);
		}
		if (futureDay.length > 0)
			_needMounth = App.data.calendar[currMounth].title
		else
			_needMounth = App.data.calendar[currMounth + 1].title
		return _needMounth;
	}
	
	private function get needHours():String
	{
		var cday:int = int(needDay);
		var hour:int;
		hour = land.available[cday].hstart
		if (hour < 10)
			_needHours = '0' + hour.toString();
		else
			_needHours = hour.toString();
		return _needHours;
	}
}