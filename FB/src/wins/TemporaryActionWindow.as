package wins 
{
	import buttons.Button;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	import ui.UserInterface;
	import units.Booker;
	import wins.elements.TimerUnit;
	public class TemporaryActionWindow extends Window 
	{
		private var timerText:TextField;
		private var descriptionLabel:TextField;
		private var actionItems:Array = [];
		private var action:Object;
		private var titleSid:Number;
		private var itemToSaleBitmap:Bitmap = new Bitmap();		
		private var itemToSaleLeft:Bitmap = new Bitmap();		
		private var itemToSaleRight:Bitmap = new Bitmap();
		
		public static const VISIBLE_PROMOS:Array = ["1562", "1811", "1813", "1815", "1817", "1922", "1924", "1926", "1928", "1930", "1932", "1934"];
		public static const INVISIBLE_PROMOS:Array = ["1583", "1810", "1812", "1814", "1816", "1921", "1923", "1925", "1927", "1929", "1931", "1933"];
		
		private var _pID:String;
		
		public function get promosPair():Object 
		{
			return { sid1:_pID, sid2:INVISIBLE_PROMOS[VISIBLE_PROMOS.indexOf(_pID)] };
		}
		
		private var _promo1:Object;
		private var _promo2:Object;
		
		public function TemporaryActionWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			_pID = settings["pID"];
			
			_promo1 = App.data.actions[promosPair.sid1];
			_promo2 = App.data.actions[promosPair.sid2];
			
			action = App.data.actions[settings.pID];
			action['id'] = settings.pID;
			
			titleSid = Booker.UNDINA_EXPENSIVE;			
			settings['title'] = App.data.storage[titleSid].title;
			settings['width'] 			= 750;
			settings['height'] 			= 550;
			settings['hasPaginator'] 	= false;
			settings['hasButtons']		= false;
			settings['background'] 		= 'buildingBacking';		
			
			super(settings);
		}
		
		private function drawDecorations():void 
		{			
			drawMirrowObjs('storageWoodenDec', 0, settings.width - 0, settings.height - 130);
		}
		
		override public function drawTitle():void 
		{
			
			titleLabel = titleText( {
				title				: settings.title,
				color				: 0xffffff,
				multiline			: settings.multiline,			
				fontSize			: 46,
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
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -50;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			
			headerContainer.addChild(titleLabel);
			headerContainer.mouseEnabled = false;			
		}
		
		override public function drawBackground():void 
		{
			if (settings.background!=null) 
			{
			var background:Bitmap = backing(settings.width, settings.height, 50, settings.background);
			layer.addChild(background);	
			}
		}
		
		override public function drawBody():void 
		{
			exit.y -= 30;
			exit.x -= 5;	
			
			drawMirrowObjs('storageWoodenDec', 0, settings.width - 0, 25, false, false, false, 1, -1);
			var robb:Bitmap = backingShort(settings.width, 'bigGoldRibbon');
			robb.y = -80;
			bodyContainer.addChild(robb);
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 +5, settings.width / 2 + settings.titleWidth / 2 -5, -90, true, true);
			
			var titleText:TextField = drawText(Locale.__e('flash:1450087356504'), {
				color:			0xffd84f,
				borderColor:	0x5c300d,
				fontSize:		26
			});
			titleText.width = titleText.textWidth + 6;
			titleText.x = (settings.width - titleText.width) / 2;
			titleText.y = -40;
			bodyContainer.addChild(titleText);
			
			var bottomText:TextField = drawText(Locale.__e('flash:1450087428851'), {
				color:			0xffffff,
				borderColor:	0x56321a,
				fontSize:		26
			});
			bottomText.width = bottomText.textWidth + 6;
			bottomText.x = (settings.width - bottomText.width) / 2;
			bottomText.y = settings.height - 100;
			bodyContainer.addChild(bottomText);
			
			var bigShine:Bitmap = new Bitmap(Window.texture('glowingBackingNew'));
			bigShine.scaleX = bigShine.scaleY = 2;
			bigShine.smoothing = true;
			bigShine.x = (settings.width - bigShine.width) / 2;
			bigShine.y = settings.height/2-bigShine.height/2-70;
			bodyContainer.addChild(bigShine);			
			
			drawDecorations();
			drawTimer();
			drawItems();
			
			Load.loading(Config.getImage('promo/images', 'undina_buh_center'), onLoadIcon);
			bodyContainer.addChild(itemToSaleBitmap);
			
			Load.loading(Config.getImage('promo/images', 'undina_buh_right'), onLoadIconLeft);
			bodyContainer.addChild(itemToSaleLeft);
			
			Load.loading(Config.getImage('promo/images', 'undina_buh_left'), onLoadIconRight);
			bodyContainer.addChild(itemToSaleRight);
			//drawSale();
		}
		
		private function onLoadIcon(data:*):void 
		{	
			itemToSaleBitmap.bitmapData = data.bitmapData;
			itemToSaleBitmap.x = (settings.width - itemToSaleBitmap.width) / 2 + 10;
			itemToSaleBitmap.y = 0;
			itemToSaleBitmap.scaleX = itemToSaleBitmap.scaleY = 1;
		}
		
		private function onLoadIconRight(data:*):void 
		{	
			itemToSaleRight.bitmapData = data.bitmapData;
			itemToSaleRight.x = (settings.width - itemToSaleRight.width) / 2 + 170;
			itemToSaleRight.y = 100;
			itemToSaleRight.scaleX = itemToSaleRight.scaleY = 0.7;
		}
		
		private function onLoadIconLeft(data:*):void 
		{	
			itemToSaleLeft.bitmapData = data.bitmapData;
			itemToSaleLeft.x = (settings.width -itemToSaleLeft.width) / 2 - 280;
			itemToSaleLeft.y = 100;
			itemToSaleLeft.scaleX = itemToSaleLeft.scaleY = 0.75;
		}
		
		private function drawTimer():void {
			var timer:TimerUnit = new TimerUnit( {backGround:'glow',width:140,height:60,time: { started:action.begin_time, duration:action.duration}} );
			timer.start();
			timer.x = (settings.width - timer.width) / 2
			timer.y = settings.height - 180;
			bodyContainer.addChild(timer);
		}
			//1 block		
		private function drawItems():void 
		{
			//var item:ActionItem = new ActionItem( {qID:1583, price1:40, price2:1, price3:10}, this);
			var item:ActionItem = new ActionItem( {qID:promosPair.sid2, price1:_promo2.price[App.SOCIAL], price2:1, price3:10}, this);
			item.x = 10;
			item.y = 30;
			bodyContainer.addChild(item);
			actionItems.push(item);
			//2 block				
			//var item2:ActionItem = new ActionItem( {qID:1562, price1:200, price2:6, price3:20} , this);
			var item2:ActionItem = new ActionItem( {qID:promosPair.sid1, price1:_promo1.price[App.SOCIAL], price2:6, price3:20} , this);
			item2.x =settings.width-item2.width+10;
			item2.y = 30;
			bodyContainer.addChild(item2);
			actionItems.push(item2);
		}
	
		private function drawSale():void {
			var sprite:Sprite = new Sprite();
			sprite.x = -30;
			sprite.y = -40;
			var label:Bitmap = new Bitmap(UserInterface.textures.saleLabelBank);
			label.smoothing = true;
			var textAction:TextField = Window.drawText(Locale.__e('flash:1450087466832'), {
				color: 0xffffff,
				borderColor: 0x765134,
				fontSize: 28
			});
			textAction.width = textAction.textWidth + 5;
			textAction.x = (label.width - textAction.textWidth) / 2;
			textAction.y = (label.height - textAction.textHeight) / 2;
			
			sprite.addChild(label);
			sprite.addChild(textAction);
			
			bodyContainer.addChild(sprite);
		}
		
		public function blockButtons(block:Boolean):void 
		{
			var item:ActionItem;
			if (block) {
				for each (item in actionItems) {
					item.buyBttn.state = Button.DISABLED;
				}
			}else {
				for each (item in actionItems) {
					item.buyBttn.state = Button.NORMAL;
				}
			}
		}
		
		override public function dispose():void 
		{
			super.dispose();
		}		
	}
}

import buttons.Button;
import core.Load;
import core.Numbers;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.UserInterface;
import units.Booker;
import wins.SimpleWindow;
import wins.Window;

internal class ActionItem extends LayerX {
	private var window:*;
	private var data:Object;
	public var buyBttn:Button;
	public var action:Object;
	private var bg:Bitmap;
	private var cont:Sprite;
	private var oneSign:TextField = new TextField();
	private var _itemInfo:Object;
	
	public function ActionItem(data:Object, window:*) {
		this.data = data;
		this.window = window;
		this.action = App.data.actions[data.qID];
		action['id'] = data.qID;
		
		_itemInfo = App.data.storage[Numbers.firstProp(action.items).key];
		
		drawBlock();
		drawButton();
	}
	
	private function drawBlock():void 
	{
		cont = new Sprite();
		cont.x = 10;
		addChild(cont);
		bg = Window.backing(265, 375, 50, 'paperBacking');
		cont.addChild(bg);
		
		bg.y += 20;
		
		//1		
		var text:TextField = Window.drawText(Locale.__e('flash:1450087516552'), {//Получи до
			color:			0xFFFFFF,
			borderColor:	0x000000,
			fontSize:		27
		});
		text.x = 50;
		text.y = 35;
		cont.addChild(text);
		
		var number:TextField = Window.drawText(data.price1, {//сколько
			color:			0x93C9FF,
			borderColor:	0x464646,
			borderSiza:1,
			fontSize:		27
		});
		number.x = text.x + text.textWidth + 10;
		number.y = text.y;
		cont.addChild(number);
		
		var gem:Bitmap = new Bitmap(UserInterface.textures.blueCristal);
		gem.scaleX = gem.scaleY = 0.7;
		gem.smoothing = true;
		gem.x = number.x + number.textWidth + 10;
		gem.y = number.y;
		cont.addChild(gem);
		
		//2
		var arrow1:Bitmap = new Bitmap(Window.textures.backpackArrow);
		arrow1.scaleX = 0.6;
		arrow1.smoothing = true;
		arrow1.x = bg.width/2-arrow1.width/2-10;
		arrow1.y = text.y + 60;
		cont.addChild(arrow1);
		
		var gemBig1:Bitmap = new Bitmap(UserInterface.textures.blueCristal);
	
		gemBig1.smoothing = true;
		gemBig1.x = arrow1.x + arrow1.width + 10;
		gemBig1.y = arrow1.y ;
		cont.addChild(gemBig1);
		
		var number1:TextField = Window.drawText(data.price2, {   //цена 
			color:			0x93C9FF,
			borderColor:	0x464646,
			borderSiza:1,
			fontSize:		34
		});
		number1.x = gemBig1.x +gemBig1.width;
		number1.y = gemBig1.y+gemBig1.height/2-number1.textHeight/2;
		cont.addChild(number1);
		
		/*var sids:Object = {
			1562:Booker.UNDINA_EXPENSIVE,
			1583:Booker.UNDINA_CHEAP,
			1810:Booker.UNDINA_CHEAP,
			1811:Booker.UNDINA_EXPENSIVE,
			1812:Booker.UNDINA_CHEAP,
			1813:Booker.UNDINA_EXPENSIVE,
			1814:Booker.UNDINA_CHEAP,
			1815:Booker.UNDINA_EXPENSIVE,
			1816:Booker.UNDINA_CHEAP,
			1817:Booker.UNDINA_EXPENSIVE,
			1921:Booker.UNDINA_CHEAP,
			1922:Booker.UNDINA_EXPENSIVE,
			1923:Booker.UNDINA_CHEAP,
			1924:Booker.UNDINA_EXPENSIVE,
			1925:Booker.UNDINA_CHEAP,
			1926:Booker.UNDINA_EXPENSIVE,
			1927:Booker.UNDINA_CHEAP,
			1928:Booker.UNDINA_EXPENSIVE,
			1929:Booker.UNDINA_CHEAP,
			1930:Booker.UNDINA_EXPENSIVE,
			1931:Booker.UNDINA_CHEAP,
			1932:Booker.UNDINA_EXPENSIVE,
			1933:Booker.UNDINA_CHEAP,
			1934:Booker.UNDINA_EXPENSIVE
		}*/
		
		var desc1:TextField=Window.drawText('0', {
			fontSize:21,
			autoSize:"center",
			textAlign:"center",
			color:0x8b4b1f,
			borderColor:0xffffcc,
			border:true,
			borderSiza:1,
			width:220,
			wrap:true,
			multiline:true   
		});
		//desc1.text = App.data.storage[sids[data.qID]].description;
		desc1.text = _itemInfo.description;
		desc1.x = 20
		desc1.y = arrow1.y+arrow1.height+30;
		cont.addChild(desc1);
		
		//calendar
		var arrow2:Bitmap = new Bitmap(Window.textures.backpackArrow);
		arrow2.scaleX = 0.6;
		arrow2.smoothing = true;
		arrow2.x = arrow1.x;
		arrow2.y = desc1.y + desc1.textHeight+20;
		cont.addChild(arrow2);
		
		var gemBig2:Bitmap = new Bitmap(UserInterface.textures.blueCristal);
	
		gemBig2.smoothing = true;
		gemBig2.x = arrow2.x + arrow1.width + 10;
		gemBig2.y = arrow2.y ;
		cont.addChild(gemBig2);
		
		var number2:TextField = Window.drawText(data.price3, {   //цена 
			color:			0x93C9FF,
			borderColor:	0x464646,
			borderSiza:1,
			fontSize:		34
		});
		number2.x = gemBig2.x +gemBig2.width;
		number2.y = gemBig2.y+gemBig2.height/2-number2.textHeight/2;
		cont.addChild(number2);
		
		var desc2:TextField=Window.drawText('0', {
			fontSize:21,
			autoSize:"center",
			textAlign:"center",
			color:0x8b4b1f,
			borderColor:0xffffcc,
			border:true,
			borderSiza:1,
			width:220,
			wrap:true,
			multiline:true   
			});
		desc2.text =Locale.__e('flash:1450093735356')+" "+data.price3+" "+Locale.__e('flash:1450093786160') ;
		desc2.x = 20
		desc2.y = arrow2.y+arrow2.height+10;
		cont.addChild(desc2);
		
		var calendar:Bitmap = new Bitmap(UserInterface.textures.interCalendarIco);
		calendar.x = arrow2.x - calendar.width - 10;
		calendar.y= arrow2.y;
		cont.addChild(calendar);
		
	}
	
	private function drawButton():void {
		
		buyBttn = new Button( {
			width:			160,
			height:			50,
			caption:		Payments.price(action.price[App.social]),
			textAlign:		'center',
			fontSize:		32,
			color:			0xfffa99,
			borderColor:	0x054f14,
			shadowSize:		1
		})
		
		buyBttn.textLabel.y += 2;
		buyBttn.x = bg.width/2-buyBttn.width/2;
		buyBttn.y = bg.height-buyBttn.height/2;
		cont.addChild(buyBttn);
		
		if (App.isSocial('MX')) {
			var mxLogo:Bitmap = new Bitmap(UserInterface.textures.mixieLogo);
			mxLogo.scaleX = mxLogo.scaleY = 0.8;
			buyBttn.addChild(mxLogo);
			mxLogo.y = buyBttn.textLabel.y - (mxLogo.height - buyBttn.textLabel.height)/2;
			mxLogo.x = buyBttn.textLabel.x-10;
			buyBttn.textLabel.x = mxLogo.x + mxLogo.width + 5;
		}
		
		buyBttn.addEventListener(MouseEvent.CLICK, onBuy);
	}
	
	private function onBuy(e:MouseEvent):void {
		if (e.currentTarget.mode == Button.DISABLED) return;
		
		window.blockButtons(true);
		
		Payments.buy( {
			type:			'promo',
			id:				action.id,
			price:			int(action.price[App.social]),
			count:			1,
			title: 			Locale.__e('flash:1396521604876'),
			description: 	Locale.__e('flash:1393581986914'),
			callback:		onBuyComplete,
			error:			function():void {
				window.close();
			},
			icon:			getIconUrl(action)
		});
	}
	
	private function onBuyComplete(e:* = null):void {
		window.blockButtons(false);
		
		// Открыть зону и убрать ее из списка зачисления на склад
		for (var s:String in action.items) {
			if (App.data.storage[s].type == 'Zones') {
				if (App.user.world.zones.indexOf(int(s)) < 0) {
					App.user.world.onOpenZone(0, { }, { sID:int(s), require:{} } );
				}
				delete action.items[s];
			}
		}
		
		App.user.stock.addAll(action.items);
		App.user.stock.addAll(action.bonus);
		
		for(var item:* in action.items) {
			var bonus:BonusItem = new BonusItem(item, action.items[item]);
			var point:Point = Window.localToGlobal(buyBttn);
				bonus.cashMove(point, App.self.windowContainer);
		}
		
		App.user.buyPromo(action.id);
		App.ui.salesPanel.createPromoPanel();
		
		window.close();
		
		new SimpleWindow( {
			label:SimpleWindow.ATTENTION,
			title:Locale.__e("flash:1393579648825"),
			text:Locale.__e("flash:1382952379990")
		}).show();
	}
	
	public function getIconUrl(promo:Object):String {
		if (promo.hasOwnProperty('iorder')) {
			var _items:Array = [];
			for (var sID:* in promo.items) {
				_items.push( { sID:sID, order:promo.iorder[sID] } );
			}
			_items.sortOn('order');
			sID = _items[0].sID;
		}else {
			sID = promo.items[0].sID;
		}
		
		return Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview);
	}

}