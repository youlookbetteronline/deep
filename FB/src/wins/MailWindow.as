package wins 
{
	import buttons.Button;
	import buttons.MoneyButton;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import ui.Hints;
	import ui.UserInterface;
	import units.Oracle;

	public class MailWindow extends Window
	{
		public var win_mode:uint = WIN_FREE;
		public var WIN_PAY:uint = 2;
		public var playBttn:MoneyButton;
		public var playFreeBttn:Button;
		public var takeTaskBttn:Button;
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
		
		public const WIN_FREE:uint = 1;
		
		private var title:TextField;		
		private var questionView:LayerX;
		
		public var paperContainer:LayerX = new LayerX();
		
		public function MailWindow(settings:Object = null)
		{			
			if (settings == null) 
			{
				settings = new Object();
			}
			
			this.target = settings['target'];
			settings['width'] = 650; // зависит от подложки
			settings['height'] = 460; // зависит от подложки
			settings['faderAsClose'] = false;
			settings['faderClickable'] = false;
			settings['hasTitle'] = true;
			settings['title'] = target.info.title;
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			settings['fontSize'] = 40;
			
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
			
		}
		public var itemImg:Bitmap;
		public function drawPredictionItem():void 
		{
			itemImg = new Bitmap(new BitmapData(115, 115));//(Window.textures.instCharBacking);//кружочек
			itemImg.x = (back.width - itemImg.width) / 2;
			itemImg.y = back.y + back.height - itemImg.height - 70;
			
			rewardContainer.x = itemImg.x + (itemImg.width - rewardContainer.width) / 2;
			rewardContainer.y = itemImg.y + (itemImg.height - rewardContainer.height) / 2;
			paperContainer.addChild(rewardContainer);
			
		}
		
		
		private var frontMail:Bitmap;
		override public function drawBody():void 
		{			
			
			exit.x = background.x + background.width - 65;
			exit.y = 200;
			
			bodyContainer.addChild(paperContainer);
			
			paperContainer.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			paperContainer.addEventListener(MouseEvent.MOUSE_UP, onUp);
			
			drawPredictionLabel();
			drawPredictionItem();
			frontMail = new Bitmap(Window.textures.mailFront);
			frontMail.x = (background.width - frontMail.width) / 2;
			frontMail.y = background.height - frontMail.height - 20;
			bodyContainer.addChild(frontMail);
			
			var mailStamp:Bitmap = new Bitmap(Window.textures.mailStamp);
			mailStamp.x = frontMail.x + 24;
			mailStamp.y = frontMail.y + 80;
			bodyContainer.addChild(mailStamp);
			
			drawBttns();
			
			if (!settings.target.tribute) 
			{
				playFreeBttn.state  = Button.DISABLED;
				playFreeBttn.visible = false;
				takeTaskBttn.state  = Button.NORMAL;
				takeTaskBttn.visible = true;
				drawTime();
			}
			else
			{
				playFreeBttn.state  = Button.NORMAL;
				playFreeBttn.visible = true;
				takeTaskBttn.state  = Button.DISABLED;
				takeTaskBttn.visible = false;
			}
			
			drawMirrowObjs('decSeaweed', settings.width + 57, - 55, background.height - 205, true, true, false, 1, 1, bodyContainer);
		}
		private var LOCKX:Number = 0;
		private var draggedObject:DisplayObject;
		private function onDown(e:MouseEvent):void
		{
			exit.visible = false;
			e.currentTarget.startDrag(
				false,
				new Rectangle(
					e.currentTarget.x,
					0 - e.currentTarget.height/2 + 106,
					0,
					160
				)
			);
			draggedObject = DisplayObject(e.target);
		}
		
		private function onUp(e:MouseEvent):void 
		{
			exit.visible = true;
			e.currentTarget.stopDrag();
		}
		
		public function drawPredictionLabel():void
		{
			var text:String = target.info.description;
			
			descriptionLabel = drawText(text, {
				width:settings.width - 120,
				fontSize:30,
				textAlign:"center",
				color:0x7f3d0e,
				borderColor:0xfef7e9,
				multiline:true,
				wrap:true,
				textLeading: -5
			});
			
			predictionTextLabel = drawText(text, {
				width:settings.width - 120,
				fontSize:30,
				textAlign:"center",
				color:0x7f3d0e,
				borderColor:0xfef7e9,
				wrap:true,
				multiline:true
			});
			
			back = new Bitmap(Window.textures.mailPaper);
			back.x = 0;
			back.y = 0;
			
			descriptionLabel.width = back.width - 80;
			descriptionLabel.x = back.x + (back.width - descriptionLabel.width) / 2;
			descriptionLabel.y = back.y + 40;
			
			paperContainer.addChild(back);
			paperContainer.addChild(descriptionLabel);	
			paperContainer.addChild(predictionTextLabel);
			predictionTextLabel.alpha = 0;
			paperContainer.x = (background.width - paperContainer.width) / 2;
			paperContainer.y = 60;
			LOCKX = paperContainer.x;
		}
		
		private var backTimer:Shape = new Shape();
		public function drawTime():void 
		{			
			if (!timeConteiner) 
			{
				timeConteiner = new Sprite();
				bodyContainer.addChild(timeConteiner);
			}else {
				bodyContainer.removeChild(timeConteiner);
				timeConteiner = new Sprite();
				bodyContainer.addChild(timeConteiner);
			}
			
			while (timeConteiner.numChildren) 
			{
				timeConteiner.removeChildAt(0);
			}
			
			descriptionTimeLabel = drawText(Locale.__e('flash:1441759926191'), {//текст над таймером
				fontSize:30,
				textAlign:"center",
				color:0xffdf61,
				borderColor:0x6d350d
			});
			
			descriptionTimeLabel.width = descriptionTimeLabel.textWidth + 10;
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
			if (descriptionTimeLabel.x < 0)
				timeConteiner.x -= descriptionTimeLabel.x;
			timeConteiner.y = 295;
			App.self.setOnTimer(updateDuration);
		}
		
		private function updateDuration():void
		{
			var time:int = App.nextMidnight - App.time;
			timerText.text = TimeConverter.timeToStr(time);
			
			if (time <= 0)
			{
				descriptionLabel.visible = true;
				timerText.visible = false;
				playFreeBttn.state  = Button.NORMAL;
				takeTaskBttn.state  = Button.DISABLED;
				playFreeBttn.visible = true;
				takeTaskBttn.visible = false;
				descriptionTimeLabel.visible = false;
			} 
		}		
		
		override public function drawBackground():void 
		{
			background = new Bitmap(Window.textures.mailBack);
			settings.width = background.width;
			settings.heihgt = background.height;
			layer.addChild(background);
		}
		
		private function drawBttns():void
		{
			playFreeBttn = new Button( {
				caption		:Locale.__e("flash:1477467290940"),
				wordWrap	:true,
				fontSize	:22,
				multiline	:true,
				width		:150,
				height		:50,
				textAlign	:"center"
			});
			
			takeTaskBttn = new Button( {
				caption		:Locale.__e("flash:1480329572639"),
				wordWrap	:true,
				fontSize	:22,
				multiline	:true,
				width		:150,
				height		:50,
				textAlign	:"center"
			});
			
			
			bodyContainer.addChild(playFreeBttn);
			bodyContainer.addChild(takeTaskBttn);
			
			playFreeBttn.filters = [new DropShadowFilter(3.0, 90, 0, 0.5, 3.0, 3.0, 1.0, 3, false, false, false)];
			playFreeBttn.x = (background.width - playFreeBttn.width) / 2;
			playFreeBttn.y = background.height - playFreeBttn.height / 2 - 38;
			playFreeBttn.textLabel.height = 52;
			
			takeTaskBttn.filters = [new DropShadowFilter(3.0, 90, 0, 0.5, 3.0, 3.0, 1.0, 3, false, false, false)];
			takeTaskBttn.x = (background.width - takeTaskBttn.width) / 2;
			takeTaskBttn.y = background.height - takeTaskBttn.height / 2 - 38;
			takeTaskBttn.textLabel.height = 52;
			
			playFreeBttn.addEventListener(MouseEvent.CLICK, onPlayFreeClick);
			takeTaskBttn.addEventListener(MouseEvent.CLICK, onTakeTask);
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
		
		private function onTakeTask(e:MouseEvent):void 
		{
			if (e.currentTarget.mode == Button.DISABLED)
				return;
			Window.closeAll();
			new DaylicWindow({}).show();
			
			e.currentTarget.state = Button.DISABLED;
		}
		
		private function onPlayClick(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED)
				return;
			
			if (App.user.stock.count(Stock.FANT) >= settings.target.info.skip)
			{
				exit.visible = false;
				e.currentTarget.state = Button.DISABLED;
				takeTaskBttn.state  = Button.NORMAL;
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
			playFreeBttn.state = Button.DISABLED;
			playFreeBttn.visible = false;
			
			takeTaskBttn.state = Button.NORMAL;
			takeTaskBttn.visible = true;
			
			App.user.quests.dayliInit = false;
			delete App.user.daylics.quests;
			App.user.quests.getDaylics(true);
				
			drawTime();
			
			var sID:uint = bonus.sID;
			var pItem:Object = getPrediction(bonus);
			predictItem = new PredictionItem(this, { sID:pItem.m, count:pItem.c, pText:pItem.p } );
			predictItem.take();
			settings.target.clearIcon();
		}
		
		public function updateWinView(pText:String):void 
		{
			App.ui.glowing(rewardContainer);
			descriptionLabel.visible = false;
			predictionTextLabel.width = back.width - 80;
			predictionTextLabel.wordWrap = true;
			predictionTextLabel.height = 155;
			predictionTextLabel.visible = true;
			predictionTextLabel.x = back.x + (back.width - predictionTextLabel.width) / 2;
			predictionTextLabel.y = back.y + 40;
			exit.visible = true;
		}
		
		private function takeReward():void 
		{
			exit.visible = true;
		}
		
		public override function dispose():void 
		{
			if (playFreeBttn) playFreeBttn.removeEventListener(MouseEvent.CLICK, onPlayFreeClick);
			if (takeTaskBttn) takeTaskBttn.removeEventListener(MouseEvent.CLICK, onTakeTask);
			
			paperContainer.removeEventListener(MouseEvent.MOUSE_DOWN, onDown);
			paperContainer.removeEventListener(MouseEvent.MOUSE_UP, onUp);
			App.self.setOffTimer(updateDuration);
			
			super.dispose();
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
import wins.MailWindow;
import wins.Window;

internal class PredictionItem extends Sprite 
{	
	public var WD:uint = 85;
	public var HT:uint = 85;
	public var imageContainer:LayerX = new LayerX();
	public var itemData:Object = new Object();
	public var target:MailWindow;
	public var sID:uint;
	public var count:uint;
	public var pText:String;
	public var btForChange:Bitmap = new Bitmap();
	
	public function PredictionItem(target:MailWindow, itemData:Object)
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
			item.cashMove(point, App.self.windowContainer);
		});
	}	
	
	public function onReady(data:Bitmap):void
	{
		btForChange = new Bitmap(data.bitmapData);
	}
	
	public function dissAp():void 
	{
		UserInterface.dissapear([target.rewardContainer, target.descriptionLabel, target.predictionTextLabel], updateWinData, { speed:1 } );
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

		target.rewardContainer.addChild(imageContainer);
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
		bt.x = - bt.width / 2;
		bt.y = - bt.height / 2;
		imageContainer.addChild(bt);
		
		UserInterface.appear([target.rewardContainer, target.predictionTextLabel], function():void{target.updateWinView(pText); }, {speed:1});
	}
}