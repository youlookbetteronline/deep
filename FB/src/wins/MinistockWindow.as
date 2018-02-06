package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import ui.UserInterface;
	/**
	 * ...
	 * @author ...
	 */
	public class MinistockWindow extends Window 
	{
		private var items:Vector.<MiniStockItem>;
		private var container:Sprite = new Sprite();
		private var item:MiniStockItem;
		public function MinistockWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			settings['title'] = 'Палатка';
			settings['background'] = settings.background || "capsuleWindowBacking";
			settings['hasPaginator'] = true;
			settings['exitTexture'] = 'closeBttnMetal',	
			settings['width'] = 715;
			settings['height'] = 475;
			settings['fontColor'] = 0xffffff;
			settings['fontBorderColor'] = 0x116011;
			settings['borderColor'] = 0x116011;
			settings['shadowColor'] = 0x116011;
			settings['fontSize'] = 42;
			settings['fontBorderSize'] = 3;
			settings['shadowSize'] = 2;
			settings['itemsOnPage'] = 8;
			settings["paginatorSettings"] = {buttonsCount: 3};
			settings['content'] = [];
			super(settings);
			createContent();
		}
		
		private function createContent():void
		{
			for (var itm:* in App.user.stock.data)
			{
				if (App.data.storage[itm].mtype == 3 || App.user.stock.data[itm] == 0)
					continue;
				settings.content.push(itm)
			}
		}
		
		
		override public function drawBackground():void 
		{
			super.drawBackground();
			var back:Bitmap = Window.backing(settings.width - 70, settings.height - 70, 30, 'paperClear');
			back.x = (settings.width - back.width) / 2;
			back.y = (settings.height - back.height) / 2;
			layer.addChild(back);
		}
		
		override public function drawBody():void 
		{
			drawRibbon();
			drawMinistockBttn();
			titleLabel.y += 11;
			exit.y -= 20;
			contentChange();
			paginator.y += 10;
		}
		
		override public function contentChange():void 
		{
			clearItems();
			items = new Vector.<MiniStockItem>();
			var X:int = 0;
			var Y:int = 0;
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				item = new MiniStockItem(settings.content[i], App.user.stock.data[settings.content[i]],this);
				container.addChild(item);
				items.push(item);
				item.x = X;
				item.y = Y;				
				X += item.bg.width + 5;
				if ((i+1) % 4 == 0)
				{
					X = 0;
					Y += item.bg.height + 13;
				}
			}
			container.x = 60;
			container.y = 35;
			bodyContainer.addChild(container);
		}
		
		public function clearItems():void 
		{
			for each(var _itm:* in items)
			{
				if (_itm.parent)
					_itm.parent.removeChild(_itm);
			}
				
		}
		
		override public function drawArrows():void {
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = (settings.height - paginator.arrowLeft.height) / 2 - 40;
			paginator.arrowLeft.x = -paginator.arrowLeft.width/2 + 85;
			paginator.arrowLeft.y = y;
			
			paginator.arrowRight.x = settings.width-paginator.arrowRight.width/2 - 23;
			paginator.arrowRight.y = y;
		}
		
		private function drawMinistockBttn():void 
		{
			var stockBttn:ImageButton = new ImageButton(UserInterface.textures.backpackBttnIco);
			stockBttn.addEventListener(MouseEvent.CLICK, onStockBttn);
			stockBttn.y = -40;
			stockBttn.x = -5;
			bodyContainer.addChild(stockBttn);
		}
		
		private function onStockBttn(e:MouseEvent):void 
		{
			close();
			new ShipWindow( {
				target:	(settings.hasOwnProperty('stockTarget'))?settings.stockTarget:null
			}).show();
		}
		
	}

}
import buttons.Button;
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import units.Unit;
import wins.Window;

internal class MiniStockItem extends LayerX{
	public var bg:Bitmap;
	private var image:Bitmap = new Bitmap();
	private var count:int;
	private var sid:int;
	private var useBttn:Button;
	private var placeBttn:Button;
	private var window:*;
	public function MiniStockItem(sid:int, count:int, window:*)
	{
		this.window = window;
		this.count = count;
		this.sid = sid;
		bg = Window.backing(145, 145, 40, 'itemBacking');
		addChild(bg);
		
		Load.loading(Config.getIcon(App.data.storage[sid].type, App.data.storage[sid].preview), onLoad); 
		
		
		var title:TextField = Window.drawText(App.data.storage[sid].title,{
			fontSize	:24,
			color		:0x6e411e,
			border		:false,
			textAlign	:'center',
			textLeading	:-6,
			width		:138,
			wrap		:true
		});
		title.x = bg.x + (bg.width - title.width) / 2;
		title.y = bg.y;
		addChild(title);
		drawButtons();
		this.tip = function():Object { 
			return {
				title:App.data.storage[sid].title,
				text:App.data.storage[sid].description
			};
		};
	}
	
	private function onLoad(data:Bitmap):void
	{
		image.bitmapData = data.bitmapData;
		Size.size(image, 70, 70);
		addChild(image);
		image.x = bg.x + (bg.width - image.width) / 2;
		image.y = bg.y + (bg.height - image.height) / 2;
		
		
		var counter:TextField = Window.drawText('x'+String(count),{
			fontSize	:32,
			color		:0xffffff,
			borderColor	:0x88532c,
			textAlign	:'left'
		});
		counter.x = image.x + image.width;
		counter.y = bg.y + bg.height - 60;
		addChildAt(counter, 1);
		
	}
	
	private function drawButtons():void
	{
		placeBttn = new Button( {
			caption:Locale.__e('flash:1382952380210'),
			width:112,
			height:35,
			fontSize:24,
			hasDotes:false
		})
		placeBttn.x = (bg.width - placeBttn.width) / 2;
		placeBttn.y = bg.height - placeBttn.height / 2 - 10;
		placeBttn.addEventListener(MouseEvent.CLICK, onPlaceEvent);
		
		useBttn = new Button( {
			caption:Locale.__e('flash:1423568900779'),
			width:112,
			height:35,
			fontSize:24,
			hasDotes:false
		})
		useBttn.x = (bg.width - useBttn.width) / 2;
		useBttn.y = bg.height - useBttn.height / 2 - 10;
		useBttn.addEventListener(MouseEvent.CLICK, onUseEvent);
		
		switch(App.data.storage[sid].type){
			case 'Firework':
			case 'Decor':
				addChild(placeBttn);
				break;
			case 'Energy':
				addChild(useBttn);
		}
	}
	
	private function onPlaceEvent(e:MouseEvent):void 
	{
		var settings:Object = { sid:sid, fromStock:true };
		var unit:Unit = Unit.add(settings);
		unit.move = true;
		App.map.moved = unit;
		window.close();
	}
	
	private function onUseEvent(e:MouseEvent):void 
	{
		App.user.stock.charge(sid);
		App.ui.upPanel.update();
		
	}
	
	
}