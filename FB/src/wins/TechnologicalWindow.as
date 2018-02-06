package wins 
{
	import adobe.utils.CustomActions;
	import buttons.Button;
	import com.adobe.images.BitString;
	import com.greensock.easing.Cubic;
	import com.greensock.TweenLite;
	import core.Load;
	import core.Size;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import ui.Hints;
	public class TechnologicalWindow extends Window 
	{
		private var progressBar:ProgressBar;
		public var progressBacking:Bitmap;
		private var textTitle:TextField;
		private var innerBackground:Bitmap;
		private var itemBg:Bitmap;
		
		private var history:int = 0;
		
		public function TechnologicalWindow(settings:Object=null) 
		{
			
			if (settings == null) {
				settings = new Object();
			}
			
			settings["title"] = settings.title;
			settings["width"] = 670;
			settings["height"] = 570;
			settings["hasPaginator"] = true;
			settings["hasArrows"] = true;
			settings["hasButtons"] = true;
			settings['page'] = history;
			settings["itemsOnPage"] = 6;
			settings['shadowColor'] = 0x513f35;
			settings['shadowSize'] = 4;
			
			settings['content'] = [];
			
			for each (var item:* in settings.technologies) 
			{
				settings.content.push(item);
			}
			
			super(settings);			
		}
		
		override public function drawArrows():void 
		{
			paginator.drawArrow(bodyContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bodyContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = (settings.height - paginator.arrowLeft.height) / 2;
			paginator.arrowLeft.x = -paginator.arrowLeft.width / 2 + 70;
			paginator.arrowLeft.y = y - 50;
			
			paginator.arrowRight.x = (settings.width - paginator.arrowRight.width / 2) + 10;
			paginator.arrowRight.y = y - 50;
			
			paginator.x = int((settings.width - paginator.width) / 2 - 40);
			paginator.y = int(settings.height - paginator.height);
			
			paginator.arrowLeft.showGlowing();
			paginator.arrowRight.showGlowing();
		}
		
		override public function drawExit():void 
		{
			super.drawExit();			
			exit.x = settings.width - 47;			
			exit.y = -3;
		}
		
		override public function drawBody():void 
		{			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -45, true, true);
			drawMirrowObjs('storageWoodenDec', -4, settings.width + 10, settings.height - 115);//bootom
			drawMirrowObjs('storageWoodenDec', -4, settings.width + 10, 40, false, false, false, 1, -1);
			
			innerBackground = Window.backing(605, 215, 40, 'buildingDarkBacking');
			bodyContainer.addChild(innerBackground);
			innerBackground.x = 35;
			innerBackground.y = 260;
			
			itemBg = Window.backing(160, 200, 15, 'itemBacking');
			bodyContainer.addChild(itemBg);
			itemBg.x += 475;
			itemBg.y += 35;
			
			var rewardText:TextField = drawText(Locale.__e("flash:1382952380000"), {//Награда
				fontSize:			30,
				autoSize:			'center',
				textAlign:			'center',
				color:				0x753915,
				borderColor:		0xFFFFFF
			});
			rewardText.x = itemBg.x + itemBg.width / 2 - rewardText.width / 2;
			rewardText.y = itemBg.y + 10;
			bodyContainer.addChild(rewardText);
			
			var curtain:Shape = new Shape();
			curtain.graphics.beginFill(0xe6c18d, 1);
			curtain.graphics.drawRoundRect(0, 0, 420, 80, 15, 15);
			curtain.graphics.endFill();
			bodyContainer.addChild(curtain);
			curtain.x = 30;
			curtain.y = 40;
			
			textTitle = Window.drawText('', {
				color:0x6b452e,
				fontSize:30,
				borderColor:0xFFFFFF,
				textAlign:'center'
			});
			textTitle.width = 550;
			bodyContainer.addChild(textTitle);
			//textTitle.x = (curtain.x + curtain.width / 2 - textTitle.width / 2);
			textTitle.x = settings.width / 2 - textTitle.width / 2;
			textTitle.y = 5;
			
			var desc:TextField = drawText(settings.description,
			{
				color:0xFFFFFF,
				borderColor:0x8c4b23,
				fontSize:23,
				multiline:true,
				autoSize: 'center',
				textAlign:"center",
				textLeading: 1.5
			});
			desc.wordWrap = true;
			desc.width = 380;
			desc.x = curtain.x + curtain.width / 2 - desc.width / 2;
			desc.y = curtain.y + curtain.height / 2 - desc.height / 2;
			bodyContainer.addChild(desc);
			
			if (settings.content.length != 0) {
				paginator.itemsCount = settings.content.length;
				paginator.onPageCount = 1;
				drawGoldenButtons();
				
				if (settings.target.helpTarget > 0) {
					for (var i:int = 0; i < settings.content.length; i++) {
						var tech:Object = App.data.storage[settings.content[i]];
							for (var it:String in tech.devel.items) {
								var material:String;
								for (material in tech.devel.items[it]) {
									break;
								}
								if (int(material) == settings.target.helpTarget) {
									paginator.page = Math.floor(i / paginator.onPageCount);
								}
							}
					}
				}
				paginator.update();				
			}
			
			bodyContainer.addChild(techSprite);
			contentChange();
		}
		
		private function drawGoldenButtons():void {
			var i:int = 0;
			for (var itm:String in settings.content) {
				var techInfo:Object = App.data.storage[settings.content[itm]];
				var count:int = 0;
				for each (var pr:Object in techInfo.devel.point) {
					count++;
				}
				if (settings.target.prizes[settings.content[itm]] >= count) {
					paginator.goldenButtons.push(i);						
				}
				i++;
			}
		}
		
		private var techSprite:Sprite = new Sprite();
		override public function contentChange():void {
			disposeAllTechnology();
			drawGoldenButtons();
			
			var techInfo:Object = App.data.storage[settings.content[paginator.startCount]];
			
			textTitle.text = techInfo.title;
			
			drawTechProgress(techInfo.devel);
			drawTechItems(techInfo.kicks, settings.content[paginator.startCount]);
		}
		
		private var points:Array = [];
		private var prizesItems:Array = [];
		private var currPrize:int = 1;
		public function drawTechProgress(tech:Object):void 
		{
			progressBacking = Window.backingShort(settings.width - 235, "prograssBarBacking3");
			progressBacking.x = 25;
			progressBacking.y = 185;
			progressBacking.height += 15;
			techSprite.addChild(progressBacking);
			
			points = [];
			for (var itm:String in tech.point) {
				points.push(tech.point[itm]);
			}
			
			progressBar = new ProgressBar( {
				win:		this,
				width:		420,
				isTimer:    false
			});
			progressBar.x = progressBacking.x - 10;
			progressBar.y = progressBacking.y - 3;
			techSprite.addChild(progressBar);
			setProgress();
			progressBar.start();
			
			var numberOfParts:int = points.length;
			for (var i:int = 1; i < numberOfParts + 1; i++) {
				var divider:Shape = new Shape();
				divider.graphics.beginFill(0xc98437, 1);
				divider.graphics.lineStyle(2, 0x754209, 1, false);
				divider.graphics.drawRoundRect(0, 0, 6, 36, 6, 6);
				divider.graphics.endFill();
				divider.x = (progressBar.x + (progressBar.width) * i / numberOfParts) + 7;
				divider.y = progressBar.y + 10;
				if (i < numberOfParts) {
					techSprite.addChild(divider);
				}				
				
				var count:int;
				var material:int;
				var check:Boolean = false;
				if (i < settings.target.prizes[settings.content[paginator.startCount]] + 1) check = true;
				for (var c:String in tech.items[i]) {
					material = int(c);
					count = tech.items[i][c];
					break;
				}
				var prize:PrizeItem = new PrizeItem(this, { sID:material, count:count, check:check } );
				prize.x = progressBar.x + (progressBar.width) * i / numberOfParts - 25;
				prize.y = progressBar.y - 60;
				techSprite.addChild(prize);
				prizesItems.push(prize);
				
				var textLabel:TextField = drawText(points[i - 1], {
					fontSize:			28,
					autoSize:			'center',
					textAlign:			'center',
					color:				0xfbe458,
					borderColor:		0x744309
				});
				textLabel.x = divider.x + divider.width * 0.5 - textLabel.width * 0.5;
				if (i == numberOfParts)
					textLabel.x -= 10;
				textLabel.y = divider.y + divider.height + 3;
				techSprite.addChild(textLabel);
			}
			
			for (i = 1; i < numberOfParts + 1; i++) {
				if (settings.target.technologies[settings.content[paginator.startCount]] > points[i - 1]) {
					currPrize = i;
				}
			}
			
			currPrize = settings.target.prizes[settings.content[paginator.startCount]] + 1;
			
			if (!tech.items.hasOwnProperty(currPrize)) currPrize = 1;
			if (settings.target.prizes[settings.content[paginator.startCount]] == points.length) currPrize = points.length;
			drawPrize(tech.items[currPrize]);
		}
		
		private var bttnTake:Button;
		private function drawPrize(prize:Object):void {
			var count:int;
			var material:int;
			for (var c:String in prize) {
				material = int(c);
				count = prize[c];
				break;
			}
			
			var shine:Bitmap = new Bitmap(Window.texture('glow'));
			shine.scaleX = shine.scaleY = 0.4;
			shine.x = progressBacking.x + progressBacking.width + 10;
			shine.y = progressBacking.y - shine.height - 10;
			techSprite.addChild(shine);
			
			var prizeImage:Bitmap = new Bitmap();
			techSprite.addChild(prizeImage);
			Load.loading(Config.getIcon(App.data.storage[material].type, App.data.storage[material].view), function(data:*):void {
				prizeImage.bitmapData = data.bitmapData;
				Size.size(prizeImage, 100, 100);
				prizeImage.smoothing = true;
				
				prizeImage.x = shine.x + (shine.width - prizeImage.width) / 2;
				prizeImage.y = shine.y + (shine.height - prizeImage.height) / 2;
			});
			
			var bttnSettings:Object = {
				caption:Locale.__e("flash:1382952379737"),
				width:120,
				height:45,
				fontSize:22
			}
			
			bttnTake = new Button(bttnSettings);
			
			techSprite.addChild(bttnTake);
			bttnTake.x = itemBg.x + 20;
			bttnTake.y = (itemBg.y + itemBg.height - bttnTake.height / 2) - 5;
			changeTakeBttn();
			bttnTake.addEventListener(MouseEvent.CLICK, onStorage);
			
			if (settings.target.prizes[settings.content[paginator.startCount]] == points.length) {				
				var check:Bitmap = new Bitmap(Window.texture('checkMark'));
				check.x = bttnTake.x + 30;
				check.y = progressBacking.y - 20;
				techSprite.addChild(check);
				
				bttnTake.visible = false;
			}
		}
		
		public static var takeButtonIsDisabled:Boolean = false;
		public function changeTakeBttn():void {
			if (!bttnTake) return;
			var count:int = settings.target.technologies[settings.content[paginator.startCount]];
			var max:int   = points[currPrize - 1];
			
			if (count >= max && settings.target.prizes[settings.content[paginator.startCount]] == -1) settings.target.prizes[settings.content[paginator.startCount]] = 0;
			
			var take:int = settings.target.prizes[settings.content[paginator.startCount]];
			
			if (count < max || take > currPrize || take == -1) {
				bttnTake.hideGlowing();
				bttnTake.state = Button.DISABLED;
				takeButtonIsDisabled = true;
				blockItems(false);
			}
			else {
				bttnTake.state = Button.NORMAL;
				takeButtonIsDisabled = false;
				bttnTake.showGlowing();
				blockItems(true);
			}
		}
		
		public function setProgress():void {
			changeTakeBttn();
			
			if (progressBar)
				progressBar.progress = progress();
			
			function progress():Number {
				var value:Number = 0;
				var count:int = settings.target.technologies[settings.content[paginator.startCount]];
				var prev:int = 0;
				var maxPercent:Number = (progressBar.width) / progressBar.width;
				
				for (var i:int = 0; i < points.length; i++) {
					if (points[i]> count) {
						value = maxPercent * (i / points.length) + (1 / points.length) * maxPercent * ((count - prev) / (points[i] - prev));
						break;
					}
					
					prev = points[i];
				}
				
				if (value == 0 && i >= points.length - 1) {
					value = maxPercent * (i / points.length) + maxPercent * (1 / points.length) * ((count - prev) / prev);
				}
				
				if (value > 1) value = 1;
				if (!value) value = 0;
				
				return value;
			}
		}
		
		private function onStorage(e:MouseEvent):void {
			if (e.currentTarget.mode == Button.DISABLED) return;
			settings.target.storageAction(settings.content[paginator.startCount], onStorageEventComplete);
			bttnTake.visible = false;
			/*setTimeout(function():void{
				bttnTake.visible = true;
			}, 1000);*/
		}
		
		public function onStorageEventComplete(sID:uint, price:uint, bonus:Object = null, treasure:Object = null):void {	
			bttnTake.state = Button.DISABLED;
			if (bonus) {
				take(bonus);
			}
			
			if (bonus) {
				flyBonus(treasure);
			}
			
			settings.target.prizes[settings.content[paginator.startCount]] += 1;
			
			contentChange();
			
			if (price == 0 ) {
				return;
			}
			
			var X:Number = App.self.mouseX - bttnTake.mouseX + bttnTake.width / 2;
			var Y:Number = App.self.mouseY - bttnTake.mouseY;
			Hints.minus(sID, price, new Point(X, Y), false, App.self.tipsContainer);
		}
		
		private function flyBonus(data:Object):void {
			var targetPoint:Point = Window.localToGlobal(bttnTake);
				for (var _sID:Object in data)
				{
					var sID:uint = Number(_sID);
					for (var _nominal:* in data[sID])
					{
						var nominal:uint = _nominal;
						var count:uint = Number(data[sID][_nominal]);
					}
					
					var item:*;
					
					for (var i:int = 0; i < count; i++)
					{
						item = new BonusItem(sID, nominal);
						App.user.stock.add(sID, nominal);	
						
						item.cashMove(targetPoint, App.self.windowContainer)
					}			
				}
				SoundsManager.instance.playSFX('reward_1');
		}
		
		private function disposeAllTechnology():void {
			if (techSprite) {
				while (techSprite.numChildren > 0) {
					var child:* = techSprite.getChildAt(0);
					if (child.hasOwnProperty('dispose') && child.dispose != null) {
						child.dispose();
					}
					if (techSprite.contains(child)) {
						techSprite.removeChild(child);
					}
				}
			}
		}
		
		private var items:Array;
		private var itemsContainer:Sprite = new Sprite();
		public function drawTechItems(tech:Object, tID:uint):void {
			if (items) {
				for each(var _item:* in items) {
					itemsContainer.removeChild(_item);
					_item.dispose();
				}
			}
			items = []
			
			var content:Array = [];
			for (var itm:String in tech) {
				tech[itm]['sID'] = itm;
				content.push(tech[itm]);
			}
			content.sortOn('o', Array.NUMERIC);
			
			var separator:Bitmap = Window.backingShort(255, 'divider', false);
			separator.x = 65;
			separator.y = 485;
			separator.alpha = 0.5;
			techSprite.addChild(separator);
			
			var separator2:Bitmap = Window.backingShort(275, 'divider', false);
			separator2.x = 610;
			separator2.y = 485;
			separator2.alpha = 0.5;
			separator2.scaleX = -separator2.scaleX;
			
			techSprite.addChild(separator2);
			
			if (settings.target.prizes[tID] == points.length) {
				var desc:TextField = drawText(Locale.__e('flash:1453124563446'), {//Ты уже изобрел это
					color:0x613d1b,
					borderSize:0,
					fontSize:32,
					multiline:true,
					autoSize: 'center',
					textAlign:"center"
				});
				desc.wordWrap = true;
				desc.width = 550;
				desc.x = (settings.width - desc.width) / 2;
				desc.y = innerBackground.y + innerBackground.height / 2 - desc.height / 2;
				techSprite.addChild(desc);
				return;
			}
			
			techSprite.addChild(itemsContainer);
			var target:*;
			var X:int = 0;
			var Xs:int = X;
			var Ys:int = 260;
			itemsContainer.x = 85;
			itemsContainer.y = Ys;
			if (settings.content.length == 0) return;
			for (var i:int = 0; i < content.length; i++)
			{
				var item:EventItem = new EventItem(this, { info:content[i]}, tID );
				item.x = Xs;
				items.push(item);
				itemsContainer.addChild(item);
				
				Xs += item.bg.width + 15;
			}
			
			changeTakeBttn();
			itemsContainer.x = (settings.width - itemsContainer.width) / 2;
			//separator2.y = itemsContainer.y + itemsContainer.height + 30;
		}
		
		public function blockItems(value:Boolean):void {
			for each(var _item:EventItem in items) {
				if(value)
					_item.bttn.state = Button.DISABLED;
				else {
					_item.bttn.state = Button.NORMAL;
					_item.checkButton();
				}
			}
		}
		
		private function take(items:Object, e:MouseEvent = null):void {
			for (var _sID:Object in items)
			{
				var sID:uint = Number(_sID);
				{
					var nominal:uint = Number(items[sID]);
					var count:uint = 1;
				}
				
				for (var j:int = 0; j < count; j++)
				{
					App.user.stock.add(sID, nominal);	
				}			
			}
				
			for(var i:String in items) { 
				
				Load.loading(Config.getIcon(App.data.storage[i].type, App.data.storage[i].preview), function(data:Bitmap):void {
					rewardW = new Bitmap;
					rewardW.bitmapData = data.bitmapData;
					wauEffect(e);
				});
			}
		}
		
		public var rewardW:Bitmap;
		private function wauEffect(e:MouseEvent =  null):void {
			if (rewardW.bitmapData != null) {
				var rewardCont:Sprite = new Sprite();
				App.self.windowContainer.addChild(rewardCont);
				
				var glowCont:Sprite = new Sprite();
				glowCont.alpha = 0.6;
				glowCont.scaleX = glowCont.scaleY = 0.5;
				rewardCont.addChild(glowCont);
				
				var glow:Bitmap = new Bitmap(Window.textures.actionGlow);
				glow.x = -glow.width / 2;
				glow.y = -glow.height + 90;
				glowCont.addChild(glow);
				
				var glow2:Bitmap = new Bitmap(Window.textures.actionGlow);
				glow2.scaleY = -1;
				glow2.x = -glow2.width / 2;
				glow2.y = glow.height - 90;
				glowCont.addChild(glow2);
				
				var bitmap:Bitmap = new Bitmap(new BitmapData(rewardW.width, rewardW.height, true, 0));
				bitmap.bitmapData = rewardW.bitmapData;
				bitmap.smoothing = true;
				bitmap.x = -bitmap.width / 2;
				bitmap.y = -bitmap.height / 2;
				rewardCont.addChild(bitmap);
				
				if (e) {
					rewardCont.x = e.target.parent.x + e.target.parent.width / 2 ;
					rewardCont.y = e.target.parent.y + e.target.parent.height / 2 ;
				} else {
					rewardCont.x = rewardCont.y = 0;
				}
				
				function rotate():void {
					glowCont.rotation += 1.5;
				}
				
				App.self.setOnEnterFrame(rotate);
				
				TweenLite.to(rewardCont, 0.5, { x:App.self.stage.stageWidth / 2, y:App.self.stage.stageHeight / 2, scaleX:1.25, scaleY:1.25, ease:Cubic.easeInOut, onComplete:function():void {
					setTimeout(function():void {
						App.self.setOffEnterFrame(rotate);
						glowCont.alpha = 0;
						var bttn:* = App.ui.bottomPanel.bttnMainStock;
						var _p:Object = { x:App.ui.bottomPanel.x + bttn.parent.x + bttn.x + bttn.width / 2, y:App.ui.bottomPanel.y + bttn.parent.y + bttn.y + bttn.height / 2};
						SoundsManager.instance.playSFX('takeResource');
						TweenLite.to(rewardCont, 0.3, { ease:Cubic.easeOut, scaleX:0.7, scaleY:0.7, x:_p.x, y:_p.y, onComplete:function():void {
							TweenLite.to(rewardCont, 0.1, { alpha:0, onComplete:function():void {App.self.windowContainer.removeChild(rewardCont);}} );
						}} );
					}, 3000)
				}} );
			}
		}
		
		public override function dispose():void {
			if (items) {
				for each(var _item:* in items) {
					itemsContainer.removeChild(_item);
					_item.dispose();
				}
			}
			items = [];
			
			super.dispose();
		}
		
	}

}

import buttons.Button;
import buttons.MoneyButton;
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.text.TextField;
import ui.Hints;
import ui.UserInterface;
import wins.SimpleWindow;
import wins.ShopWindow;
import wins.TechnologicalWindow;
import wins.Window;
import wins.BanksWindow;

internal class EventItem extends Sprite
{
	public var window:*;
	public var item:Object;
	public var bg:Bitmap;
	private var bitmap:Bitmap;
	private var sID:uint;
	private var tID:uint;
	private var info:Object;
	public var bttn:Button;	
	
	public function EventItem(window:TechnologicalWindow, data:Object, tID:uint)
	{
		this.info = data.info;
		this.sID = data.info.sID;
		this.tID = tID;
		this.item = App.data.storage[data.info.sID];
		this.window = window;
		
		bg = Window.backing(125, 160, 15, 'itemBacking');
		addChild(bg);
		bg.x += 5;
		bg.y += 20;
		
		Load.loading(Config.getIcon(item.type, item.preview), onLoad);
		
		drawTitle();
		drawBttn();
		drawCount();
	}
	
	private function onClick(e:MouseEvent):void 
	{
		if (e.currentTarget.mode == Button.DISABLED) 
		{
			if (e.currentTarget is MoneyButton) 
			{
				if (App.user.stock.count(Stock.FANT) == 0 && TechnologicalWindow.takeButtonIsDisabled) 
				{
					new BanksWindow().show();
				}else 
				{
					return;
				}
				
			}else 
			{
				if (TechnologicalWindow.takeButtonIsDisabled) 
				{
					if (ShopWindow.findMaterialSource(sID)) {
						window.close();
					}else {
						new SimpleWindow( {
							popup:		true,
							title:		item.title,
							text:		item.description
						}).show();
					}					
				}else 
				{
					return;
				}				
			}
			
			return;
		}
		
		switch(info.t) {
			case 2:
				if (!App.user.stock.checkAll(item.price)) {
					notEnoughMaterials();
					return;
				}
			break;
			case 3:
				if (!App.user.stock.check(sID, 1)) { 
					notEnoughMaterials();
					return;
				}
			break;
		}
		
		var sendObject:Object = {
			act:'kick',
			uID:App.user.id,
			wID:App.user.worldID,
			guest:App.user.id
		};
		
		window.blockItems(true);
		window.settings.kickEvent(sID, tID, onKickEventComplete, info.t, sendObject, info.c);
	}
	
	private function notEnoughMaterials():void {
		window.close();
		new SimpleWindow( {
			text: Locale.__e('flash:1428055030855'),
			title: Locale.__e('flash:1407829337190')
		}).show();
	}
	
	private function onKickEventComplete(bonus:Object = null, treasure:Object = null):void {//sID:uint, price:uint
		
		var sID:uint;
		var price:uint;
		if (info.t == 1) {
			window.close();
			return;
		}
		else if (info.t == 2)
		{
			sID = Stock.FANT;
			price = item.price[sID];
		}
		else if (info.t == 3)
		{
			sID = this.sID;
			price = info.c;
		}	
		
		var X:Number = App.self.mouseX - bttn.mouseX + bttn.width / 2;
		var Y:Number = App.self.mouseY - bttn.mouseY;
		Hints.minus(sID, price, new Point(X, Y), false, App.self.tipsContainer);
		
		if (bonus){
			flyBonus(bonus);
		}
		if (treasure){
			flyBonus(treasure);
		}
		window.blockItems(false);
		window.setProgress();
	}	
	
	public function onStorageEventComplete(sID:uint, price:uint, bonus:Object = null):void {	
		if (bonus) {
			flyBonus(bonus);
		}
		
		window.updateCount();
		
		if (price == 0 ) {
			return;
		}
		
		var X:Number = App.self.mouseX - bttn.mouseX + bttn.width / 2;
		var Y:Number = App.self.mouseY - bttn.mouseY;
		Hints.minus(sID, price, new Point(X, Y), false, App.self.tipsContainer);
	}
	
	private function flyBonus(data:Object):void {
		var targetPoint:Point = Window.localToGlobal(bttn);
			targetPoint.y += bttn.height / 2;
			for (var _sID:Object in data)
			{
				var sID:uint = Number(_sID);
				for (var _nominal:* in data[sID])
				{
					var nominal:uint = Number(_nominal);
					var count:uint = Number(data[sID][_nominal]);
				}
				
				var item:*;
				
				for (var i:int = 0; i < count; i++)
				{
					item = new BonusItem(sID, nominal);
					App.user.stock.add(sID, nominal);	
					item.cashMove(targetPoint, App.self.windowContainer)
				}			
			}
			SoundsManager.instance.playSFX('reward_1');
	}
	
	private var sprite:LayerX;
	private function onLoad(data:Bitmap):void {
		sprite = new LayerX();
		sprite.tip = function():Object {
			return {
				title: item.title,
				text: item.description
			};
		}
		
		bitmap = new Bitmap(data.bitmapData);
		Size.size(bitmap, 120, 120);
		sprite.x = ((bg.width - bitmap.width) / 2) + 5;
		sprite.y = (bg.height - bitmap.height) / 2 + 25;
		sprite.addChild(bitmap);
		addChildAt(sprite, 1);
		bitmap.smoothing = true;
		
		sprite.addEventListener(MouseEvent.CLICK, searchEvent);
	}
	
	private function drawBttn():void 
	{
		var bttnSettings:Object = {
			caption:Locale.__e("flash:1382952379978"),
			width:105,
			height:35,
			fontSize:20
		}
		
		if (item.real == 0 || info.t == 1)
		{
			bttnSettings['borderColor'] = [0xaff1f9, 0x005387];
			bttnSettings['bgColor'] = [0x70c6fe, 0x765ad7];
			bttnSettings['fontColor'] = 0x453b5f;
			bttnSettings['fontBorderColor'] = 0xe3eff1;
			
			bttn = new Button(bttnSettings);
		}
		
		if (item.real || info.t == 2) 
		{			
			bttnSettings['bgColor'] = [0xa8f749, 0x74bc17];
			bttnSettings['borderColor'] = [0x5b7385, 0x5b7385];
			bttnSettings['bevelColor'] = [0xcefc97, 0x5f9c11];
			bttnSettings['fontColor'] = 0xffffff;			
			bttnSettings['fontBorderColor'] = 0x4d7d0e;
			bttnSettings['fontCountColor'] = 0xc7f78e;
			bttnSettings['fontCountBorder'] = 0x40680b;		
			bttnSettings['countText']	= item.price[Stock.FANT];
			if (App.lang == 'jp') 
			{
				bttnSettings['fontSize'] = 12;	
			}			
			
			bttn = new MoneyButton(bttnSettings);
		}
		
		if (info.t == 3) {
			bttn = new Button(bttnSettings);
		}
		
		addChild(bttn);
		bttn.x = ((bg.width - bttn.width) / 2) + 5;
		bttn.y = bg.height;
		bttn.addEventListener(MouseEvent.CLICK, onClick);
		
		checkButton();
	}
	
	public function checkButton():void {
		switch(info.t) {
			case 1:
				bttn.state = Button.ACTIVE;
			break;
			case 2:
				/*if (!App.user.stock.checkAll(item.price)) {
					bttn.state = Button.DISABLED;
				}*/
				
				for (var ir:* in item.price) 
				{
					if (App.user.stock.count(Stock.FANT) < item.price[ir] ) {
						bttn.state = Button.DISABLED;
					}
					
				}
				
				
				//trace(item.price)
			break;
			case 3:
				if (!App.user.stock.check(sID, 1)) { 
					bttn.state = Button.DISABLED;
				}
			break;
		}
		drawCount();
	}
	
	public function drawTitle():void {
		var sprite:Sprite = new Sprite();
		
		var textTitle:TextField = Window.drawText(item.title + ' +' + info.k, {
			color:0xFFFFFF,
			fontSize:22,
			borderColor:0x7d5228,
			multiline:false,
			wrap:true,
			textAlign:"center"
		});
		textTitle.width = textTitle.textWidth + 10;
		sprite.addChild(textTitle);
		
		sprite.x = (bg.width - sprite.width) / 2;
		sprite.y += 25;
		addChild(sprite);
	}
	
	private var textCount:TextField;
	public function drawCount():void {	
		var count:int = App.user.stock.count(sID);
		var countText:String = 'x' + String(count);
		if (count < 1) {
			countText = '';
		}
		if (textCount) {
			removeChild(textCount);
			textCount = null;
		}
		textCount = Window.drawText(countText, {
			color:0xffffff,
			fontSize:30,
			borderColor:0x7b3e07
		});
		textCount.width = textCount.textWidth + 10;
		textCount.x = bg.x + bg.width - textCount.width;
		textCount.y = bg.y + bg.height - 50;
		addChild(textCount);
	}
	
	private function searchEvent(e:MouseEvent):void {
		return;
		ShopWindow.findMaterialSource(sID);
	}
	
	public function dispose():void {
		if (bttn) bttn.removeEventListener(MouseEvent.CLICK, onClick);
		if (sprite) sprite.removeEventListener(MouseEvent.CLICK, searchEvent);
	}
}

import buttons.Button;
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.geom.Point;
import flash.text.TextField;
import ui.UserInterface;
import wins.ShopWindow;
import wins.TechnologicalWindow;
import wins.Window;

internal class PrizeItem extends Sprite
{
	public var window:*;
	public var item:Object;
	private var bitmap:Bitmap;
	private var sID:uint;
	private var count:uint;
	private var info:Object;
	private var check:Boolean = false;
	
	public function PrizeItem(window:TechnologicalWindow, data:Object)
	{
		this.sID = data.sID;
		this.count = data.count;
		this.check = data.check;
		this.item = App.data.storage[data.sID];
		this.window = window;
		
		sprite = new LayerX();
		bitmap = new Bitmap();
		
		sprite.tip = function():Object {
			return {
				title: item.title,
				text: item.description
			};
		}
		sprite.addChild(bitmap);
		addChild(sprite);
		
		Load.loading(Config.getIcon(item.type, item.preview), onLoad);
		
		drawCount();
	}
	
	private var sprite:LayerX;
	private function onLoad(data:Bitmap):void {		
		bitmap.bitmapData = data.bitmapData;
		Size.size(bitmap, 50, 50);
		bitmap.smoothing = true;
		bitmap.y += 10;
		bitmap.x += 10;
	}
	
	private var textCount:TextField;
	private function drawCount():void {
		textCount = Window.drawText('x' + count, {
			color:0xffffff,
			fontSize:26,
			borderColor:0x7b3e07
		});
		textCount.width = textCount.textWidth + 10;
		textCount.x = 35;
		textCount.y = 20;
		sprite.addChild(textCount);
		
		if (check) {
			textCount.visible = false;
			var check:Bitmap = new Bitmap(Window.texture('checkMark'));
			check.x = 35;
			check.y = 30;
			check.scaleX = check.scaleY = 0.5;
			sprite.addChild(check)
		}
	}
}

