package wins 
{
	import buttons.Button;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class CraftListWindow extends Window 
	{
		private var _item:CraftItem;
		private var _listSprite:Sprite = new Sprite();
		private var _description:TextField;
		private var _bttn:Button;
		private var _back:Shape = new Shape();

		public function CraftListWindow(settings:Object=null) 
		{
			settings['fontColor']		= 0xffffff;
			settings['background']		= 'workerHouseBacking';
			settings['fontBorderColor'] = 0x085c10;
			settings['borderColor'] 	= 0x085c10;
			settings['shadowColor'] 	= 0x085c10;
			settings['fontSize'] 		= 40;
			settings['fontBorderSize'] 	= 2;
			settings['shadowSize'] 		= 2;
			settings['hasPaginator'] 	= false;
			settings['title'] 			= settings.target.info.title;
			settings['width'] 			= 450;
			settings['height'] 			= 210 + (85 * settings.content.length);
			super(settings);
		}
		
		override public function drawBackground():void
		{
			super.drawBackground();
			var back:Bitmap = Window.backing(settings.width - 60, settings.height - 60, 30, 'itemBackingPaper');
			back.x = (settings.width - back.width) / 2;
			back.y = (settings.height - back.height) / 2;
			layer.addChild(back);
		}
		
		override public function drawBody():void 
		{
			drawRibbon();
			exit.y -= 20;
			titleLabel.y += 15;
			drawDescription();
			contentChange();
			drawBttn();
			drawBack();
			build();
		}
		
		private function drawBack():void 
		{
			_back.graphics.beginFill(0xfbe6c9);
			_back.graphics.drawRect(0, 0, settings.width - 120, settings.content.length * 95);
			_back.graphics.endFill();
			_back.filters = [new BlurFilter(20,0,10)]
		}
		
		private function drawDescription():void 
		{
			_description = Window.drawText(Locale.__e('flash:1509450088545', App.data.storage[settings.target.model.manufactures[0]].title ), {
				fontSize	:24,
				color		:0xffffff,
				borderColor	:0x6e411e,
				textAlign	:"center",
				wrap		:true,
				multiline	:true,
				width		:settings.width - 80
			})
			
		}
		
		override public function contentChange():void 
		{
			var Y:int = 0;
			for (var i:int = 0; i < settings.content.length; i++)
			{
				_item = new CraftItem(settings.content[i]);
				_listSprite.addChild(_item);
				_item.y = Y;
				Y += 85;
			}
		}
		
		private function drawBttn():void 
		{
			var bttnSettings:Object = {
			caption		:Locale.__e('flash:1382952380242'),
			fontColor	:0xffffff,
			width		:155,
			height		:55,
			fontSize	:28
			};
		
			bttnSettings['bgColor'] = [0xfed031, 0xf8ac1b];
			bttnSettings['bevelColor'] = [0xf7fe9a, 0xcb6b1e];
			bttnSettings['fontBorderColor'] = 0x7f3d0e;
			
			_bttn = new Button(bttnSettings);
			_bttn.addEventListener(MouseEvent.CLICK, onOkEvent);
			
		}
		
		private function onOkEvent(e:MouseEvent):void 
		{
			close();
		}
		
		private function build():void 
		{
			_description.x = (settings.width - _description.width) / 2;
			_description.y = 35;
			
			_bttn.x = (settings.width - _bttn.width) / 2;
			_bttn.y = settings.height - 45 - _bttn.height / 2;
			
			_listSprite.x = 130;
			_listSprite.y = _description.y + _description.height + 50;

			_back.x = (settings.width - _back.width) / 2;
			_back.y = 115;
			
			bodyContainer.addChild(_description);
			bodyContainer.addChild(_back)
			bodyContainer.addChild(_bttn);
			bodyContainer.addChild(_listSprite);
			
		}
		
	}

}
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.text.TextField;
import wins.Window;

internal class CraftItem extends LayerX
{
	private var _cID:int
	private var _outID:int
	private var _outCount:int
	private var _icon:Bitmap = new Bitmap();
	private var _back:Shape = new Shape();
	private var _title:TextField;
	private var _count:TextField;
	
	public function CraftItem(cID:int)
	{
		this._cID = cID;
		this._outID = App.data.crafting[_cID].out
		this._outCount = App.data.crafting[_cID].count
		draw();
	}
	
	private function draw():void 
	{
		_back.graphics.beginFill(0xe9b37f);
		_back.graphics.drawCircle(0, 0, 40);
		_back.graphics.endFill();
		addChild(_back);
		
		_title = Window.drawText(App.data.storage[_outID].title, {
			fontSize	:24,
			color		:0x7e3e13,
			border		:false,
			textAlign	:"center",
			wrap		:true,
			multiline	:true,
			width		:100
		})
		_title.x = 60;
		_title.y = _back.y - _title.height / 2;
		addChild(_title);
		
		
		_count = Window.drawText('x'+String(_outCount), {
			fontSize	:24,
			color		:0xffffff,
			borderColor	:0x7e3e13,
			textAlign	:"center",
			wrap		:true,
			multiline	:true,
			width		:100
		})
		_count.x = 150;
		_count.y = _back.y - _count.height / 2;
		addChild(_count);
		
		Load.loading(Config.getIcon(App.data.storage[_outID].type, App.data.storage[_outID].preview), onLoad) 
	}
	
	private function onLoad(data:*):void 
	{
		_icon.bitmapData = data.bitmapData;
		Size.size(_icon, 60, 60);
		_icon.smoothing = true;
		_icon.x = (_back.width - _icon.width) / 2 - _back.width / 2;
		_icon.y = (_back.height - _icon.height) / 2 - _back.height / 2;
		addChild(_icon);
	}
}