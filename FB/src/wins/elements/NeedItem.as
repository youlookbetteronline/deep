package wins.elements 
{
	import core.Load;
	import core.Numbers;
	import core.Size;
	import flash.display.Bitmap;
	import flash.text.TextField;
	import ui.FindPanel;
	import wins.ShopWindow;
	import wins.Window;
	/**
	 * ...
	 * @author ...
	 */
	public class NeedItem extends LayerX
	{
		private var _settings:Object = new Object();
		private var _item:Object;
		private var _count:int;
		private var _icon:Bitmap;
		private var _title:TextField;
		private var _countField:TextField;
		private var _background:Bitmap;
		private var _findPanel:FindPanel;
		public function NeedItem(settings:Object) 
		{
			this._settings = settings;
			this._item = App.data.storage[Numbers.firstProp(settings.item).key];
			this._count = Numbers.firstProp(settings.item).val;
			
			drawBg();
			drawIcon();
			drawTitle();
			drawCount();
			drawButton();
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
			
			_countField.x = WIDTH - _countField.width - 10;
			_countField.y = HEIGHT - 40;
			
			_findPanel.x = (WIDTH - _findPanel.width) / 2;
			_findPanel.y = HEIGHT;
			
			addChild(_background);
			addChild(_icon);
			addChild(_title);
			addChild(_countField);
			if (App.user.stock.count(_item.sID) < _count)
				addChild(_findPanel);
		}
		
		private function drawBg():void 
		{
			_background = Window.backing(WIDTH, HEIGHT, 10, 'itemBacking');
		}
		
		private function drawButton():void
		{
			_findPanel = new FindPanel(_item.sID, 120);
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
				_icon.y = (HEIGHT - _icon.height) / 2 + 5;
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
			_countField = Window.drawText(App.user.stock.count(_item.sID) + '/' + String(_count),{
				fontSize		:30,
				color			:0xffffff,
				borderColor		:0x6e411e,
				borderSize		:2,
				textAlign		:'right',
				width			:70
			});
			
		}
		
		public function get WIDTH():int { return _settings.width; }
		public function get HEIGHT():int { return _settings.height; }
		
	}

}