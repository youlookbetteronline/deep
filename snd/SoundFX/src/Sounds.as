package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.system.Security;
	
	/**
	 * ...
	 * @author gav
	 */
	public class Sounds extends Sprite 
	{
		Security.allowDomain('*');
		Security.allowInsecureDomain('*');
			
		[Embed(source="sounds/flyEnd.mp3")]
		private const FlyEnd:Class;
		public var flyEnd:Sound = new FlyEnd();
		
		[Embed(source="sounds/flyStart.mp3")]
		private const FlyStart:Class;
		public var flyStart:Sound = new FlyStart();
		
		[Embed(source="sounds/dropWater.mp3")]
		private const DropWater:Class;
		public var dropWater:Sound = new DropWater();
		
		[Embed(source="sounds/bonus.mp3")]
		private const Bonus:Class;
		public var bonus:Sound = new Bonus();
		
		[Embed(source="sfx/LevelUp.mp3")]
		private const Levelup:Class;
		public var levelup:Sound = new Levelup();
		
		[Embed(source="sfx/bubbles.mp3")]
		private const Bubbles:Class;
		public var bubbles:Sound = new Bubbles();
		
		[Embed(source="sounds/takeCollection.mp3")]
		private const TakeCollection:Class;
		public var takeCollection:Sound = new TakeCollection();
		
		[Embed(source="sounds/reward.mp3")]
		private const Reward:Class;
		public var reward:Sound = new Reward();
		
		[Embed(source="sounds/glow.mp3")]
		private const Glow:Class;
		public var glow:Sound = new Glow();
		
		[Embed(source="sounds/build.mp3")]
		private const Build:Class;
		public var build:Sound = new Build();
		
		[Embed(source="sounds/production.mp3")]
		private const Production:Class;
		public var production:Sound = new Production();
		
		[Embed(source="sounds/takeResource.mp3")]
		private const TakeResource:Class;
		public var takeResource:Sound = new TakeResource();
		
		[Embed(source="sounds/harvestHard.mp3")]
		private const Harvest:Class;
		public var harvest:Sound = new Harvest();
		
		[Embed(source="sounds/buttons/button_sound_1.mp3")]
		private const Button1:Class;
		public var button1:Sound = new Button1();
		
		[Embed(source="sounds/buttons/_button_click.mp3")]
		private const Button2:Class;
		public var button2:Sound = new Button2();
		
		[Embed(source="sounds/buttons/_click.mp3")]
		private const Button3:Class;
		public var button3:Sound = new Button3();
		
		[Embed(source="sounds/buttons/arrow_bttn.mp3")]
		private const Arrow_bttn:Class;
		public var arrow_bttn:Sound = new Arrow_bttn();
		
		[Embed(source="sounds/buttons/green_button.mp3")]
		private const GreenButton:Class;
		public var green_button:Sound = new GreenButton();
		
		[Embed(source="sfx/QuestDone.mp3")]
		private const QuestDone:Class;
		public var newQuest:Sound = new QuestDone();
		
		[Embed(source="sounds/flipgame/Fail.mp3")]
		private const Fail:Class;
		public var fail:Sound = new Fail();
		
		[Embed(source="sounds/flipgame/Final_prize.mp3")]
		private const Final_prize:Class;
		public var final_prize:Sound = new Final_prize();
		
		[Embed(source="sounds/flipgame/Flip.mp3")]
		private const Flip:Class;
		public var flip:Sound = new Flip();
		
		[Embed(source="sounds/flipgame/Success.mp3")]
		private const Success:Class;
		public var success:Sound = new Success();
		
		[Embed(source="sounds/muhentuhen.mp3")]
		private const Muhentuhen:Class;
		public var muhentuhen:Sound = new Muhentuhen();
		
		[Embed(source="sounds/arena/buy.mp3")]
		private const Buy:Class;
		public var buy:Sound = new Buy();
		
		[Embed(source="sounds/arena/choiceskill.mp3")]
		private const Choiceskill:Class;
		public var choiceskill:Sound = new Choiceskill();
		
		[Embed(source="sounds/arena/clothe.mp3")]
		private const Clothe:Class;
		public var clothe:Sound = new Clothe();
		
		[Embed(source="sounds/arena/feed.mp3")]
		private const Feed:Class;
		public var feed:Sound = new Feed();
		
		[Embed(source="sounds/arena/rename.mp3")]
		private const Rename:Class;
		public var rename:Sound = new Rename();
		
		[Embed(source="sounds/arena/unclothe.mp3")]
		private const Unclothe:Class;
		public var unclothe:Sound = new Unclothe();
		
		[Embed(source="sounds/arena/upgradelevel.mp3")]
		private const Upgradelevel:Class;
		public var upgradelevel:Sound = new Upgradelevel();
		
		[Embed(source="sounds/arena/upgradeskills.mp3")]
		private const Upgradeskills:Class;
		public var upgradeskills:Sound = new Upgradeskills();
		
		[Embed(source="sounds/arena/battle/damage.mp3")]
		private const Damage:Class;
		public var damage:Sound = new Damage();
		
		[Embed(source="sounds/arena/battle/draw.mp3")]
		private const Draw:Class;
		public var draw:Sound = new Draw();
		
		[Embed(source="sounds/arena/battle/lose.mp3")]
		private const Lose:Class;
		public var lose:Sound = new Lose();
		
		[Embed(source="sounds/arena/battle/startbattle.mp3")]
		private const Startbattle:Class;
		public var startbattle:Sound = new Startbattle();
		
		[Embed(source="sounds/arena/battle/win.mp3")]
		private const Win:Class;
		public var win:Sound = new Win();
		
		
		
		public var sounds:Object = {
			flyEnd			:flyEnd,
			flyStart		:flyStart,
			dropWater		:dropWater,
			bonus			:bonus,
			levelup			:levelup,
			newQuest		:newQuest,
			takeCollection	:takeCollection,
			reward			:reward,
			glow			:glow,
			build			:build,
			bubbles			:bubbles,
			production		:production,
			takeResource	:takeResource,
			harvest			:harvest,
			arrow_bttn		:arrow_bttn,
			button_default	:button2,
			button_hard		:button1,
			button_soft		:button3,
			green_button	:green_button,
			fail			:fail,
			final_prize		:final_prize,
			flip			:flip,
			success			:success,
			muhentuhen		:muhentuhen,
			buy				:buy,
			choiceskill		:choiceskill,
			clothe			:clothe,
			feed			:feed,
			rename			:rename,
			unclothe		:unclothe,
			upgradelevel	:upgradelevel,
			upgradeskills	:upgradeskills,
			damage			:damage,
			draw			:draw,
			lose			:lose,
			startbattle		:startbattle,
			win				:win
			
			

		}
		
		public function Sounds()
		{
			
		}
	}
	
}