package wins 
{
	import com.flashdynamix.motion.extras.BitmapTiler;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class BonusOnlineWindow extends Window
	{
		private var info:Object = App.user.bonusOnline.info;
		private var titleCont:Sprite;
		private var itemsCont:Sprite;
		private var title:TextField;
		private var descLabel:TextField;
		private var bonusOnlineItems:Vector.<BonusOnlineItem> = new Vector.<BonusOnlineItem>;
		private var progressBarBacking:Bitmap;
		private var descBg:Shape = new Shape();
		private var backgroundItems:Bitmap = new Bitmap();
		private var craftProgressBar:ProgressBar;
		public function BonusOnlineWindow(settings:Object = null)
		{
			if (!settings)
				settings = { };
			settings['width'] = 520;
			settings['height'] = 609;
			settings['background'] = 'capsuleWindowBacking';
			settings['hasPaginator'] = false;
			settings['title'] = Locale.__e('flash:1484901086557');
			settings['desc'] = Locale.__e('bonus:1:description');//;// Locale.__e('flash:1491491472628');
			settings["shadowBorderColor"] = 0x2a5e0b;
			settings["shadowColor"] = 0x2a5e0b;
			settings['exitTexture']		= 'closeBttnMetal';
			
			//settings['hasTitle'] = false;
			super(settings);
		}
		override public function drawBody():void 
		{
			super.drawBody();
			drawMirrowObjs('decSeaweed', settings.width + 57, - 57, settings.height - 175, true, true, false, 1, 1, layer);
			var fish2:Bitmap = new Bitmap(Window.textures.decFish2);
			fish2.scaleX = fish2.scaleX * ( -1);
			fish2.x = settings.width + 40;
			fish2.y = settings.height - 130;
			bodyContainer.addChild(fish2);	
			drawMessage();
			createItems();
			contentChange();
			App.self.setOnTimer(updateStatus);
			progressBarBacking = Window.backingShort(280, 'backingOne');
			progressBarBacking.x = (settings.width - progressBarBacking.width) / 2;
			progressBarBacking.y = settings.height - progressBarBacking.height - 90;
			bodyContainer.addChild(progressBarBacking);
			
			craftProgressBar = new ProgressBar( { typeLine:'sliderOne', width:276, win:this, timerY:-5} );
			//craftProgressBar.height = 36;
			craftProgressBar.x = progressBarBacking.x - 18;
			craftProgressBar.y = progressBarBacking.y - 14;
			bodyContainer.addChild(craftProgressBar);
			craftProgressBar.start();
			updateStatus();
			exit.y -= 25;
		}
		
		/*protected function drawRibbon():void 
		{
			var titleBackingBmap:Bitmap = backingShort(320, 'ribbonGrenn', true, 1.3);
			titleBackingBmap.x = (settings.width -titleBackingBmap.width) / 2;
			titleBackingBmap.y = -65;
			//titleBackingBmap.filters = [new GlowFilter(0xf3ff2c, .7, 11, 11, 3)];
			bodyContainer.addChild(titleBackingBmap);
			bodyContainer.addChild(titleLabel);
		}*/
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: 0xf9fdff,
				multiline			: settings.multiline,			
				fontSize			: 40,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: 0x5c9900,			
				borderSize 			: settings.fontBorderSize,	
				shadowColor     	: 0x235b00,
				width				: settings.width - settings.titlePading,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			drawRibbon();
			titleLabel.y += 12;
			
			
		}
		public function createItems():void 
		{
			super.contentChange();
			backgroundItems = Window.backing(settings.width - 80, 465, 40, 'paperClear')//фоны самих квестов
			backgroundItems.x = (settings.width - backgroundItems.width) / 2;
			backgroundItems.y = descLabel.y + 40;
			bodyContainer.addChild(backgroundItems);
			itemsCont = new Sprite();
			bodyContainer.addChild(itemsCont);
			
			for each(var ins:BonusOnlineItem in bonusOnlineItems)
			{
				if (ins.parent)
					ins.parent.removeChild(ins);
				ins.dispose();
				ins = null;
			}
			bonusOnlineItems.length = 0;
			// clear all elements
			
			var dY:int = 0;
			var item:BonusOnlineItem;
			var prevItem:BonusOnlineItem;
			for ( var key:String in info.devel.obj)
			{
				prevItem = item;
				
				item = new BonusOnlineItem(key, info.devel.obj[key], uint (info.devel.req[key]), this);
				item.y += dY;
				bonusOnlineItems.push(item);
				dY += 97;
				itemsCont.addChild(item);
				
				/*if (prevItem && prevItem.canTake && !(prevItem.isTake)) 
				{
					//item.isLast = false;
					item.update();
				}*/
			}
			itemsCont.x = 55; /*settings.width * 0.5 - itemsCont.width * 0.5*/;
			itemsCont.y = 80;
		}
		private var currentTime:Number = 0;
		private var prevTime:Number = 0;
		private var endTime:Number = 0;
		private function updateStatus():void
		{
			for each(var ins:BonusOnlineItem in bonusOnlineItems)
			{
				ins.update();
			}
			currentTime = App.user.bonusOnline.info.devel.req[App.user.bonusOnline.numberBonus + 1];
			prevTime = App.user.bonusOnline.info.devel.req[App.user.bonusOnline.numberBonus];
			if (App.user.bonusOnline.numberBonus == 0)
				prevTime = 0;
			endTime = App.user.bonusOnline.info.devel.req[4];
			craftProgressBar.progress = Number((Math.abs((currentTime - App.user.bonusOnline.nextTimePoint) - endTime) / endTime));
			craftProgressBar.time = App.user.bonusOnline.nextTimePoint;
		}
		private function drawMessage():void 
		{
			titleCont = new Sprite();
			title = Window.drawText(info.title, {
				color:0xFFFFFF,
				textLeading: -12,
				borderColor:0xa9784b,
				fontSize:48,
				//multiline:true,
				textAlign:"center",
				//wrap:true,
				width:300,
				shadowColor:0x513f35,
				shadowSize:4
			});
			title.wordWrap = true;
			App.user.bonusOnline
			descLabel = Window.drawText(settings.desc, {
				color:		0xFFFFFF,
				border:		true,
				borderColor:0x7d3f16,
				fontSize:	26,
				multiline:	true,
				width:		380,
				autoSize:	'center',
				textAlign:	"center"
			});
			descLabel.wordWrap = true;
			
			descBg.graphics.beginFill(0xf5d761, 1);
			descBg.graphics.drawRect(0, 0, settings.width - 100, 35);
			descBg.graphics.endFill();
			descBg.x = (settings.width - descBg.width)/2;
			descBg.y = descLabel.y + 32;
			descBg.filters = [new BlurFilter(20, 0, 2)];
			bodyContainer.addChild(descBg);
			
			//var separator:Bitmap = Window.backingShort(settings.width - 100, 'dividerLine', false);
			//separator.alpha = 0.47;
			
			//var separator2:Bitmap = Window.backingShort(settings.width - 100, 'dividerLine', false);
			//separator2.alpha = 0.47;
			
			//titleCont.addChild(title);
			bodyContainer.addChild(descLabel);
			/*titleCont.addChild(separator);
			titleCont.addChild(separator2);*/
			//bodyContainer.addChild(titleCont);
			
		
			/*title.y = 0;
			title.x = separator.width * 0.5 - title.width * 0.5;*/
			descLabel.y = titleLabel.y + 90;
			descLabel.x = (settings.width-descLabel.textWidth)/2 - 25;
			

			//drawMirrowObjs('questDecTitle', title.x - 50, title.x + title.width + 50, title.y + title.height / 2 - 11, false, false, false, 1, 1, titleCont);
			/*titleCont.x = settings.width * 0.5 - separator.width * 0.5;
			titleCont.y = 30;*/
		}
		override public function dispose():void 
		{
			super.dispose();
			App.self.setOffTimer(updateStatus);
		}
	}

}
import buttons.Button;
import core.Size;
import core.TimeConverter;
import flash.display.Bitmap;
import flash.display.GradientType;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.BlurFilter;
import flash.text.TextField;
import wins.BonusOnlineWindow;
import wins.CollectionBonusList;
import wins.Window;
internal class BonusOnlineItem extends LayerX
{
	//public var isLast:Boolean = true;
	
	private var ID:String;// может пригодится
	private var req:uint = 0;
	private var reward:Object = { };
	private var takeBttn:Button;
	private var win:BonusOnlineWindow;
	private var checkMark:Bitmap;
	private var bg:Shape = new Shape();
	public function BonusOnlineItem(id:String,reward:Object, req:uint,win:BonusOnlineWindow)
	{
		this.win = win;
		this.req = req;
		this.reward = reward;
		this.ID = id;
		super();
		drawBody();
	}
	private function drawBody():void
	{
		var leftCont:Sprite = new Sprite();
		addChild(leftCont);
		var circle:Bitmap;	
		var textSet:Object = {
			color:0xf9e770,
			borderColor:0x68311c,
			fontSize:26,
			multiline:true,
			wrap:true,
			textAlign:'center',
			width:90,
			textLeading: -11
		};
		var timeLabelText:String = (req >= 3600)?TimeConverter.timeToCuts(req, false, false):TimeConverter.timeToCuts(req, false, true);
		timeLabelText = timeLabelText.replace(' ', '\n');
		var dY:int = 27;
		var dX:int = 5;
		switch(ID)
		{
			case '1':
				circle					= new Bitmap (Window.textures.clearBubbleBacking_0);
				textSet['color'] 		= 0xf8ecd0;
				textSet['borderColor']	= 0x68311c;
				textSet['fontSize']		= 28;
				break;
			case '2':
				circle					= new Bitmap (Window.textures.clearBubbleBacking_0);
				textSet['color'] 		= 0xe2e2e2;
				textSet['borderColor']	= 0x3e3d3d;
				textSet['fontSize']		= 28;
				break;
			case '3':
				circle					= new Bitmap (Window.textures.clearBubbleBacking_0);
				textSet['color'] 		= 0xffd7a9;
				textSet['borderColor']	= 0x68311c;
				textSet['fontSize']		= 28;
				//dY						= 10;
				break;
			case '4':
				circle					= new Bitmap (Window.textures.clearBubbleBacking_0);
				textSet['color'] 		= 0xf9e770;
				textSet['fontSize']		= 28;
				//dY						= 10;
				break;
		}
		var glow:Bitmap = new Bitmap(Window.textures.glowingBackingNew);
		Size.size (glow, 98, 98);
		glow.smoothing = true;
		glow.x = -4;
		glow.y = -4;
		glow.visible = false;
		if (ID == '4')
			glow.visible = true;
		circle.scaleX = circle.scaleY = 1.5;
		circle.smoothing = true;
		circle.x += 15;
		circle.y += 13;
		leftCont.addChild(circle);
		//leftCont.addChild(glow);
		var timeLabel:TextField = Window.drawText( timeLabelText, textSet);
		leftCont.addChild(timeLabel);
		timeLabel.y = dY;
		timeLabel.x = dX;
		
		
		/*var bg:Shape = new Shape();
		var bgR:Shape = new Shape();
		bg.x = circle.width;
		bg.y = circle.y;
		bg.graphics.beginGradientFill(GradientType.LINEAR, [0xFFFFFF, 0xFFFFFF], [0.03, 0.47],[132, 255]);
		bg.graphics.drawRect(0, 0, 130, 55);
		bg.graphics.endFill();
		
		bgR.graphics.beginGradientFill(GradientType.LINEAR, [0xFFFFFF, 0xFFFFFF], [0.47, 0.03],[132, 255]);
		bgR.graphics.drawRect(0, 0, 130, 55);
		bgR.graphics.endFill();
		bgR.x = bg.x + bg.width;
		bgR.y = bg.y;
		
		leftCont.addChild(bg);
		leftCont.addChild(bgR);*/
		bg.graphics.beginFill(0xfbeaa6, 1);
		bg.graphics.drawRect(0, 0, 235, 50);
		bg.graphics.endFill();
		bg.x = circle.width + 30;
		bg.y = circle.y + 15;
		bg.filters = [new BlurFilter(20, 0, 2)];
		leftCont.addChild(bg);
		
		
		var rewCont:Sprite = new Sprite();
		addChild(rewCont);
		
		var rewTitle:TextField = Window.drawText(
		Locale.__e("flash:1382952380000"), {
			fontSize	:34,
			color		:0xfeed5a,
			border		:true,
			borderSize	:3,
			borderColor	:0x613719,
			autoSize	:"left",
			shadowSize	:2,
			shadowColor	:0x623a17
		});
		rewTitle.x = 0;
		rewTitle.y = 36;
		rewCont.addChild(rewTitle);			
		//var rewardB:RewardList = new RewardList(reward, false, 140, "", 0.4, 30, 30, 36, "", 0.74, 10, 0);
		var rewardB:CollectionBonusList = new CollectionBonusList(reward, false, {backDafault:false, bgY:10, counterDX:-20, itemBg:"glowingBackingNew", hasTitle: false });
		rewCont.addChild(rewardB);
		rewardB.x = 90;
		rewardB.y = -39;
		
	/*	if (rewardB.x <= rewTitle.textWidth)
			rewardB.x = rewTitle.textWidth - rewardB.width * .5 + 5;*/
		
		rewCont.x = 102;
		rewCont.y = -3;
		var rightCont:Sprite = new Sprite();
		addChild(rightCont);
		takeBttn = new Button( {
			width:80,
			height:36,
			fontSize:22,
			hasDotes:false,
			caption:Locale.__e("flash:1382952379737")
		});
		rightCont.addChild(takeBttn);
		rightCont.x = 300;
		rightCont.y = 0;
		
		takeBttn.x = 25;
		takeBttn.y = 33;
		takeBttn.visible = false;
		takeBttn.addEventListener(MouseEvent.CLICK, onTakeBttn);
		
		checkMark = new Bitmap(Window.textures.checkmarkBig);
		checkMark.x = 25;
		checkMark.y = 25;
		checkMark.scaleX = checkMark.scaleY = 0.7;
		checkMark.smoothing = true;
		rightCont.addChild(checkMark);
		checkMark.visible = false;
		update();
	}
	private function onTakeBttn(e:MouseEvent):void
	{
		if (e.currentTarget.mode == Button.DISABLED) return;
		e.currentTarget.state = Button.DISABLED;
		//if (win)
			//win.close();
		App.user.bonusOnline.takeBonus(int(ID));
		update();
	}
	public function update():void
	{
		if ( isTake )
		{
			takeBttn.visible = false;
			checkMark.visible = true;
		}
		else if (canTake)
		{
			takeBttn.visible = isLast;
			checkMark.visible = false;
		}
		else
		{
			takeBttn.visible = false;
			checkMark.visible = false;
		}
	}
	public function get isLast():Boolean
	{
		return App.user.bonusOnline.numberBonus + 1 == int(ID);
	}
	public function get canTake():Boolean
	{
		return App.user.bonusOnline.nextTimePoint <= 0;
	}
	public function get isTake():Boolean
	{
		return App.user.bonusOnline.bonus.hasOwnProperty(ID);
	}
	public function dispose():void
	{
		
	}
}