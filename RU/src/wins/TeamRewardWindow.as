package wins 
{
	
	import buttons.Button;
	import core.Load;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public class TeamRewardWindow extends Window 
	{
		
		public var info:Object;
		public var sid:int;
		public var target:*;
		public var team:*;
		
		private var descLabel:TextField;
		private var teamOneImage:Bitmap;
		private var teamTwoImage:Bitmap;
		private var teamOneLabel:TextField;
		private var teamTwoLabel:TextField;
		private var teamOneBttn:Button;
		private var teamTwoBttn:Button;
		private var teamOneReward:RewardListB;
		private var teamTwoReward:RewardListB;
		
		public function TeamRewardWindow(settings:Object=null) 
		{
			
			if (!settings) settings = { };
			
			target = settings.target;
			sid = target.sid;
			info = App.data.storage[sid];
			team = settings
			
			settings['width'] = settings['width'] || 460;
			settings['height'] = settings['height'] || 500;
			settings['title'] = settings['title'] || (Locale.__e('flash:1441023082142') + ':');
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
			var center:int = 200;
			
			
			// Команды
			teamOneImage = new Bitmap();
			bodyContainer.addChild(teamOneImage);
			
			teamTwoImage = new Bitmap();
			bodyContainer.addChild(teamTwoImage);
			
			teamOneLabel = drawText(target.info.teams[1].title, {
				width:			150,
				textAlign:		'center',
				fontSize:		28,
				color:			0xf6542e,
				borderColor:	0x521100
			});
			teamOneLabel.x = 100;
			teamOneLabel.y = center - teamOneLabel.height * 0.5;
			bodyContainer.addChild(teamOneLabel);
			
			teamTwoLabel = drawText(target.info.teams[2].title, {
				width:			150,
				textAlign:		'center',
				fontSize:		28,
				color:			0x7c82f2,
				borderColor:	0x040e56
			});
			teamTwoLabel.x = settings.width - 100 - teamTwoLabel.width;
			teamTwoLabel.y = center - teamTwoLabel.height * 0.5;
			bodyContainer.addChild(teamTwoLabel);
			
			descLabel = drawText(Locale.__e('flash:1441023233686'), {
				width:			300,
				textAlign:		'center',
				fontSize:		24,
				color:			0x593513,
				borderColor:	0xfdf6e3,
				multiline:		true,
				wrap:			true
			});
			descLabel.x = settings.width * 0.5 - descLabel.width * 0.5;
			descLabel.y = center - descLabel.height * 0.5;
			bodyContainer.addChild(descLabel);
			
			Load.loading(Config.getImage('content', 'BearRedTeam'), function(data:Bitmap):void {
				teamOneImage.bitmapData = data.bitmapData;
				teamOneImage.x = teamOneLabel.x + teamOneLabel.width * 0.5 - teamOneImage.width * 0.5;
				teamOneImage.y = teamOneLabel.y + teamOneLabel.height * 0.5 - teamOneImage.height * 0.65;
			});
			
			Load.loading(Config.getImage('content', 'BearBlueTeam'), function(data:Bitmap):void {
				teamTwoImage.bitmapData = data.bitmapData;
				teamTwoImage.x = teamTwoLabel.x + teamTwoLabel.width * 0.5 - teamTwoImage.width * 0.5;
				teamTwoImage.y = teamTwoLabel.y + teamTwoLabel.height * 0.5 - teamTwoImage.height * 0.65;
			});
			
			
			// Кнопки вступления в команду
			teamOneBttn = new Button( {
				width:			170,
				height:			60,
				caption:		Locale.__e('flash:1382952379978')
			});
			teamOneBttn.name = '1';
			teamOneBttn.x = teamOneLabel.x + teamOneLabel.width * 0.5 - teamOneBttn.width * 0.5 + 30;
			teamOneBttn.y = settings.height - 150;
			bodyContainer.addChild(teamOneBttn);
			teamOneBttn.addEventListener(MouseEvent.CLICK, onChooseTeam);
			
			teamTwoBttn = new Button( {
				width:			170,
				height:			60,
				caption:		Locale.__e('flash:1382952379978')
			});
			teamTwoBttn.name = '2';
			teamTwoBttn.x = teamTwoLabel.x + teamTwoBttn.width * 0.5 - teamTwoBttn.width * 0.5 - 30;
			teamTwoBttn.y = settings.height - 150;
			bodyContainer.addChild(teamTwoBttn);
			teamTwoBttn.addEventListener(MouseEvent.CLICK, onChooseTeam);
			
			
			// Награда
			teamOneReward = new RewardListB( { 2:1 }, true, 240, null, 'flash:1382952380000');
			teamOneReward.x = teamOneBttn.x + teamOneBttn.width * 0.5 - teamOneReward.width * 0.5;
			teamOneReward.y = teamOneBttn.y - 180;
			bodyContainer.addChild(teamOneReward);
			teamOneReward.title.y += 20;
			
			teamTwoReward = new RewardListB( { 2:1 }, true, 240, null, 'flash:1382952380000');
			teamTwoReward.x = teamTwoBttn.x + teamTwoBttn.width * 0.5 - teamTwoReward.width * 0.5;
			teamTwoReward.y = teamTwoBttn.y - 180;
			bodyContainer.addChild(teamTwoReward);
			teamTwoReward.title.y += 20;
			
			
			updateState();
		}
		
		private function onChooseTeam(e:MouseEvent):void {
			var bttn:Button = e.currentTarget as Button;
			
			if (bttn.mode == Button.DISABLED) return;
			
			chooseTeam(int(bttn.name));
		}
		
		private function chooseTeam(team:*):void {
			updateState();
			
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