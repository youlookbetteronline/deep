package wins 
{
	import buttons.Button;
	import buttons.ImageButton;
	import buttons.ImagesButton;
	import buttons.MoneyButton;
	import core.Load;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	import ui.Cursor;
	import units.Mhelper;
	
	public class MhelperWindow extends Window
	{
		private var mhelper:Mhelper;
		public var infoBttn:ImageButton;
		
		public function MhelperWindow(settings:Object) 
		{
			settings['width'] = 670;
			settings['height'] = 580;
			settings['title'] = settings.target.info.title;
			settings['hasPaginator'] = true;
			settings['hasButtons'] = true;
			settings['hasArrow'] = true;
			settings['itemsOnPage'] = 8;	
			settings['content'] = [];
			super(settings);
			mhelper = settings.target;
		}
		private function showTargets():void
		{
			Window.closeAll();
			var txt:String;
			Mhelper.waitWorker = settings.target;
			Mhelper.chooseTargets = [];
			Mhelper.clickCounter = 0;
			//Mhelper.waitForTarget = true;
			App.ui.upPanel.showCancel(Mhelper.waitWorker.onCancel);
			App.ui.upPanel.showConfirm(Mhelper.waitWorker.onConfirm);
			txt = Locale.__e('flash:1441181269694');
			App.ui.upPanel.showHelp(Locale.__e('flash:1456159293680') + ' ' + (Mhelper.waitWorker.targetsLength) + "/" +  Mhelper.waitWorker.stacks, 0);//Выбрано
			
			setTimeout(function():void {
				App.self.addEventListener(MouseEvent.CLICK, Mhelper.waitWorker.unselectPossibleTargets);
			}, 100);
		}
		
		override public function drawBody():void 
		{
			super.drawBody();
			createContent();
			paginator.page = 0;
			paginator.itemsCount = settings.content.length;
			paginator.update();
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -50, true, true);
			drawMirrowObjs('storageWoodenDec', -10, settings.width, settings.height - 110);//bottom
			drawMirrowObjs('storageWoodenDec', -5, settings.width, 35, false, false, false, 1, -1);//top
			var itemsBack:Bitmap = backing(620, 440, 50, 'buildingDarkBacking');
			itemsCont.addChildAt(itemsBack, 0);
			itemsCont.x = 25;
			itemsCont.y = 47;
			bodyContainer.addChild (itemsCont);
			drawButtons();
			contentChange();
			paginator.x = ( settings.width - paginator.width) / 2 - 35;
			paginator.y = settings.height - 35;
			exit.y -= 20;
		}
		
		public var items:Vector.<MhelperWindowItem> = new Vector.<MhelperWindowItem>();
		
		private function createContent():void
		{
			settings.content.splice (0, settings.content.length);
			var count:int = 0;
			for each(var item:* in settings.target.targets) {
				settings.content.push(item);
				count++;
			}
			var slot:Object = null;
			for ( ; count < mhelper.info.stacks; count ++ )
			{
				settings.content.push(slot);
			}
		}
		private var itemsCont:Sprite = new Sprite();
		override public function contentChange():void 
		{
			super.contentChange();
			for each(var _item:MhelperWindowItem in items) {
				itemsCont.removeChild(_item);
				_item.dispose();
				_item = null;
			}
			var counter:int = 0;
			items = new Vector.<MhelperWindowItem>();
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++)
			{
				var item:MhelperWindowItem = new MhelperWindowItem(settings.content[i], this, i);
				
				itemsCont.addChild(item);
					
				items.push(item);

				item.x = (item.bg.width + 7)  * (counter % (settings.itemsOnPage / 2)) + 17;
				item.y = (item.bg.height + 15) * ( Math.floor(counter / (settings.itemsOnPage / 2)) ) + 18;
				counter++;
			}
			
			settings.page = paginator.page;
			blockAll(isBlock);
			buttnsCheak();
		}
		
		private function buttnsCheak():void
		{
			if (detachMode)
			{
				attachBttn.state = Button.DISABLED;
				detachBttn.state = Button.DISABLED;
				speed.state = Button.DISABLED;
				collect.state = Button.DISABLED;
				return;
			}
			
			if (speed)
			{
				speed.countLabelText = mhelper.getPriceItems();
				if ( mhelper.getPriceItems() <= 1)
					speed.state = Button.DISABLED;
				else
					speed.state = Button.NORMAL;
			}
			if ( collect )
			{
				var count:int = Numbers.countProps(mhelper.findCollect());
				if ( count >0 && App.user.stock.data[Stock.FANTASY] > count )
					collect.state = Button.NORMAL;
				else
					collect.state = Button.DISABLED;
			}
			if ( mhelper.targetsLength >= mhelper.stacks )
			{
				attachBttn.state = Button.DISABLED;
			}
			else
			{
				attachBttn.state = Button.NORMAL;
			}
			if ( mhelper.targetsLength <= 0 )
			{
				detachBttn.state = Button.DISABLED;
				
			}
			else
			{
				detachBttn.state = Button.NORMAL;
			}			
		}
		
		override public function drawArrows():void 
		{
			super.drawArrows();
			
			paginator.arrowLeft.x = -paginator.arrowLeft.width / 2 + 75;
			paginator.arrowRight.x = settings.width-paginator.arrowRight.width/2 - 10;
			paginator.arrowLeft.y = 235;
			paginator.arrowRight.y = 235;
		}
		
		private function drawButtons():void
		{
			var infoIcon:Bitmap = new Bitmap(new BitmapData(75,75, true, 0), 'auto', true);
			infoBttn = new ImagesButton(infoIcon.bitmapData);
			
			infoBttn.tip = function():Object { 
				return {
					title:Locale.__e("flash:1382952380254"),
					text:''
				};
			};
			
			infoBttn.addEventListener(MouseEvent.CLICK, showHelp);
			
			Load.loading(Config.getImageIcon("quests/icons", "helpBttn"), function(data:Bitmap):void {
				infoBttn.bitmapData = data.bitmapData;				
				infoBttn.initHotspot();
			});
			
			infoBttn.x = settings.width - settings.width + infoBttn.width / 2 + 90;
			infoBttn.y = settings.height - infoBttn.height - 40;
			bodyContainer.addChild(infoBttn);
			
			var buttonSettings:Object = {
				textAlign:		'center',
				autoSize:		'center',
				fontSize:		28,
				color:			0x5e430c,
				borderColor:	0xFFFFFF,
				shadowSize:		1,
				width:			145,
				height:			40
			};
			
			buttonSettings['caption'] = Locale.__e ("flash:1456154257763");//Собрать все
			collect = new Button(buttonSettings);
			buttonSettings['caption'] = Locale.__e ("flash:1382952379978");//Выбрать
			attachBttn = new Button(buttonSettings);
			attachBttn.y = 5;
			bodyContainer.addChild(attachBttn);
			attachBttn.addEventListener(MouseEvent.CLICK, attachEvent );
			buttonSettings['caption'] = Locale.__e ("flash:1382952380210");//Поставить
			detachBttn = new Button(buttonSettings);
			detachBttn.y = 5;
			bodyContainer.addChild(detachBttn);
			detachBttn.addEventListener(MouseEvent.CLICK, detachEvent);			
			
			buttonSettings['bgColor'] = 		[0x99cbfe, 0x5c87ef];
			buttonSettings['bevelColor']=		[0xb5dbff, 0x386cdc],
			buttonSettings['fontBorderColor'] =	0x375bb0;
			buttonSettings['fontCountBorder'] =	0x303788;
			buttonSettings['fontSize'] =		20;
			buttonSettings['caption'] = Locale.__e ("flash:1456154675716");//Ускорить всё
			speed = new MoneyButton(buttonSettings);
			speed.countLabelText = mhelper.getPriceItems();
			if (speed.countText < 10) 
			{
				speed.countLabel.x -= 20;
			}else if(speed.countText >= 10 && speed.countText <= 99)
			{
				speed.countLabel.x -= 18;
			}else 
			{
				speed.countLabel.x -= 12;
			}
			
			speed.countLabel.width += 10;
			speed.coinsIcon.x -= 2;
			speed.textLabel.x += 2;
			collect.y = speed.y = 5;
			bodyContainer.addChild (speed);
			bodyContainer.addChild (collect);
			speed.addEventListener(MouseEvent.CLICK, speedAction);
			collect.addEventListener(MouseEvent.CLICK, collectAction);
			
			detachBttn.x = (settings.width + speed.width - detachBttn.width) / 2+2;
			speed.x = (settings.width - speed.width - collect.width) / 2 -2;
			collect.x = -collect.width + speed.x-4;
			attachBttn.x = detachBttn.x + detachBttn.width+4;
		}
		
		private var helpButton:ImageButton;
		public var detachMode:Boolean = false;
		private function detachEvent(e:MouseEvent = null):void
		{
			detachMode = !detachMode;
			contentChange();
			blockAll(detachMode);
		}
		
		private function showHelperTargets(possibleSIDs:Array = null):void {
			if (!possibleSIDs) possibleSIDs = [];
		
			possibleTargets = Map.findUnits(possibleSIDs);
			for each(var res:* in possibleTargets)
			{
				if (res.lock) continue;
				res.state = res.HIGHLIGHTED;
			}
		}
		
		private function attachEvent(e:MouseEvent = null):void
		{
			if ( e.target.mode == Button.DISABLED )
				return;
			
			showHelperTargets(settings.target.posibleTargets);
			showTargets();
			blockAll(true);
			Cursor.type = 'mhelper';
		}
		
		private function speedAction(e:MouseEvent):void {
			if ( speed.mode == Button.DISABLED )
				return;
			mhelper.speedAction(this);
			blockAll(true);
		}
		
		private function collectAction(e:MouseEvent):void {
			if (e.target.mode == Button.DISABLED)
				return;
			mhelper.collectAction(this);
			blockAll(true);
		}
		
		private function showHelp(e:MouseEvent):void
		{
			var hintWindow:ExpeditionHintWindow = new ExpeditionHintWindow( {
				popup: true,
				hintsNum:3,
				hintID:1,
				height:575
			}
			);
			hintWindow.show();
		}
		
		private var isBlock:Boolean = false;
		private var collect:Button;
		private var speed:MoneyButton;
		private var possibleTargets:Array;
		private var attachBttn:Button;
		private var detachBttn:Button;
		
		public function blockAll(value:Boolean):void
		{
			
			isBlock = value;
			for each (var item:MhelperWindowItem in items)
			{
				item.block(value);
			}
		}
		
		override public function dispose():void 
		{
			super.dispose();
			for each (var item:MhelperWindowItem in items)
			{
				item.dispose();
			}
		}
	}

}
import buttons.Button;
import buttons.MoneyButton;
import core.Load;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.events.MouseEvent;
import flash.text.TextField;
import units.Anime2;
import units.Mhelper;
import wins.MhelperWindow;
import wins.Window;
internal class MhelperWindowItem extends LayerX
{
	private var icon:Bitmap = new Bitmap();
	public var bg:Bitmap;
	private var win:MhelperWindow;
	private var item:Object;
	private var txtTime:TextField;
	private var stockBttn:Button;
	private var boostBttn:MoneyButton;
	private var mhelper:Mhelper;
	private var detachBttn:Button;
	private var index:int = 0;
	private var preloader:Preloader = new Preloader();
	public function MhelperWindowItem(_item:Object, _win:MhelperWindow,_index:int) 
	{
		
		item = _item;
	
		win = _win;
		mhelper = win.settings.target;
		index = _index;
		var backing:String = 'itemBackingGold';
		//backing = "itemGoldenBacking";		
		
		bg = Window.backing(140, 190, 45,  backing);
		bg.x = 0;
		bg.y = 0;
		sprite = new LayerX();
		
		sprite.tip = function():Object {
			var check:Object = mhelper.cheackState(item);
			if (check.isReady == Mhelper.READY){
				return {
					title:item.info.title,
					text:Locale.__e("flash:1382952379966") + '\n'
				};
			}
			return {
				title:item.info.title,
				text:Locale.__e("flash:1382952379839", [TimeConverter.timeToStr(item.crafted - App.time)]) + '\n',
				timer:true
			};
		}
		preloader.x = (bg.width)/ 2;
		preloader.y = (bg.height)/ 2 - 15;
		addChildAt(bg, 0);
		sprite.addChild(icon);
		addChild(sprite);
		if (item)
		{	
			
			item.info = App.data.storage[item.sid];
			addChild(preloader);
			Load.loading (Config.getIcon(item.info.type, item.info.view),onLoadObj);
			drawTimer();
			checkState();
		}
		else
		{
			drawSlot();
		}
		
	}
	
	private function onLoadObj(data:Bitmap):void
	{
		removeChild(preloader);
		
	
		icon.bitmapData = data.bitmapData;
		icon.height = 130;
		icon.scaleX = icon.scaleY;
		if ( icon.width > 135 )
		{
			icon.width = 135;
			icon.scaleY = icon.scaleX;
		}
		icon.smoothing = true;
		icon.x = (bg.width - icon.width)/2;
		icon.y =  (bg.height - icon.height) / 2;
		drawTitle();

	}
	private function drawTitle ():void
	{
		var title:TextField = Window.drawText(item.info.title, {
			textAlign:		'center',
			fontSize:		20,
			textLeading:	-9,
			multiline:		true,
			color:			0x7f5130,
			borderColor:	0xf3d8ab,
			borderSize:		2,
			wrap:			true
		});
		title.width = title.textWidth + 20;
		title.x = (bg.width - title.textWidth) / 2 - 10;	
		title.y = 10;
		addChild(title);
	}
	private function slotsEvent(e:MouseEvent):void
	{
		if ( e.target.mode == Button.DISABLED )
			return;
		win.blockAll(true);
		mhelper.extendAction(win);
	}
	private var plus:Bitmap = new Bitmap();
	private var plusBttn:MoneyButton;
	private var sprite:LayerX;
	private function drawSlot():void
	{
		plus.bitmapData = Window.textures.plus;
		plus.x = (bg.width - plus.width) / 2;
		plus.y = (bg.height - plus.height) / 2;
		addChild(plus);
		if ( index >= mhelper.targetsLength && mhelper.stacks > index )
		{
			bg.alpha = 1;
			if (plusBttn )
				plusBttn.visible = false;
		}
		else
		{
			for ( var ins:Object in mhelper.info.extra )
				break;
			bg.alpha = 0.5;
			if (plusBttn )
				plusBttn.visible = true;
			
			plusBttn = new MoneyButton({
				textAlign:			'center',
				autoSize:			'center',
				fontSize:			22,
				caption:			Locale.__e("flash:1382952379890"),//Открыть
				color:				0x5e430c,
				borderColor:		0xFFFFFF,
				shadowSize:			1,
				width:				125,
				height:				35,
				bgColor: 			[0x99cbfe, 0x5c87ef],
				bevelColor:			[0xb5dbff, 0x386cdc],
				fontBorderColor:	0x375bb0,
				fontCountBorder:	0x303788,	
				countText:			mhelper.info.extra[ins]
			});
			plusBttn.x = (bg.width - plusBttn.width ) / 2;
			plusBttn.y = 168;
			addChild (plusBttn);
			plusBttn.addEventListener(MouseEvent.CLICK, slotsEvent);
		}
	}
	private function drawTimer():void
	{
		var textSettings:Object = {
			text:Locale.__e("flash:1382952379793"),
			color:0xffda20,
			fontSize:24,
			borderColor:0x734e24,
			textAlign:'center'
		}
		
		txtTime = Window.drawText(TimeConverter.timeToStr(getTime()), textSettings);
		
		txtTime.x = (bg.width - txtTime.width ) / 2;
		txtTime.y = 140;
		addChild(txtTime);
		App.self.setOnTimer(updateDuration);
		if ( getTime() <= 0 )
		{
			txtTime.visible = false;
			App.self.setOffTimer(updateDuration);
		}
	}
	private function updateDuration():void
	{
		txtTime.text = TimeConverter.timeToStr(getTime());
		if ( getTime() <= 0 )
		{
			checkState();
		}
	}
	private function getTime():int
	{
		return mhelper.getTime(item);
	}
	private function checkState():void
	{
		var textSettings:Object = {
			color:		0xffffff,
			fontSize:	18,
			borderColor:0x303788,
			width:		190,
			textAlign:	'center',
			shadowSize:		0.5
		}
		if (  win.detachMode)
		{
			if (!detachBttn)
			{
				detachBttn = new Button ({
					textAlign:		'center',
					autoSize:		'center',
					fontSize:		28,
					caption:		Locale.__e("flash:1382952380210"),//Поставить
					color:			0x5e430c,
					borderColor:	0xFFFFFF,
					shadowSize:		1,
					width:			125,
					height:			35
				});
				detachBttn.addEventListener(MouseEvent.CLICK, detachEvent);
				addChild(detachBttn);
				detachBttn.x = (bg.width - detachBttn.width) / 2;
				detachBttn.y = 168;
			}
			return;
		}
		var check:Object = mhelper.cheackState(item);
		if ( check.isReady == Mhelper.READY )
		{
			txtTime.visible = false;
			App.self.setOffTimer(updateDuration);
			if (!stockBttn)
			{
				stockBttn = new Button (
					{
						textAlign:		'center',
						autoSize:		'center',
						fontSize:		28,
						caption:		Locale.__e("flash:1382952380146"),//Собрать
						color:			0x5e430c,
						borderColor:	0xFFFFFF,
						shadowSize:		1,
						width:			125,
						height:			35
					}
				);
				stockBttn.addEventListener(MouseEvent.CLICK, storageEvent);
				addChild(stockBttn);
				stockBttn.x = (bg.width - stockBttn.width) / 2;
				stockBttn.y = 168;
			}
		}
		if (check.isBoost == Mhelper.UNBOOST)
		{
			var inform:TextField =  Window.drawText(Locale.__e('flash:1456313755118'), textSettings);//Не ускоряется
			inform.x = (bg.width - inform.width ) / 2;
			inform.y = 135;
			txtTime.y = 155;
			if (check.isReady == Mhelper.READY)
			{
				inform.y = 145;
			}
			addChild(inform);
		}
		if ( check.isReady == Mhelper.UNREADY && check.isBoost == Mhelper.BOOST)
		{
			if (!boostBttn)
			{
				boostBttn = new MoneyButton (
					{
						textAlign:			'center',
						autoSize:			'center',
						fontSize:			22,
						caption:			Locale.__e("flash:1382952380104"),//Ускорить
						color:				0x5e430c,
						borderColor:		0xFFFFFF,
						shadowSize:			1,
						width:				125,
						height:				35,
						bgColor: 			[0x99cbfe, 0x5c87ef],
						bevelColor:			[0xb5dbff, 0x386cdc],
						fontBorderColor:	0x375bb0,
						fontCountBorder:	0x303788,		
						countText:			mhelper.getPriceItems(item)
					}
				);
				boostBttn.addEventListener(MouseEvent.CLICK, boostEvent);
				addChild(boostBttn);
				boostBttn.x = (bg.width - boostBttn.width) / 2;
				boostBttn.y = 168;
			}
		}
	}
	public function block(value:Boolean):void
	{
		if ( !item )
		{
			if ( plusBttn )
			{
				if (value)
					plusBttn.state = Button.DISABLED;
				else 
					plusBttn.state = Button.NORMAL;
			}
			return;
		}
		if (stockBttn)
			stockBttn.visible = !value;
		if ( txtTime )
			txtTime.visible = !value;
		if ( boostBttn )
			boostBttn.visible = !value;
		if (!value && item)
			checkState();
	}
	private function storageEvent(e:MouseEvent):void 
	{
		win.blockAll(true);
		mhelper.collectAction(win,item);
	}
	private function detachEvent(e:MouseEvent):void 
	{
		win.close();
		mhelper.startDetach(item);
	}
	private function boostEvent(e:MouseEvent):void 
	{
		win.blockAll(true);
		mhelper.speedAction(win,item);
	}
	public function dispose():void
	{
		App.self.setOffTimer(updateDuration);
	}
	
}