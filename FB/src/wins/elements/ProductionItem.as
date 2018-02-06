package wins.elements 
{

	import buttons.Button;
	import buttons.ImageButton;
	import com.greensock.*;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import core.Load;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import ui.UserInterface;
	import wins.ProductionWindow;
	import wins.RecipeAnimalWindow;
	import wins.RecipeWindow;
	import wins.Window;
	import wins.WindowEvent;

	//Вспомогательный класс
	public class ProductionItem extends LayerX{
		
		public var background:Bitmap = null;
		public var bitmap:Bitmap = null;
		public var itemIcon:ImageButton;
		public var sID:String;
		public var fID:int;
		public var recipe:Object;
		public var count:uint;
		public var canRotate:Boolean = true;
		public var building:int;
		public var title:TextField = null;
		public var timeText:TextField = null;
		public var requestText:TextField = null;
		public var recipeBttn:Button;
		public var progressBar:Sprite;
		public var icon:Bitmap;
		public var win:* =  null;
		private var productTitle:TextField;
		private var tween:TweenMax;
		private var productionWindow:ProductionWindow;
		public var sprTip:LayerX = new LayerX();
		
		
		private var settings:Object = {
			width:170,
			height:206,
			recipeBttnMarginY:-28,
			//recipeBttnHasDotes:true,
			
			titleColor:0x814f31,
			
			timeColor:0xffffff,
			timeBorderColor:0x764a3e, 
			
			timeMarginY:-24,
			timeMarginX: -3
		};
		
		public var testFlag:Boolean = true;
		
		public function ProductionItem(win:*, _settings:Object = null)
		{
			for (var item:* in _settings) 
			{
				settings[item] = _settings[item];
			}
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOverHandler);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOutHandler);
			this.win = win;
			productionWindow = win;
			//professionWindow = win;
			
			background = new Bitmap(Window.textures.clearBubbleBacking);
			background.smoothing = true;
			addChild(background);
			
			//backgroundOff = Window.backing(settings.width, settings.height, 40, "itemBackingOff");
			//addChild(backgroundOff);
			//backgroundOff.visible = false;
			
			
			if (contains(sprTip)) {
				removeChild(sprTip);
				sprTip = new LayerX();
			}
			bitmap = new Bitmap();
			//sprTip.addChild(bitmap);
			bitmap.y = 10;
			addChild(sprTip);
			title = Window.drawText("", {
				fontSize:22,
				color:settings.titleColor,
				borderColor:0xfcf6e4,
				multiline:true,
				textAlign:"center",
				autoSize:"center"
			});
			
			sprTip.tip = function():Object {
				return {
					desc:App.data.storage[sID].title,
					text:App.data.storage[sID].text
				}
			}
			
			//addChild(title);
			title.wordWrap = false;
			
			title.width = background.width - 40;
			//title.x = background.x + background.width - title.width;
			title.y = 8;
			
			addTime();
			
		}
		
		private function onMouseOverHandler(e:MouseEvent):void 
		{
			//removeStaff();			
			//addStaff();
			if (!App.user.quests.tutorial) 
			{
				win.drawFormula(fID, this);
			}
			
		}
		
		private function onMouseOutHandler(e:MouseEvent):void 
		{
			//win.removeProductionTips();
			//removeStaff();
		}
		
		private function addStaff():void 
		{
			var size:Point = new Point(120, 50);
			var pos:Point = new Point(
				(background.width - size.x) / 2,
				background.y - size.y / 2
			);
			
			productTitle = Window.drawTextX(App.data.storage[sID].title, size.x, size.y, pos.x, pos.y, this, {
				fontSize:26,
				multiline:true,
				textLeading: (App.lang != 'ru') ? 0: -12,
				wrap:true,
				multiline:true,
				color:0xffffff,
				borderColor:0x1e366e
			}, "up");
			
			if (parent && productTitle != null){
				TweenLite.to(productTitle, 0.5, { alpha:1, ease:Bounce.easeInOut } );
			}
		}
		
		private function removeStaff():void 
		{
			//if (fieldArrow && fieldArrow.parent) 
			//{
				//fieldArrow.parent.removeChild(fieldArrow);
				//fieldArrow = null;
				//fieldArrow = null;
			//}
			if (productTitle) 
			{
				if(productTitle.parent)
					productTitle.parent.removeChild(productTitle);
				productTitle = null;
			}
		}
			
		private function drawCloseItem(lvlNeed:int):void 
		{
			//background.bitmapData = Window.textures.buildingsLockedBacking;
			//background.smoothing = true;
			
			var lock:Bitmap = new Bitmap(Window.textures.lock);
			lock.smoothing = true;
			lock.x = (background.width - lock.width) / 2;
			lock.y = (background.height - lock.height) / 2;
			addChild(lock);
			
			var upArrow:Bitmap = new Bitmap(Window.textures.upgradeArrow);
			upArrow.smoothing = true;
			upArrow.scaleX = upArrow.scaleY = .5;
			upArrow.x = lock.x + 10;
			upArrow.y = lock.y + lock.height - upArrow.height - 12;
			addChild(upArrow);
			
			requestText = Window.drawText(Locale.__e(/*"flash:1400851737141", [*/String(lvlNeed)/*]*/), {
				fontSize:22,
				color:0xfcf6e4,
				borderColor:0x5e3402,
				multiline:true,
				textAlign:"center",
				wrap:true,
				width:background.width - 20
			});
			addChild(requestText);
			
			requestText.x = lock.x + (lock.width - requestText.width) / 2 + 8;
			requestText.y = lock.y + lock.height - requestText.textHeight - 10;
		}
		
		private function removeReqTekst():void
		{
			if (!requestText) return;
			
			if (requestText.parent) requestText.parent.removeChild(requestText);
			requestText = null;
		}
		
		private function addTime():void 
		{
			//icon = new Bitmap(Window.textures.timerDark);
			//addChild(icon);
			
			
			//timeText = Window.drawText("", {
				//fontSize:20,
				//color:settings.timeColor,
				//borderColor:settings.timeBorderColor
			//});
			//addChild(timeText);
			
			//icon.x = 40 + settings.timeMarginX;
			//icon.y = background.height - 59 + settings.timeMarginY;
			
			//timeText.x = icon.x + icon.width + 3;
			//timeText.y = icon.y + 6;
			
			
			
			//recipeBttn = new Button( {
				//caption:Locale.__e("flash:1382952380065"),
				//width:110,
				//fontSize:26,
				//hasDotes:false,
				//height:36
			//});
			//
			//addChild(recipeBttn);
			//recipeBttn.x = (background.width - recipeBttn.width) / 2;
			//recipeBttn.y = background.height - recipeBttn.height / 2 - 4 + settings.recipeBttnMarginY;
			
			//recipeBttn.addEventListener(MouseEvent.CLICK, onRecipeBttnClick);
		}
		
		public var recWin:RecipeWindow;
		public var recAnimalWin:RecipeAnimalWindow;
		protected function onRecipeBttnClick(e:MouseEvent):void
		{
			if (!testFlag)
				return;
			win.settings.target.isProduct();
			/*if (App.data.storage[sID].type == "Animal") 
			{
				openRecipeAnimalWindow();
			}else
			{*/
			
			hideGlowing();
			hidePointing();
			openRecipeWindow();
				
			//}			
		}
		
		public function openRecipeWindow():void {
			if (App.user.quests.tutorial) 
			{
				stopGlowing = true;
				stopGlowing = true;
				customGlowing(itemIcon);
				
				if (App.user.quests.currentQID == 135 && App.user.quests.currentMID == 2)
				{
					return;
				}
			}
			//building = settings.building.info.sID;
			/*if (poolArray.indexOf(building) != -1)
			{
				Window.closeAll();
				recWin = new RecipePoolWindow( {
					title:Locale.__e("flash:1382952380065"),
					fID:fID,
					onCook:win.onCookEvent,
					busy:win.busy,
					win:win,
					target:this,
					hasDescription:true,
					hasAnimations:false,
					craftData:settings.craftData,
					//dontCheckTechno:win.settings.target.dontCheckTechno(),
					prodItem:this,
					sID:this.sID,
					isHelp:isHelp
				});// .show();
				recWin.show();
				
			}*/
			//else
			//{
			recWin = new RecipeWindow( {
				title:Locale.__e("flash:1382952380065"),
				fID:fID,
				building:settings.building,
				onCook:win.onCookEvent,
				busy:win.busy,
				win:win,
				target:this,
				hasDescription:true,
				hasAnimations:false,
				craftData:settings.craftData,
				//dontCheckTechno:win.settings.target.dontCheckTechno(),
				prodItem:this,
				sID:this.sID,
				isHelp:isHelp
			});// .show();
			recWin.show();
			isHelp = false;
			//}
		}
		
		private function openRecipeAnimalWindow():void
		{
			recAnimalWin = new RecipeAnimalWindow( {
				title:Locale.__e("flash:1382952380065"),
				fID:fID,
				onCook:win.onCookEvent,
				busy:win.busy,
				win:win,
				hasDescription:true,
				hasAnimations:false,
				craftData:settings.craftData,
				dontCheckTechno:win.settings.target.dontCheckTechno(),
				prodItem:this
				});// .show();
				recAnimalWin.show();
		}
		private var preloader:Preloader = new Preloader();
		
		private var isHelp:Boolean = false;
		public function change(fID:*, lvlNeed:int = 0, isHelp:Boolean = false):void
		{
			this.isHelp = isHelp;
			dispose();
			
			var formula:Object = App.data.crafting[fID];
			
			this.sID 		= formula.out;
			this.fID 		= int(fID);
			this.count 		= formula.count;
			this.recipe 	= formula.items;
			
			title.text = App.data.storage[sID].title;
			title.x = (background.width - title.width) / 2;
			lvlNeed = App.data.crafting[settings.crafting.fid].level;
			if (lvlNeed  > App.user.level ) {   // переделать
				testFlag = false;  // just for test
			}
			else 
				testFlag = true;
			
			bitmap.bitmapData = null;
			
			addChild(preloader);
			preloader.scaleX = preloader.scaleY = 0.7;
			preloader.x = (background.width)/ 2;
			preloader.y = (background.height) / 2;
			Load.loading(Config.getIcon(App.data.storage[sID].type, App.data.storage[sID].preview), onPreviewComplete);
			
			drawCount();
			if (!testFlag) {
				drawCloseItem(lvlNeed);
			}else {
				removeReqTekst();
			}
			
			var info:Object = App.data.storage[sID];
			
			var sid:*
			var qID:int = 0;
			var mID:int = 0;
			var targets:Object = {}
			
			sprTip.tip = function():Object {
				return {
					desc: info.title,
					text: info.description
				};
			}
			
			
			qID = App.user.quests.currentQID;
			if (App.data.quests.hasOwnProperty(qID) && App.data.quests[qID].tutorial  == 1) 
			{
				mID = App.user.quests.currentMID;
				targets = App.data.quests[qID].missions[mID].target;
				for each(sid in targets)
				{
					if (this.sID == sid && this.testFlag)
					{
						stopGlowing = false;
						glowing();
					}
				}
			}
			
			
			if (Quests.help) {
				var count:int = 10000000;
				var fid:int = -1;
				var craft:*;
			
				for each (craft in settings.craftData)
				if (App.data.crafting[craft.fid].count<=count&&App.data.crafting[craft.fid].out == this.sID) 
				{
					count = App.data.crafting[craft.fid].count;
					fid = craft.fid;
				}
				if (App.data.quests.hasOwnProperty(qID)) 
				{
					qID = App.user.quests.currentQID;
					mID = App.user.quests.currentMID;
					targets = App.data.quests[qID].missions[mID].target;
					for each(sid in targets)
					{
						if (this.sID == sid && App.data.crafting[this.settings.crafting.fid].count == App.data.crafting[fid].count && this.testFlag)
						{
							stopGlowing = false;
							showGlowing();
							
							hidePointing();
							showPointing("bottom", 0, 120, this.parent, '', null, false, true);
							if (!App.user.quests.tutorial)
							{
								setTimeout(hidePointing, 2000)
								setTimeout(hideGlowing, 2000)
							}
						}
					}
				}
				
				isHelp = false;
			}
			
			
			
			if (isHelp) {
				showGlowing();
			}
			addStaff();
		}
		
		public function dispose():void
		{
			if (itemIcon) {
				itemIcon.removeEventListener(MouseEvent.CLICK, onRecipeBttnClick);
				itemIcon.dispose();
				itemIcon = null;
			}
			
			if (requestText && requestText.parent) {
				requestText.parent.removeChild(requestText);
			}
			requestText = null;
			
			if (recWin) {
				recWin.close();
				recWin = null;
			}
			if (recAnimalWin) {
				recAnimalWin.close();
				recAnimalWin = null;
			}
			
			
			if (progressBar != null)
			{
				win.removeEventListener(WindowEvent.ON_PROGRESS, progress)
				removeChild(progressBar);
				removeChild(bg);
				bg = null;
				progressBar = null;
			}
			
			stopGlowing = true;
			
			background.filters = null;
			
			//background.filters = [new GlowFilter(0x1e366e, .5, 8, 8, 6)];
			//recipeBttn.filters = null;
		}
		
		private var counterSprite:LayerX = null;
		public function drawCount():void {
			if (counterSprite != null)
			{
				removeChild(counterSprite);
				counterSprite = null
			}
			
			if (App.data.crafting[fID].count <= 1)
				return;
			
			counterSprite = new LayerX();
			counterSprite.tip = function():Object { 
				return {
					title:"",
					text:Locale.__e("flash:1382952380064")
				};
			};
			
			var countOnStock:TextField = Window.drawText("x "+App.data.crafting[fID].count, {
				color:0xffffff,
				borderColor:0x1e366e,  
				fontSize:28,
				autoSize:"left"
			});
			
			var width:int = countOnStock.width + 24 > 30?countOnStock.width + 24:30;
			//var bg:Bitmap = Window.backing(width, 40, 10, "smallBacking");
			//
			//
			//counterSprite.addChild(bg);
			addChild(counterSprite);
			counterSprite.x = background.width - counterSprite.width - 36;
			counterSprite.y = 26;
			
			addChild(countOnStock);
			countOnStock.x = background.x + background.width - countOnStock.width - 13;
			countOnStock.y = background.y + background.height - countOnStock.height - 13;
			/*if (App.lang == 'nl' || App.lang == 'pl') 
			{
				countOnStock.y = counterSprite.y + 30;
			}else if (App.lang == 'de') 
			{
				countOnStock.y = counterSprite.y + 32;
			}*/
		}
		
		private var bg:Bitmap
		private function drawProgressBar(crafted:uint, time:uint):void{
			if (progressBar != null)
			{
				removeChild(progressBar);
				progressBar = null;
			}
			
			progressBar = new Sprite();
			
			bg = new Bitmap(UserInterface.textures.craftSliderBg);
			addChild(bg);
			
			win.addEventListener(WindowEvent.ON_PROGRESS, progress)
			addChild(progressBar);
			
			//icon.visible = false;
			//timeText.visible = false;
			
			bg.x = (background.width - bg.width)/2;
			bg.y = background.height - 46;
			progressBar.x = bg.x + 2;
			progressBar.y = bg.y + 1;
		}
		
		private function progress(e:WindowEvent = null):void
		{
			var _progress:Number = ((App.time - win.crafted) / win.totalTime) *100;
			UserInterface.slider(progressBar, _progress, 100, "craftSlider");
		}
		
		//private var iconT:Bitmap;
		public function onPreviewComplete(obj:Object):void
		{
			if(contains(preloader)){
				removeChild(preloader);
			}
			bitmap.bitmapData = obj.bitmapData;
			bitmap.smoothing = true;
			itemIcon = new ImageButton(bitmap.bitmapData);
			//itemIcon.tip = function():Object {
				//return {
					//title:App.data.storage[sID].title,
					//text:App.data.storage[sID].description
				//}
			//}
			/*itemIcon.tip = function():Object {
				//var count:String;
				var timecount:String;
				var iconT2:Bitmap;
				
				
				
				//count = App.data.crafting[fID].count ;//TimeConverter.timeToCuts(App.data.crafting[fID].time, false, false);//TimeConverter.timeToStr(App.data.crafting[fID].time);
				if (App.data.crafting[fID].time != 0)
				{
					iconT2= new Bitmap(Window.textures.timerDark);
					timecount =  TimeConverter.timeToCuts(App.data.crafting[fID].time, false, false);
					Size.size(iconT2, 40, 40);
				} else
				{
					iconT2 = null;
					timecount = Locale.__e("flash:1428061669314");
				}
				//ProductionWindow.formulaID = fID;
				//win.showFormula(fID);
				//timecount = TimeConverter.timeToCuts(App.data.crafting[fID].time, false, false);//TimeConverter.timeToStr(App.data.crafting[fID].time);
				return {
					text:App.data.storage[sID].description,
					//count1:"x" + count,
					count1:" "+timecount,
					title:App.data.storage[sID].title,
					desc:Locale.__e("flash:1472809261622"),
					icon:iconT2,
					//icon2:iconT2,
					iconScale: (iconT2 != null) ? iconT2.scaleX : 0
					//iconScale2: iconT2.scaleX
				}
			}*/
			/*setTimeout(function():void {
						drawFormula(value);
					}, 1000);*/
				//ProductionWindow.formulaID = fID;
				
			if(testFlag)
				itemIcon.addEventListener(MouseEvent.CLICK, onRecipeBttnClick);
			else
				itemIcon.addEventListener(MouseEvent.CLICK, onClosedBttnClick);
				//itemIcon.mouseEnabled = false;
			//itemIcon.y = 10;
			
			sprTip.addChild(itemIcon);

			/*if (itemIcon.height > 100) {
				itemIcon.height = 100
				itemIcon.scaleX = itemIcon.scaleY;
			//	itemIcon.y = background.y - 30;
			//	itemIcon.x = background.x - 30;
			if (itemIcon.width > 100) {
			itemIcon.width = 100;
			itemIcon.scaleY = itemIcon.scaleX;
			}
			}*/
			Size.size(itemIcon, background.width - 25, background.width - 25);
			
			itemIcon.y = background.y - 3;
			itemIcon.x = background.x;
			//itemIcon.name = 'prodItem';
			sprTip.x = (background.width - itemIcon.width) / 2;
			sprTip.y = (background.height - itemIcon.height) / 2;
		}
		
		private function onClosedBttnClick(e:MouseEvent):void 
		{
			
			productionWindow.drawClosedWindow(this.fID);
		}
		
		public function glow():void
		{
			var myGlow:GlowFilter = new GlowFilter();
			myGlow.inner = false;
			myGlow.color = 0xfbd432;
			myGlow.blurX = 6;
			myGlow.blurY = 6;
			myGlow.strength = 8
			this.filters = [myGlow];
		}
		
		//Используется в квестах
		public function select():void {
			//recipeBttn.showGlowing();
			//recipeBttn.showPointing("top", (recipeBttn.width - 30) / 2, 0, recipeBttn.parent);
			//App.user.quests.currentTarget = recipeBttn;
		}
		
		
		private function glowing():void {
			setTimeout(stopQuestGlow, 2000);
			/*if (App.user.quests.tutorial) 
			{
				customGlowing(itemIcon);
				App.user.quests.currentTarget = itemIcon;
				App.user.quests.lock = false;
				Quests.lockButtons = false;
				return;
			}*/
			
			customGlowing(background, glowing);
			if (itemIcon) {
				customGlowing(itemIcon);
			}
		}
		
		private function stopQuestGlow():void {
			stopGlowing = true;
			if (itemIcon) 
			customGlowing(itemIcon);
		}
		
		private var stopGlowing:Boolean = false;
		private function customGlowing(target:*, callback:Function = null):void {
			TweenMax.to(target, 1, { glowFilter: { color:0xFFFF00, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void {
				if (stopGlowing) {
					TweenMax.to( target, 1, { glowFilter: { color:0xFFFF00, alpha:0.1, strength: 7, blurX:30, blurY:30 }, onComplete:function():void {
						target.filters = null;
						return;
					}});
				}
				TweenMax.to(target, 0.8, { glowFilter: { color:0xFFFF00, alpha:0.6, strength: 7, blurX:6, blurY:6 }, onComplete:function():void {
					if (!stopGlowing && callback != null) {
						callback();
					}
					if (stopGlowing) {
						TweenMax.to( target, 2, { glowFilter: { color:0xFFFF00, alpha:0.0, strength: 7, blurX:30, blurY:30 }, onComplete:function():void {
							target.filters = null;
							return;
						}});
					}
				}});	
			}});
		}	
		
		public var rotateTween:TweenLite;
		public var rotateAngle:int;
		public function removeAngleTween():void {
			if (rotateTween) {
				rotateTween.kill();
				rotateTween = null;
				this.parent.rotation = rotateAngle;
			}
		}
		
	}
}