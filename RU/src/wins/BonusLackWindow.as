package wins 
{
	import buttons.Button;
	import com.adobe.images.BitString;
	import core.Load;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import utils.BonusHelper;
	import utils.TopHelper;
	/**
	 * ...
	 * @author ...
	 */
	public class BonusLackWindow extends Window 
	{
		private var _persImage:Bitmap;
		private var _description:TextField;
		private var _itemsContainer:Sprite = new Sprite();
		private var _items:Vector.<BubbleItem>;
		private var _item:BubbleItem;
		private var _bttn:Button;
		public function BonusLackWindow(settings:Object=null) 
		{
			settings = settingsInit(settings);
			super(settings);
			
		}
		
		private function settingsInit(settings:Object = null):Object
		{
			if (settings == null) {
				settings = {};
			}
			settings["width"]				= 80 + Numbers.countProps(settings.bonus)*120;
			settings["height"] 				= 355;
			settings["hasPaginator"] 		= false;
			settings["hasPaper"] 			= false;
			settings["hasArrows"]			= false;
			settings["hasButtons"]			= false;
			settings['exitTexture'] 		= 'blueClose';
			settings['fontColor'] 			= 0xffffff;
			settings['fontBorderColor'] 	= 0x1f5167;
			settings['fontBorderSize']		= 3;
			settings['fontSize'] 			= 40;
			settings["faderAsClose"]		= false;
			settings["escExit"]				= false;
			settings["hasExit"]				= false;
			settings['title'] 				= Locale.__e('flash:1429693439093');
			
			return settings;
		}
		
		private function parseContent():void
		{
			settings.content = Numbers.objectToArraySidCount(settings.bonus);
		}
		
		override public function drawBackground():void 
		{
			var background:Bitmap = backing4(settings.width, settings.height, 160, 'blueBackingTL', 'blueBackingTR', 'blueBackingBL', 'blueBackingBR');
			layer.addChild(background);	
		}
		
		override public function drawBody():void 
		{
			this.x += 40;
			fader.x -= 40;
			
			drawPersonage();
			drawDescription();
			contentChange();
			drawButtons();
			build();
			
		}
		
		private function drawPersonage():void 
		{
			Load.loading(Config.getImageIcon('content', 'JanePresent'), function(data:Bitmap):void{
				_persImage = new Bitmap(data.bitmapData);
				_persImage.y = -15;
				_persImage.x = -115;
				bodyContainer.addChild(_persImage);
			})
		}
		
		private function drawDescription():void 
		{
			_description = Window.drawText(Locale.__e('flash:1518449154191'), {
				fontSize		:30,
				color			:0xffe558,
				borderColor		:0x174052,
				borderSize		:3,
				textAlign		:'center',
				width			:525,
				multiline		:true,
				wrap			:true
			})
		}
		
		private function drawButtons():void 
		{
			_bttn = new Button({
				caption			:Locale.__e('flash:1382952379737'),
				fontColor		:0xffffff,
				width			:170,
				height			:51,
				fontSize		:32,
				bgColor			:[0xfed131, 0xf8ab1a],
				bevelColor		:[0xf7fe9a, 0xcb6b1e],
				fontBorderColor	:0x6e411e
			});
			
			_bttn.addEventListener(MouseEvent.CLICK, onClick)
		}
		
		private function onClick(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED)
				return;
			e.currentTarget.state = Button.DISABLED;
			BonusHelper.getLack(lackCallback)
		}
		
		private function lackCallback(bonus:Object):void 
		{
			close();
			App.user.stock.addAll(bonus);
			for (var _sid:* in bonus) 
			{
				var item:BonusItem = new BonusItem(_sid, bonus[_sid]);
				var point:Point = new Point(App.self.mouseX, App.self.mouseY)
				point.y += 80;
				item.cashMove(point, App.self.windowContainer);
			}
		}
		
		override public function contentChange():void 
		{
			parseContent();
			for each(var _itm:BubbleItem in _items){
				_itm.parent.removeChild(_itm);
				_itm = null;
			}
			_items = new Vector.<BubbleItem>;
			
			var currentX:int = 0;
			for (var i:int = 0; i < settings.content.length; i++)
			{
				_item = new BubbleItem({
					item:	settings.content[i]
				});
				_item.x = currentX;
				_itemsContainer.addChild(_item);
				_items.push(_item);
				currentX += _item.WIDTH + 15;
			}
		}
		
		private function build():void 
		{
			titleLabel.y += 40;
			
			_description.x = (settings.width - _description.width) / 2;
			_description.y = 52;
			
			_itemsContainer.x = (settings.width - _itemsContainer.width) / 2;
			_itemsContainer.y = 150;
			
			bodyContainer.addChild(_description);
			bodyContainer.addChild(_itemsContainer)
			
			_bttn.x = (settings.width - _bttn.width) / 2;
			_bttn.y = settings.height - _bttn.height - 20;
			bodyContainer.addChild(_bttn);
		}
	}
}
import com.greensock.TweenLite;
import com.greensock.TweenMax;
import com.greensock.easing.Elastic;
import com.greensock.easing.Linear;
import com.greensock.easing.Strong;
import com.greensock.plugins.TransformAroundPointPlugin;
import com.greensock.plugins.TweenPlugin;
import core.Load;
import core.Numbers;
import core.Size;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.geom.Point;
import flash.text.TextField;
import wins.Window;

internal class BubbleItem extends LayerX
{
	private var _settings:Object = {
		width:105,
		height:105
	}
	private var _sid:int;
	private var _count:int;
	private var _item:Object;
	private var _background:Bitmap;
	private var _icon:Bitmap;
	private var _countText:TextField
	private var _titleText:TextField
	public function BubbleItem(settings:Object)
	{
		for (var property:* in settings)
			_settings[property] = settings[property];
		this._sid = Numbers.firstProp(_settings.item).key;	
		this._count = Numbers.firstProp(_settings.item).val;	
		this._item = App.data.storage[_sid];
		drawBackground();
		drawTitle();
		drawIcon();
		drawCount();
		
		build();
		
		this.tip = function():Object{
			return {
				title	:_item.title,
				text	:_item.description
			}
		}
	}
	
	private function drawBackground():void 
	{
		_background = new Bitmap(Window.textures.circleBlueBacking)
		addChild(_background);
	}
	
	private function drawIcon():void 
	{
		Load.loading(Config.getIcon(_item.type, _item.view), onLoadIcon)
	}
	
	private function onLoadIcon(data:Bitmap):void 
	{
		
		TweenPlugin.activate([TransformAroundPointPlugin]);
		_icon = new Bitmap(data.bitmapData);
		var defScale:int = 1;
		var defWidth:int = _icon.width
		Size.size(_icon, 70, 70);
		var changeScale:Number = _icon.width / defWidth;
		_icon.smoothing = true;
		
		_icon.x = (WIDTH - _icon.width) / 2;
		_icon.y = (HEIGHT - _icon.width) / 2;
		addChild(_icon);
		
		_titleText.x = (WIDTH - _titleText.width) / 2;
		_titleText.y = -30;
		
		addChild(_titleText);
		var lPoint:Point = new Point(_icon.x + _icon.width / 2, _icon.y + _icon.height / 2);
		//var lTween:TweenMax = new TweenMax(_iconSprite, 2, {scaleX:0.1, transformAroundPoint: { point:lPoint}, ease:Linear.easeNone, onComplete:function():void{}});
		var lTween:TweenLite =  TweenLite.to(_icon, 1.5, { 
			transformAroundPoint: { 
				point:lPoint, 
				scaleX: -changeScale/*/2*/
			}, 
			ease:Linear.easeNone, 
			onComplete:backTween	
		});
		
		function backTween():void
		{
			lTween = TweenLite.to(_icon, 1.5, { 
				transformAroundPoint: { 
					point:lPoint, 
					scaleX: changeScale
				}, 
				ease:Linear.easeNone, 
				onComplete:tween	
			});
		}
		function tween():void
		{
			lTween =  TweenLite.to(_icon, 1.5, { 
				transformAroundPoint: { 
					point:lPoint, 
					scaleX: -changeScale/*/2*/
				}, 
				ease:Linear.easeNone, 
				onComplete:backTween	
			});
		}
	}
	
	private function drawTitle():void 
	{
		var text:String = _item.title
		var labelArray:Array = text.split(' ');
		var label:String = '';
		for (var i:int = 0; i < labelArray.length; i++)
		{
			label += labelArray[i];
			if (i != labelArray.length - 1)
			label+='\n'
		}
		
		_titleText = Window.drawText(label,{
			color			:0xffffff,
			borderColor		:0x1f5167,
			borderSize		:3,
			fontSize		:26,
			width			:100,
			height			:50,/*
			multiline		:true,
			wrap			:true,*/
			textAlign		:'center',
			textLeading		:-18
		})
	}
	
	private function drawCount():void 
	{
		_countText = Window.drawText('x '+String(_count),{
			color			:0xffffff,
			borderColor		:0x1f5167,
			borderSize		:3,
			fontSize		:34,
			width			:90,
			textAlign		:'center'
		})
	}
	
	private function build():void 
	{
		addChild(_background);
		
		_countText.x = (WIDTH - _countText.width) / 2;
		_countText.y = HEIGHT - 5;
		
		addChild(_countText);
		
		
		
		if (_icon)
		{
			_icon.x = (WIDTH - _icon.width) / 2;
			_icon.y = (HEIGHT - _icon.width) / 2;
			addChild(_icon);
			
			_titleText.x = (WIDTH - _countText.width) / 2;
			_titleText.y = -30;
		
			addChild(_titleText);
		}
		
		
	}
	
	public function get WIDTH():int { return _settings.width; }
	public function get HEIGHT():int { return _settings.height; }
}