package wins 
{
	import buttons.Button;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	/**
	 * ...
	 * @author das
	 */
	public class BathyscaphePayWindow extends Window 
	{
		public var travelBttn:Button;
		public var container:Sprite;
		private var descLabel:TextField;
		public var worldID:int = User.HOME_WORLD;

		public function BathyscaphePayWindow(settings:Object=null) 
		{
			
			settings['width'] = 460;
			settings['height'] = 410;
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			settings['popup'] = true;
			worldID = settings['worldID'] || User.HOME_WORLD;
			settings['title'] = App.data.storage[worldID].title || Locale.__e('flash:1418286565591');
			settings['fontColor'] = 0xffffff;
			settings['fontSize'] = 42;
			settings['borderColor'] = 0x085c10;
			settings['shadowColor'] = 0x085c10;
			settings['fontBorderColor'] = 0x085c10;
			settings['fontBorderSize'] = 2;
			settings['shadowSize'] = 2;
			settings['shadowColor'] = 0x085c10;
			settings['exitTexture'] = 'closeBttnMetal';
			
			super(settings);

		}
		
		override public function drawBackground():void
		{
			drawMirrowObjs('decSeaweedWithBubbles', settings.width + 56, -56, settings.height - 267, true, true, false, 1, 1, layer);
			super.drawBackground();
			var back:Bitmap = Window.backing(settings.width - 60, settings.height - 60, 30, 'itemBackingPaper');
			back.x = (settings.width - back.width) / 2;
			back.y = (settings.height - back.height) / 2;
			layer.addChild(back);
		}
		
		override public function drawBody():void {
			
			drawRibbon();
			descLabel = drawText(Locale.__e('flash:1508926483031'), {
				fontSize	:28,
				color		:0xffffff,
				borderColor	:0x623518,
				autoSize	:"center",
				textAlign	:'center',
				width		:300,
				multiline	:true,
				wrap		:true
			});
			
			travelBttn = new Button( {
				width:		180,
				height:		55,
				caption:	Locale.__e('flash:1382952380219')
			});
			travelBttn.addEventListener(MouseEvent.CLICK, onTravel);
			if (App.user.bathyscaphe == null || App.user.bathyscaphe.currentThrow < App.data.storage[worldID].fuel)
				travelBttn.state = Button.DISABLED;
			container = new Sprite();
			bodyContainer.addChild(container);
			
			contentChange();
			build();
		}
		
		override public function contentChange():void 
		{
			var item:FuelItem = new FuelItem(settings.sID, {
				content:	settings.content,
				wID:		worldID
			})
			item.x = (settings.width - item.width) / 2;
			item.y = 130;
			bodyContainer.addChild(item);
		}
		
		public function onTravel(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED)
				return;
				
			Travel.goTo(worldID);
		}
		
		override public function dispose():void {
			travelBttn.removeEventListener(MouseEvent.CLICK, onTravel);
			travelBttn.dispose();
			
			super.dispose();
		}
		
		private function build():void 
		{
			exit.y -= 20;
			titleLabel.y += 14;
			titleBackingBmap.y += 5;
			
			descLabel.x = (settings.width - descLabel.width) / 2;
			descLabel.y = 32;
			bodyContainer.addChild(descLabel);
			
			travelBttn.x  = (settings.width - travelBttn.width) / 2;
			travelBttn.y = settings.height - 74;
			bodyContainer.addChild(travelBttn);
		}
		
		
	}

}

import buttons.Button;
import buttons.ObjectMoneyButton;
import core.Load;
import core.Numbers;
import core.Size;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.Hints;
import units.Unit;
import utils.Effects;
import wins.Window;
import wins.elements.PriceLabel;
import wins.ShopWindow;
import wins.BanksWindow;
import wins.WorldsWindow;

internal class FuelItem extends LayerX
{	
	private var _icon:Bitmap;
	private var _item:Object;
	private var _title:TextField;
	private var _count:TextField;
	private var _settings:Object = {
		width		:138,
		height		:180
	};
	private var _bttn:Button;
	private var _timeContainer:Sprite;
	private var _background:Bitmap;
	private var _info:Object;
	
	public function FuelItem(fuelSid:int, settings:Object)
	{
		for (var property:* in settings) {
			_settings[property] = settings[property];
		}
		
		_item = App.data.storage[fuelSid];
		
		drawBg();
		drawIcon();
		drawTitle();
		drawBttn();
		drawCount();
		build();
		this.tip = function():Object{
			return{
				title	:_item.title,	
				text	:_item.description	
			}
		}
	}
	
	public function build():void 
	{
		_title.x = (WIDTH - _title.width) / 2;
		_title.y = 10;
		
		_count.x = WIDTH - _count.width - 10;
		_count.y = HEIGHT - 50;
		
		_bttn.x = (WIDTH - _bttn.width) / 2;;
		_bttn.y = HEIGHT - _bttn.height / 2;
		
		addChild(_background);
		addChild(_icon);
		addChild(_title);
		addChild(_count);
		if (App.user.bathyscaphe.currentThrow < App.data.storage[_settings.wID].fuel)
			addChild(_bttn);
	}
	
	public function get WIDTH():int { return _settings.width; }
	public function get HEIGHT():int { return _settings.height; }
	
	private function drawBg():void 
	{
		_background = Window.backing(WIDTH, HEIGHT, 10, 'itemBacking');
	}
	
	private function drawIcon():void 
	{
		_icon = new Bitmap();
		Load.loading(Config.getIcon(_item.type, _item.preview),function (data:Bitmap):void 
		{
			_icon.bitmapData = data.bitmapData;
			Size.size(_icon, 100, 90);
			_icon.smoothing = true;
			
			_icon.x = (WIDTH - _icon.width) / 2;
			_icon.y = (HEIGHT - _icon.height) / 2 + 26;
		});
	}
	
	private function drawTitle():void 
	{
		
		_title = Window.drawText(_item.title,{
			fontSize	:26,
			color		:0x7e3e13,
			borderSize	:0,
			textAlign	:'center',
			width		:WIDTH
		});
	}
	
	private function drawCount():void 
	{
		_count = Window.drawText(String(App.user.bathyscaphe.currentThrow) + '/' + String(App.data.storage[_settings.wID].fuel),{
			fontSize		:30,
			color			:0xffffff,
			borderColor		:0x6e411e,
			borderSize		:2,
			textAlign		:'right',
			width			:80
		});
		
	}
	
	private function drawBttn():void 
	{
		var bttnSettings:Object = {
			caption		:Locale.__e('flash:1467807291800'),
			fontColor	:0xffffff,
			width		:100,
			height		:38,
			fontSize	:23
		};
		bttnSettings["bgColor"] = [0xc7e314, 0x7fb531];
		bttnSettings["borderColor"] = [0xeafed1, 0x577c2d];
		bttnSettings["bevelColor"] = [0xdef58a, 0x577c2d];
		bttnSettings["fontColor"] = 0xffffff;			
		bttnSettings["fontBorderColor"] = 0x085c10;
		bttnSettings["caption"] = Locale.__e("flash:1510758225006");
		
		
		_bttn = new Button(bttnSettings);
		_bttn.addEventListener(MouseEvent.CLICK, findMaterial);
	}
	
	private function findMaterial(e:MouseEvent):void 
	{
		Window.closeAll()
		//App.user.bathyscaphe.click();
		
		var onMap:Array = Map.findUnits([Unit.BATHYSCAPHE]);
		if (onMap.length > 0)
		{
			App.map.focusedOn(onMap[0], false, function():void{
				onMap[0].click();
			})
			
		}
		else
		{
			new WorldsWindow( {
					title: 		Locale.__e('flash:1415791943192'),
					onMap:		Unit.BATHYSCAPHE,
					only:		World.worldsWhereEnabled(Unit.BATHYSCAPHE),
					popup:		true
				}).show();
		}
	}
	
	private function searchCallback():void 
	{
		var onMap:Array = Map.findUnits([Unit.BATHYSCAPHE]);
		if (onMap.length > 0)
		{
			App.map.focusedOn(onMap[0], false, function():void{
				onMap[0].click();
			})
			
		}
	}
}