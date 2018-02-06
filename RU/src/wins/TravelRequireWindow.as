package wins {
	
	import buttons.Button;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	public class TravelRequireWindow extends Window {
		
		protected var sIDmap:int;
		protected var enough:Boolean;
		protected var requires:Array = [];
		protected var reqCont:Sprite;
		
		public function TravelRequireWindow(settings:Object = null) {
			if (settings == null) {
				settings = new Object();
			}
			
		//	settings['background'] 		= 'paperBacking';
			settings['width'] 			= 580;
			settings['height'] 			= 365;
			settings['title'] 			= Locale.__e('flash:1394010224398');
			settings['hasPaginator'] 	= false;
			settings['hasExit'] 		= true;
			settings['hasTitle'] 		= true;
			settings['titleDecorate'] 	= false;
			settings['faderClickable'] 	= true;
			settings['faderAlpha'] 		= 0.6;
			settings['popup'] 			= true;
			
			this.sIDmap = settings.sIDmap || 0;
			
			super(settings);
		}
		
		override public function drawTitle():void {
			titleLabel = titleText( {
				title				: settings.title,
				color				: 0xffffff,
				multiline			: settings.multiline,			
				fontSize			: 44,
				textLeading	 		: settings.textLeading,	
				border				: true,
				borderColor 		: 0xc4964e,			
				borderSize 			: 4,	
				shadowColor			: 0x503f33,
				shadowSize			: 4,
				width				: settings.width - 140,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50
			});
			titleLabel.x = (settings.width - titleLabel.width) / 2;
			titleLabel.y = - titleLabel.height / 2;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			
			headerContainer.y = 22;
			headerContainer.mouseEnabled = false;
		}
		
		override public function drawBody():void {
			exit.x -= 4;
			exit.y -= 26;
			drawDescription();
			drawRequireInfo();
			drawButtons();
		}
		
		public function drawDescription():void {
			var descriptionLabel:TextField = drawText(settings.description, {
				fontSize:24,
				autoSize:"left",
				textAlign:"center",
				color:0x5b2b03,
				borderColor:0xf8e6d8
			});
			//descriptionLabel.width = settings.width - 60;
			descriptionLabel.x = (settings.width - descriptionLabel.width) / 2;
			descriptionLabel.y = 30;
			bodyContainer.addChild(descriptionLabel);
		}
		
		public var bonusList:RewardList;
		protected var separator:Bitmap;
		protected var requireLabel:TextField;
		protected var separator2:Bitmap;
		protected function drawRequireInfo():void {
			/*separator = Window.backingShort(285, 'separator3', false);
			separator.x = 75;
			separator.y = 85;
			separator.alpha = 0.5;
			bodyContainer.addChild(separator);*/
			
			requireLabel = drawText(Locale.__e("flash:1423742002798") + ':', {
				fontSize:32,
				autoSize:"left",
				textAlign:"center",
				color:0xfdfba8,
				borderSize:3,
				borderColor:0x4f2a17,
				shadowSize:2,
				shadowColor:0x4f2a17
			});
			requireLabel.x = (settings.width - requireLabel.width) / 2;
			requireLabel.y = 60;
			bodyContainer.addChild(requireLabel);
			
			separator2 = Window.backingShort(285, 'separator3', false);
			separator2.x = 75;
			separator2.y = 250;
			separator2.alpha = 0.5;
			bodyContainer.addChild(separator2);
			
			drawRequire();
			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, onStockEvent);
		}
		
		private function onStockEvent(e:AppEvent):void {
			drawRequire();
			drawButtons();
		}
		
		protected var item:RequireItem;
		protected var have:int;
		protected var need:int;
		protected var X:int = 0;
		protected var req:*;
		protected function drawRequire():void {
			for each(item in requires) {
				if(item.parent)item.parent.removeChild(item);
				item = null;
			}
			requires.splice(0, requires.length);
			requires = [];
			
			if (reqCont != null && bodyContainer.contains(reqCont)) {
				bodyContainer.removeChild(reqCont);
			}
			reqCont = new Sprite();
			
			if (App.data.storage[sIDmap].hasOwnProperty('require')) {
				enough = true;
				have = 0;
				need = 0;
				X = 0;
				for (var sID:* in App.data.storage[sIDmap].require) {
				/*	have = App.user.stock.data[req] || 0;
					need = App.data.storage[sIDmap].require[req] || 1;
					if (have < need) enough = false;
					item = new RequireItem(req, have, need, this);
					item.x = X;
					item.y = 0;
					reqCont.addChild(item);
					requires.push(item);
					//X += item.width + 15;
					X += 120 + 15;*/
					
				var background:Bitmap = Window.backing(160, 230, 10, "itemBacking");
				//partBcList.push(background);
				reqCont.addChild(background);
		
				var inItem:MaterialItem = new MaterialItem({
					sID:sID,
					need:App.data.storage[sIDmap].require[sID] || 1,
					window:this, 
					type:MaterialItem.IN,
					color:0x5a291c,
					borderColor:0xfaf9ec,
					bitmapDY: 10,
					bgItemY:80,
					bgItemX:20
					
				});
				
				inItem.checkStatus();
				inItem.addEventListener(WindowEvent.ON_CONTENT_UPDATE, onUpdateOutMaterial)
				
				partList.push(inItem);
				inItem.y = 10;
				
				reqCont.addChild(inItem);
				inItem.x = offsetX;
				
				count++;
				
				offsetX += inItem.background.width  + 10/* + dX*/;
				inItem.background.visible = false;
				background.x = inItem.x ;
				background.y = inItem.y ;
				
					
				}
				reqCont.x = (settings.width - reqCont.width) / 2;
				reqCont.y = 95;
				bodyContainer.addChild(reqCont);
			}
		}
		
		public function drawButtons():void {
			if (enough) {
				var bttn:Button = new Button({
					width:180,
					height:53,
					caption:Locale.__e('flash:1394010224398'),
					bgColor:[0xfed348,0xf4aa23],
					borderColor:[0xc3ab8f, 0x41232d],
					fontColor:0xFFFFFF,
					fontBorderColor:0x874f38,
					bevelColor:[0xfff07e, 0xc77e0f]
				});
				bttn.x = (settings.width - bttn.width) / 2;
				bttn.y = 275;
				bodyContainer.addChild(bttn);
				bttn.addEventListener(MouseEvent.CLICK, onMove);
			}
		}
		
		protected function onMove(e:MouseEvent):void {
			if (settings.callback)
				settings.callback();
			
			close();
		}
		
		override public function close(e:MouseEvent = null):void {
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, onStockEvent);
			super.close();
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
import wins.Window;
import wins.SimpleWindow;
import wins.ShopWindow;
import wins.PurchaseWindow;

internal class RequireItem extends Sprite {
	
	private var sID:int;
	private var have:int;
	private var need:int;
	private var window:*;
	
	private var titleLabel:TextField;
	private var countLabel:TextField;
	private var background:Shape = new Shape();
	private var iconBitmap:Bitmap = new Bitmap();
	
	public function RequireItem(sID:int, have:int, need:int, window:*):void {	
		this.sID = sID;
		this.have = have;
		this.need = need;
		this.window = window;
		
		drawCircle();
		addChild(iconBitmap);
		drawTitle();
		drawCount();
		drawButtons();
		Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onLoad);
	}
	
	public function drawTitle():void {
		titleLabel = Window.drawText(App.data.storage[sID].title + ':', {
			fontSize:24,
			autoSize:"left",
			textAlign:"center",
			color:0x763c17,
			borderColor:0xf5f2e9
		});
		titleLabel.x = (120 - titleLabel.width) / 2;
		titleLabel.y = 0;
		addChild(titleLabel);
	}
	
	public function drawCount():void {
		if (have < need) {
			countLabel = Window.drawText(String(have) + '/' + String(need), {
				fontSize:36,
				autoSize:"left",
				textAlign:"center",
				color:0xe78f79,
				borderColor:0x742226
			});
			countLabel.x = (120 - countLabel.width) / 2;
			countLabel.y = 100;
		} else {
			countLabel = Window.drawText(String(have) + '/' + String(need), {
				fontSize:36,
				autoSize:"left",
				textAlign:"center",
				color:0xffdd33,
				borderColor:0x664816
			});
			countLabel.x = (120 - countLabel.width) / 2;
			countLabel.y = 116;
		}
		
		addChild(countLabel);
	}
	
	private var circle:Shape;
	public function drawCircle():void {
		circle = new Shape();
		circle.graphics.beginFill(0xc8cabc, 1);
		circle.graphics.drawCircle(0, 0, 56);
		circle.graphics.endFill();
		circle.x = 56;
		circle.y = 80;
		addChild(circle);
	}
	
	public function onLoad(data:Bitmap):void {
		iconBitmap.bitmapData = data.bitmapData;
		Size.size(iconBitmap, 110, 110);
		iconBitmap.smoothing = true;
		iconBitmap.x = circle.x - iconBitmap.width / 2;
		iconBitmap.y = circle.y - iconBitmap.height / 2;
	}
	
	public function drawButtons():void {
		if (have < need) {
			var findBttn:Button = new Button({ 
				caption:Locale.__e('flash:1405687705056'),
				width:95,
				height:30,
				fontSize:20,
				bgColor:[0x82c9f6,0x5dacde],
				borderColor:[0xa0d5f6, 0x3384b2],
				fontColor:0xFFFFFF,
				fontBorderColor:0x435060,
				bevelColor:[0xc2e2f4, 0x3384b2],
				radius:10
			});
			findBttn.x = (120 - findBttn.width) / 2;
			findBttn.y = 142;
			addChild(findBttn);
			findBttn.addEventListener(MouseEvent.CLICK, onFind);
			
			var buyBttn:Button = new Button({ 
				caption:Locale.__e('flash:1382952379751'),
				width:110,
				height:38,
				fontSize:24,
				bgColor:[0xa2f545,0x7bbf1a],
				borderColor:[0xcefc97, 0x5f9c11],
				fontColor:0xFFFFFF,
				fontBorderColor:0x4d7d0e,
				bevelColor:[0xcefc97,0x5f9c11],
				radius:10
			});
			buyBttn.x = (120 - buyBttn.width) / 2;
			buyBttn.y = 175;
			addChild(buyBttn);
			buyBttn.addEventListener(MouseEvent.CLICK, onBuy);
		}
	}
	
	private function onFind(e:MouseEvent):void {
		if (ShopWindow.findMaterialSource(sID)) {
			window.close();
		} else {
			new SimpleWindow( {
				popup:true,
				height:300,
				width:420,
				title:App.data.storage[sID].title,
				text:Locale.__e('flash:1431964448191')
			}).show();
		}
	}
		
	private function onBuy(e:MouseEvent):void {
		if (e.currentTarget.mode == Button.DISABLED) return;
			
			/*if (settings.hasOwnProperty('disableAll'))
				settings.disableAll(true);*/
			
			var def:int = need - have;
			e.currentTarget.state = Button.DISABLED;
			App.user.stock.buy(sID, def, onBuyEvent);
			
		/*new PurchaseWindow( {
			itemsOnPage:3,
			content:PurchaseWindow.createContent('Energy', { view:App.data.storage[sID].view } ),
			title:Locale.__e('flash:1382952379751'),
			fontBorderColor:0xd49848,
			shadowColor:0x553c2f,
			shadowSize:4,
			popup:true
		}).show();*/
	}
	private function onBuyEvent(price:Object):void
		{
			for (var sid:* in price) {
				
				var pnt:Point = App.self.tipsContainer.localToGlobal(new Point(buyBttn.mouseX, buyBttn.mouseY));
				pnt.x += this.x + buyBttn.x; 
				pnt.y += this.y + buyBttn.y - 30; 
				
				Hints.minus(sid, price[sid], pnt, false);
				break;
			}
			
			clearInterval(intervalPluck);
			
			
			have = App.user.stock.count(sID);
		//	changeOnREADY();
			dispatchEvent(new WindowEvent("onContentUpdate"));
			
			/*if (settings.hasOwnProperty('disableAll'))
				settings.disableAll(false);*/
		}
}