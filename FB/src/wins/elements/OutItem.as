package wins.elements 
{

	import buttons.Button;
	import buttons.MoneyButton;
	import com.greensock.TweenMax;
	import core.Load;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import ui.UserInterface;
	import wins.Window;

	//Вспомогательный класс
	public class OutItem extends Sprite{
		
		public var background:Bitmap = null;
		public var bitmap:Bitmap = null;
		public var sID:String;
		
		public var title:TextField = null;
		public var timeText:TextField = null;
		public var recipeText:TextField = null;
		public var recipeBttn:Button;
		public var jamTick:LayerX;
		public var jamTickBitmap:Bitmap;
		public var icon:Bitmap
		public var buyBttn:MoneyButton
		public var fontSize:int = 22;
		private var price:uint = 0;
		public var preloader:Preloader = new Preloader();
		public var sprTip:LayerX = new LayerX();
		public var stopGlowing:Boolean = false;
		
		private var settings:Object = { 
			bttnText		:Locale.__e("flash:1382952380036"),
			hasBuyBttn		:false,
			onBuy			:function():void { },
			timeColor		:0xfff2d3,
			timeborderColor	:0x6d3e1b,
			bitmapSize		:80,
			border			:true
		};
		private var timeDesc:LayerX;
		
		public function OutItem(onCook:Function, settings:Object = null)
		{
			if (settings != null)
			{
				for (var key:* in settings)
					this.settings[key] = settings[key];
			}
			
			settings['bttnText'] = settings.recipeBttnName;
			//if (settings.hasOwnProperty('border'))
				//this.settings['border'] = settings.border;
			//else
				//this.settings['border'] = true;
			this.sID = settings.sID ;
			
			var backgroundShape:Shape = new Shape();
			backgroundShape.graphics.beginFill(0xe59e79);
			backgroundShape.graphics.drawCircle(50, 50, 50);
			backgroundShape.graphics.endFill();
			
			background = new Bitmap(new BitmapData(100, 100, true, 0));
			background.bitmapData.draw(backgroundShape);
			
			//background = new Bitmap(Window.textures.bgOutItem);//Window.backing(170, 270, 10, "bgItem");
			addChild(background);
			
			if (contains(sprTip)) {
				removeChild(sprTip);
				sprTip = new LayerX();
			}
			bitmap = new Bitmap();
			sprTip.addChild(bitmap);
			addChild(sprTip);
			
			title = Window.drawText("", {
				fontSize:24,
				border:settings.border,
				color:0x70401d,
				borderColor:0xfff6e8,
				textLeading: -6,
				multiline:true,
				textAlign:"center",
				//autoSize:"center",
				width:background.width - 50,
				wrap:true
			});
			
			addChild(title);
			title.wordWrap = true;
			
			title.y = background.y;
			//removeChild(bitmap);
			
			//bitmap = new Bitmap();
			//addChild(bitmap);
			
			addChild(preloader);
			preloader.x = (background.width) / 2;
			preloader.y = (background.height) / 2;
			timeDesc = new LayerX();
			icon = new Bitmap(Window.textures.timerDark);
			timeDesc.addChild(icon);
			
			icon.x = 0;
			icon.y = 80;
			if (settings.target.booster)
				this.settings.timeColor = 0xfffa74;
			timeText = Window.drawText("", {
				borderSize		:4,
				fontSize		:26,
				color			:this.settings.timeColor,
				borderColor		:this.settings.timeborderColor
			});
			timeDesc.addChild(timeText);
			
			timeText.x = icon.x + icon.width +2 ;
			timeText.y = icon.y + (icon.height - timeText.height)/2;
			
			recipeBttn = new Button( {
				width:123,
				fontSize:26,
				radius:19,
				caption:Locale.__e("flash:1382952380036"),
				fontSize:26,
				height:44,
				bgColor:				[0xc6ea6a,0x85ba38],//Цвета градиента
				fontBorderColor:		0x53742d,	
				bevelColor:				[0xf5feb8, 0x648a38],
				eventPostManager:true
				
			});
			addChild(timeDesc);
			timeDesc.y = background.height - 77 - 0;
			addChild(recipeBttn);
			recipeBttn.x = (background.width - recipeBttn.width) / 2;
			recipeBttn.y = timeText.y +timeText.height + 30;
			recipeBttn.addEventListener(MouseEvent.CLICK, onCook)
			//var recipeText = Window.drawText(Locale.__e("flash:1382952380097"), {
				//fontSize:24,
				//color:0x814f31,
				//borderColor:0xfaf9ec,
				//textLeading: -6,
				//multiline:true,
				//textAlign:"center",
				////autoSize:"center",
				//width:background.width - 50,
				//wrap:true
			//});
			//addChild(recipeText);
			
			
			
			jamTick = new LayerX();
			jamTickBitmap = new Bitmap(UserInterface.textures.tick);
			jamTick.addChild(jamTickBitmap);
			addChild(jamTick);
			jamTick.x = background.width - jamTick.width + 10;
			jamTick.y = 0;
			jamTick.visible = false;
			jamTick.tip = function():Object { 
				return {
					title:"",
					text:""//Locale.__e("flash:1382952379767 варенья переполнен.")
				};
			};
			
			
			/*if (App.user.quests.currentQID == 8 && App.user.quests.currentMID == 1) {
				glowing();
			}*/
			
			if (settings.hasOwnProperty('formula') && settings.formula.count > 1)
				drawCount();
			
				
			
			if (!settings.hasBuyBttn) return;
			
			buyBttn = new MoneyButton({
				caption		:Locale.__e('flash:1382952379751'),
				width		:121,
				height		:50,
				fontSize	:22,
				radius		:16,
				fontColor:0xffffff,
				fontBorderColor:0x53742d,
				fontCountColor:0xffffff,				
				fontCountBorder:0x53742d,
				
				bgColor     :[0xa8f84a,0x74bc17],
				bevelColor :[0xc8fa8f,0x5f9c11], 
				
				countText	:0,
				multiline	:true
			});
			buyBttn.textLabel.x -= 2;
			buyBttn.coinsIcon.y -= 1;
			buyBttn.coinsIcon.x -= 1;
			buyBttn.countLabel.y += 3;
			buyBttn.countLabel.x += 3;
			addChild(buyBttn);
			
			buyBttn.x = (background.width - buyBttn.width) / 2;
			buyBttn.y = background.height - buyBttn.height / 2 - 8;
			buyBttn.addEventListener(MouseEvent.CLICK, settings.onBuy);
			
			buyBttn.visible = false;
			
			
		}
			public function flyMaterial():void
		{
			var item:BonusItem = new BonusItem(uint(sID), 0);
			
			var point:Point = Window.localToGlobal(bitmap);
			point.y += bitmap.height / 2;
			
			item.cashMove(point, App.self.windowContainer);
			
			App.user.stock.add(int(sID), settings.formula.count);
		}
		
		public function change(formula:Object):void
		{
			if (title.parent != null) title.parent.removeChild(title);
			
			var size:Point = new Point(100, 50);
			var pos:Point = new Point(
				(background.width - size.x) / 2,
				background.y - size.y / 2
			);
			
			title = Window.drawTextX(App.data.storage[formula.out].title, size.x, size.y, pos.x, pos.y, this, {
				fontSize		:24,
				border			:settings.border,
				color			:0x814f31,
				borderColor		:0xfaf9ec,
				textLeading		: -6
			}, "up");
				
			sID = formula.out;
			var iconUrl:String
			
			if (formula.hasOwnProperty('iconUrl'))
				iconUrl = formula.iconUrl;
			else
				iconUrl = Config.getIcon(App.data.storage[formula.out].type, App.data.storage[formula.out].preview);
			
			Load.loading(iconUrl, onPreviewComplete);
			
			if (formula.time)
			{
				var currentTime:uint = formula.time;
				if (settings.target.booster)
					currentTime -= currentTime * 0.01 * settings.target.booster.boostPercent;
				timeText.text = TimeConverter.timeToCuts(currentTime, false, false);
				timeText.height = timeText.textHeight + 6;
				timeDesc.x = (background.width - icon.width - timeText.textWidth + 5)/2
			} else
			{
				var time:TextField = Window.drawText(Locale.__e("flash:1428061669314"), {
					color:0xFFFFFF,
					borderColor:0x763b18,
					fontSize:26,
					borderSize:4,
					letterSpacing:1,
					autoSize:"left"
				});
				addChild(time);
				icon.visible = false;
				time.x = background.x + (background.width - time.width) / 2;
				time.y = recipeBttn.y -  time.height - 4;//background.y + background.height + 6;
			}
			
		/*	if (formula.time == null)
			{
				timeText.visible = false;
				icon.visible = false;
			}
			else
			{
				
			}*/
			
			var info:Object = App.data.storage[sID];
			sprTip.tip = function():Object {
				return {
					title: info.title,
					text: info.description
				};
			}
			
			if (!settings.hasBuyBttn) return;
			
			price = 1;//info.unlock.price;
			buyBttn.count = String(price);
			
				
		}
		
		private function glowing():void {

			if (App.user.quests.tutorial) {
				customGlowing(recipeBttn);
				App.user.quests.currentTarget = recipeBttn;
				App.user.quests.lock = false;
				Quests.lockButtons = false;
				return;
			}
			
			customGlowing(background, glowing);
			if (recipeBttn) {
				customGlowing(recipeBttn);
			}
		}
		
		public function drawCount():void {
			var counterSprite:LayerX = new LayerX();
			counterSprite.tip = function():Object { 
				return {
					title:"",
					text:Locale.__e("flash:1382952380064")
				};
			};
			
			var countOnStock:TextField = Window.drawText("x "+settings.formula.count, {
				color:0xffffff,
				borderColor:0x1d356e,
				fontSize:18,
				autoSize:"left"
			});
			
			var width:int = countOnStock.width + 24 > 30 ? countOnStock.width + 24 : 30;
			//var bg:Bitmap = Window.backing(width, 40, 10, "smallBacking");
			var bg:Bitmap = new Bitmap(Window.textures.clearBubbleBacking); //Window.backing(width, 40, 10, "smallBacking");
			Size.size(bg, width - 5, width - 5);
			bg.smoothing = true;
			
			counterSprite.addChild(bg);
			addChild(counterSprite);
			counterSprite.x = background.width - counterSprite.width/2 - 4;
			counterSprite.y = 36;
			
			addChild(countOnStock);
			countOnStock.x = counterSprite.x + (counterSprite.width - countOnStock.width) / 2;
			countOnStock.y = counterSprite.y + (counterSprite.height - countOnStock.height) / 2;
		}
			
		public function onPreviewComplete(obj:Object):void
		{
			removeChild(preloader);
			
			bitmap.bitmapData = obj.bitmapData;
			bitmap.smoothing = true;
			Size.size(bitmap, settings.bitmapSize, settings.bitmapSize);
			//bitmap.scaleX = bitmap.scaleY = 0.9;
			//if(bitmap.width>80){
				//bitmap.scaleX = bitmap.scaleY = 0.8;
			//}
			//bitmap.scaleX = bitmap.scaleY = 1.2;
			bitmap.y -= 0;
			sprTip.x = (background.width - bitmap.width) / 2;
			sprTip.y = (background.height - bitmap.height) / 2 - 0;
			
			
			
		}
		
		public function removeGlow():void 
		{
			if (App.user.quests.tutorial) {
				stopGlowing = true;
			
			stopGlowing = true;
			customGlowing(recipeBttn);
			}
		}
		public function addGlow():void 
		{
			var qID:int = App.user.quests.currentQID;
				if (App.data.quests.hasOwnProperty(qID)&&App.data.quests[qID].tutorial  == 1) {
				
				var mID:int = App.user.quests.currentMID;
				var targets:Object = App.data.quests[qID].missions[mID].target;
				for each(var sid:* in targets){
					if(this.sID == sid){
						//stopGlowing = false;
						glowing();
					}
				}
			}
		}
		
		
		
		private function customGlowing(target:*, callback:Function = null):void {
			TweenMax.to(target, 1, { glowFilter: { color:0xFFFF00, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void {
				TweenMax.to(target, 0.8, { glowFilter: { color:0xFFFF00, alpha:0.6, strength: 7, blurX:6, blurY:6 }, onComplete:function():void {
					if (callback != null) {
						callback();
					}
					if (stopGlowing) {
						target.filters = null;
					}
				}});	
			}});
		}
	}
}