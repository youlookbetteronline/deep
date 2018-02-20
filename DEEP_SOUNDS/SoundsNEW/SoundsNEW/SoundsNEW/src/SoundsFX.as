package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.system.Security;
	
	/**
	 * ...
	 * @author 
	 */
	public class SoundsFX extends Sprite 
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
		
		//[Embed(source="sounds/levelup.mp3")]
		[Embed(source="sfx/LevelUp.mp3")]
		private const Levelup:Class;
		public var levelup:Sound = new Levelup();
		
		[Embed(source="sfx/bubbles.mp3")]
		private const Bubbles:Class;
		public var bubbles:Sound = new Bubbles();
		
		//[Embed(source="sounds/newQuest.mp3")]
		//private const NewQuest:Class;
		//public var newQuest:Sound = new NewQuest();
		
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
		
		/*[Embed(source="sounds/takeMaterial.mp3")]
		private const OpenWindow:Class;
		public var openWindow:Sound = new OpenWindow();*/
		
		[Embed(source="sounds/takeResource.mp3")]
		private const TakeResource:Class;
		public var takeResource:Sound = new TakeResource();
		
		[Embed(source="sounds/harvestHard.mp3")]
		private const Harvest:Class;
		public var harvest:Sound = new Harvest();
		
		// Buttons
		//[Embed(source="sounds/buttons/button2.mp3")]
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
		
		[Embed(source="sounds/coin.mp3")]
		private const Coin:Class;
		public var coin:Sound = new Coin();
		
		[Embed(source="sounds/Experience3.mp3")]
		private const Experience3:Class;
		public var experience3:Sound = new Experience3();
		
		[Embed(source="sounds/takeMaterial.mp3")]
		private const TakeMaterial:Class;
		public var takeMaterial:Sound = new TakeMaterial();
		
		[Embed(source="sounds/country.mp3")]
		private const Country:Class;
		public var country:Sound = new Country();
		
		/*
		[Embed(source="sounds/open_sounds/open1.mp3")]
		private const Open1:Class;
		public var open1:Sound = new Open1();
		
		[Embed(source="sounds/open_sounds/open2.mp3")]
		private const Open2:Class;
		public var open2:Sound = new Open2();
		
		[Embed(source="sounds/open_sounds/open3.mp3")]
		private const Open3:Class;
		public var open3:Sound = new Open3();
		
		[Embed(source="sounds/open_sounds/open4.mp3")]
		private const Open4:Class;
		public var open4:Sound = new Open4();
		
		[Embed(source="sounds/open_sounds/open5.mp3")]
		private const Open5:Class;
		public var open5:Sound = new Open5();
		
		[Embed(source="sounds/open_sounds/open6.mp3")]
		private const Open6:Class;
		public var open6:Sound = new Open6();
		
		[Embed(source="sounds/open_sounds/open7.mp3")]
		private const Open7:Class;
		public var open7:Sound = new Open7();
		
		[Embed(source="sounds/open_sounds/open8.mp3")]
		private const Open8:Class;
		public var open8:Sound = new Open8();*/
		
		
		
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
			//openWindow		:openWindow,
			takeResource	:takeResource,
			harvest			:harvest,
			arrow_bttn		:arrow_bttn,
			button_default	:button2,
			button_hard		:button1,
			button_soft		:button3,
			green_button	:green_button,
			coin			:coin,
			experience3		:experience3,
			takeMaterial	:takeMaterial,
			country			:country
			/*open1:open1,
			open2:open2,
			open3:open3,
			open4:open4,
			open5:open5,
			open6:open6,
			open7:open7,
			open8:open8*/
		}
		
		public function SoundsFX()
		{
			
		}
	}
}