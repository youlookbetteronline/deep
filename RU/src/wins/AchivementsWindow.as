package wins 
{
	import buttons.ImagesButton;
	import com.adobe.images.BitString;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import ui.UserInterface;
	
	public class AchivementsWindow extends Window
	{
		private static var isPremShoed:Boolean = false;
		private var textFilter:GlowFilter;
		private var shadowFilter:BlurFilter;
		
		public static function checkAchProgress(ind:int):void
		{			
			if (App.user.mode == User.GUEST) return;
			if (App.user.ach[ind]) 
			{
				/*if (!App.data.ach[ind].enable) 
				{
				return
				}*/
				for (var mis:* in App.user.ach[ind]) 
				{
					if (App.user.ach[ind][mis] < 1000000000 && App.data.ach[ind].missions[mis].need <= App.user.ach[ind][mis]) 
					{
						if (AchivementMsgWindow.showed.indexOf(App.data.ach[ind].ID) != -1)
							continue;
						
						if (mis == 1 && /*App.user.level <= 35 &&*/ !isPremShoed && !App.user.quests.tutorial)
						{
							isPremShoed = true;
							var currentTarget:*;
							var timeHide:int = 0;
							
							currentTarget = App.ui.bottomPanel.iconsBottom[2].bttn;
							currentTarget.showGlowing();
							currentTarget.showPointing("top", 0, 0, currentTarget.parent, '', null);
							
							var hideGlowArrow:Function = function():void
							{
								timeHide++;
								if (timeHide > 5)
								{
									App.self.setOffTimer(hideGlowArrow);
									currentTarget.hideGlowing();
									currentTarget.hidePointing();
									timeHide = 0;
								}
							}
							App.self.setOnTimer(hideGlowArrow);
							new InformWindow({
								label: 14,
								title: Locale.__e('flash:1393579648825'),
								text: Locale.__e('flash:1404212292872')	
							}).show();							
						}else {
							App.ui.bottomPanel.bttns[3].hidePointing();		
							
							new AchivementMsgWindow(App.data.ach[ind], mis).show();
						}
						App.ui.bottomPanel.updateAchiveCounter();
					}
				}
			}			
		}
		
		public var totalMissions:int;
		public var achivements:Array = [];
		
		public function AchivementsWindow(settings:Object = null) 
		{
			if (settings == null) 
			{
				settings = new Object();
			}
			
			settings['width'] = 800;
			settings['height'] = 680;
			settings['title'] = Locale.__e('flash:1396961879671');
			settings['background'] = 'shopBackingNew';
			settings["itemsOnPage"] = 4;			
			settings["page"] = 0;
			settings["shadowBorderColor"] = 0x2a5e0b;
			
			totalMissions = 0;
			
			super(settings);			
			
			for (var ach:* in App.data.ach)
			{
				if (App.data.ach[ach].hasOwnProperty('update') && App.data.ach[ach].update != "" && !App.data.updatelist[App.social].hasOwnProperty(App.data.ach[ach].update))
				{
					delete App.data.ach[ach];
					continue;
				}
				var item:Achivement = new Achivement(ach, App.data.ach[ach], this);
				
				if (App.data.ach[ach].enable) 
				{
					achivements.push(item);
				}	
				
			}
			
			achivements.sortOn(['indDone', 'numMission','order'], [Array.NUMERIC]);			
			findTargetPage(settings);		
		}
		
		private function findAmuletBttn(settings:Object):void 
		{
			if (settings.findAmulet != null)
			{				
				bttnAmulet.showGlowing();
				bttnAmulet.showPointing('bottom', -15, 60, bttnAmulet.parent);
			}
		}
		
		override public function drawExit():void 
		{
			super.drawExit();
			exit.x = settings.width - 65;
			exit.y = -10;
		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: 0xf9fdff,
				multiline			: settings.multiline,			
				fontSize			: settings.fontSize,				
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
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = -16;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
			headerContainer.addChild(titleLabel);
			headerContainer.mouseEnabled = false;
		}
		
		private function findTargetPage(settings:Object):void 
		{
			if (settings.find != null) 
			{				
				for (var i:int = 0; i < achivements.length; i++ )
				{
					if (achivements[i].id == settings.find) 
					{
						achivements.unshift(achivements[i]);
						return;
					}
				}
			}
		}
		
		override public function drawArrows():void
		{
			paginator.drawArrow(bottomContainer, Paginator.LEFT,  0, 0, { scaleX: -1, scaleY:1 } );
			paginator.drawArrow(bottomContainer, Paginator.RIGHT, 0, 0, { scaleX:1, scaleY:1 } );
			
			var y:Number = 75;
			paginator.arrowLeft.x = paginator.arrowLeft.width/1.5;;
			paginator.arrowLeft.y = settings.height/2 - y+35;
			
			paginator.arrowRight.x = settings.width  - paginator.arrowRight.width/1.5;
			paginator.arrowRight.y = settings.height/2 - y+35;
			
			paginator.x = int((settings.width - paginator.width)/2 - 10);
			paginator.y = int(settings.height - paginator.height - 3);
		}
		
		override public function drawBackground():void 
		{
			var background:Bitmap = backing(settings.width, settings.height, 50, settings.background);
			background.y = - 15;
			layer.addChild(background);			
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
		
		override public function drawBody():void 
		{
			this.y -= 5;
			fader.y += 5;
				
			drawMirrowObjs('decSeaweed', settings.width + 39, - 39, settings.height - 195, true, true, false, 1, 1);
			//drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -46, true, true);
			//drawMirrowObjs('storageWoodenDec', 2, settings.width-2, 35,false,false,false,1,-1);
			//drawMirrowObjs('storageWoodenDec', 2, settings.width - 2, settings.height - 128);
			var titleBackingBmap:Bitmap = backingShort(390, 'ribbonGrenn',true,1.3);
			titleBackingBmap.x = settings.width/2 -titleBackingBmap.width/2;
			titleBackingBmap.y = -55;
			bodyContainer.addChild(titleBackingBmap);
			
			var plankBmap:Bitmap = backingShort(settings.width - 90, 'shopPlank'); // надо будет заменить
			plankBmap.x = 45;
			plankBmap.y = 120;
			layer.addChild(plankBmap);
			
			var plankBmap1:Bitmap = backingShort(settings.width - 90, 'shopPlank');
			plankBmap1.x = 45;
			plankBmap1.y = 240;
			layer.addChild(plankBmap1);
			
			var plankBmap2:Bitmap = backingShort(settings.width - 90, 'shopPlank');
			plankBmap2.x = 45;
			plankBmap2.y = plankBmap1.y + 120;
			layer.addChild(plankBmap2);
			
			var plankBmap3:Bitmap = backingShort(settings.width - 90, 'shopPlank');
			plankBmap3.x = 45;
			plankBmap3.y = plankBmap2.y + 120;
			layer.addChild(plankBmap3);
			
			titleLabel.y -= 0;
			/*var rrect:Sprite = new Sprite();
			rrect.graphics.beginFill(0xedca94);
			rrect.graphics.drawRoundRect(0,0,480, 100,40);
			rrect.graphics.endFill();
			bodyContainer.addChild(rrect);
			rrect.alpha = .1;
			rrect.x = 140;
			rrect.y = -5;*/
			
			
			
			var downPlankBmap:Bitmap = backingShort(300, 'shopPlankDown');
			downPlankBmap.x = settings.width/2 -downPlankBmap.width/2;
			downPlankBmap.y = settings.height - 65;
			layer.addChild(downPlankBmap);
			
			drawDesc();
			paginator.itemsCount = 0;
			
			for (var ach:* in App.data.ach) 
			{
				if (App.data.ach[ach].enable) 
				{
					paginator.itemsCount++;
				}				
			}
			
			paginator.page = settings.page;
			paginator.update();
			contentChange();
			
			//drawAmulet();
		}
		
		public var bttnAmulet:ImagesButton;
		
		/*private function drawAmulet():void 
		{
			bttnAmulet = new ImagesButton(UserInterface.textures.interRoundBttn, UserInterface.textures.amuletFullSmall);	
			bttnAmulet.addEventListener(MouseEvent.CLICK, amuletClick);
					
			bodyContainer.addChild(bttnAmulet);
			
			bttnAmulet.x = 600;
			bttnAmulet.x = 600;
			bttnAmulet.y = -40;
			
			findAmuletBttn(settings);
		}*/
		
		/*private function amuletClick(e:MouseEvent):void 
		{
			if (bttnAmulet.__hasGlowing||bttnAmulet.__hasPointing) 
			{
				bttnAmulet.hidePointing();
				bttnAmulet.hideGlowing();
			}
			
			new AmuletWindow({}).show();
		}*/
		
		private var missionsCount:TextField;
		
		private function drawDesc():void 
		{
			var title:TextField = Window.drawText(Locale.__e('flash:1393518655260'), {
				color:0x7a4415,
				borderColor:0xf9f3db,
				textAlign:"center",
				autoSize:"center",
				fontSize:30
			});
			
			bodyContainer.addChild(title);
			title.x = (settings.width - title.textWidth) / 2 + 80;
			title.y = 40;
			if (App.social !== 'SP')
			{
				var backgroundTitle:Bitmap = Window.backingShort(title.textWidth + 80, 'questTaskBackingNew', true);
				backgroundTitle.x = title.x + (title.width -  backgroundTitle.width)/ 2 ;
				backgroundTitle.y = title.y;
				backgroundTitle.scaleY = .45;
				backgroundTitle.alpha = 1;
				bodyContainer.addChild(backgroundTitle);
				bodyContainer.swapChildren(backgroundTitle, title);
			}
			var doneCont:Sprite = new Sprite();
			
			var backgroundExsepted:Bitmap = Window.separator2(160, 'giftBeckingCollection', 'giftBeckingCollectio');
			backgroundExsepted.x = 30;
			backgroundExsepted.y = 30;
			backgroundExsepted.scaleY = 1.2;
			backgroundExsepted.filters = [new DropShadowFilter(4.0, 45, 0, 0.5, 4.0, 4.0, 1.0, 3, false, false, false)];
			doneCont.addChild(backgroundExsepted);
			
			var missionsDone:TextField = Window.drawText(Locale.__e('flash:1393579829632'), {
				color:0xffffff,
				borderColor:0x7b4003,
				textAlign:"center",
				autoSize:"center",
				fontSize:24
			});
			
			doneCont.addChild(missionsDone);
			missionsDone.y = backgroundExsepted.y + 17;
			missionsDone.x = backgroundExsepted.x + (backgroundExsepted.width - missionsDone.width)/2 + 10;
			
			missionsCount = Window.drawText(String(0) + "/" + String(totalMissions), {
				color:0xffe760,
				borderColor:0x7b4003,
				textAlign:"center",
				autoSize:"left",
				fontSize:36
			});
			
			missionsCount.width = missionsCount.textWidth + 10;
			doneCont.addChild(missionsCount);
			missionsCount.x = missionsDone.x + (missionsDone.width - missionsCount.width)/ 2;
			missionsCount.y = missionsDone.y + missionsDone.textHeight - 5;
			
			if (missionsCount.x < 0)
			{
				missionsDone.x = Math.abs(missionsCount.x);
				missionsCount.x = 0;
			}
			
			bodyContainer.addChild(doneCont);
			doneCont.x = 30;
			doneCont.y = -24;
		}
		
		override public function contentChange():void 
		{			
			for each(var item:Achivement in achivements) 
			{
				if(item.parent)item.parent.removeChild(item);
				item.dispose();
				item = null;
			}
			
			achivements.splice(0, achivements.length);
			achivements = [];
			
			for (var ach:* in App.data.ach)
			{
				if (App.data.ach[ach].enable) 
				{
					var doGlow:Boolean = false;
					if (settings.find == ach) doGlow = true;
					item = new Achivement(ach, App.data.ach[ach], this, doGlow);
					achivements.push(item);
				}				
			}
			
			var arr:Array = [];
			
			for (var j:int = 0; j < achivements.length; j++ )
			{
				if (achivements[j].indDone == 0)
				{
					arr.push(achivements[j]);
					achivements.splice(j, 1);
					j--;
				}
			}
			
			if (arr.length > 0)
			{
				for (j = 0; j < achivements.length; j++ ) 
				{
					arr.push(achivements[j]);
				}
				achivements.splice(0, achivements.length);
				achivements = arr;
			}
			
			var posY:int = 110;
			achivements.sortOn(['indDone', 'numMission', 'order'], [Array.NUMERIC]);
			
			for (var i:int = paginator.startCount; i < paginator.finishCount; i++ ) 
			{
				item = achivements[i];				
				bodyContainer.addChild(item);
				item.x = (settings.width - item.background.width) / 2  ;
				item.y = posY;
				posY += 120 ;
			}
			setDoneMissions();
		}
		
		public function setDoneMissions():void 
		{
			var doneMiss:int = 0;
			var totalMiss:int = 0;
			for (var i:int = 0; i < achivements.length; i++ ) 
			{
				var ach:Achivement = achivements[i];
				doneMiss += ach.getDoneMissions();
				totalMiss += ach.totalStars;
			}
			if (doneMiss < 0) doneMiss = 0;
			missionsCount.text = String(doneMiss) + "/" + String(totalMiss);
		}
		
		public function changeCurrent(ind:int):void
		{
			for (var i:int = 0; i < achivements.length; i++ )
			{
				var item:Achivement = achivements[i];
				if (item.id == ind) 
				{
					item.update(ind, App.data.ach[ind]);
				}
			}
		}
		
		private function getDoneMissions():int 
		{
			return 100;
		}		
	}
}

import api.ExternalApi;
import buttons.Button;
import buttons.ImageButton;
import buttons.MoneyButton;
import com.greensock.easing.Elastic;
import com.greensock.TweenLite;
import com.greensock.TweenMax;
import core.Load;
import core.Post;
import core.WallPost;
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.text.TextField;
import strings.Strings;
import ui.Hints;
import ui.UserInterface;
import wins.Window;
import wins.ProgressBar;
import wins.AchivementsWindow;
import wins.AchivementMsgWindow;

internal class Achivement extends Sprite 
{
	public var background:Bitmap;
	public var bitmap:Bitmap = new Bitmap();	
	public var achive:Object = { };
	public var mission:Object = { };	
	public var id:int;
	public var totalStars:int;
	public var numMission:int = 0;
	public var indDone:int = 0;
	public var order:int = 0
	
	private var window:AchivementsWindow;	
	private var openStars:int;	
	private var isAllDone:Boolean = false;
	private var missionDone:Boolean = false;
	private var tweenStart:TweenLite;
	private var starsCont:Sprite = new Sprite();
	private var margX:int = 7;
	private var margY:int = 5;
	private var tweenGlow1:TweenLite;
	private var tweenGlow2:TweenLite;
	private var infoCont:Sprite = new Sprite();
	private var takeBttn:Button;
	private var rewardCont:Sprite = new Sprite();
	private var canGlowing:Boolean = true;
	
	public function Achivement(id:int, achive:Object, window:AchivementsWindow, doGlow:Boolean = false) 
	{
		this.window = window;
		update(id, achive, doGlow);
	}
	
	public function update(id:int, achive:Object, doGlow:Boolean = false):void
	{
		indDone = 0;
		order = 0;
		missionDone = false;
		isAllDone = false;
		numMission = 0;
		
		this.achive = achive;
		this.id = id;
		
		numMission = getMission();
		if (numMission > getTotalMissions()) 
			isAllDone = true;
		else 
			missionDone = checkEndMission(numMission);
		
		if (!missionDone) indDone = 1;
		order = achive.order;
		
		totalStars = 3;
		openStars = numMission - 1;
		
		if (openStars > totalStars) openStars = totalStars;
		if (isAllDone) openStars = totalStars;
		
		var count:int = 1;
		for (var mis:* in achive.missions) 
		{
			if (count == numMission) 
			{
				mission = achive.missions[mis];
				break;
			}
			count++;
		}
		
		clearBody();
		drawBody();
		
		if (doGlow) glowing();
	}
	
	private function clearBody():void 
	{	
		if (background && background.parent)
			background.parent.removeChild(background);
		background = null;
		
		if (bitmap && bitmap.parent)
			bitmap.parent.removeChild(bitmap);
		bitmap = null;
		
		if (starsCont && starsCont.parent)
			starsCont.parent.removeChild(starsCont);
		starsCont = null;
		starsCont = new Sprite();
		
		if (infoCont && infoCont.parent)
			infoCont.parent.removeChild(infoCont);
		infoCont = null;
		infoCont = new Sprite();
		
		if (takeBttn) {
			takeBttn.removeEventListener(MouseEvent.CLICK, onTake);
			takeBttn.dispose();
		}
		takeBttn = null;
		
		if (rewardCont && rewardCont.parent)
			rewardCont.parent.removeChild(rewardCont);
		rewardCont = null;
		rewardCont = new Sprite();
		
		if (rewardCont && rewardCont.parent)
			rewardCont.parent.removeChild(rewardCont);
		rewardCont = null;
		rewardCont = new Sprite();
	}
	
	private function checkEndMission(num:int):Boolean 
	{
		if (App.user.ach[id]) 
		{
			var count:int = 1;
			
			for (var mis:* in achive.missions) 
			{
				if (count == num)
				{
					if (achive.missions[mis].need <= App.user.ach[id][mis])
						return true;
					
					break;
				}
				count++;
			}
		}
		
		return false;
	}
	
	private function getTotalMissions():int 
	{
		var num:int = 0;
		for (var cnt:* in achive.missions) 
		{
			num++;
		}
		return num;
	}
	
	private function getMission():int 
	{
		var num:int = 1;
		for (var cnt:* in App.user.ach[id]) 
		{
			if (App.user.ach[id][cnt] > 1000000000)
				num++;
		}
		
		if (num == 0) num = 1;
		return num;
	}
	
	private function drawBody():void 
	{
		background = Window.backing2(720, 130, 44, 'shopBackingNew', 'shopBackingNew2');
		background.smoothing = true;
		//addChild(background);
		
		drawStars();		
		drawInfo();		
		drawBttn();		
		drawRewardInfo();
	}	
	
	public var starScaleX1:Number = 0.9;
	public var starScaleX2:Number = 0.7;
		
	private function drawStars():void
	{
		var i:int;
		var posX:int = 15;
		var posY:int = 30;
		
		for ( i = 0; i < totalStars; i++ )
		{
			var star:Bitmap = new Bitmap(Window.textures.achievStarDisabled);
			star.smoothing = true;
			
			starsCont.addChild(star);
			star.x = posX;
			star.y = posY+3;
			star.scaleX = star.scaleY = 1;
			posX += star.width+5;
			posY -= 20;
			if (i == totalStars - 2)
			{
				posY += 40;
				
			}
			if (i == totalStars - 1){
				star.scaleX = -1;
				star.x += star.width;
			}
		}
		
		posX = 15;
		posY = 30;
		
		var starGlow:Bitmap;
		var doGlow:Boolean = false;
		
		if (missionDone && !isAllDone)
		{
			openStars += 1;
			doGlow = true;
		}
		
		
		for (i = 0; i < openStars; i++ )
		{
			starScaleX1 = .9;
			starScaleX2 = .7;
			
			var star2:Bitmap = new Bitmap(Window.textures.achievStar);
			star2.scaleX = star2.scaleY = 1;
			star2.smoothing = true;
			starsCont.addChild(star2);
			
			star2.x = posX;
			star2.y = posY+3;
			posX += star2.width+5;
			posY -= 20;
			if (i == totalStars - 2)
			{
				posY += 40;
				posX -= 40;
			}
			
			if (i == totalStars - 1){
				star2.x += star2.width +star2.width/1.4 - 3;
				//star2.y += 9;
				starScaleX1 = -.9;
				starScaleX2 = -.7;
				star2.scaleX = -1;
				margX *= -1;
			}
			
			/*star2.x = posX-3;
			star2.y = posY-3;
			
			posX += star.width + 4;
			posY -= 10;*/
			
			/*if (doGlow && i == (openStars - 1)) // было
			{
				star2.alpha = 0;
				starGlow = star2;
				star2.x -= 11;
				star2.y -= 1;
			}*/
			/*if (doGlow && i == (openStars - 1)) // первая и вторая норм
			{
				star2.alpha = 0;
				starGlow = star2;
				star2.x += 10;
				star2.y += 8;
			}*/
			
			if (doGlow && i == (openStars - 1) && i != totalStars-1)
			{
				star2.alpha = 0;
				starGlow = star2;
				star2.x += 10;
				star2.y += 8;
			}else{	
				if (doGlow && i == (openStars - 1)) // было
				{
					star2.alpha = 0;
					starGlow = star2;
					star2.x -= 10;
					star2.y += 8;
				}
			}
		}
		
		if(starGlow)
			tweenStart = TweenLite.to(starGlow, 0.5, {onComplete:function():void { starGlow.alpha = 0; glowStar(starGlow);}} ); 
		
		addChild(starsCont);
		starsCont.x = 18;
		starsCont.y = background.y + 5;
	}	
	
	private function glowStar(star:Bitmap):void
	{
		tweenGlow1 = TweenLite.to(star, 1, {x:star.x-margX, y:star.y-margY, alpha:1, scaleX:starScaleX1, scaleY:0.9, ease:Elastic.easeOut, onComplete:function():void {
			tweenGlow2 = TweenLite.to(star, 1, {x:star.x+margX, y:star.y+margY, alpha:0, scaleX:starScaleX2, scaleY:0.7, onComplete:function():void {
				glowStar(star);
			}});
		}});
	}
	
	private function drawInfo():void 
	{
		var backgroundDesc:Bitmap = new Bitmap;
		var title:TextField = Window.drawText(achive.title, {
			color:0xffe55c,
			borderColor:0x71360c,
			textAlign:"center",
			autoSize:"center",
			fontSize:30
		});
		
		title.width = title.textWidth + 10;
		
		var font:int = 26;
		
		while (title.textWidth>200) 
		{		
			title = Window.drawText(achive.title, {
				color:0xffe55c,
				borderColor:0x71360c,
				textAlign:"center",
				autoSize:"center",
				fontSize:font--
			});
		}
		
		infoCont.addChild(title);
		title.x = 0;
		title.y = 2;
		
		if (!missionDone)
		{
			var txt:String; 
			if (isAllDone)
				txt = achive.description;
			else
				txt = mission.description;
			
			var desc:TextField = Window.drawText(txt, {
				color:0xffffff,
				borderColor:0x8e4f2e,
				textAlign:"center",
				autoSize:"center",
				fontSize:22,
				distShadow:0,
				multiline:true,
				wrap:true
			});
			
			desc.width = 200;
			//desc.border = true;
			
			/*if (desc.height <= 30)
			{
				title.y = 15;
			}*/
			
			
			infoCont.addChild(desc);
			desc.x = (title.textWidth - desc.width) / 2;
			
			
			if (desc.x < 0)
			{
				title.x = Math.abs(desc.x);
				desc.x = 0;
			}
			backgroundDesc = Window.amazingBackingShort(desc.width+10, "giftBeckingCollectio");
			backgroundDesc.x = desc.x-5;
			backgroundDesc.y = title.y + backgroundDesc.height / 3 + 10;
			desc.y = backgroundDesc.y + backgroundDesc.height/2 - desc.textHeight / 2/*title.y + title.height*/ /*-  desc.height +0*/;
			 //title.y + backgroundDesc.height + 10
			
			backgroundDesc.filters = [new DropShadowFilter(4.0, 45, 0, 0.5, 4.0, 4.0, 1.0, 3, false, false, false)];
			
			infoCont.addChild(backgroundDesc);
			infoCont.swapChildren(backgroundDesc, desc)
			infoCont.swapChildren(backgroundDesc, title)
			//backgroundExsepted.scaleY = 1.2;
			
		}
		
		addChild(infoCont);
		infoCont.x = 340 - infoCont.width / 2;
		infoCont.y = 4;
	}
	
	private function drawBttn():void 
	{
		if (missionDone && !isAllDone) 
		{
			var bg:Bitmap = Window.backingShort(190, 'buttonGrenn');
			takeBttn = new ImageButton(bg.bitmapData);
			
			var buttonText:TextField = Window.drawText(Locale.__e('flash:1393579618588'), {
				color:0xffffff,
				borderColor:0x4b6c00,
				textAlign:"center",
				autoSize:"center",
				fontSize:26
			});
			//buttonText.border = true;
			
			
			/*takeBttn = new Button( {
				caption:Locale.__e("flash:1393579618588"),
				fontSize:24,
				width:190,
				hasDotes:false,
				height:44,
				greenDotes:false,
				bgColor:				[0xa8f84a,0x74bc17],	
				borderColor:			[0x4d7b83,0x4d7b83],	
				bevelColor:				[0xc8fa8f, 0x5f9c11],
				fontColor:				0xffffff,				
				fontBorderColor:		0x4d7d0e
			});*/
			
			addChild(takeBttn);
			takeBttn.x = 340 - takeBttn.width / 2;
			takeBttn.y = background.height - takeBttn.height - 30;	
			
			buttonText.x = takeBttn.x + (takeBttn.width - buttonText.width) / 2;
			buttonText.y = takeBttn.y + (takeBttn.height - buttonText.height) / 2;
			addChild(buttonText);
			takeBttn.addEventListener(MouseEvent.CLICK, onTake);
		}
	}	
	
	private function drawRewardInfo():void 
	{
		if (isAllDone) 
		{
			//var bg:Bitmap = new Bitmap(Window.textures.questCheckmarkSlot);
			var mark:Bitmap = new Bitmap(Window.textures.checkmarkBig);
			
			//bg.x = 4;
			mark.x = 12;
			mark.y = 0;
			//rewardCont.addChild(bg);
			var markTxt:TextField = Window.drawText(Locale.__e('flash:1446376312281'), {
				color:0xcef55a,
				borderColor:0x316b07,
				textAlign:"left",
				autoSize:"left",
				fontSize:28
			});
			
			markTxt.height = markTxt.textHeight;
			rewardCont.addChild(markTxt);
			markTxt.y = mark.y + mark.height + 0;
			markTxt.x = mark.x + (mark.width - markTxt.width)/2 ;
			rewardCont.addChild(mark);
		}else {
			var progressBacking:Bitmap = Window.backingShort(200, "progBarBacking");
			progressBacking.x = -26;
			rewardCont.addChild(progressBacking);
			/*progressBacking.scaleX = 1;
			progressBacking.scaleY = 1;*/
			progressBacking.alpha = 1;
			progressBacking.smoothing = true;
			var progressBar:ProgressBar = new ProgressBar( { win:this, width:155, isTimer:false,scale:0.7});
			progressBar.x = progressBacking.x - 23;
			progressBar.y = progressBacking.y - 16;
			rewardCont.addChild(progressBar);
			progressBar.start();
			progressBar.progress = getProgress();
			progressBar.scaleX = 1.3;
			progressBar.scaleY = 1.3;
			
			var count:TextField = Window.drawText(getProgressTxt(), {
				color:			0xffffff,
				borderColor:	0x654317,
				fontSize:		28
			});
			
			count.width = count.textWidth + 10;
			count.x = (progressBacking.width - count.textWidth) / 2 - 25;
			count.y = -1;
			rewardCont.addChild(count);
			
			var bonusCont:Sprite = new Sprite();
			
			var rewardTxt:TextField = Window.drawText(Locale.__e('flash:1382952380000'), {
				color:0xffffff,
				borderColor:0x654317,
				textAlign:"left",
				autoSize:"left",
				fontSize:28
			});
			
			rewardTxt.height = rewardTxt.textHeight;
			bonusCont.addChild(rewardTxt);
			rewardTxt.y = 15;
			rewardTxt.x = -45;
			
			for (var _ind:* in mission.bonus)
			{
				break;
			}
			
			var icon:Bitmap = new Bitmap();
			icon.filters = [new GlowFilter(0xffffff, .8, 4, 4, 6)];
			var settings:Object = {			
				color:0xcde3ff,
				borderColor:0x281e7e			
			};
			var countTxt:TextField = Window.drawText(getBonus(), {
				color:0xf7e344,
				borderColor:0xf95b02,
				textAlign:"left",
				autoSize:"left",
				fontSize:32
			});
			
			Load.loading(Config.getIcon(App.data.storage[_ind].type, App.data.storage[_ind].preview), function(data:*):void { 
				icon.bitmapData = data.bitmapData;				
				icon.scaleX = icon.scaleY = .2;
				icon.smoothing = true;
				bonusCont.addChild(icon);
				icon.x = rewardTxt.x + rewardTxt.textWidth + 7;
				icon.y = rewardTxt.y + (rewardTxt.height - icon.height) / 2;
				countTxt.x = icon.x + icon.width +3;
			} );			
			
			if (App.data.storage[_ind] == 2) 
			{
				countTxt.textColor = 0xffdb65;
				countTxt.borderColor = 0x775002;
			}
			
			countTxt.height = countTxt.textHeight;
			bonusCont.addChild(countTxt);			
			countTxt.y = rewardTxt.y + (rewardTxt.height - countTxt.height) / 2;;		
			
			if (App.data.storage[_ind].preview == "honey")
			{
				settings = {
					color:0xffdb65,
					borderColor:0x775002				
				};
			}		
			
			bonusCont.x = (progressBacking.width - bonusCont.width) / 2;
			bonusCont.y = progressBacking.height - 8;
			rewardCont.addChild(bonusCont);
		}
		
		rewardCont.x = 608 - rewardCont.width / 2;
		rewardCont.y = (background.height - rewardCont.height) / 2;
		addChild(rewardCont);
	}
	
	private function scaleCorrection(ind:int):Number 
	{
		switch (ind) 
		{
			case Stock.FANTASY:
			return 0.5					
			break;
			case Stock.COINS:
			return 0.5				
			break;
			case Stock.FANT:
			return 0.35					
			break;
			default:
			return 0.4
		}
	}
	
	private function getBonus():String 
	{
		var indMat:int;
		
		for (var _ind:* in mission.bonus) {
			indMat = _ind;
			break;
		}
		
		var bonus:int = mission.bonus[_ind];
		
		return String(bonus);
	}
	
	private function getProgressTxt():String 
	{
		var needItems:int = mission.need;
		var haveItems:int;
		if (App.user.ach[id])
			haveItems = getHaveItems();
		else 
			haveItems = 0;
		
		if (haveItems > needItems) haveItems = needItems;
		var rez:String = String(haveItems) + "/" + String(needItems)
		
		return rez;
	}
	
	private function getHaveItems():int
	{
		if (achive.missions[numMission].event == 'levelup') 
		{
			return App.user.level;
		}
		
		var num:int = 1;
		
		for (var ind:* in App.user.ach[id]) 
		{
			if (num == numMission) 
			{
				return App.user.ach[id][ind]
			}
			num ++;
		}
		return 0;
	}
	
	private function getProgress():Number 
	{
		var needItems:int = mission.need;
		var haveItems:int;
		if (App.user.ach[id])
			haveItems = App.user.ach[id][numMission];
		else 
			haveItems = 0;
		
		var rez:Number =  haveItems / needItems;
		if (rez > 1) rez = 1;
		
		return rez;
	}	
	
	private function onTake(e:MouseEvent):void 
	{
		takeBttn.removeEventListener(MouseEvent.CLICK, onTake);
		
		for (var i:int = 0; i < AchivementMsgWindow.showed.length; i++ ) 
		{
			if (AchivementMsgWindow.showed[i] == id) AchivementMsgWindow.showed.splice(i,1);
		}
		
		var indMissiont:int;
		var count:int = 1;
		
		for (var cnt:* in App.user.ach[id]) 
		{
			if (numMission == count) 
			{
				indMissiont = cnt;
				break;
			}
			
			count++;
		}
		
		sendPost();
		stopGlowing();
		
		Post.send({
			ctr:'ach',
			act:'take',
			uID:App.user.id,
			qID:id,
			mID:indMissiont
		}, onTakeBonus);
	}
	
	private function onTakeBonus(error:int, data:Object, params:Object):void 
	{
		if (error) 
		{
			Errors.show(error, data);
			return;
		}
		
		if (data.bonus) 
		{
			for (var bns:* in data.bonus) 
			{
				App.user.stock.add(bns, data.bonus[bns]);				
				var pnt:Point = Window.localToGlobal(takeBttn)
				var pntThis:Point = new Point(pnt.x, pnt.y + 10);
				Hints.plus(bns, data.bonus[bns], pntThis, false, window);				
				flyMaterial();
			}
		}
		
		//Делаем push в _6e
		if (App.social == 'FB')
		{
			ExternalApi.og('get','achievement');
		}
		
		App.user.ach[id][numMission] = App.time;
		
		window.changeCurrent(id);
		window.setDoneMissions();
		
		App.ui.bottomPanel.updateAchiveCounter();
		if (takeBttn !=null) 
		{
			takeBttn.addEventListener(MouseEvent.CLICK, onTake);
		}		
	}
	
	public function sendPost():void
	{
		WallPost.makePost(WallPost.ACHIVE, {title:achive.title});		
	}
	
	private function flyMaterial():void
	{
		for (var _ind:* in mission.bonus) 
		{
			break;
		}
		
		var item:BonusItem = new BonusItem(_ind, 0);
		
		var point:Point = Window.localToGlobal(takeBttn);
		item.cashMove(point, App.self.windowContainer);
	}
	
	public function getDoneMissions():int
	{
		var sts:int = openStars;		
		return sts;
	}
	
	public function glowing():void 
	{
		customGlowing(this, glowing);	
	}	
	
	private function customGlowing(target:*, callback:Function = null):void 
	{
		TweenMax.to(target, 1, { glowFilter: { color:0xFFFF00, alpha:0.8, strength: 7, blurX:12, blurY:12 }, onComplete:function():void {
			TweenMax.to(target, 0.8, { glowFilter: { color:0xFFFF00, alpha:0.6, strength: 7, blurX:6, blurY:6 }, onComplete:function():void {
				if (callback != null && canGlowing) 
				{
					callback();
				}else if (!canGlowing)
				{
					TweenMax.to(target, 0.8, { glowFilter: { color:0xFFFF00, alpha:0, strength: 7, blurX:1, blurY:1 } });
				}
			}});	
		}});
	}
	
	private function stopGlowing():void
	{
		canGlowing = false;
		window.settings.find = 0;
	}
	
	public function dispose():void 
	{
		clearBody();		
		window = null;
		mission = null;
		achive = null;
	}
}