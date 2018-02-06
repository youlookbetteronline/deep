package wins 
{
	import buttons.Button;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public class TeamWindow extends Window 
	{
		
		public var info:Object;
		public var sid:int;
		public var target:*;
		
		private var descLabel:TextField;
		private var teamOneImage:Bitmap;
		private var teamTwoImage:Bitmap;
		private var teamOneLabel:TextField;
		private var teamTwoLabel:TextField;
		private var teamOneBttn:Button;
		private var teamTwoBttn:Button;
		private var teamOneReward:RewardListB;
		private var teamTwoReward:RewardListB;
		private var tropicText:TextField;
		private var ancientText:TextField;
		
		public function TeamWindow(settings:Object=null) 
		{
			
			if (!settings) settings = { };
			
			target = settings.target;
			sid = target.sid;
			info = App.data.storage[sid];
			
			settings['width'] = settings['width'] || 750 - 53;
			settings['height'] = settings['height'] || 600 - 47;
			settings['title'] = info.title || (Locale.__e('flash:1441023082142') + ':');
			settings['hasPaginator'] = false;
			settings['hasButtons'] = false;
			
			super(settings);
			
			// Team 1
			// flash:1441023161705	red
			
			// Team 2
			// flash:1441023194658	blue
			// flash:1441023233686	Выбери к какой команде хочешь присоединиться
		}
		
		override public function drawBody():void {
			var center:int = 245;
			drawMirrowObjs('storageWoodenDec', -5, settings.width+5, 40,false,false,false,1,-1);
			drawMirrowObjs('storageWoodenDec', -5, settings.width +5, settings.height - 115);
			
			drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 5, settings.width / 2 + settings.titleWidth / 2 + 5, -45, true, true);
			
			var rrect:Sprite = new Sprite();
			 rrect.graphics.beginFill(0xedca94);
			 rrect.graphics.drawRoundRect(0,0,480, 60,40);
			 rrect.graphics.endFill();
			 bodyContainer.addChild(rrect);
			rrect.alpha = .6;
			rrect.x = 115;
			rrect.y = -5;
			
			// Команды
			teamOneImage = new Bitmap();
			bodyContainer.addChild(teamOneImage);
			
			teamTwoImage = new Bitmap();
			bodyContainer.addChild(teamTwoImage);
			
			teamOneLabel = drawText(info.teams.team[1].name, {
				width:			250,
				textAlign:		'center',
				fontSize:		42,
				color:			0xfdf98b,
				borderColor:	0x6e2306
			});
			teamOneLabel.x = (settings.width / 4 - teamOneLabel.width / 2);
			teamOneLabel.y = center - teamOneLabel.height * 0.5;
			drawMirrowObjs('titleDecor', 20, teamOneLabel.width + 82, teamOneLabel.y + 5);
			bodyContainer.addChild(teamOneLabel);
			
			teamTwoLabel = drawText(info.teams.team[2].name, {
				width:			250,
				textAlign:		'center',
				fontSize:		42,
				color:			0xd7ff9e,
				borderColor:	0x1a2f72
			});
			teamTwoLabel.x = settings.width/2 + (settings.width / 4 - teamTwoLabel.width / 2);
			teamTwoLabel.y = center - teamTwoLabel.height * 0.5;
			drawMirrowObjs('titleDecor', teamTwoLabel.x - 10, teamTwoLabel.x + teamTwoLabel.width + 13, teamTwoLabel.y + 5);
			bodyContainer.addChild(teamTwoLabel);
			
			
			
			var textWidth:int = settings.width - 80;
			descLabel = drawText(Locale.__e('flash:1442830969796'), {
				width:			textWidth,
				textAlign:		'center',
				//autoSize:		"center",
				fontSize:		26,
				color:			0xfdf6e3,
				borderColor:	0x593513,
				multiline:		true,
				wrap:			true
			});
			descLabel.x = settings.width * 0.5 - descLabel.width * 0.5;
			descLabel.y = descLabel.height * 0.5 - 10;
			bodyContainer.addChild(descLabel);
			
			Load.loading(Config.getImage('thappy', 'team_1'), function(data:Bitmap):void {
				teamOneImage.bitmapData = data.bitmapData;
				teamOneImage.scaleX = teamOneImage.scaleY = (settings.width / 2) / teamOneImage.width;
				teamOneImage.x =  0/*teamOneLabel.x + teamOneLabel.width * 0.5 - teamOneImage.width * 0.5*/;
				teamOneImage.y = 0 + 26/*teamOneLabel.y + teamOneLabel.height * 0.5 - teamOneImage.height * 0.65 -31*/;
			});
			
			Load.loading(Config.getImage('thappy', 'team_2'), function(data:Bitmap):void {
				teamTwoImage.bitmapData = data.bitmapData;
				teamTwoImage.scaleX = teamTwoImage.scaleY = (settings.width / 2) / teamTwoImage.width;
				teamTwoImage.x = settings.width / 2 - 10;
				teamTwoImage.y = 0 + 26/*teamTwoLabel.y + teamTwoLabel.height * 0.5 - teamTwoImage.height * 0.65 -31*/;
			});
			
			
			// Кнопки вступления в команду
			
			
			
			teamOneBttn = new Button( {
				width:			170,
				fontSize:				36,	
				height:			60,
				caption:		Locale.__e('flash:1382952379978')
			});
			teamOneBttn.name = '1';
			teamOneBttn.x = teamOneLabel.x + teamOneLabel.width * 0.5 - teamOneBttn.width * 0.5 + 10;
			teamOneBttn.y = settings.height - 140;
			bodyContainer.addChild(teamOneBttn);
			teamOneBttn.addEventListener(MouseEvent.CLICK, onChooseTeam);
			
			teamTwoBttn = new Button( {
				width:			170,
				fontSize:				36,	
				height:			60,
				caption:		Locale.__e('flash:1382952379978')
			});
			teamTwoBttn.name = '2';
			teamTwoBttn.x = teamTwoLabel.x + teamTwoBttn.width * 0.5 - teamTwoBttn.width * 0.5 +25;
			teamTwoBttn.y = settings.height - 140;
			bodyContainer.addChild(teamTwoBttn);
			teamTwoBttn.addEventListener(MouseEvent.CLICK, onChooseTeam);
			
			
			// Награда
			teamOneReward = new RewardListB( { 1285:1, 1289:2, 1290:3, 1162:4 }, true, 300, {
				itemWidth:70,
				itemHeight:70,
				disableCount:true,
				scale:0.7,
				sort:true
			}, 'flash:1382952380000');
			teamOneReward.x = teamOneBttn.x + teamOneBttn.width * 0.5 - teamOneReward.width * 0.5;
			teamOneReward.y = teamOneBttn.y - 165;
			bodyContainer.addChild(teamOneReward);
			teamOneReward.title.y += 10;
			
			teamTwoReward = new RewardListB( { 1284:1, 1288:2, 1291:3, 1162:4 }, true, 300, {
				itemWidth:70,
				itemHeight:70,
				disableCount:true,
				scale:0.7,
				sort:true
			}, 'flash:1382952380000');
			teamTwoReward.x = teamTwoBttn.x + teamTwoBttn.width * 0.5 - teamTwoReward.width * 0.5;
			teamTwoReward.y = teamTwoBttn.y - 165;
			bodyContainer.addChild(teamTwoReward);
			teamTwoReward.title.y += 10;
			
			
			updateState();
		}
		
		private function onChooseTeam(e:MouseEvent):void {
			var bttn:Button = e.currentTarget as Button;
			
			if (bttn.mode == Button.DISABLED) return;
			teamOneBttn.state = Button.DISABLED;
			teamTwoBttn.state = Button.DISABLED;
			
			chooseTeam(int(bttn.name));
		}
		
		private function chooseTeam(team:*):void {
			//updateState();
			
			if (!target) return;
			
			target.onSelect(team, onChooseTeamComplete);
		}
		private function onChooseTeamComplete(team:*):void {
			close();
			
			target.click();
		}
		
		public function get team():* {
			return target.team;
		}
		
		public function updateState():void {
			if (team) {
				teamOneBttn.state = Button.DISABLED;
				teamTwoBttn.state = Button.DISABLED;
			}else {
				teamOneBttn.state = Button.NORMAL;
				teamTwoBttn.state = Button.NORMAL;
			}
		}
		
		override public function close(e:MouseEvent = null):void {
			super.close(e);
			
			target.onClose();
		}
	}

}