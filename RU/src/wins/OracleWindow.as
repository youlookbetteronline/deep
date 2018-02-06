package wins 
{
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import ui.Hints;
	import ui.UserInterface;
	import units.Oracle;
	
	public class OracleWindow extends Window
	{
		public var win_mode:uint = WIN_FREE;
		public var WIN_PAY:uint = 2;
		public var playBttn:MoneyButton;
		public var playFreeBttn:Button;
		public var items:Array = [];
		public var scale:Number = 0.45;
		public var target:Oracle;
		public var cached:Array = new Array();
		public var rewardContainer:LayerX = new LayerX();
		public var sid:int = 0;
		public var dX:uint = 0
		public var descriptionLabel:TextField;
		public var predictionTextLabel:TextField;
		public var timeConteiner:Sprite;
		public var timerText:TextField;
		public var descriptionTimeLabel:TextField;
		public var background:Bitmap;
		public var back:Bitmap;
		public var predictItem:PredictionItem;
		private var shadowFilter:BlurFilter;
		private var textFilter:GlowFilter;
		private var backTimer:Shape = new Shape();
		public const WIN_FREE:uint = 1;
		
		private var title:TextField;		
		private var questionView:LayerX;
		
		public function OracleWindow(settings:Object = null)
		{			
			if (settings == null) 
			{
				settings = new Object();
			}
			
			this.target = settings['target'];
			settings['width'] = 650;
			settings['height'] = 420;
			settings['faderAsClose'] = false;
			settings['faderClickable'] = false;
			settings['hasTitle'] = true;
			settings['title'] = target.info.title;
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			settings['fontSize'] = 36;
			
			sid = settings.target.sid;
			super(settings);
			
			var pList:* = settings.target.info.predictions;
			for (var itm:* in pList)
			{
				Load.loading(Config.getIcon(App.data.storage[pList[itm].m].type, App.data.storage[pList[itm].m].view),function(data:Bitmap):void{});
			}
		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: 0xf9fdff,
				multiline			: settings.multiline,			
				fontSize			: 34,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: 0x5c9900,			
				borderSize 			: settings.fontBorderSize,	
				
				shadowBorderColor	: 0x235b00,
				width				: settings.width - settings.titlePading,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			
			titleLabel.x = (settings.width - titleLabel.width) * .5 - 5;
			titleLabel.y = -7;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.mouseEnabled = false;
		}
		
		public function drawPredictionItem():void 
		{
			var itemImg:Bitmap = new Bitmap(Window.textures.backBigTurtle);//кружочек
			itemImg.x = (settings.width- itemImg.width)/2;
			itemImg.y = back.y + back.height - 65;
			
			rewardContainer.x = itemImg.x + 15;
			rewardContainer.y = itemImg.y + 15;
			bodyContainer.addChild(itemImg);
			bodyContainer.addChild(rewardContainer);
			questionView = new LayerX();
			questionView.x = itemImg.x + 5;
			questionView.y = itemImg.y + 20;
			bodyContainer.addChild(questionView);	
			
			
			/*layer.addChild(title);
			title.x = 50;
			title.y = 50;*/
			
			/*questionView.tip = function():Object {
				return {
					text:	Locale.__e('flash:1393580965018')
				}
			}*/
			
			var questionLabel:TextField = drawText('?', {
				fontSize:	82,
				width:		100,
				textAlign:	'center',
				color:		0xfff75b,
				borderColor:0xd09249,
				sharpness:	0
			});
			questionView.addChild(questionLabel);
		}
		
		/*public function drawHeaderImg():void 
		{
			var headerImg:Bitmap = new Bitmap(UserInterface.textures.oracleHeader);
			headerImg.x = (settings.width - headerImg.width)/2//bodyContainer.x + 60;
			headerImg.y = bodyContainer.y - headerImg.height;
			layer.addChild(headerImg);
		}*/
		
		override public function drawBody():void 
		{			
			/*if (settings.target.sid == 2167) 
			{				
				//moveWindow = new Point(0,79);
			}*/
			
			drawMirrowObjs('decSeaweed', settings.width - 55, + 45, settings.height - 174, true, true, false, 1, 1);
			var titleBackingBmap:Bitmap = backingShort(350, 'ribbonGrenn',true,1.3);
			
			titleBackingBmap.x = (settings.width - titleBackingBmap.width)/ 2 - 5;
			titleBackingBmap.y = -50;
			bodyContainer.addChild(titleBackingBmap);
			
			/*var downPlankBmap:Bitmap = backingShort(320, 'shopPlankDown');
			downPlankBmap.x = settings.width / 2 -downPlankBmap.width / 2;
			downPlankBmap.y = settings.height - downPlankBmap.height + 10;
			layer.addChild(downPlankBmap);*/
			
			/*titleLabel.x += dX;
			titleLabel.x -= 20;*/
			exit.x = background.x + background.width - 60;
			exit.y -= 30;
			
			/*if (settings.target.sid == 2167) {
				drawHeaderImg();
			}*/
			
			drawPredictionLabel();
			drawPredictionItem();
			drawBttns();
			
			if (!settings.target.tribute) 
			{
				playFreeBttn.visible = false;
				playBttn.visible = true;
				drawTime();
			}
			else
			{
				playFreeBttn.visible = true;
				playBttn.visible = false;
			}
			
			//drawMirrowObjs('diamondsTop', (settings.width / 2 - settings.titleWidth / 2 - 5) - 15, (settings.width / 2 + settings.titleWidth / 2 + 5) - 30, -45, true, true);
			//drawMirrowObjs('diamondsTop', titleLabel.x + 200, titleLabel.x + 200, 2, true, true);
		}
		
		public function drawPredictionLabel():void
		{
			var text:String = target.info.description;
			
			descriptionLabel = drawText(text, {
				width:settings.width - 140,
				fontSize:26,
				textAlign:"center",
				color:0x6e411e,
				border:false,
				multiline:true,
				wrap:true,
				textLeading: -5
			});
			
			
			
			predictionTextLabel = drawText(text, {
				width:settings.width - 150,
				fontSize:22,
				textAlign:"center",
				color:0x815634,
				border:false,
				wrap:true,
				multiline:true
			});
			
			back = Window.backing(430, 150, 40, 'paperClear');//Window.backing(430, 130, 30, 'paperBacking');
			back.x = (background.width-back.width)/2;
			back.y = 30;
			
			/*descriptionLabel.wordWrap = true;
			descriptionLabel.height = descriptionLabel.textHeight + 5;*/
			descriptionLabel.width = back.width - 30;
			descriptionLabel.height += 30;
			descriptionLabel.x = back.x + (back.width - descriptionLabel.width) / 2 + 80;
			descriptionLabel.y = back.y + (back.height - descriptionLabel.height) / 2 -10;
			
			//descriptionLabel.border = true;
			//predictionTextLabel.border = true;
			/*if (settings.target.info.sID == Oracle.WISE_DRAGON) 
			{
				descriptionLabel.y = back.y + (back.height - descriptionLabel.height) / 2 - 5;
			}*/
			
			
			//bodyContainer.addChild(back);
			bodyContainer.addChild(descriptionLabel);	
			bodyContainer.addChild(predictionTextLabel);
			predictionTextLabel.alpha = 0;
			//predictionTextLabel.visible = true;
		}
		
		public function drawTime():void 
		{			
			if (!timeConteiner) {
				timeConteiner = new Sprite();
				bodyContainer.addChild(timeConteiner);
			}else {
				bodyContainer.removeChild(timeConteiner);
				timeConteiner = new Sprite();
				bodyContainer.addChild(timeConteiner);
			}
			
			while (timeConteiner.numChildren) {
				timeConteiner.removeChildAt(0);
			}
			descriptionTimeLabel = drawText(Locale.__e('flash:1477995682038'), {//текст над таймером
				fontSize:30,
				textAlign:"center",
				color:0xffdf61,
				borderColor:0x6d350d
			});
			
			descriptionTimeLabel.width = descriptionTimeLabel.textWidth+10;
			descriptionTimeLabel.y = -15;
			//if(!descriptionTimeLabel.parent || descriptionTimeLabel.parent != timeConteiner)
			
			
			var time:int = App.nextMidnight - App.time;//цифры таймера
			//var time:int = 0;//цифры таймера
			
			timerText = Window.drawText(TimeConverter.timeToStr(time), {
				color:0xffffff,
				letterSpacing:3,
				textAlign:"center",
				fontSize:28,
				borderColor:0x6d350d
			});
			
			backTimer.graphics.beginFill(0xfeef77);
		    backTimer.graphics.drawRect(0, 0, 220, 35);
			backTimer.y = 30;
		    backTimer.graphics.endFill();
		    
		    backTimer.filters = [new BlurFilter(20, 0, 2)];
		    timeConteiner.addChild(backTimer);
			timeConteiner.addChild(descriptionTimeLabel);			
			timerText.width = timerText.textWidth + 10;
			timerText.y = 30;
			
			timerText.x = backTimer.x + (backTimer.width - timerText.width) / 2;
			descriptionTimeLabel.x = backTimer.x + (backTimer.width - descriptionTimeLabel.width) / 2;
			
			timeConteiner.addChild(timerText);
			timeConteiner.x = (settings.width - timeConteiner.width) / 2;//55 + dX;
			timeConteiner.y = 255;
			App.self.setOnTimer(updateDuration);
			
			
		}
		
		private function updateDuration():void
		{
			var time:int = App.nextMidnight - App.time;
			//var time:int = 0;
			timerText.text = TimeConverter.timeToStr(time);
			
			if (time <= 0)
			{
				descriptionLabel.visible = true;
				timerText.visible = false;
				playFreeBttn.visible = true;
				playBttn.visible = false;
				descriptionTimeLabel.visible = false;
			} 
		}		
		
		override public function drawBackground():void 
		{
			background = backing(480, settings.height, 50, 'paperScroll');
			background.x += 80;
			layer.addChild(background);
		}
		
		private function drawBttns():void
		{
			playBttn = new MoneyButton({
				caption		        :Locale.__e("flash:1441760006423"),
				color	            :0xa4d635,
				width				:130,
				height				:50,	
				fontSize			:22,
				countText			:settings.target.info.skip,
				fontCountSize		:28,
				fontCountColor 		:0xc6e5ff,
				fontCountBorder 	:0x242275,
				iconScale			:0.6,
				multiline			:true,
				worldwrap			:true,
				setWidth			:true
			});
			
			playFreeBttn = new Button( {
				caption		:Locale.__e("flash:1441759744030"),
				wordWrap	:true,
				fontSize	:22,
				multiline	:true,
				width		:150,
				height		:50,
				textAlign	:"center"
			});
			
			bodyContainer.addChild(playBttn);
			bodyContainer.addChild(playFreeBttn);
			
			playBttn.width += 20;
			playBttn.x = (background.width - playBttn.width) / 2 + 80;
			playBttn.y = settings.height - playBttn.height*2 + 23;
			playBttn.textLabel.x += 3;
			if (App.lang == 'ru' || App.lang == 'de' || App.lang == 'es' || App.lang == 'pl') 
			{
				playBttn.textLabel.y += 4;
			}	

			playBttn.countLabel.x -= 5;
			
			//playBttn.textLabel.height = 50;
			//playBttn.textLabel.width = playBttn.width - 50;
			
			playFreeBttn.x = (background.width - playBttn.width) / 2 + 80;
			playFreeBttn.y = settings.height - playBttn.height*2 + 30;
			playFreeBttn.textLabel.height = 52;
			
			playBttn.addEventListener(MouseEvent.CLICK, onPlayClick);
			playFreeBttn.addEventListener(MouseEvent.CLICK, onPlayFreeClick);
			
			//playFreeBttn.state = Button.DISABLED;	
			//playBttn.state = Button.DISABLED;	
		}
		
		private function onPlayFreeClick(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED)
			{				
				return;
			}
			
			exit.visible = false;
			e.currentTarget.state = Button.DISABLED;
			settings.onPlay(0, onPlayComplete);
		}
		
		private function onPlayClick(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED)
				return;
			
			if (App.user.stock.count(Stock.FANT) >= settings.target.info.skip)
			{
				exit.visible = false;
				e.currentTarget.state = Button.DISABLED;
				var X:Number = App.self.mouseX - e.currentTarget.mouseX + e.currentTarget.width / 2;
				var Y:Number = App.self.mouseY - e.currentTarget.mouseY;
				
				Hints.minus(Stock.FANT, settings.target.info.skip, new Point(X, Y), false, App.self.tipsContainer);
			}
			
			settings.onPlay(1, onPlayComplete);
		}
		
		private function getPrediction(bonus:Object):Object 
		{
			for (var b:* in bonus) 
			{
				var sID:uint = b;
				var count:uint = bonus[b];
				break;
			}
			
			var pList:Object = this.target.info.predictions;
			
			for (var itm:* in pList)
			{
				if (pList[itm].c == count && pList[itm]["m"] == sID) 
				{
					return pList[itm];
				}
			}
			return null;
		}
		
		public function onPlayComplete(bonus:Object):void 
		{
			
			questionView.visible = false;
			playFreeBttn.visible = false;
			playBttn.visible = true;
			
			drawTime();
			
			var sID:uint = bonus.sID;
			var pItem:Object = getPrediction(bonus);
			
			predictItem = new PredictionItem(this, { sID:pItem.m, count:pItem.c, pText:pItem.p } );
			predictItem.take();
			playBttn.state = Button.NORMAL;
			playFreeBttn.state = Button.NORMAL;
			settings.target.clearIcon();
			/*rewardContainer.tip = function():Object {
				return {
					title:App.data.storage[sID].title
				}
			}*/
		}
		
		public function updateWinView(pText:String):void 
		{
			App.ui.glowing(rewardContainer);
			descriptionLabel.visible = false;
			//predictionTextLabel.width = 380;
			predictionTextLabel.width = back.width - 80;
			predictionTextLabel.wordWrap = true;
			predictionTextLabel.height = 75;
			predictionTextLabel.visible = true;
			predictionTextLabel.x = back.x + (back.width - predictionTextLabel.width) / 2 + 80;//(back.height/2) -10;
			predictionTextLabel.y = back.y + (back.height - predictionTextLabel.height) / 2 - 20;//45 + (53 - predictionTextLabel.height) / 2;
			exit.visible = true;
			playBttn.state = Button.NORMAL;
			playBttn.addEventListener(MouseEvent.CLICK, onPlayClick);
		}
		
		private function takeReward():void 
		{
			//winItem.take();
			exit.visible = true;
		}
		
		public function onWheelStop():void 
		{
			playBttn.state = Button.NORMAL;
			playBttn.visible = true;
			playFreeBttn.visible = false;
		}
		
		public override function dispose():void 
		{
			if(playFreeBttn) playFreeBttn.removeEventListener(MouseEvent.CLICK, onPlayFreeClick);
			if (playBttn) playBttn.removeEventListener(MouseEvent.CLICK, onPlayClick);
			App.self.setOffTimer(updateDuration);
			
			super.dispose();
		}	
		
		override public function titleText(settings:Object):Sprite
		{
			if (!settings.hasOwnProperty('width'))
				settings['width'] = 300;
				
			var cont:Sprite = new Sprite();
			var cont2:Sprite = new Sprite();
			var shadow:Sprite = new Sprite();
			
			var fontBorder:int = settings.fontBorderSize;
			settings.fontBorderSize = fontBorder;
			var fontBorderGlow:int = settings.fontBorderGlow;
			settings.fontBorderGlow = fontBorderGlow;
			
			
			
			var textLabel:TextField = Window.drawText(settings.title, settings);
			this.settings['titleWidth'] = textLabel.textWidth;
			this.settings['titleHeight'] = textLabel.textHeight;
			textLabel.wordWrap = true;
			textLabel.width = settings.width;
			textLabel.height = textLabel.textHeight + 4;
			
			var borderColor:uint = settings.borderColor
			settings.borderColor = borderColor;//settings.shadowBorderColor;
			settings.color = borderColor;
			
			var textShadow:TextField = Window.drawText(settings.title, settings);
			textShadow.wordWrap = true;
			textShadow.width = settings.width;
			textShadow.height = textLabel.textHeight + 4;
			
			textShadow.cacheAsBitmap = true;
			textLabel.cacheAsBitmap = true;

			var textShadow2:TextField = Window.drawText(settings.title, settings);
			textShadow2.wordWrap = true;
			textShadow2.width = settings.width;
			textShadow2.height = textLabel.textHeight + 4;
			textShadow2.cacheAsBitmap = true;
			
			settings.borderColor = 0x2a5e0b;
			settings.color = 0x2a5e0b;
			var textShadow3:TextField = Window.drawText(settings.title, settings);
			textShadow3.wordWrap = true;
			textShadow3.width = settings.width;
			textShadow3.height = textLabel.textHeight + 4;
			textShadow3.cacheAsBitmap = true;
					
			var textShadow4:TextField = Window.drawText(settings.title, settings);
			textShadow4.wordWrap = true;
			textShadow4.width = settings.width;
			textShadow4.height = textLabel.textHeight + 4;
			textShadow4.cacheAsBitmap = true;
			
			cont2.addChild(shadow);
			shadow.addChild(textShadow3);
			shadow.addChild(textShadow4);
			cont2.addChild(cont);
			
			//cont.addChild(textShadow);
			//cont.addChild(textShadow2);
			
			cont.addChild(textLabel);
			textFilter = new GlowFilter(0x579705, 1, 3,3, 10, 1);
			cont.filters = [textFilter/*, new BlurFilter(1.2,1.2,1)*/];
			
			shadowFilter = new BlurFilter(2,2,1);
			shadow.filters = [shadowFilter/*, new BlurFilter(1.2,1.2,1)*/];
			
			
			textShadow.y = 1;
			textShadow2.y = -2;
			textShadow3.y = 4;
			textShadow3.x = 1;
			textShadow4.y = 4;
			textShadow4.x = -1;
			cont.mouseEnabled = false;
			cont.mouseChildren = false;
			return cont2;
		}

	}
}

import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.geom.Point;
import flash.text.TextField;
import ui.UserInterface;
import wins.OracleWindow;
import wins.Window;

internal class PredictionItem extends Sprite 
{	
	public var WD:uint = 85;
	public var HT:uint = 85;
	public var imageContainer:LayerX = new LayerX();
	public var itemData:Object = new Object();
	public var target:OracleWindow;
	public var sID:uint;
	public var count:uint;
	public var pText:String;
	public var btForChange:Bitmap = new Bitmap();
	
	public function PredictionItem(target:OracleWindow, itemData:Object)
	{
		this.target = target;
		this.itemData = itemData;
		this.sID = itemData.sID;
		this.count = itemData.count;
		this.pText = itemData.pText;
		checkContainer();
	}
	
	public function checkContainer():void 
	{
		var tp:String = App.data.storage[sID].type;
		var vw:String = App.data.storage[sID].preview;
		if (vw == 'nectar')
			vw = vw+'1';
		dissAp();
		Load.loading(Config.getIcon(tp, vw), onReady, 0, false, null);
	}
	
	public function take():void 
	{		
		var that:* = this;
		App.ui.flashGlowing(this, 0xFFFF00, function():void {
			var item:BonusItem = new BonusItem(sID, count);
			var point:Point = new Point(0,0);
			point = Window.localToGlobal(target.rewardContainer);
			//App.user.stock.add(sID, count);			
			item.cashMove(point, App.self.windowContainer);
		});
	}	
	
	public function onReady(data:Bitmap):void
	{
		btForChange = new Bitmap(data.bitmapData);
	}
	
	public function dissAp():void 
	{
		/*UserInterface.dissapear([target.descriptionLabel],null,{speed:2});
		if(!target.descriptionLabel.visible){
			target.predictionTextLabel.alpha = 0;
			target.predictionTextLabel.visible = true;
		}*/
		UserInterface.dissapear([target.rewardContainer, target.descriptionLabel, target.predictionTextLabel], updateWinData, { speed:1 } );
		/*fe = new FlintEffect();
		var bD1:BitmapData = new BitmapData(target.descriptionLabel.width, target.descriptionLabel.height, true, 0xffffff);
		bD1.draw(target.descriptionLabel);
		var bm1:Bitmap = new Bitmap(bD1);
		var bD2:BitmapData = new BitmapData(target.predictionTextLabel.width, target.predictionTextLabel.height, true, 0xffffff);
		bD2.draw(target.predictionTextLabel);
		var bm2:Bitmap = new Bitmap(bD1);
		var p1:Point = target.localToGlobal(new Point(target.descriptionLabel.x,target.descriptionLabel.y));
		var p2:Point = target.localToGlobal(new Point(target.predictionTextLabel.x,target.predictionTextLabel.y));
		var p1:Point = new Point(target.descriptionLabel.x,target.descriptionLabel.y);
		var p2:Point = new Point(target.predictionTextLabel.x,target.predictionTextLabel.y);
		fe.flintTween(target.predictionTextLabel.parent, {bD:bm1,x:p1.x,y:p1.y}, {bD:bm2,x:p2.x,y:p2.y});*/
	}
	
	public function updateWinData(data:Object = null):void
	{
		if (imageContainer.parent && imageContainer.parent == target.rewardContainer)
		{
			imageContainer.parent.removeChild(imageContainer);
			imageContainer = null;
		}
		
		imageContainer = new LayerX();
		
		while (target.rewardContainer.numChildren)
		{
			target.rewardContainer.removeChildAt(0);
		}

		var countText:TextField = Window.drawText("x"+count+"", {
			color:0xffffff,
			letterSpacing:3,
			textAlign:"center",
			fontSize:30,
			borderColor:0x502f06
		});
		/*target.predictionTextLabel.width = back.width - 80;
		target.predictionTextLabel.wordWrap = true;
		target.predictionTextLabel.height = 75;
		target.predictionTextLabel.visible = true;
		target.predictionTextLabel.x = back.x + (back.width - predictionTextLabel.width) / 2;
		target.predictionTextLabel.y = back.y + (back.height - predictionTextLabel.height) / 2;*/
		target.rewardContainer.addChild(imageContainer);
		target.rewardContainer.addChild(countText);
		countText.width = countText.textWidth + 5;
		countText.height = countText.textHeight + 5;
		countText.x = WD - countText.width / 2;
		countText.y = HT - countText.height / 2;
		var ttl:String = App.data.storage[sID].title;
		var dscr:String = App.data.storage[sID].description;
		
		imageContainer.tip = function():Object {
			return {
				title:ttl,
				description:dscr
			}
		}
		
		target.predictionTextLabel.text = pText;
		target.predictionTextLabel.visible = false;
		var bt:Bitmap = new Bitmap(btForChange.bitmapData);
		bt.smoothing = true;
		Size.size(bt, 75, 75);
		/*bt.width = bt.width * 0.8;
		bt.height = bt.height * 0.8;*/
		bt.x = (WD-bt.width)/2;
		bt.y = (HT-bt.height)/2;
		imageContainer.addChild(bt);
		
		UserInterface.appear([target.rewardContainer,target.predictionTextLabel],function():void{target.updateWinView(pText);},{speed:1});
	}
}