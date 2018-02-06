package wins
{
	import buttons.ImageButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Valentine
	 */
	public class AmuletWindow extends Window
	{
		
		public static const AMULET_PART_1:uint = 821;
		public static const AMULET_PART_2:uint = 822;
		public static const AMULET_PART_3:uint = 823;
		public static const AMULET_PART_4:uint = 824;
		public static const AMULET_PART_5:uint = 825;
		public static const AMULET_PART_6:uint = 826;
		public static const AMULET_PART_7:uint = 827;
		public static const AMULET_PART_8:uint = 828;
		public static const AMULET_PART_9:uint = 829;
		public static const AMULET_PART_10:uint = 830;
		public static const AMULET_PART_11:uint = 831;
		public static const AMULET_PART_12:uint = 832;
		
		public static var amuletArr:Array = [AMULET_PART_1, AMULET_PART_2, AMULET_PART_3, AMULET_PART_4, AMULET_PART_5, AMULET_PART_6, AMULET_PART_7, AMULET_PART_8, AMULET_PART_9, AMULET_PART_10, AMULET_PART_11, AMULET_PART_12]
		private var posArr:Array = [{x: 262, y: 202}, {x: 216, y: 454}, {x: 351, y: 274}, {x: 97, y: 263}, {x: 396, y: 96}, {x: 90, y: 106}, {x: 256, y: 65}, {x: 297, y: -22}, {x: 18, y: (-25)}, {x: 410, y: 7}, {x: 386, y: 180}, {x: 45, y: 180}]
		
		public static function checkAmuletPart(part:uint):Boolean
		{
			for (var i:int = 0; i < amuletArr.length; i++) 
			{
				if (amuletArr[i] == part)
				return true
			}
			return false
		}
		
		/*	public static function checkAmuletParts(parts:Object):Boolean
		{
			for (var item:* in parts){
				
			for (var i:int = 0; i < amuletArr.length; i++) 
			{
				if (amuletArr[i] == part)
				return true
			}
			}
			return false
		}*/
		
		public function AmuletWindow(settings:Object = null)
		{
						
			if (settings == null)
			{
				settings = new Object();
			}
			
			settings["find"] = settings.find || false;
			settings["title"] = settings.title || Locale.__e('flash:1434360743123');
			settings["hasPaginator"] = settings.hasPaginator || false;
			settings["popup"] = settings.popup || true;
			settings["width"] = settings.width || 700;
			settings["height"] = settings.height || 600;
			super(settings);
		}
		
		override public function drawBackground():void
		{
			var background:Bitmap = backing2(settings.width, settings.height, 50, 'instSmallBackingTop', 'instSmallBackingBot');
			background.y = -15;
			layer.addChild(background);
		
		}
		
		override public function drawExit():void
		{
			super.drawExit();
			exit.x = settings.width - 50;
			exit.y = -15;
		}
		
		override public function drawBody():void
		{
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -56, true, true);
			drawMirrowObjs('storageWoodenDec', 2, settings.width - 2, 35, false, false, false, 1, -1);
			drawMirrowObjs('storageWoodenDec', 2, settings.width - 2, settings.height - 128);
			
			titleLabel.y -= 10;
			
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, drawAmulet);
			drawAmulet();
		}
		
		private function drawAmulet():void
		{
			drawAmuletBack();
			//	drawAmuletItems();
		
		}
		private var backItems:Array;
		private var missionsCount:TextField;
		private var bitmap:Bitmap = new Bitmap();
		
		private function drawAmuletBack():void
		{
			missionsCount = Window.drawText(String(0) + "/" + String(amuletArr.length), {color: 0xffe760, borderColor: 0x7b4003, textAlign: "center", autoSize: "left", fontSize: 36});
			
			var countExistElements:uint = 0;
			for each (var itm:AmuletBackItem in backItems)
			{
				if (itm.parent)
					itm.parent.removeChild(itm);
				itm.dispose();
				itm = null;
			}
			backItems = [];
			
			Load.loading(Config.getImage('amulet', 'AmuletFull'), function(data:*):void
				{
					
					bitmap.bitmapData = data.bitmapData;
					bitmap.y -= 41;
					bitmap.x += 4;
				})
			bodyContainer.addChild(bitmap);
			for (var i:int = 0; i < amuletArr.length; i++)
			{
				if (!App.user.stock.check(amuletArr[i]))
				{
					var item:AmuletBackItem = new AmuletBackItem({id: i, pos: posArr[i]}, this)
					backItems.push(item);
					bodyContainer.addChild(item)
					/*var bitmap:Bitmap = new Bitmap();
					   bitmap.x = posArr[i].x;
					 bitmap.y = posArr[i].y;*/
					 if (settings.find&&(amuletArr[i] == settings.find)) 
					 {
						item.startGlowing(null,true); 
					 }
				}
				else
				{
					countExistElements++;
				}
			}
			bodyContainer.addChild(missionsCount);
			
			missionsCount.text = String(countExistElements) + "/" + String(amuletArr.length);
			missionsCount.x = settings.width - 150;
			missionsCount.y = settings.height - 140;
			
			searchBttn = new ImageButton(Window.textures.showMeBttn);
			bodyContainer.addChild(searchBttn);
			searchBttn.x = missionsCount.x + missionsCount.textWidth + 20;
			searchBttn.y = missionsCount.y;
			searchBttn.addEventListener(MouseEvent.CLICK, showHelp);
		}
		
		private function showHelp(e:MouseEvent):void
		{
			new SimpleWindow( {
			label: SimpleWindow.ATTENTION, 
			text: Locale.__e('flash:1434374975076'), 
			popup: true,
			offsetY: -100
				
				}).show();
		}
		
		private var items:Array;
		private var searchBttn:ImageButton;
		
		private function drawAmuletItems():void
		{
			items = [];
			for (var i:int = 0; i < amuletArr.length; i++)
			{
				if (App.user.stock.check(amuletArr[i]))
				{
					
					var item:AmuletItem = new AmuletItem({id: i, pos: posArr[i]}, this)
					items.push(item);
					bodyContainer.addChild(item)
					/*Load.loading(Config.getImage('promo/images', 'crystals'), function(data:*):void {
					
					 })	*/
				}
			}
		}
		
		override public function dispose():void
		{
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, drawAmulet);
			if (bitmap)
				bodyContainer.removeChild(bitmap);
			bitmap = null;
			super.dispose();
		}
	}

}
import buttons.Button;
import core.Load;
import flash.display.Bitmap;
import flash.display.Sprite;
import wins.AmuletWindow;
import wins.Window;
import wins.ShopWindow;
import wins.SimpleWindow;

internal class AmuletItem extends Sprite
{
	
	public var bg:Bitmap;
	public var item:Object;
	private var bitmap:Bitmap;
	private var buyBttn:Button;
	private var _parent:*;
	private var preloader:Preloader = new Preloader();
	
	//public var paginator:Paginator				= null;	
	
	public function AmuletItem(item:Object, parent:AmuletWindow)
	{
		
		this._parent = parent;
		this.item = item;
		/*bg = Window.backing(136, 154, 15, 'itemBacking');
		 addChild(bg);*/
		
		var sprite:LayerX = new LayerX();
		addChild(sprite);
		
		bitmap = new Bitmap();
		sprite.addChild(bitmap);
		
		/*sprite.tip = function():Object {
		
		   if (item.type == "Plant")
		   {
		   return {
		   title:item.title,
		   text:Locale.__e("flash:1382952380297", [TimeConverter.timeToCuts(item.levelTime * item.levels), item.experience, App.data.storage[item.out].cost])
		   };
		   }
		   else if (item.type == "Decor")
		   {
		   return {
		   title:item.title,
		   text:Locale.__e("flash:1382952380076", String(item.experience))
		   }
		   }
		   else
		   {
		   return {
		   title:item.title,
		   text:item.description
		   };
		   }
		 };*/
		
		//drawTitle();
		//drawBttn();
		
		addChild(preloader);
		preloader.x = item.pos.x;
		preloader.y = item.pos.y;
		preloader.scaleX = preloader.scaleY = 0.67;
		
		Load.loading(Config.getImage('amulet', 'AmuletPieceBig' + (item.id + 1)), function(data:*):void
			{
				if (preloader)
				{
					removeChild(preloader)
					preloader = null
				}
				
				bitmap.bitmapData = data.bitmapData;
				bitmap.smoothing = true;
				bitmap.x = item.pos.x;
				bitmap.y = item.pos.y;
			
			})
	
	}
	
	public function dispose():void
	{
	/*if(buyBttn)buyBttn.removeEventListener(MouseEvent.CLICK, onBuy);
	 if(buyBttnNow)buyBttn.removeEventListener(MouseEvent.CLICK, onBuyNow);*/
	}

}

import buttons.Button;
import core.Load;
import flash.display.Bitmap;
import wins.Window;
import wins.SimpleWindow;

internal class AmuletBackItem extends LayerX
{
	
	public var bg:Bitmap;
	public var item:Object;
	private var bitmap:Bitmap;
	private var buyBttn:Button;
	private var _parent:*;
	private var preloader:Preloader = new Preloader();
	
	//public var paginator:Paginator				= null;	
	
	public function AmuletBackItem(item:Object, parent:AmuletWindow)
	{
		
		this._parent = parent;
		this.item = item;
		
		var sprite:LayerX = new LayerX();
		addChild(sprite);
		
		bitmap = new Bitmap();
		sprite.addChild(bitmap);
		
		addChild(preloader);
		preloader.x = item.pos.x;
		preloader.y = item.pos.y;
		preloader.scaleX = preloader.scaleY = 0.67;
		
		Load.loading(Config.getImage('amulet', 'AmuletPiece' + (item.id + 1)), function(data:*):void
			{
				if (preloader)
				{
					removeChild(preloader)
					preloader = null
				}
				
				bitmap.bitmapData = data.bitmapData;
				bitmap.smoothing = true;
				bitmap.x = item.pos.x;
				bitmap.y = item.pos.y;
			
			//	addChild(bitmap);
			})
	
	}
	
	public function dispose():void
	{
		if (bitmap && bitmap.parent)
			bitmap.parent.removeChild(bitmap);
		bitmap = null;
	
	}

}
