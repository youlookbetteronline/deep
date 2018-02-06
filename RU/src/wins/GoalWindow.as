package wins 
{
	import buttons.UpgradeButton;
	import com.greensock.easing.Strong;
	import com.greensock.TweenLite;
	import core.IsoConvert;
	import core.Load;
	import effects.Particles;
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	/**
	 * ...
	 * @author ...
	 */
	public class GoalWindow extends Window
	{
		private var captionText:String;
		public var preloader:Preloader = new Preloader();
		
		public function GoalWindow(settings:Object = null) 
		{
			
			if (settings == null) {
				settings = new Object();
			}
			settings['width'] = 500;
			settings['height'] = 280;
			settings.background = 'paperBacking'
			settings.animationShowSpeed = 0.5;
			settings.hasExit = false;
			settings.hasPaginator  = false;
			settings.faderAsClose = false;
			settings.faderClickable = false;
			settings.escExit = false;
			super(settings);
		}
		
		public var backGradient:Shape;
		override public function drawFader():void {
		super.drawFader();
		
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(App.self.stage.stageWidth, App.self.stage.stageHeight, 1.5, 0, 0);
			backGradient = new Shape();
			backGradient.graphics.beginGradientFill(GradientType.LINEAR, [0x8cf6ff , 0x255f9a], [1, 1], [0, 255], matrix);
			backGradient.graphics.drawRect(0, 0, App.self.stage.stageWidth, App.self.stage.stageHeight);
			backGradient.graphics.endFill();
			addChildAt(backGradient, 0);
			//backGradient.filters = [new GlowFilter(0x4c4725, 1, 4, 4, 3, 1)];
			backGradient.alpha = 0;
		}
		
		public var goalIcon:Bitmap;
		public var bttnMainHome:UpgradeButton;
		public var underBg:Bitmap;
		override public function drawBackground():void {
			
			var background:Bitmap = backing2(settings.width, settings.height , 50, 'itemBackingPaperBigDrec', 'itemBackingPaperBig');
			layer.addChild(background);	
			
			switch (settings.quest.character) 
			{
				/*case 3:
					goalIcon = new Bitmap(Window.textures.goalsCharGirl, "auto", true);
				break;
				case 4:
					goalIcon = new Bitmap(Window.textures.goalsCharBoy, "auto", true);
				break;
				case 6:
					goalIcon = new Bitmap(Window.textures.goalsCharSpirit, "auto", true);
				break;
				case 2:
					goalIcon = new Bitmap(Window.textures.goalsCharProf, "auto", true);
				break;*/
				case 1:
					goalIcon = new Bitmap(Window.textures.goalsCharFirstPers, "auto", true);
				break;
				/*case 8:
					goalIcon = new Bitmap(Window.textures.goalsCharZikimus, "auto", true);
				break;	
				case 10:
					goalIcon = new Bitmap(Window.textures.goalsCharShaman, "auto", true);
				break;
				case 11:
					goalIcon = new Bitmap(Window.textures.goalsCharZikimund, "auto", true);
				break;
				case 12:
					goalIcon = new Bitmap(Window.textures.goalsCharIngrid, "auto", true);
				break;	
				case 13:
					goalIcon = new Bitmap(Window.textures.goalsCharEgg, "auto", true);
				break;	*/
				default:
					goalIcon = new Bitmap(Window.textures.goalsCharSpirit, "auto", true);
				break
			}
			goalIcon.visible = false;
			goalIcon.x = (App.self.stage.stageWidth - settings.width) / 2 - goalIcon.width;
			goalIcon.y -= (goalIcon.height - settings.height) / 2;
			addChild(effContainer);
			addChild(goalIcon);
		
			
		}
		public var finishX:int; 
		public var finishY:int;
		public var finishGoalX:int;
		public var finishGoalY:int;
		public var mask2:Shape = new Shape();
		override public function startOpenAnimation():void {
		
			/*drawFader();
			drawHeader();
			drawBottom();
			
			drawBody();
			
			drawBackground();*/
			/*background.alpha = 0;
			bodyContainer.visible = false;
			headerContainer.visible = false;
			headerContainerSplit.visible = false;*/
			
			
			layer.x = -layer.width;// (App.self.stage.stageWidth - settings.width * .3) / 2;
			layer.y = (App.self.stage.stageHeight - settings.height*.3) / 2;
			goalIcon.x = (App.self.stage.stageWidth - settings.width*.3) / 2;
			goalIcon.y = (App.self.stage.stageHeight - settings.height*.3) / 2;
			
			
			finishX = (App.self.stage.stageWidth - settings.width+200) / 2;
			finishY = (App.self.stage.stageHeight - settings.height) / 2;
			finishGoalX = (App.self.stage.stageWidth - settings.width - 240) / 2;
			finishGoalY = (App.self.stage.stageHeight - goalIcon.height) / 2;
			
			
			mask2.graphics.beginFill(0x000000, 1);
			mask2.graphics.drawRect( finishGoalX + goalIcon.width/2,0,App.self.stage.stageWidth , App.self.stage.stageHeight);
			mask2.graphics.endFill();
			
			addChild(mask2);
			layer.mask = mask2;
			layer.visible = true;
			goalIcon.visible = false;
			goalIcon.scaleX = goalIcon.scaleY = 0.3;			
			layer.scaleX = layer.scaleY = 0.3;
			
		//	finishX = 250;
		//	finishY = 250;
			if (settings.quest.type == 3) 
			{
				finishBackGradient();
			}else 
			{
				TweenLite.to(backGradient, 1, { ease:Strong.easeOut, alpha:1, onComplete:finishBackGradient } );
		
			}
			// 1 second +
			
			// 1 second +
		
			//finishOpenLayer();
			//finishOpenAnimation()
			// 3 second +
		}
		public var timer:uint = 0;
		private function finishBackGradient():void 
		{
			/*timer = setTimeout(function():void {*/
				goalIcon.visible = true;
			TweenLite.to(goalIcon, 1, { x:finishGoalX+240, y:finishGoalY,ease:Strong.easeOut, alpha:1,scaleX:1,scaleY:1,onComplete:continueGoalIcon} );
			/*},500);*/
		}
		private function continueGoalIcon():void 
		{
			/*timer = setTimeout(function():void {*/
				goalIcon.visible = true;
			TweenLite.to(goalIcon, 1, { x:finishGoalX, y:finishGoalY, ease:Strong.easeOut, alpha:1, scaleX:1, scaleY:1, onComplete:finishGoalIcon } );
			TweenLite.to(layer, 1, { x:finishX+20, y:finishY, scaleX:1, scaleY:1, ease:Strong.easeOut, onComplete:finishOpenLayer } );
		
			/*},500);*/
		}
		private function finishGoalIcon():void 
		{
				/*timer = setTimeout(function():void {*/
			/*},200);*/
		}
		private var effContainer:LayerX = new LayerX()
		private function finishOpenLayer():void 
		{
			if (settings.quest.type == 3) 
			{
				finishOpenAnimation();
			}else 
			{
			timer = setTimeout(function():void {
			TweenLite.to(backGradient, 2/*,settings.animationShowSpeed*/, { ease:Strong.easeOut, alpha:0, onComplete:finishOpenAnimation } );
			},1500);	
			}
			if (settings.quest.type == 4) 
			{
				
				
				effContainer.x = layer.x;
				effContainer.y = layer.y+100;
				intervalEff = setInterval(function():void {
				var particle:Particles = new Particles();
				particle.init(effContainer, new Point(coordsEff[countEff].x, coordsEff[countEff].y));
				countEff++;
				if (countEff == 12)
				clearInterval(intervalEff);
				
			},2);
			
			setTimeout(function():void {
				addMore()
			},1000)
			}
					
		}
		
		private function addMore():void 
		{
			countEff2 = 0;
			intervalEff2 = setInterval(function():void {
				var particle:Particles = new Particles();
				particle.init(effContainer, new Point(coordsEff[countEff2].x, coordsEff[countEff2].y));
				countEff2++;
				if (countEff2 == 12)
				clearInterval(intervalEff2);
				
			},2);
		}
		
		private var countEff:int = 0;
		private var countEff2:int = 0;
		private var intervalEff:int;
		private var intervalEff2:int;
		private var coordsEff:Object = { 
			/*0:{x:40, y:-100},
			1:{x:100, y:-110},
			2:{x:160, y:-110},
			3:{x:220, y:-120},
			4:{x:380, y:-100},
			5:{x:260, y:-120},
			6:{x:190, y:-110},
			7:{x:60, y:-100},
			8:{x:120, y:-110},
			9:{x:200, y:-120},
			10:{x:250, y:-120},
			11:{x:360, y:-100},
			12:{x:220, y:-120}*/
			0:{x:40-100, y:-100},
			1:{x:100-100, y:-110},
			2:{x:160, y:-110},
			3:{x:220-100, y:-120},
			4:{x:380+100, y:-100},
			5:{x:260, y:-120},
			6:{x:190, y:-110},
			7:{x:60, y:-100},
			8:{x:120-100, y:-110},
			9:{x:200, y:-120},
			10:{x:250+100, y:-120},
			11:{x:360+100, y:-100},
			12:{x:220, y:-120}
		};
		
		private var descLabel:TextField;
		private var bitmap:Bitmap;
		private var upperPart:Bitmap;
		private var titleTxt:TextField;
		public var bonusList:CollectionBonusList;
		
		/*private function drawBonusInfo():void{
			
			
			bonusList = new RewardList(settings.quest.bonus['materials'],false,0,'',1,48);
			bodyContainer.addChild(bonusList);
			bonusList.x += 20;
			bonusList.y = upperPart.y+6;
		}*/
		
		override protected function onRefreshPosition(e:Event = null):void
		{ 	
			super.onRefreshPosition();
			goalIcon.x = (App.self.stage.stageWidth - settings.width - 240) / 2;
			goalIcon.y = (App.self.stage.stageHeight - goalIcon.height) / 2;
			
			
			
			layer.x = (App.self.stage.stageWidth - settings.width+200) / 2 +20;
			layer.y = (App.self.stage.stageHeight - settings.height) / 2;
			//goalIcon.visible = false;
			mask2.x = goalIcon.x + (goalIcon.width / 2);
			mask2.height = App.self.stage.stageHeight;
			mask2.visible = false;
			layer.mask = null;
			/*var stageWidth:int = App.self.stage.stageWidth;
			var stageHeight:int = App.self.stage.stageHeight;
			
			layer.x = (stageWidth - settings.width) / 2;
			layer.y = (stageHeight - settings.height) / 2;
			
			if(settings.hasTitle){
				layer.y += headerContainer.height / 4;
			}
			
			if(fader){
				fader.width = stageWidth;
				fader.height = stageHeight;
			}*/
		}
		
		override public function drawBody():void
		{
			var globalOffsetX:int = 20;
			var titleContainer:Sprite = new Sprite();
			var title:TextField = Window.drawText(settings.quest.title, {
				color				:0xffffff,
				borderColor			:0xb98659,
				borderSize			:4,
				fontSize			:42,
				autoSize			:"center"
			});
			titleContainer.addChild(title);
			bodyContainer.addChild(titleContainer);
			var titleGlow:GlowFilter = new GlowFilter(0x855729, 1, 6, 6, 6, 1, false, false);
			titleContainer.filters = [titleGlow];
			
			if (settings.quest.type == 2 || settings.quest.type == 4) 
			{
			title.x = (settings.width - title.width) / 2;
			title.y = -25;	
			}
			else 
			{
			title.x = (settings.width - title.width) / 2;
			title.y = 20;	
			}
			
			
			//drawMirrowObjs('diamondsTop', title.x +4, title.x + title.width -4, title.y+4 , true, true);
			switch (settings.quest.type) 
			{
				case 2:
				captionText = Locale.__e('flash:1424770409895');	
				break;
				case 3:
				captionText = Locale.__e('flash:1424770461606');	
				break;
				case 4:
				captionText = Locale.__e('flash:1404394519330');	
				break;
				
				default:
			}
			
			bttnMainHome = new UpgradeButton(UpgradeButton.TYPE_ON,{
				caption:captionText,
			//	width:236,
				height:55,
				textAlign:'center',
				autoSize:'center',
				worldWrap:true,
				widthButton:195
				/*
				fontBorderColor:0x6f2700,
				
				fontSize:42,
				//iconScale:0.95,
				radius:30,
				textAlign:'center',
				autoSize:'center',
				widthButton:195*/
			});
			//bttnMainHome.textLabel.x = (bttnMainHome.width - bttnMainHome.textLabel.textWidth) / 2 - 4;
		//	bttnMainHome.textLabel.x = (bttnMainHome.width - bttnMainHome.textLabel.width)/2;
		//	mainPanelFriend.addChild(bttnMainHome);
			
			bottomContainer.addChild(bttnMainHome);
			bttnMainHome.x = (settings.width - bttnMainHome.width)/2 ;
			bttnMainHome.y = (settings.height - 56);
			bttnMainHome.addEventListener(MouseEvent.CLICK, bttnEvent)
			var descSize:int = 38;
			do{
				descLabel = Window.drawText(settings.quest.description, {//quest.description.replace(/\r/g,""), {
					color:0x624512, 
					border:false,
					fontSize:descSize,
					autoSize:'center',
					multiline:true,
					textAlign:"center"
				});
					
				descLabel.wordWrap = true;
				descLabel.width = 350;
				//descLabel.border = true;
				descLabel.height = descLabel.textHeight + 40;
					
				descSize -= 1;	
			}
			while (descLabel.height > (settings.height - title.height - bttnMainHome.height))
			bodyContainer.addChild(descLabel);
			
			
			
		
			switch (settings.quest.type) 
			{
				case 2:
				underBg = Window.backing2(144, 124, 25, 'storageBackingTop', 'storageBackingBot');
				//underBg.alpha = 0.7;
				bodyContainer.addChild(underBg);
				bodyContainer.addChild(preloader);
				
				descLabel.y =(settings.height + title.height + title.y +36 - 76 - descLabel.height - underBg.height -10)/2 ;
				descLabel.x = (settings.width - descLabel.width) / 2 +globalOffsetX;
				underBg.x = (settings.width - underBg.width) / 2;
				underBg.y = descLabel.y +descLabel.textHeight +globalOffsetX;
				preloader.x = underBg.x +(underBg.width) / 2;
				preloader.y = underBg.y +(underBg.height) / 2;
				
				Load.loading(Config.getIcon(App.data.storage[settings.quest.target].type, App.data.storage[settings.quest.target].preview), onPreviewComplete);
				break;
				case 3:
				descLabel.y =(settings.height + title.height + title.y +36 - 76 - descLabel.height)/2 ;
				descLabel.x = (settings.width - descLabel.width) / 2 +globalOffsetX;
				break;
			case 4:
				upperPart = Window.backingShort(settings.width - 60, 'yellowRibbon');
				upperPart.scaleY = 1.3;
				upperPart.smoothing = true;
				descLabel.y =(settings.height + title.height + title.y +36 - 76 - descLabel.height - upperPart.height -10)/2 ;
				descLabel.x = (settings.width - descLabel.width) / 2 +globalOffsetX;
				upperPart.x = (settings.width - upperPart.width) / 2 +globalOffsetX/2;
				upperPart.y = descLabel.y +descLabel.textHeight +40;
				//bodyContainer.addChild(upperPart);
				var upperPartText:TextField = Window.drawText(Locale.__e("flash:1382952380000"), {
				color:0xfdfeec, 
				borderColor:0x5f481c,
				fontSize:36,
				textAlign:"center"
				});
				//bodyContainer.addChild(upperPartText);
				upperPartText.width = upperPartText.textWidth + 20;
				upperPartText.x = upperPart.x + (upperPart.width - upperPartText.width) / 2;
				upperPartText.y = upperPart.y - upperPartText.textHeight/2;
				
				bonusList = new CollectionBonusList(settings.quest.bonus['materials']);
				bodyContainer.addChild(bonusList);
				bonusList.x = (settings.width - bonusList.width) / 2 +globalOffsetX/2;
				bonusList.y = (descLabel.y + descLabel.height + 15) ;
				//drawBonusInfo();
				break;
				
				default:
			}
			
			
			}
		
		public function onPreviewComplete(data:Object):void
		{
			if (preloader) 
			{
			bodyContainer.removeChild(preloader);
			preloader = null;
			}
		
			bitmap = new Bitmap();
			var itemContainer:LayerX = new LayerX;
			itemContainer.addChild(bitmap);
			bodyContainer.addChild(itemContainer);
			bitmap.bitmapData = data.bitmapData;
			var scale:Number = 95 / data.height;
			bitmap.width 	*= scale;
			bitmap.height 	*= scale;
			bitmap.smoothing = true;
			itemContainer.tip = function():Object { 
					return {
						title:App.data.storage[settings.quest.target].title
						
					};
			}
			titleTxt = Window.drawText(Locale.__e('flash:1426177901851')+" "+App.data.storage[settings.quest.target].title, {
				fontSize:28,
				color:0xffffff,
				textAlign:"center",
				borderColor:0x603508,
				width:200
			});
			//levelTxt.width = 120;
			itemContainer.addChild(titleTxt);
			
			
			
			itemContainer.x = underBg.x +(underBg.width - bitmap.width) / 2;
			itemContainer.y = underBg.y + (underBg.height - bitmap.height) / 2;
			titleTxt.x = bitmap.x + (bitmap.width - titleTxt.width) / 2 ;
			titleTxt.y -= 20;
		}
		
		private function bttnEvent(e:MouseEvent):void 
		{
			switch (settings.quest.type) 
			{
				case 2:
				close();
				App.user.quests.readEvent(settings.quest.ID, function():void { }) ;
				break
				case 3:
				close();
				App.user.quests.readEvent(settings.quest.ID, function():void { }) ;
				break
				case 4:
				var position:Object = App.map.heroPosition;
				var position2:* = IsoConvert.isoToScreen(position.x, position.z,true);
				Treasures.bonus(Treasures.convert(settings.quest.bonus['materials']), new Point(position2.x, position2.y));
				close();
				App.user.quests.readEvent(settings.quest.ID, function():void { }) ;
				break
			}
		}
		
	}

}