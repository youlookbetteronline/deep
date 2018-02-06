package wins 
{
	import buttons.Button;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import units.Hippodrome;
	import utils.TopHelper;
	/**
	 * ...
	 * @author ...
	 */
	public class HippodromeResultWindow extends Window
	{
		private var rewardList:BonusList;
		private var bttn:Button;
		public function HippodromeResultWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			settings['hasPaginator'] = false;
			settings['background'] = 'paperScroll';
			settings['width'] = 440;
			settings['height'] = (settings.mode==Hippodrome.LOSE)?410:475;
			settings['fontColor'] = 0xffffff;
			settings['fontBorderColor'] = 0x492103;
			settings['borderColor'] = 0x492103;
			settings['shadowColor'] = 0x492103;
			settings['fontSize'] = 56;
			settings['fontBorderSize'] = 3;
			settings['shadowSize'] = 0;
			settings['hasTitle'] = (settings.mode==Hippodrome.WIN)?true:false;
			settings['hasExit'] = (settings.mode==Hippodrome.LOSE)?true:false;
			settings['title'] = Locale.__e('flash:1393579648825');
			super(settings);
			
		}
		
		override public function drawBody():void{
			switch(settings.mode){
				case Hippodrome.WIN:	drawWin(); 	break;
				case Hippodrome.LOSE:	drawLose(); break;
				case Hippodrome.DRAW:	drawDraw(); break;
			}
			drawBttn();
		}
		
		public function drawWin():void{
			drawRibbon();
			var cup:Bitmap = new Bitmap(Window.textures.cupGlow);
			cup.x = (settings.width - cup.width) / 2 - 7;
			cup.y = -10;
			bodyContainer.addChild(cup);
			
			var descWin:TextField = Window.drawText(Locale.__e('flash:1444123579159'), 
			{
				fontSize:56,
				color:0xffdf34,
				borderColor:0x451c00,
				textAlign:"center"
			});
			descWin.width = descWin.textWidth + 5;
			descWin.x = (settings.width - descWin.width) / 2;
			descWin.y = cup.y + cup.height - 80;
			bodyContainer.addChild(descWin);
			
			rewardList = new BonusList(settings.reward, false, {
				hasTitle:true,
				width: 315,
				fontSize: 38,
				titleY: 7,
				height: 60,
				titleColor:0xffffff,
				titleBorderColor:0x451c00,
				bonusTextColor:0xffffff,
				bonusBorderColor:0x451c00,
				glow:0,
				textSize: 38,
				textDX: 45,
				size: 70,
				itemDX: 28,
				titleDX: 20
			} );
			
			rewardList.x = (settings.width - rewardList.width) / 2 - 40;
			rewardList.y = descWin.y + descWin.textHeight + 20;
			bodyContainer.addChild(rewardList);
		}
		
		public function drawLose():void{
			exit.y -= 22;
			
			var descLose:TextField = Window.drawText(Locale.__e('flash:1494419997861'), 
			{
				fontSize:48,
				color:0xffdf34,
				borderColor:0x451c00,
				textAlign:"center"
			});
			descLose.width = descLose.textWidth + 5;
			descLose.x = (settings.width - descLose.width) / 2;
			descLose.y = 55;
			bodyContainer.addChild(descLose);
			
			var horsePicture:Bitmap = new Bitmap(Window.textures.horsePicture);
			horsePicture.x = (settings.width - horsePicture.width) / 2;
			horsePicture.y = settings.height - horsePicture.height - 65;
			bodyContainer.addChild(horsePicture);
			
			
		}
		
		public function drawDraw():void{
			var horsePicture:Bitmap = new Bitmap(Window.textures.horsePicture);
			horsePicture.x = (settings.width - horsePicture.width) / 2;
			horsePicture.y = settings.height - horsePicture.height - 235;
			bodyContainer.addChild(horsePicture);
			
			var descDraw:TextField = Window.drawText(Locale.__e('flash:1494422919217'), 
			{
				fontSize:56,
				color:0xffdf34,
				borderColor:0x451c00,
				textAlign:"center"
			});
			descDraw.width = descDraw.textWidth + 5;
			descDraw.x = (settings.width - descDraw.width) / 2;
			descDraw.y = horsePicture.y + horsePicture.height;
			bodyContainer.addChild(descDraw);
			
			rewardList = new BonusList(settings.reward, false, {
				hasTitle:true,
				width: 315,
				fontSize: 38,
				titleY: 7,
				height: 60,
				titleColor:0xffffff,
				titleBorderColor:0x451c00,
				bonusTextColor:0xffffff,
				bonusBorderColor:0x451c00,
				glow:0,
				textSize: 38,
				textDX: 45,
				size: 70,
				itemDX: 28,
				titleDX: 20
			} );
			
			rewardList.x = (settings.width - rewardList.width) / 2 - 40;
			rewardList.y = descDraw.y + descDraw.textHeight + 20;
			bodyContainer.addChild(rewardList);
		}
		
		override protected function drawRibbon():void 
		{
			var titleBackingBmap:Bitmap = backingShort(350, 'actionRibbonBg', true);
			titleBackingBmap.x = (settings.width -titleBackingBmap.width) / 2;
			titleBackingBmap.y = -35;
			bodyContainer.addChild(titleBackingBmap);
			titleLabel.x = titleBackingBmap.x + (titleBackingBmap.width - titleLabel.width) / 2;
			titleLabel.y = titleBackingBmap.y + 16;
			
			bodyContainer.addChild(titleLabel);
		}
		
		private function drawBttn():void
		{
			var bttnText:String;
			switch(settings.mode){
				case Hippodrome.WIN:	bttnText = Locale.__e('flash:1382952379737'); 	break;
				case Hippodrome.DRAW:	bttnText = Locale.__e('flash:1382952379737'); 	break;
				case Hippodrome.LOSE:	bttnText = Locale.__e('flash:1494333803790');	break;
			}
			if (settings.mode == Hippodrome.LOSE && settings.teritoryMode == Hippodrome.GUEST)
				bttnText = Locale.__e('flash:1404381496750');
			bttn = new Button( {
				width			:(settings.mode==Hippodrome.WIN)?165:220,
				height			:53,
				radius			:19,
				fontSize		:36,
				textAlign		:'center',
				caption			:bttnText,
				fontBorderColor	:0x762e00,	
				bgColor			:[0xfed131,0xf8ab1a],
				bevelColor		:[0xf7fe9a, 0xf8ab1a]
			});
			bttn.x = (settings.width - bttn.width) / 2;
			bttn.y = settings.height - bttn.height;
			bodyContainer.addChild(bttn);
			switch(settings.mode){
				case Hippodrome.WIN:
				case Hippodrome.DRAW:	
					bttn.addEventListener(MouseEvent.CLICK, onTake);	
					break;
				case Hippodrome.LOSE:
					bttn.addEventListener(MouseEvent.CLICK, onUpgrade);	
					break;
			}
		}
		
		private function onTake(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED)
				return;
			close();
		}
		
		private function onUpgrade(e:MouseEvent):void
		{
			if (e.currentTarget.mode == Button.DISABLED)
				return;
			Window.closeAll();
			
			if(settings.teritoryMode == Hippodrome.HOME)
				settings.target.onOpenUpgWindow();
		}
		
		override public function close(e:MouseEvent = null):void 
		{
			switch(settings.mode){
				case Hippodrome.WIN:
					App.user.stock.addAll(settings.reward);	
					
					var topID:int = TopHelper.getTopID(settings.target.sid);
					var istanceTop:int = TopHelper.getTopInstance(TopHelper.getTopID(settings.target.sid));
					if (!App.user.data.user.top.hasOwnProperty(topID))
						App.user.data.user.top[topID] = {};
						
					if (!App.user.data.user.top[topID][istanceTop])
					{
						App.user.data.user.top[topID][istanceTop] = {'count':1};
					}else{
						App.user.data.user.top[topID][istanceTop]['count']++;
					}
					if (settings.hasOwnProperty('window'))
						settings['window'].winsTextCount.text = App.user.data.user.top[topID][istanceTop]['count'];
					
					break;
				case Hippodrome.DRAW:	
					App.user.stock.addAll(settings.reward);	
					break;
			}
			super.close(e);
		}
		
		
	}

}