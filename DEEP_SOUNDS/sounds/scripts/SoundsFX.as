package
{
   import flash.display.Sprite;
   import flash.media.Sound;
   import flash.system.Security;
   
   public class SoundsFX extends Sprite
   {
      
      {
         Security.allowDomain("*");
         Security.allowInsecureDomain("*");
      }
      
      private const FlyEnd:Class = SoundsFX_FlyEnd;
      
      public var flyEnd:Sound;
      
      private const FlyStart:Class = SoundsFX_FlyStart;
      
      public var flyStart:Sound;
      
      private const DropWater:Class = SoundsFX_DropWater;
      
      public var dropWater:Sound;
      
      private const Bonus:Class = SoundsFX_Bonus;
      
      public var bonus:Sound;
      
      private const Levelup:Class = SoundsFX_Levelup;
      
      public var levelup:Sound;
      
      private const Bubbles:Class = SoundsFX_Bubbles;
      
      public var bubbles:Sound;
      
      private const TakeCollection:Class = SoundsFX_TakeCollection;
      
      public var takeCollection:Sound;
      
      private const Reward:Class = SoundsFX_Reward;
      
      public var reward:Sound;
      
      private const Glow:Class = SoundsFX_Glow;
      
      public var glow:Sound;
      
      private const Build:Class = SoundsFX_Build;
      
      public var build:Sound;
      
      private const Production:Class = SoundsFX_Production;
      
      public var production:Sound;
      
      private const TakeResource:Class = SoundsFX_TakeResource;
      
      public var takeResource:Sound;
      
      private const Harvest:Class = SoundsFX_Harvest;
      
      public var harvest:Sound;
      
      private const Button1:Class = SoundsFX_Button1;
      
      public var button1:Sound;
      
      private const Button2:Class = SoundsFX_Button2;
      
      public var button2:Sound;
      
      private const Button3:Class = SoundsFX_Button3;
      
      public var button3:Sound;
      
      private const Arrow_bttn:Class = SoundsFX_Arrow_bttn;
      
      public var arrow_bttn:Sound;
      
      private const GreenButton:Class = SoundsFX_GreenButton;
      
      public var green_button:Sound;
      
      private const QuestDone:Class = SoundsFX_QuestDone;
      
      public var newQuest:Sound;
      
      private const Coin:Class = SoundsFX_Coin;
      
      public var coin:Sound;
      
      private const Experience3:Class = SoundsFX_Experience3;
      
      public var experience3:Sound;
      
      private const TakeMaterial:Class = SoundsFX_TakeMaterial;
      
      public var takeMaterial:Sound;
      
      public var sounds:Object;
      
      public function SoundsFX()
      {
         this.flyEnd = new this.FlyEnd();
         this.flyStart = new this.FlyStart();
         this.dropWater = new this.DropWater();
         this.bonus = new this.Bonus();
         this.levelup = new this.Levelup();
         this.bubbles = new this.Bubbles();
         this.takeCollection = new this.TakeCollection();
         this.reward = new this.Reward();
         this.glow = new this.Glow();
         this.build = new this.Build();
         this.production = new this.Production();
         this.takeResource = new this.TakeResource();
         this.harvest = new this.Harvest();
         this.button1 = new this.Button1();
         this.button2 = new this.Button2();
         this.button3 = new this.Button3();
         this.arrow_bttn = new this.Arrow_bttn();
         this.green_button = new this.GreenButton();
         this.newQuest = new this.QuestDone();
         this.coin = new this.Coin();
         this.experience3 = new this.Experience3();
         this.takeMaterial = new this.TakeMaterial();
         this.sounds = {
            "flyEnd":this.flyEnd,
            "flyStart":this.flyStart,
            "dropWater":this.dropWater,
            "bonus":this.bonus,
            "levelup":this.levelup,
            "newQuest":this.newQuest,
            "takeCollection":this.takeCollection,
            "reward":this.reward,
            "glow":this.glow,
            "build":this.build,
            "bubbles":this.bubbles,
            "production":this.production,
            "takeResource":this.takeResource,
            "harvest":this.harvest,
            "arrow_bttn":this.arrow_bttn,
            "button_default":this.button2,
            "button_hard":this.button1,
            "button_soft":this.button3,
            "green_button":this.green_button,
            "coin":this.coin,
            "experience3":this.experience3,
            "takeMaterial":this.takeMaterial
         };
         super();
      }
   }
}
