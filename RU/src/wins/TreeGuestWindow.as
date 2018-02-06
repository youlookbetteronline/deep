package wins 
{
	import api.ExternalApi;
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;

	public class TreeGuestWindow extends Window
	{
		private var items:Array = new Array();
		public var info:Object;
		public var back:Bitmap;
		
		public function TreeGuestWindow(settings:Object = null)
		{
			if (settings == null) {
				settings = new Object();
			}
			
			info = settings.target.info;
			
			settings['fontColor'] = 0xffcc00;
			settings['fontSize'] = 36;
			settings['fontBorderColor'] = 0x705535;
			settings['shadowBorderColor'] = 0x342411;
			settings['fontBorderSize'] = 8;
			settings['description'] = Locale.__e('flash:1382952380315');
			
			settings['width'] = 640;
			settings['height'] = 340;
			settings['title'] = info.title;
			settings['hasPaginator'] = true;
			settings['hasButtons'] = false;
			settings['hasArrow'] = true;
			settings['itemsOnPage'] = 10;
			
			settings['content'] = [];
			for (var sID:* in info.kicks)
				settings['content'].push( { sID:sID, count:info.kicks[sID] } )
				
			settings['content'].sortOn('sID', Array.NUMERIC);
			super(settings);
		}
		
		override public function drawBackground():void {
			var background:Bitmap = backing(settings.width, settings.height, 10, "windowBacking");
			layer.addChild(background);
			background.y = 30;
		}
		
		override public function drawBody():void {

			drawLabel(settings.target.textures.sprites[1].bmp, 0.6);
			titleLabel.y += 20;
			titleLabelImage.y += 20;
			
			exit.x += 30;
			exit.x -= 5;
			
			drawItems();
			
			var descriptionLabel:TextField = drawText(Locale.__e(settings.description), {
				fontSize:22,
				autoSize:"left",
				textAlign:"center",
				color:0x5d450f,
				borderColor:0xefe5c3,
				textLeading:-9
			});
			
			descriptionLabel.x = (settings.width - descriptionLabel.width) / 2;
			descriptionLabel.y = 70;
			descriptionLabel.width = settings.width - 80;
			
			bodyContainer.addChild(descriptionLabel);	
			
			//drawBttns();
		}
		
		private function drawItems():void {
			
			var container:Sprite = new Sprite();
			
			var X:int = 0;
			var Y:int = 0;
			
			for (var i:int = 0; i < settings.content.length; i++)
			{
				var _item:ShareGuestItem = new ShareGuestItem(settings.content[i], this);
				container.addChild(_item);
				_item.x = X;
				_item.y = Y;
				items.push(_item);
				
				X += _item.bg.width + 5;
			}
			
			bodyContainer.addChild(container);
			container.x = (settings.width - container.width) / 2;
			container.y = 125;
		}
		
		public function blockItems(value:Boolean):void {
			for each(var _item:ShareGuestItem in items) {
				if(value)
					_item.bttn.state = Button.DISABLED;
				else
					_item.bttn.state = Button.NORMAL;
			}
		}
		
		private function drawBttns():void {
			/*
			kickBttn = new Button({
				caption		:Locale.__e("flash:1382952380279"),
				width		:190,
				height		:38,	
				fontSize	:26
			});
			
			buyAllBttn = new MoneyButton({
				caption		:Locale.__e("flash:1382952380280"),
				width		:190,
				height		:42,	
				fontSize	:26,
				countText	:20
			});
			buyAllBttn.x = (settings.width - buyAllBttn.width) / 2;
			buyAllBttn.y = 400;
			
			kickBttn.x = (settings.width - kickBttn.width) / 2;
			kickBttn.y = 400;
			
			bodyContainer.addChild(kickBttn);
			bodyContainer.addChild(buyAllBttn);
			
			kickBttn.addEventListener(MouseEvent.CLICK, kickEvent);
			buyAllBttn.addEventListener(MouseEvent.CLICK, buyAllEvent);
			
			kickBttn.visible = false;*/
		}
		
	}
}


import buttons.Button;
import core.Load;
import core.Post;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.Hints;
import wins.elements.PriceLabel;
import wins.Window;

internal class ShareGuestItem extends LayerX{
	
	public var window:*;
	public var item:Object;
	public var bg:Bitmap;
	private var bitmap:Bitmap;
	private var sID:uint;
	public var bttn:Button;
	private var kicks:uint;
	
	public function ShareGuestItem(obj:Object, window:*) {
		
		this.sID = obj.sID;
		this.kicks = window.info.kicks[sID].c;
		this.item = App.data.storage[sID];
		this.window = window;
		
		bg = Window.backing(150, 190, 20, 'itemBacking');
		addChild(bg);
		
		drawTitle();
		drawBttn();
		drawLabel();
		
		Load.loading(Config.getIcon(item.type, item.preview), onLoad);
		
		tip = function():Object {
			return {
				//title: Locale.__e("flash:1382952380283", kicks)
				title: Locale.__e(item.title),
				text: Locale.__e(item.description)
			}
		}
	}
	
	private function drawBttn():void {
		
		var bttnSettings:Object = {
			caption:Locale.__e('flash:1382952380090'),
			width:110,
			height:36,
			fontSize:26
		}
		
		if(item.real == 0){
			bttnSettings['borderColor'] = [0xaff1f9, 0x005387];
			bttnSettings['bgColor'] = [0x70c6fe, 0x765ad7];
			bttnSettings['fontColor'] = 0x453b5f;
			bttnSettings['fontBorderColor'] = 0xe3eff1;
		}
		
		bttn = new Button(bttnSettings);
		
		addChild(bttn);
		bttn.x = (bg.width - bttn.width) / 2;
		bttn.y = bg.height - bttn.height + 20;
		bttn.addEventListener(MouseEvent.CLICK, onClick);
		
		if (item.real == 0 && App.user.friends.data[App.owner.id]['energy'] <= 0)
			bttn.state = Button.DISABLED;
	}
	
	private function onClick(e:MouseEvent):void {
		
		if (e.currentTarget.mode == Button.DISABLED) return;
		if (!App.user.stock.check(Stock.FANT, item.real)) return;
		
		var boost:int = 0;
		if(item.real > 0)
			boost = 1;
		
		window.blockItems(true);
		window.settings.kickEvent(sID, onKickEventComplete, boost);
		
		//if(bitmap.bitmapData != null)
		//	window.settings.target.sendKickPost(App.owner.id, bitmap);
	}
	
	private function onKickEventComplete(sID:uint, price:uint):void {
		
		if (price == 0) {
			window.close();
			return;
		}
		App.user.stock.take(sID, price);
		
		var X:Number = App.self.mouseX - bttn.mouseX + bttn.width / 2;
		var Y:Number = App.self.mouseY - bttn.mouseY;
		Hints.minus(sID, price, new Point(X, Y), false, App.self.tipsContainer);
		window.close();
	}	
	
	private function onLoad(data:Bitmap):void {
		bitmap = new Bitmap(data.bitmapData);
		addChild(bitmap);
		bitmap.x = (bg.width - bitmap.width) / 2;
		bitmap.y = (bg.height - bitmap.height) / 2 - 10;
	}
	
	public function dispose():void {
		bttn.removeEventListener(MouseEvent.CLICK, onClick);
	}
	
	public function drawTitle():void {
		
		var title:TextField = Window.drawText(String(item.title), {
			color:0x6d4b15,
			borderColor:0xfcf6e4,
			textAlign:"center",
			autoSize:"center",
			fontSize:20,
			textLeading:-6,
			multiline:true
		});
		title.wordWrap = true;
		title.width = bg.width - 10;
		title.height = title.textHeight;
		title.y = 10;
		title.x = 5;
		addChild(title);
	}
	
	public function drawLabel():void {
		var price:PriceLabel;
		if (item.real == 0){
			
			var text:String = Locale.__e('flash:1382952380285');
			var guestsFree:Object = window.settings.target._free;
			
			var free:Boolean = false
			for each(var uid:* in guestsFree)
			{
				if (uid == App.user.id) 
					free = true;
			}
			
			if (free) {
				text = Locale.__e("flash:1382952380318");
				bttn.visible = false;
			
				var label:TextField = Window.drawText(text, {
					color:0x6d4b15,
					borderColor:0xfcf6e4,
					textAlign:"center",
					autoSize:"center",
					fontSize:20,
					textLeading:-6,
					multiline:true
				});
				
				label.wordWrap = true;
				label.width = bg.width - 10;
				label.height = label.textHeight;
				label.y = 140;
				label.x = 5;
				addChild(label);
			}
			else
			{
				price = new PriceLabel({1:1});
				addChild(price);
				price.x = (bg.width - price.width) / 2;
				price.y = 130;
			}
			
		}else{
			
			price = new PriceLabel(item);
			addChild(price);
			price.x = (bg.width - price.width) / 2;
			price.y = 135;
			
		}
	}
}

