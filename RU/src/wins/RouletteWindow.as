package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.ImagesButton;
	import buttons.MoneyButton;
	import buttons.UpgradeButton;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import ui.UpPanel;
	import ui.UserInterface;
	public class RouletteWindow extends Window 
	{
		public static const CURRENCY:int = 3;
		
		public static var expire:int = 0;
		public static var slots:Object = {};
		public static var rTry:Object = {};
		public static var rPositions:Object = {};
		public static var trying:int = 1;
		public static var canChoose:Boolean = true;
		
		public var background:Bitmap;
		
		private var buyBttn:Button;
		private var infoBttn:ImageButton;
		private var giftImageBttn:Bitmap;
		private var chest:Bitmap;
		private var items:Array;
		private var positions:Array;
		private var itemsContainer:Sprite;
		private var playBttnText:TextField;
		private var currenceCount:TextField;
		private var lastWin:TextField;
		private var jackpot:TextField;
		private var newSlots:Array = [];
		private var attempt:int = 0;
		//private var goBttn:UpgradeButton;
		private var goBttn:MoneyButton;
		private var curtain:Bitmap;
		
		public function RouletteWindow(settings:Object=null) 
		{
			if (!settings) settings = { };
			
			settings['width'] = 490;
			settings['height'] = 595;
			settings['autoClose'] = false;
			settings['title'] = Locale.__e('flash:1474469177843');//Капитан Немо
			settings['hasPaginator'] = false;
			settings["faderAlpha"] = 0.000000001;
			settings['background'] = 'cloverBacking';
			
			expire = App.data.roulette[1].time + App.data.roulette[1].jackpot[4] * 24 * 3600;
			
			super(settings);
			
			if (Numbers.countProps(rTry) != 0 && Numbers.countProps(rTry) != Numbers.countProps(slots))
			{
				trying = Numbers.countProps(slots) - Numbers.countProps(rTry) + 1;
			}
			
			//App.self.setOnTimer(drawJackpot);
			checkSlots();
			
			//this.x += 100;
		}
		
		private function init():void 
		{
			currenceCount.text = String(App.user.stock.count(CURRENCY));
			Post.send( {
				ctr:'Roulette',
				act:'init',
				sID:1,
				id:1,
				wID:App.user.worldID,
				uID:App.user.id
			}, function(error:int, data:Object, params:Object):void {
				if (error) return;
				
				if (data.hasOwnProperty('slots')) 
				{
					RouletteWindow.slots = data.slots;
					RouletteWindow.rTry = data.slots;
				}
				
				RouletteWindow.rPositions = { };
				
				trying = 1;				
				checkSlots();
				drawItems();
			});
		}
		
		override public function drawBackground():void {
			if (settings.background!=null) 
			{
			//var background:Bitmap = backing(settings.width, settings.height, 50, settings.background);
			background = new Bitmap(Window.textures.rouletteBacking);
			background.filters = [new GlowFilter(0xb0cda0, .5, 24, 24, 3)]; 
			layer.addChild(background);	
			}
		}
		
		private function checkSlots():void 
		{	
			newSlots = [];
			for (var slotID:* in slots)
			{
				var obj:Object = { };
				obj[slotID] = slots[slotID];
				newSlots.push(obj);
			}	
			
			schuffle();
			
			for (var pos:* in rPositions) 
			{
				for (var i:int = 0; i < newSlots.length; i++) 
				{
					var sid:*;
					
					for (var idSlot:* in newSlots[i])
					{
						for (sid in newSlots[i][idSlot]) break;
					}
					
					if (sid == rPositions[pos])
					{
						swap(i, pos);
					}
				}
			}
			
			function schuffle():void 
			{
				var length:uint = newSlots.length;
				
				while (length--) 
				{
					var n:int = Math.random() * (length + 1);
					var temp:Object = newSlots[length];
					newSlots[length] = newSlots[n];
					newSlots[n] = temp;
				}
			}
			
			function swap(x:uint, y:uint):void {
				var temp:* = newSlots[x];
				newSlots[x] = newSlots[y];
				newSlots[y] = temp;
			}
		}		
		
		private var upBack:Bitmap = new Bitmap();
		
		override public function drawBody():void 
		{
			exit.y = 40;
			exit.x = background.width - 80;
			this.x -= 100;
			fader.x += 100;
			this.y -= 50;
			fader.y += 50;
			drawTop();
			
			var centerContainer:Sprite = new Sprite();
			bodyContainer.addChild(centerContainer);
			
			
			
			/*upBack = Window.backing(settings.width - 100, 370, 40, "cloverInnerBacking"); //внутренняя подложка за айтемами
			upBack.x = settings.width / 2 - upBack.width / 2;
			upBack.y = -100;*/
			//centerContainer.addChild(upBack);
			
			/*curtain = new Shape();
			curtain.graphics.beginFill(0x848657, 0.8);
			curtain.graphics.drawRect(0, 0, 230, 30);
			curtain.graphics.endFill();
			bodyContainer.addChild(curtain);
			curtain.x = settings.width / 2 - curtain.width / 2;
			curtain.y = upBack.y + 225 + upBack.height;*/
			
			curtain = Window.backingShort(330, 'backingGrad', true);
			curtain.scaleY = 1;
			curtain.alpha = .7;
			curtain.smoothing = true;
			curtain.x = background.width / 2 - curtain.width / 2;
			curtain.y = background.height - curtain.height - 120;
			bodyContainer.addChild(curtain);
			
			centerContainer.y = - centerContainer.height/2 + 200;
			centerContainer.x += 90;
			
			itemsContainer = new Sprite();
			itemsContainer.x = 60;
			itemsContainer.y = 55;
			centerContainer.addChild(itemsContainer);
			
			drawItems();
			drawBot();
			//drawCroupier();
			drawCurrencyCount();	
			
			//Туториал для Рулетки
			/*if (UpPanel.rouletteTutorial) 
			{
				goBttn.showGlowing();
				goBttn.showPointing("top", 0, 0, goBttn.parent);
			}*/
		}
		
		override public function drawTitle():void 
		{
			var titleText:TextField = drawText(settings.title, {
				color				: 0xfaffff,
				multiline			: settings.multiline,			
				fontSize			: 46,
				textLeading	 		: settings.textLeading,	
				border				: true,
				borderColor 		: 0xb0632b,			
				borderSize 			: 4,	
				shadowColor			: 0x815b10,
				shadowSize			: 4,
				width				: settings.width,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50
			});
			
			//titleText.y = -40;
			//bodyContainer.addChild(titleText);			
		}
		
		private function drawTop():void
		{			
			//Лента
			/*var ribbon:Bitmap = new Bitmap(Window.textures.blueRibbon);
			ribbon.x = 80;
			ribbon.y = 10;
			bodyContainer.addChild(ribbon);*/
			
			var infoIcon:Bitmap = new Bitmap(new BitmapData(75,75, true, 0), 'auto', true);
			infoBttn = new ImagesButton(Window.textures.aksBttnNew);
			infoBttn.addEventListener(MouseEvent.CLICK, onInfo);
			
			/*Load.loading(Config.getImageIcon("quests/icons", "helpBttn"), function(data:Bitmap):void {
				infoBttn.bitmapData = data.bitmapData;				
				infoBttn.initHotspot();
			});*/
			//infoBttn = new Bitmap(Window.textures.helpBttnFreebie);
			
			infoBttn.x = exit.x;
			infoBttn.y = exit.y + exit.height - 25;
			bodyContainer.addChild(infoBttn);	
			
			//RouletteItemsWindow
			var giftImgSprite:Sprite = new Sprite();
			bodyContainer.addChild(giftImgSprite);
			
			//Кругляшок
			giftImageBttn = new Bitmap(Window.textures.blueRound);
			giftImageBttn.x = 30;
			giftImageBttn.y = 10;
			giftImgSprite.addChild(giftImageBttn);
			
			//Сундучок
			/*chest = new Bitmap(Window.textures.chestRouleteIco);
			chest.x = giftImageBttn.x + giftImageBttn.width / 2 - chest.width / 2 + 5;
			chest.y = giftImageBttn.y + giftImageBttn.height / 2 - chest.height / 2 + 5;
			chest.scaleX = chest.scaleY = 0.9;
			giftImgSprite.addChild(chest);	*/	
			
			giftImgSprite.addEventListener(MouseEvent.CLICK, onGiftShow);
			
			/*jackpot = drawText(Locale.__e('flash:1452617385941', String(1000000)), {
				width:		settings.width + 40,
				color:		0xf2f6df,
				borderColor:0x003144,
				fontSize:	31,
				textAlign:	'center'
			});
			
			jackpot.y = 15;
			bodyContainer.addChild(jackpot);*/
			
			//var roulette:Object = App.data.roulette[1].jackpot;
			//var textWin:String = String(Math.ceil(roulette[1] + roulette[2] * (roulette[4] * 24 * 3600 / roulette[3])));
			
			/*lastWin = drawText(Locale.__e('flash:1456327865881', textWin), {//Последний выигрыш %s
				width:		settings.width + 40,
				color:		0xf2f6df,
				borderColor:0x003144,
				fontSize:	28,
				textAlign:	'center'
			});
			lastWin.y = jackpot.y + lastWin.textHeight + 5;
			lastWin.x += 15;
			bodyContainer.addChild(lastWin);*/
		}
		
		private function drawBot():void 
		{			
			/*goBttn = new UpgradeButton(UpgradeButton.TYPE_R, {
				caption:			Locale.__e('flash:1474465958506'),//Играть
				widthButton:		190,
				height:				70,
				fontSize:			40,
				fontBorderColor:	0x06394a,
				fontColor:			0xfcf4dd
			});*/
			goBttn = new MoneyButton({
				caption			:Locale.__e("flash:1474465958506"),
				width			:170,
				height			:50,
				fontSize		:32,
				fontCountSize	:30,
				iconScale		:.95,
				fontCountBorder	:0x7f3d0e,	
				fontBorderColor	:0x7f3d0e,	
				countText		:90,
				type			:'gold',
				bgColor			:[0xfed132, 0xf8ac1b],
				borderColor		:[0xfaed73, 0xcb6b1e],
				bevelColor		:[0xfaed73, 0xcb6b1e]
			});
			
			goBttn.count = String(500);	
			
			goBttn.x = (background.width - goBttn.width) / 2;
			goBttn.y = background.height - goBttn.height - 50;
			bodyContainer.addChild(goBttn);
			//goBttn.textLabel.x = goBttn.x - goBttn.textLabel.width / 2 + 5;
			/*if (App.isSocial('MX', 'AI', 'YB')) 
			{
				goBttn.textLabel.y += 5;
			}else 
			{
				goBttn.textLabel.y -= 3;
			}*/
			goBttn.textLabel.y -= 3;
			goBttn.addEventListener(MouseEvent.CLICK, onPlay);
			
			var playText:TextField = drawText(Locale.__e('flash:1474466031215'), {//Играй и выигрывай!
				color:			0xffffff,
				borderColor:	0x7f3d0e,
				fontSize:		32,
				textAlign:		'center',
				width:			background.width
			});
			//playText.y = upBack.height + 105;
			playText.y = curtain.y + (curtain.height - playText.height) / 2 + 2;
			bodyContainer.addChild(playText);
		}
		
		private function drawCroupier():void 
		{
			var pirateGirl:Bitmap = new Bitmap();
			pirateGirl.bitmapData = Window.texture('pirateGirl');
			pirateGirl.x = settings.width - settings.width - pirateGirl.width + 70;
			pirateGirl.y = -20;
			bodyContainer.addChild(pirateGirl);
		}
		
		private var plate:Bitmap = null;
		
		private function drawCurrencyCount():void {			
			
			if (plate && plate.parent == bodyContainer) 
			{
				bodyContainer.removeChild(plate);
				plate = null;
			}
			
			//plate = backing(140, 140, 50, 'mineBackingMini');//Подложка за зоной покупки
			plate = new Bitmap(Window.textures.rouletteBubble);
			plate.x = background.width - plate.width / 2 - 25;
			plate.y = 310;
			bodyContainer.addChild(plate);
			
			/*var plateAbove:Bitmap = backing(115, 125, 48, 'itemBacking');
			plateAbove.x = plate.x + plate.width / 2 - plateAbove.width / 2;
			plateAbove.y = plate.y + plate.height / 2 - plateAbove.height / 2;
			bodyContainer.addChild(plateAbove);*/
			
			//Попугай лабудидабудай
			/*var hanger:Bitmap = new Bitmap();
			hanger.bitmapData = Window.texture('parrot');
			hanger.x = settings.width - 5;
			hanger.y = 110;
			bodyContainer.addChild(hanger);*/
			
			buyBttn = new Button( {
				caption:		Locale.__e('flash:1382952379751'),//Купить
				width:			90,
				height:			35,
				bgColor:		[0x70cef6,0x5e90d8],	//Цвета градиента
				borderColor:	[0x7c95a4,0x687e88],	//Цвета градиента
				bevelColor:		[0xd6f1ff, 0x405ea4],
				fontBorderColor:0x0f5385,
				fontSize:		24
			});
			
			buyBttn.x = plate.x + (plate.width - buyBttn.width) / 2;
			buyBttn.y = plate.y + plate.height - buyBttn.height - 27;
			bodyContainer.addChild(buyBttn);
			buyBttn.addEventListener(MouseEvent.CLICK, onBuy);
			
			var ico:Bitmap = new Bitmap(UserInterface.textures.blueCristal, "auto", true);//Жетон
			ico.smoothing = true;
			ico.x = buyBttn.x;
			ico.y = buyBttn.y - 50;
			//ico.scaleX = ico.scaleY = 0.4;
			bodyContainer.addChild(ico);
			
			currenceCount = Window.drawText(String(App.user.stock.count(CURRENCY)), {
				color:			0x9dfcff,
				borderColor:	0x0f5385,
				fontSize:		28
			});
			currenceCount.x = ico.x + ico.width + 1;
			currenceCount.y = ico.y + 5;
			bodyContainer.addChild(currenceCount);
		}
		
		public function onGiftShow(e:MouseEvent):void 
		{
			
			
			var items:Object = { };
			
			for (var catIndex:* in App.data.category) 
			{
				var itemsIndex:* = App.data.category[catIndex].order - 1 ;				
				var catItems:Object = App.data.category[catIndex].items;
				
				items[itemsIndex] = { };
				
				for (var itm:* in catItems) 
				{
					items[itemsIndex][itm] = catItems[itm];
				}
			}			
			
			new RouletteItemsWindow({
				popup:true,
				items:items
			}).show();
		}
		
		public function onBuy(e:MouseEvent = null):void
		{	
			RouletteWindow.canChoose = true;
			/*new PurchaseWindow( {
				width:558,
				itemsOnPage:3,
				//hasExit:false,
				content:PurchaseWindow.createContent("Energy", {inguest:0, view:'lucky_coin'}),
				title:App.data.storage[3].title,
				description:Locale.__e("flash:1382952379757"),
				closeAfterBuy:false,
				autoClose:false,
				popup: true,	
				shortWindow:true,
				callback:function(sID:int):void {
					var object:* = App.data.storage[sID];
					App.user.stock.add(sID, object);
					drawCurrencyCount();
				}
			}).show();*/
			new BanksWindow().show();
		}
		
		private function onInfo(e:MouseEvent):void 
		{
			var hintWindow:RouletteInfoWindow = new RouletteInfoWindow( {
				popup: true
			});
			hintWindow.show();
		}
		
		private function onPlay(e:MouseEvent):void {
			
			//Туториал для Рулетки
			/*if (UpPanel.rouletteTutorial) 
			{
				goBttn.hideGlowing();
				goBttn.hidePointing();
				UpPanel.rouletteTutorial = false;
			}*/
			
			if (e.currentTarget.mode == Button.DISABLED) return;			
			e.currentTarget.state = Button.DISABLED;
			
			if (!App.user.stock.take(2, 500)) {//цена перемешки
				goBttn.state = Button.NORMAL;
				onBuy();
				return;
			}
			
			RouletteWindow.canChoose = false;
			closeItems();
		}
		
		public function onChooseItem(card:RouletteItem):void {	
			var pos:int = 0;
			for (var i:int; i < positions.length; i++) {
				if (positions[i].x == card.x && positions[i].y == card.y) {
					pos = i;
					break;
				}
			}
			
			goBttn.state = Button.NORMAL;
			
			Post.send( {
				ctr:'Roulette',
				act:'play',
				sID:1,
				id:1,
				wID:App.user.worldID,
				uID:App.user.id,
				p:pos,
				'try':trying
			}, function(error:int, data:Object, params:Object):void {
				RouletteWindow.canChoose = true;
				if (error) return;
				
				trying++;
				
				if (data.hasOwnProperty('bonus')){
					card.openCard(data.bonus);
				}
				
				drawCurrencyCount();
				new RouletteRewardWindow( { 
					prize:data.bonus,
					popup:true
				} ).show();
				
				rPositions[pos] = card.sID;
				RouletteWindow.rTry = data['try'];
			});
		}
		
		private function drawItems():void {		
			clearItems();
			items = [];
			positions = [];
			var i:int = 0;
			var item:RouletteItem;
			for each (var slotItem:* in newSlots) {
				for (var slotID:* in slotItem) {
					var slot:Object = slotItem[slotID];
					var open:Boolean = false;
					if (!rTry.hasOwnProperty(slotID)) {
						open = true;
					}
					
					for (var sid:* in slot) {
						var count:int = slot[sid];
					}					
					
					/*for (var sl:* in slot) {
						for (var sid:* in slot[sl]) {
							var count:int = slot[sl][sid];
						}
					}*/
					
					
					
					item = new RouletteItem(this, { sid:int(sid), count:count, open:open } );
					item.x = (i % 3) * 140 + 15;//расстояние по горизонтали
					item.y = Math.floor(i / 3) * 135 - 145;//расстояние по вертикали
					itemsContainer.addChild(item);
					
					items.push(item);
					positions.push( { x:item.x, y:item.y } );
					i++;
					if (i == 9) break;
				}
			}
			
			if (items.length != 0 && Numbers.countProps(rTry) == Numbers.countProps(slots)) {
				RouletteWindow.canChoose = false;
				for each (var itemr:RouletteItem in items) {
					itemr.removeOnOutListener();
				}
				setTimeout(openItems, 1000);
			}
			
			if (items.length == 0) {
				for (i = 0; i < 9; i++) {
					item = new RouletteItem(this, { sid:0, count:0, open:open } );
					item.x = (i % 3) * 140 + 15;//расстояние по горизонтали
					item.y = Math.floor(i / 3) * 135 - 145;//расстояние по вертикали
					itemsContainer.addChild(item);
					
					items.push(item);
				}
				
				infoBttn.showGlowing();
				customGlowing(giftImageBttn);				
				//customGlowing(chest);				
			}
			//itemsContainer.x = upBack.x + (upBack.width - itemsContainer.width);
		}
		
		private function clearItems():void 
		{
			for each (var item:RouletteItem in items) 
			{
				if (item.parent != null)
					item.parent.removeChild(item);
				item.dispose();
			}
		}
		
		private function closeItems():void 
		{
			goBttn.state = Button.DISABLED;
			for each (var item:RouletteItem in items) 
			{
				if (item.sID != 0) 
				{
					setTimeout(item.closeCard, Math.random() * 1000);
				}
			}
			
			setTimeout(init, 1000);
		}
		
		private function openItems():void 
		{
			goBttn.state = Button.DISABLED;
			for each (var item:RouletteItem in items) 
			{
				setTimeout(item.openCard, Math.random() * 1000);
			}
			
			setTimeout(revertItems, 5000);
		}
		
		private function revertItems():void 
		{
			for each (var item:RouletteItem in items) 
			{
				item.removeOnOutListener();
				setTimeout(item.closeCard, Math.random() * 1000);
			}
			
			setTimeout(shuffleItems, 2000);
		}
		
		private function shuffleItems():void 
		{
			RouletteWindow.canChoose = false;
			
			var _array:Array = items.slice();
			var length:uint = _array.length;
			var n:int;
			while (length--) 
			{
				n = Math.random()*(length + 1);
				swap(length, n);
			}
			items = _array;
			
			var i:int = 0;
			for (i = 0; i < items.length; i++) 
			{
				TweenLite.to(items[i], 0.3, {x:positions[i].x, y:positions[i].y} );
			}
			
			attempt++;
			if (attempt < 5) 
			{
				setTimeout(shuffleItems, 300);
			} else {
				RouletteWindow.canChoose = true;
				attempt = 0;
				
				for (i = 0; i < items.length; i++) {
					items[i].addOnOutListener();
				}
			}
			
			function swap(x:uint, y:uint):void{
				var temp:* = _array[x];
				_array[x] = _array[y];
				_array[y] = temp;
			}
		}
		
		private function drawJackpot():void {
			if (expire >= App.time) {
				var roulette:Object = App.data.roulette[1].jackpot;
				var count:String = String(Math.ceil(roulette[1] + roulette[2] * ((App.time - (expire - roulette[4] * 3600 * 24)) / roulette[3])));
				//if (jackpot) jackpot.text = Locale.__e('flash:1456327936569', count);//Джекпот %s
			}else {
				
			}
		}
		
		override public function dispose():void 
		{
			buyBttn.removeEventListener(MouseEvent.CLICK, onBuy);
			infoBttn.removeEventListener(MouseEvent.CLICK, onInfo);
			giftImageBttn.removeEventListener(MouseEvent.CLICK, onGiftShow);
			//App.self.setOffTimer(drawJackpot);
			super.dispose();
		}
		
		private function customGlowing(target:*, callback:Function = null, colorGlow:uint = 0xFFFF00):void 
		{
			/*TweenMax.to(target, 1, { glowFilter: { color:colorGlow, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void {
				TweenMax.to(target, 0.8, { glowFilter: { color:colorGlow, alpha:0.6, strength: 7, blurX:6, blurY:6 }, onComplete:function():void {
					if (callback != null) {
						callback();
					}
				}});	
			}});*/
		}		
	}

}
import com.greensock.TweenLite;
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.utils.setTimeout;
import ui.UserInterface;
import units.Anime;
import units.Anime2;
import wins.SimpleWindow;
import flash.text.TextField;
import wins.RouletteWindow;
import wins.Window;

internal class RouletteItem extends Sprite
{
	public static const BG_WIDTH:int = 115;
	
	public var bg:Bitmap;
	public var bg_bot:Bitmap;
	public var bg_top:Bitmap;
	public var sID:int;
	public var count:int;
	public var open:Boolean = true;
	private var window:*;
	public var bgOpen:Bitmap;
	private var icon:Bitmap = new Bitmap();
	private var backIco:Bitmap = new Bitmap();
	private var center:int;
	private var contentSprite:LayerX = new LayerX();
	private var textSprite:Sprite = new Sprite();
	private var shellSprite:Sprite = new Sprite();
	private var counttext:TextField;
	private var titletext:TextField;
	private var needOpen:Boolean = false;
	private var needClose:Boolean = false;
	private var textOpen:TextField;
	private var currencyCount:TextField;
	private var botShell:Object;
	private var topShell:Object;
	private var animeBot:Bitmap = new Bitmap();
	private var animeTop:Anime;
	//private var openTimeout:uint
	private var openTimeout:uint = 0;
	public function RouletteItem(window:*, data:Object)
	{
		/*for (var ts:* in data.item.count) {
			
			this.sID = ts;
			this.count = data.item.count[ts];
		}*/		
		
		this.sID = data.sid;
		this.count = data.count;
		this.window = window;
		this.open = data.open;
		
		backIco.bitmapData = Window.textures.questionMark;//Знак вопроса
		animeBot = new Bitmap(Window.textures.shell_bot);
		animeBot.smoothing = true;
		animeBot.filters = [new DropShadowFilter(6.0, 90, 0, 0.6, 5.0, 5.0, 1.0, 3, false, false, false)];
		Size.size(animeBot, 90, 90);
		animeBot.x = -1;
		animeBot.y = 15;
		shellSprite.addChild(animeBot);
		/*Load.loading(Config.getSwf("Lottary", "shell_bot"), function(data:*):void {
			if (data.animation)
			{
				var framesType:String;
				for (framesType in data.animation.animations) break;
				animeBot = new Anime(data, framesType, data.animation.ax, data.animation.ay);
				
				shellSprite.addChild(animeBot);
				if(animeTop){
					shellSprite.swapChildren(animeBot, animeTop);
				}
				animeBot.addAnimation();
				Size.size(animeBot, 90, 90);
				backIco.x = (animeBot.width - backIco.width)/2
				backIco.y = (animeBot.height - backIco.height)/2
			}
		});*/
		
		Load.loading(Config.getSwf("Lottary", "shell_top_3"), function(data:*):void {
			
			if (data.animation)
			{
				var framesType:String;
				for (framesType in data.animation.animations) break;
				animeTop = new Anime(data, framesType, data.animation.ax, data.animation.ay);
				
				shellSprite.addChild(animeTop);
				animeTop.addAnimation();
				Size.size(animeTop, 90, 90);
				
			}
		});
		
		shellSprite.addChild(contentSprite);
		//shellSprite
		addChild(shellSprite);
		addChild(textSprite);
		
		
		
		//addChild(backIco);
		
		if (sID == 0) {
			return;
		}
		
		drawText();
		setState(0);
		
		Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].view), onLoad);
		
		addEventListener(MouseEvent.CLICK, onClick);
		addOnOutListener();
	}
	
	private function onLoad(data:*):void {
		if (icon.parent) {
			contentSprite.removeChild(icon);
			icon = new Bitmap();
		}
		icon.bitmapData = data.bitmapData;
		icon.smoothing = true;
		Size.size(icon, animeBot.height - 0, animeBot.height - 0);
		icon.x = (animeBot.width - icon.width) / 2;
		icon.y = (animeBot.width - icon.height) / 2;
		contentSprite.addChild(icon);
		
		contentSprite.tip = function():Object {
			return {
				title:App.data.storage[sID].title,
				text:App.data.storage[sID].description
			}
		}
		
		//drawTitle();
		drawCount();
		
		if (open) {
			setState(1);
		} else {
			setState();
		}
		
		if (needOpen) {
			needOpen = false;
			openCard();
		}
	}
	
	public function onClick(e:MouseEvent):void {
		if (!RouletteWindow.canChoose) return;
		if (contentSprite.visible == false) {
			RouletteWindow.canChoose = false;
			if (RouletteWindow.trying == 1) {
				removeOnOutListener();
				window.onChooseItem(this);
				return;
			}
			var that:* = this;
			new SimpleWindow( {
				popup:			true,
				showCoin:		true,
				hasTitle:		true,
				hasRouletteIcon:true,
				title:			Locale.__e('flash:1474469531767'),//Внимание!
				text:			Locale.__e('flash:1474469546960', String(App.data.roulette[1].cost[RouletteWindow.trying])),//Монетки Фортуны будут потрачены в количестве %s штук
				dialog:			true,
				height:			250,
				faderAsClose        :false,
				faderClickable      :false,
				confirm:function():void {
					if (RouletteWindow.trying != 1 && !App.user.stock.take(RouletteWindow.CURRENCY, App.data.roulette[1].cost[RouletteWindow.trying])) {
						window.onBuy();
						return;
					}
					removeOnOutListener();
					window.onChooseItem(that);
					setState(0);
				},
				cancel:function():void {
					RouletteWindow.canChoose = true;
					setState(0);
				}
			}).show();
		}
	}
	
	public function onOver(e:MouseEvent):void {
		//trace("OVER")
		if (!RouletteWindow.canChoose || contentSprite.visible) return;
		setState(2);
	}
	
	public function onOut(e:MouseEvent):void {
		if (!RouletteWindow.canChoose || contentSprite.visible) return;
		setState(0);
	}
	
	private function drawTitle():void {
		if (titletext) {
			contentSprite.removeChild(titletext);
			titletext = null;
		}
		titletext = Window.drawText(App.data.storage[sID].title, {
			color		:0x773d18,
			borderColor	:0xf9fce7,
			width		:animeBot.width - 15,
			textAlign	:'center',
			multiline	:true,
			wrap		:true
		});
		titletext.y = icon.y - titletext.height / 2 - 10;
		titletext.x = icon.x + (icon.width - titletext.width)/2;
		contentSprite.addChild(titletext);
	}
	
	private function drawCount():void 
	{
		if (counttext) {
			contentSprite.removeChild(counttext);
			counttext = null;
		}
		
		counttext = Window.drawText(String(count), {
			color		:0xfffdff,
			borderColor	:0x773d18,
			width		:animeBot.width,
			textAlign	:'right',
			multiline	:true,
			wrap		:true,
			fontSize	:24
		});
		counttext.x = animeBot.x - 5;
		counttext.y = animeBot.height - counttext.textHeight;
		contentSprite.addChild(counttext);
	}
	
	private function drawText():void {
		if (textSprite.numChildren > 0) {
			while (textSprite.numChildren > 0)
				textSprite.removeChildAt(0);
		}
		textOpen = Window.drawText(Locale.__e('flash:1382952379890'), {//Открыть
			color		:0x773d18,
			borderColor	:0xf9fce7,
			width		:animeBot.width,
			textAlign	:'center',
			multiline	:true,
			wrap		:true,
			fontSize	:26
		});
		textOpen.y = (animeBot.height - textOpen.textHeight) / 2 + 15;
		//textOpen.x = (animeBot.height - textOpen.textWidth) / 2;
		textSprite.addChild(textOpen);
		
		if (App.data.roulette[1].cost[RouletteWindow.trying] != 0) {
			
			textOpen.y = 15;
			
			var ico:Bitmap = new Bitmap(UserInterface.textures.blueCristal, "auto", true)
			ico.x = ico.width * 0.7 - 20;
			ico.y = textOpen.y + textOpen.textHeight + 4;
			Size.size(ico, 35, 35);
			//ico.scaleX = ico.scaleY = 0.4;
			textSprite.addChild(ico);
			
			currencyCount = Window.drawText(String(App.data.roulette[1].cost[RouletteWindow.trying]), {
				color:			0xfffaff,
				borderColor:	0x752f00,
				fontSize:		30
			});
			currencyCount.x = ico.x + ico.width + 2;
			currencyCount.y = ico.y + (ico.height - currencyCount.textHeight) / 2;
			textSprite.addChild(currencyCount);
		}
	}
	
	public function openCard(newCard:Object = null):void {
		
		animeTop.startAnimationOnce();
		//animeBot.startAnimationOnce();
		needClose = true;
		/*var newBg:Bitmap = new Bitmap(Window.textures.shell_open);//Подложка айтемов
		bg.bitmapData = newBg.bitmapData;
		bg.y = 0;
		center = bg.width / 2;*/
		if (newCard != null) {
			for(var s:* in newCard){
					var count:int = newCard[s];
			}
			this.sID = s;
			this.count = count;
			
			App.user.stock.add(s, count);
			
			needOpen = true;
			Load.loading(Config.getIcon(App.data.storage[s].type, App.data.storage[s].view), onLoad);
			return;
		}
		showSide(true);
		//TweenLite.to(this, 0.2, {scaleX:0, x:this.x + center, onComplete:showSide, onCompleteParams:[true]});
	}
	
	public function closeCard():void {
		//if (!contentSprite.visible) return;
		if (needClose)
		{
			animeTop.startAnimationReverce();
			//animeBot.startAnimationReverce();
			needClose = false;
		}
		/*var newBg:Bitmap = new Bitmap(Window.textures.shell_close);//Подложка айтемов
		bg.bitmapData = newBg.bitmapData;
		bg.y = 46;
		if (!contentSprite.visible) return;
		center = bg.width / 2;*/
		//TweenLite.to(this, 0.2, {scaleX:0, x:this.x + center, onComplete:showSide, onCompleteParams:[false]});
		showSide(false);
		
	}
	
	private function showSide(front:Boolean = true):void {
		setState(int(front));
		/*TweenLite.to(this, 0.2, { scaleX:1, x:this.x - center, onCompleteParams:[front], onComplete:function(front:Boolean):void{
			if (front) {
				addOnOutListener();
			}
		}});*/
		if (front) {
				addOnOutListener();
			}
	}
	
	/* Состояния карты:
		 0 - карта повернута рубашкой
		 1 - карта повернута лицевой стороной
		 2 - показываем текст на карте
	 * */
	private function setState(state:int = 0):void {
		switch(state) {
			case 0:
				//openTimeout = setTimeout(function():void {
					backIco.visible = true;
					contentSprite.visible = false;
					textSprite.visible = false;
				//}, 1000);
				
				break;
			case 1:
				openTimeout = setTimeout(function():void {
					backIco.visible = false;
					contentSprite.visible = true;
					textSprite.visible = false;
				}, 400);
				
				break;
			case 2:
				//openTimeout = setTimeout(function():void {
				backIco.visible = false;
				contentSprite.visible = false;
				drawText();
				textSprite.visible = true;
				//}, 1000);
				
				break;
		}
	}
	
	public function addOnOutListener():void {
		addEventListener(MouseEvent.MOUSE_OVER, onOver);
		addEventListener(MouseEvent.MOUSE_OUT, onOut);
	}
	
	public function removeOnOutListener():void {
		removeEventListener(MouseEvent.MOUSE_OVER, onOver);
		removeEventListener(MouseEvent.MOUSE_OUT, onOut);
	}
	
	public function dispose():void {
		removeOnOutListener();
		removeEventListener(MouseEvent.CLICK, onClick);
	}
}