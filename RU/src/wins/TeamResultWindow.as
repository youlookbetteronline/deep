package wins 
{
	import buttons.Button;
	import core.Load;
	import core.Numbers;
	import core.Post;
	import effects.Effect;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	
	public class TeamResultWindow extends Window 
	{
		private var teamImage:Bitmap;
		private var teamOneImage:Bitmap;
		private var teamTwoImage:Bitmap;
		private var wictoryText:TextField;
		private var contestOverText:TextField;
		private var descriptionText:TextField;
		private var teamTwoReward:RewardListB;
		private var teamOneReward:RewardListB;
		private var glowing:GlowFilter;
		private var contestOverText1:TextField;
		private var wictoryText1:TextField;
		protected var takeBttn:Button;
		
		public function TeamResultWindow(settings:Object=null) 
		{
			settings['hasPaginator'] = false;
			settings['hasTitle'] = false;
			settings['width'] = 465;					
			settings['height'] = 480;
			settings['team'] = settings.team || 2;
			super(settings);			
		}
		
		override public function drawBody():void 
		{
			teamImage = new Bitmap();
			bodyContainer.addChild(teamImage);
			teamOneImage = new Bitmap();
			bodyContainer.addChild(teamOneImage);
			teamTwoImage = new Bitmap();
			bodyContainer.addChild(teamTwoImage);
			
			switch(settings.team) {
				case 1:
					Load.loading(Config.getImage('thappy', 'team_1'), function(data:Bitmap):void {
						teamImage.bitmapData = data.bitmapData;
						teamImage.x = settings.width / 2 -teamImage.width * 0.5;
						teamImage.y = -50;
					});
					break;
				case 2:
					Load.loading(Config.getImage('thappy', 'team_2'), function(data:Bitmap):void {
						teamImage.bitmapData = data.bitmapData;
						teamImage.x = settings.width / 2  -teamImage.width * 0.5;
						teamImage.y = -50;
					});
					break;
			}
			
			switch(settings.win)
			{
				case true:
					/*Load.loading(Config.getImage('thappy', 'team_1'), function(data:Bitmap):void {
						teamOneImage.bitmapData = data.bitmapData;
						teamOneImage.x = settings.width / 2 -teamOneImage.width * 0.5;
						teamOneImage.y = -50; //-teamOneImage.height;
					});
					*/
					wictoryText1 = drawText(Locale.__e('flash:1444123579159'),{//Победа!
						textAlign			: 'center',
						fontSize			: 52,
						color				: 0x7b3801,
						borderColor 		: 0x7b3801,
						autoSize			: 'center'	
					});	
					wictoryText1.x = (settings.width - wictoryText1.width) / 2 - 2;
					wictoryText1.y = 180 + 3;
					
					bodyContainer.addChild(wictoryText1);
					
					wictoryText = drawText(Locale.__e('flash:1444123579159'),{//Победа!
						textAlign			: 'center',
						fontSize			: 52,
						color				: 0xfeff80,
						borderColor 		: 0xbc6c15,
						autoSize			: 'center',
						filters				: [new DropShadowFilter(3, 90, 0x6f421b, 1, 0, 0)]
					});	
					wictoryText.x = (settings.width - wictoryText.width) / 2;
					wictoryText.y = 180;
				
					drawMirrowObjs('diamondsTop', wictoryText.x, wictoryText.x + wictoryText.width, wictoryText.y + 10, true, true);
				
					bodyContainer.addChild(wictoryText);
					
					descriptionText = drawText(Locale.__e('flash:1444123825840'), {//Поздравляем! Твоя команда победила! Вот награда за участие:
						//autoSize			: 'center'
						width				: settings.width - 130,
						color				: 0xfcffff,
						borderColor 		: 0x664524,
						fontSize			: 24,	
						textAlign			: 'center',
						wrap				:true
						
					});
					descriptionText.x = (settings.width - descriptionText.width) / 2;
					descriptionText.y = wictoryText.y + 70;
					bodyContainer.addChild(descriptionText);
					
					teamOneReward = new RewardListB( settings.bonus, true, 300, {
						itemWidth:70,
						itemHeight:70,
						disableCount:true,
						scale:0.7,
						sort:true
					}, 'flash:1382952380000');
					teamOneReward.x = settings.width / 2 - teamOneReward.width * 0.5;
					teamOneReward.y = settings.height - 195;
					bodyContainer.addChild(teamOneReward);
					teamOneReward.title.y += 20;
					
					//Награда:
					break;
				case false:
				/*	Load.loading(Config.getImage('thappy', 'team_2'), function(data:Bitmap):void {
						teamTwoImage.bitmapData = data.bitmapData;
						teamTwoImage.x = settings.width / 2  -teamTwoImage.width * 0.5;
						teamTwoImage.y = -50; //-teamTwoImage.height * 0.65;
					});*/
					
					contestOverText1 = drawText(Locale.__e('flash:1444118189968'),{//Конкурс окончен
						textAlign			: 'center',
						fontSize			: 52,
						color				: 0x843e0a,//тень
						borderColor 		: 0x843e0a,
						autoSize			: 'center'
					});
					
					contestOverText1.x = (settings.width - contestOverText1.width) / 2 - 2;
					contestOverText1.y = 180 + 3;
					//glowing = new GlowFilter(0x392f25, 1, 1, 1, 4, 1, false);
					//contestOverText.filters = [glowing];
					bodyContainer.addChild(contestOverText1);					
					
					contestOverText = drawText(Locale.__e('flash:1444118189968'),{//Конкурс окончен
						textAlign			: 'center',
						fontSize			: 52,
						color				: 0xfefcff,
						borderColor 		: 0xbd7810,
						autoSize			: 'center'
					});
					
					contestOverText.x = (settings.width - contestOverText.width) / 2;
					contestOverText.y = 180;
					//glowing = new GlowFilter(0x392f25, 1, 1, 1, 4, 1, false);
					//contestOverText.filters = [glowing];
					bodyContainer.addChild(contestOverText);
					drawMirrowObjs('diamondsTop', contestOverText.x, contestOverText.x + contestOverText.width, contestOverText.y + 10, true, true);
					
					descriptionText = drawText(Locale.__e('flash:1444118278815'), { //flash:1441379850927 //К сожалению, твоя команда не победила, но тоже заработала приз!
						width				: settings.width - 130,
						textAlign			: 'center',
						color				: 0xf8ffff,
						borderColor 		: 0x825325,
						fontSize			: 24,	
						wrap				:true
					});
					descriptionText.x = (settings.width - descriptionText.width) / 2;
					descriptionText.y = contestOverText.y + 65;
					bodyContainer.addChild(descriptionText);
					
					teamTwoReward = new RewardListB( settings.bonus, true, 300, {
						itemWidth:70,
						itemHeight:70,
						disableCount:true,
						scale:0.7,
						sort:true
					}, 'flash:1382952380000');
					teamTwoReward.x = settings.width / 2 - teamTwoReward.width * 0.5;
					teamTwoReward.y = settings.height - 195;
					bodyContainer.addChild(teamTwoReward);
					teamTwoReward.title.y += 20;						
					//Награда:
					break;
			}
			
			takeBttn = new Button( {
				winth:		160,
				height:		55,
				caption:	Locale.__e('flash:1382952379737')
			});
			takeBttn.x = settings.width * 0.5 - takeBttn.width * 0.5;
			takeBttn.y = settings.height - 40;
			bodyContainer.addChild(takeBttn);			
			
			drawMirrowObjs('storageWoodenDec', 0, settings.width - 0, settings.height - 70);//низ
			drawMirrowObjs('storageWoodenDec', 0, settings.width - 0, 70, false, false, false, 1, -1);//верх
			
			if (settings['bonus'] && Numbers.countProps(settings.bonus) > 0) {
				takeBttn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
					if (takeBttn.mode == Button.DISABLED) return;
					takeBttn.state = Button.DISABLED;
					
					exit.visible = false;
					settings.faderClickable = false;
					
					Post.send( {
						ctr:		'Thappy',
						act:		'bonus',
						uID:		App.user.id,
						wID:		App.map.id,
						sID:		settings.target.sid,
						id:			settings.target.id
					}, function(error:int, data:Object, params:Object):void {
						if (error) return;
						
						settings.target.taked = 1;
						
						App.user.stock.addAll(data.bonus);
						Window.closeAll();
						
						for (var sid:* in data.bonus) break;
						Effect.wowEffect(sid);
					});
					
				});
			}
		}
		
		override public function drawExit():void {
			super.drawExit();
			exit.x += 10;
			exit.y -= 9;
			exit.visible = false;
		}		
	}
}