package ui 
{
	import buttons.Button;
	import buttons.ImageButton;
	import core.Size;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import wins.PurchaseWindow;
	import wins.ShopWindow;
	import wins.Window;
	
	/**
	 * ...
	 * @author ...
	 */
	public class FindPanel extends Sprite 
	{
		private var _buyBttn:		ImageButton;
		private var _findBttn:		ImageButton;
		private var _findCallback:	Function;
		private var _buyCallback:	Function;
		private var _width:			int;
		private var _sID:			int;
		private const DEFAULT_WIDTH:int 	= 130;
		private const DEFAULT_OFFSET:int 	= 10;
		
		public function FindPanel(sID:int, width:int = DEFAULT_WIDTH, findCallback:Function = null, buyCallback:Function = null) 
		{
			super();
			this._width = width>DEFAULT_WIDTH?DEFAULT_WIDTH:width;
			this._sID = sID;
			this._findCallback = findCallback;
			this._buyCallback = buyCallback;
			draw();
			build();
			
		}
		
		private function draw():void 
		{
			_buyBttn = new ImageButton(Window.textures.cutBuyBttn);
			_findBttn = new ImageButton(Window.textures.cutFindBttn);
			Size.size(_buyBttn, _width/2, _width/2);
			Size.size(_findBttn, _width/2, _width/2);
			_buyBttn.bitmap.smoothing = true;
			_findBttn.bitmap.smoothing = true;
			
			if (!Stock.checkBuyEnergy(_sID))
				_buyBttn.state = Button.DISABLED;
				
			//if (App.user.stock.count(_sID)
			_findBttn.addEventListener(MouseEvent.CLICK, onFindEvent)
			_buyBttn.addEventListener(MouseEvent.CLICK, onBuyEvent)
			
			_findBttn.tip = function():Object
			{
				return {
					title:Locale.__e('flash:1407231372860')
				}
			}
			_buyBttn.tip = function():Object
			{
				return {
					title:Locale.__e('flash:1382952379751')
				}
			}
			
		}
		
		private function build():void 
		{
			_findBttn.x = _buyBttn.x + _buyBttn.width - DEFAULT_OFFSET * (_width / DEFAULT_WIDTH);
			_findBttn.y = _buyBttn.y + (_buyBttn.height - _findBttn.height) / 2;
			
			addChild(_buyBttn);
			addChild(_findBttn);
		}
		
		private function onFindEvent(e:MouseEvent):void 
		{
			Window.closeAll();
			if (_findCallback == null)
				ShopWindow.findMaterialSource(_sID);
			else
				_findCallback();
			
		}
		
		private function onBuyEvent(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED)
			{
				Hints.text(Locale.__e('flash:1511955454807'), Hints.TEXT_RED, new Point(App.self.mouseX, App.self.mouseY));
				return;
			}
			Window.closeAll();
			if (_buyCallback == null)
			{
				var content:Array = PurchaseWindow.parseContent(_sID);
				var itmOnPage:int = 3;
				if (content.length < 3)
					itmOnPage = content.length;
				new PurchaseWindow( {
					popup:		true,
					width:		600,
					itemsOnPage:itmOnPage,
					content:	content,
					title:		App.data.storage[_sID].title,
					description:Locale.__e('flash:1472652747853')
				}).show();
			}
			else
				_buyCallback();
			
		}
		
		
		
	}

}