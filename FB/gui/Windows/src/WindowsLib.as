package 
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.Security;
	
	
	public class WindowsLib extends Sprite 
	{
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");
			
		[Embed(source="Graphics2/CauldronWithDiamonds.png")]
		private var CauldronWithDiamonds:Class;
		public var cauldronWithDiamonds:BitmapData = new CauldronWithDiamonds().bitmapData;
		
		[Embed(source="Graphics2/BankTiles/BankSaleBonusBackingGold.png")]
		private var BankSaleBonusBackingGold:Class;
		public var bankSaleBonusBackingGold:BitmapData = new BankSaleBonusBackingGold().bitmapData;
		
		[Embed(source="Graphics2/BankTiles/BankSaleBonusBackingGems.png")]
		private var BankSaleBonusBackingGems:Class;
		public var bankSaleBonusBackingGems:BitmapData = new BankSaleBonusBackingGems().bitmapData;
		
		[Embed(source="Graphics2/BankTiles/BankItemBacking.png")]
		private var BankItemBacking:Class;
		public var bankItemBacking:BitmapData = new BankItemBacking().bitmapData;
		
		[Embed(source="Graphics2/BankTiles/BankBonusRibbonBacking.png")]
		private var BankBonusRibbonBacking:Class;
		public var bankBonusRibbonBacking:BitmapData = new BankBonusRibbonBacking().bitmapData;
		
		[Embed(source="Graphics2/BankTiles/BankBonusRibbon.png")]
		private var BankBonusRibbon:Class;
		public var bankBonusRibbon:BitmapData = new BankBonusRibbon().bitmapData;
		
		[Embed(source="Graphics2/TakenedItemsIco.png")]
		private var TakenedItemsIco:Class;
		public var takenedItemsIco:BitmapData = new TakenedItemsIco().bitmapData;
		
		[Embed(source="Graphics2/stockWindow/StorageBackingBot.png")]
		private var StorageBackingBot:Class;
		public var storageBackingBot:BitmapData = new StorageBackingBot().bitmapData;
		
		[Embed(source="Graphics2/stockWindow/StorageRoof.png")]
		private var StorageRoof:Class;
		public var storageRoof:BitmapData = new StorageRoof().bitmapData;
		
		[Embed(source="Graphics2/stockWindow/DecStorageRight.png")]
		private var DecStorageRight:Class;
		public var decStorageRight:BitmapData = new DecStorageRight().bitmapData;
		
		[Embed(source="Graphics2/stockWindow/DecStorageLeft.png")]
		private var DecStorageLeft:Class;
		public var decStorageLeft:BitmapData = new DecStorageLeft().bitmapData;
		
		[Embed(source="Graphics2/stockWindow/DecStarYellow.png")]
		private var DecStarYellow:Class;
		public var decStarYellow:BitmapData = new DecStarYellow().bitmapData;
		
		[Embed(source="Graphics2/stockWindow/DecStarBlue.png")]
		private var DecStarBlue:Class;
		public var decStarBlue:BitmapData = new DecStarBlue().bitmapData;
		
		[Embed(source="Graphics2/stockWindow/DecSnailUP.png")]
		private var DecSnailUP:Class;
		public var decSnailUP:BitmapData = new DecSnailUP().bitmapData;
		
		[Embed(source="Graphics2/stockWindow/DecSnail.png")]
		private var DecSnail:Class;
		public var decSnail:BitmapData = new DecSnail().bitmapData;
		
		[Embed(source="Graphics2/SaleRibbon.png")]
		private var SaleRibbon:Class;
		public var saleRibbon:BitmapData = new SaleRibbon().bitmapData;
		
		[Embed(source="Graphics2/ShowMeBttn.png")]
		private var ShowMeBttn:Class;
		public var showMeBttn:BitmapData = new ShowMeBttn().bitmapData;
		
		[Embed(source="Graphics2/Plus.png")]
		private var Pluss:Class;
		public var pluss:BitmapData = new Pluss().bitmapData;
		
		[Embed(source="Graphics2/RedRibbonItem.png")]
		private var RedRibbonItem:Class;
		public var redRibbonItem:BitmapData = new RedRibbonItem().bitmapData;
		
		[Embed(source="Graphics2/ChestTukan.png")]
		private var ChestTukan:Class;
		public var chestTukan:BitmapData = new ChestTukan().bitmapData;
		
		[Embed(source="Graphics2/Calendar/CalImgUp.png")]
		private var CalImgUp:Class;
		public var calImgUp:BitmapData = new CalImgUp().bitmapData;
		
		[Embed(source="Graphics2/Calendar/CalImgBot.png")]
		private var CalImgBot:Class;
		public var calImgBot:BitmapData = new CalImgBot().bitmapData;
		
		[Embed(source="Graphics2/Calendar/Tile1.png")]
		private var Tile1:Class;
		public var tile1:BitmapData = new Tile1().bitmapData;
		
		[Embed(source="Graphics2/Calendar/Tile2.png")]
		private var Tile2:Class;
		public var tile2:BitmapData = new Tile2().bitmapData;
		
		[Embed(source="Graphics2/Calendar/Tile3.png")]
		private var Tile3:Class;
		public var tile3:BitmapData = new Tile3().bitmapData;
		
		[Embed(source="Graphics2/Calendar/Tile4.png")]
		private var Tile4:Class;
		public var tile4:BitmapData = new Tile4().bitmapData;
		
		[Embed(source="Graphics2/Calendar/Tile5.png")]
		private var Tile5:Class;
		public var tile5:BitmapData = new Tile5().bitmapData;
		
		[Embed(source="Graphics2/Calendar/Tile6.png")]
		private var Tile6:Class;
		public var tile6:BitmapData = new Tile6().bitmapData;
		
		[Embed(source="Graphics2/Calendar/Tile7.png")]
		private var Tile7:Class;
		public var tile7:BitmapData = new Tile7().bitmapData;
		
		[Embed(source="Graphics2/Calendar/Tile8.png")]
		private var Tile8:Class;
		public var tile8:BitmapData = new Tile8().bitmapData;
		
		[Embed(source="Graphics2/Calendar/Tile9.png")]
		private var Tile9:Class;
		public var tile9:BitmapData = new Tile9().bitmapData;
		
		[Embed(source="Graphics2/Calendar/Tile10.png")]
		private var Tile10:Class;
		public var tile10:BitmapData = new Tile10().bitmapData;
		
		[Embed(source="Graphics2/CloseBttn.png")]
		private var CloseBttn:Class;
		public var closeBttn:BitmapData = new CloseBttn().bitmapData;
		
		[Embed(source = "Graphics2/CloseBttnMetal.png")]
		private var CloseBttnMetal:Class;
		public var closeBttnMetal:BitmapData = new CloseBttnMetal().bitmapData;
		
		[Embed(source="Graphics2/AksBttnNew.png")]
		private var AksBttnNew:Class;
		public var aksBttnNew:BitmapData = new AksBttnNew().bitmapData;
		
		[Embed(source="Graphics2/ItemBacking.png")]
		private var ItemBacking:Class;
		public var itemBacking:BitmapData = new ItemBacking().bitmapData;
		
		[Embed(source="Graphics2/Money.png")]
		private var Money:Class;
		public var money:BitmapData = new Money().bitmapData;
		
		[Embed(source="Graphics2/GiftBttn.png")]
		private var GiftBttn:Class;
		public var giftBttn:BitmapData = new GiftBttn().bitmapData;
		
		[Embed(source = "Graphics2/WishlistBttn.png")]
		private var WishlistBttn:Class;
		public var wishlistBttn:BitmapData = new WishlistBttn().bitmapData;
		
		[Embed(source="Graphics2/SellBttn.png")]
		private var SellBttn:Class;
		public var sellBttn:BitmapData = new SellBttn().bitmapData;
		
		[Embed(source="Graphics/Points.png")]
		private var Points:Class;
		public var points:BitmapData = new Points().bitmapData;
		
		[Embed(source="Graphics2/Techno/TechnoBack.png")]
		private var TechnoBack:Class;
		public var technoBack:BitmapData = new TechnoBack().bitmapData;
		
		[Embed(source="Graphics2/Techno/TechnoBackBack.png")]
		private var TechnoBackBack:Class;
		public var technoBackBack:BitmapData = new TechnoBackBack().bitmapData;
		
		[Embed(source="Graphics2/InstCharBacking.png")]
		private var InstCharBacking:Class;
		public var instCharBacking:BitmapData = new InstCharBacking().bitmapData;
		
		[Embed(source="Graphics2/InstCharBackingGuest.png")]
		private var InstCharBackingGuest:Class;
		public var instCharBackingGuest:BitmapData = new InstCharBackingGuest().bitmapData;
		
		[Embed(source="Graphics2/InstCharBackingDisabled.png")]
		private var InstCharBackingDisabled:Class;
		public var instCharBackingDisabled:BitmapData = new InstCharBackingDisabled().bitmapData;
		
		[Embed(source="Textures/Plus.png")]
		private var Plus:Class;
		public var plus:BitmapData = new Plus().bitmapData;
		
		[Embed(source = "Graphics2/Teleport.png")]
		private var Teleport:Class;
		public var teleport:BitmapData = new Teleport().bitmapData;
		
		[Embed(source = "Graphics2/GoldRibbon.png")]
		private var GoldRibbon:Class;
		public var goldRibbon:BitmapData = new GoldRibbon().bitmapData;
		
		[Embed(source = "Graphics2/ShopSpecialBacking.png")]
		private var ShopSpecialBacking:Class;
		public var shopSpecialBacking:BitmapData = new ShopSpecialBacking().bitmapData;
		
		[Embed(source = "Graphics2/PurpleRibbon.png")]
		private var PurpleRibbon:Class;
		public var purpleRibbon:BitmapData = new PurpleRibbon().bitmapData;
		
		[Embed(source = "Graphics2/RewardStripe.png")]
		private var RewardStripe:Class;
		public var rewardStripe:BitmapData = new RewardStripe().bitmapData;
		
		[Embed(source="Graphics/Labels/LevelUp.png")]
		private var LevelUp:Class;
		public var levelUp:BitmapData = new LevelUp().bitmapData;
		
		[Embed(source="Graphics2/Arrow.png")]
		private var Arrow:Class;
		public var arrow:BitmapData = new Arrow().bitmapData;
		
		[Embed(source="Graphics2/CheckMark.png")]
		private var CheckMark:Class;
		public var checkMark:BitmapData = new CheckMark().bitmapData;
		
		[Embed(source="Graphics2/storage/CloseBttnSmall.png")]
		private var CloseBttnSmall:Class;
		public var closeBttnSmall:BitmapData = new CloseBttnSmall().bitmapData;
		
		[Embed(source="Graphics2/storage/prograssBarBacking.png")]
		private var PrograssBarBacking:Class;
		public var prograssBarBacking:BitmapData = new PrograssBarBacking().bitmapData;
		
		[Embed(source="Graphics2/storage/YellowProgBarPiece.png")]
		private var YellowProgBarPiece:Class;
		public var yellowProgBarPiece:BitmapData = new YellowProgBarPiece().bitmapData;
		
		[Embed(source="Graphics2/storage/prograssBarBacking3.png")]
		private var PrograssBarBacking3:Class;
		public var prograssBarBacking3:BitmapData = new PrograssBarBacking3().bitmapData;
		
		[Embed(source = "Graphics2/professionWindow/ButtonChefBlue.png")]
		private var ButtonChefBlue:Class;
		public var buttonChefBlue:BitmapData = new ButtonChefBlue().bitmapData;
		
		[Embed(source = "Graphics2/professionWindow/ButtonChefGreen.png")]
		private var ButtonChefGreen:Class;
		public var buttonChefGreen:BitmapData = new ButtonChefGreen().bitmapData;
		
		[Embed(source = "Graphics2/professionWindow/ButtonClimberBlue.png")]
		private var ButtonClimberBlue:Class;
		public var buttonClimberBlue:BitmapData = new ButtonClimberBlue().bitmapData;
		
		[Embed(source = "Graphics2/professionWindow/ButtonClimberGreen.png")]
		private var ButtonClimberGreen:Class;
		public var buttonClimberGreen:BitmapData = new ButtonClimberGreen().bitmapData;
		
		[Embed(source = "Graphics2/professionWindow/ButtonHunterBlue.png")]
		private var ButtonHunterBlue:Class;
		public var buttonHunterBlue:BitmapData = new ButtonHunterBlue().bitmapData;
		
		[Embed(source = "Graphics2/professionWindow/ButtonHunterGreen.png")]
		private var ButtonHunterGreen:Class;
		public var buttonHunterGreen:BitmapData = new ButtonHunterGreen().bitmapData;
		
		[Embed(source = "Graphics2/professionWindow/ButtonMinerBlue.png")]
		private var ButtonMinerBlue:Class;
		public var buttonMinerBlue:BitmapData = new ButtonMinerBlue().bitmapData;
		
		[Embed(source = "Graphics2/professionWindow/ButtonMinerGreen.png")]
		private var ButtonMinerGreen:Class;
		public var buttonMinerGreen:BitmapData = new ButtonMinerGreen().bitmapData;
		
		[Embed(source = "Graphics2/professionWindow/ButtonAssistantBlue.png")]
		private var ButtonAssistantBlue:Class;
		public var buttonAssistantBlue:BitmapData = new ButtonAssistantBlue().bitmapData;
		
		[Embed(source = "Graphics2/professionWindow/ButtonAssistantGreen.png")]
		private var ButtonAssistantGreen:Class;
		public var buttonAssistantGreen:BitmapData = new ButtonAssistantGreen().bitmapData;
		
		[Embed(source = "Graphics2/professionWindow/ButtonEngineerBlue.png")]
		private var ButtonEngineerBlue:Class;
		public var buttonEngineerBlue:BitmapData = new ButtonEngineerBlue().bitmapData;
		
		[Embed(source = "Graphics2/professionWindow/ButtonEngineerGreen.png")]
		private var ButtonEngineerGreen:Class;
		public var buttonEngineerGreen:BitmapData = new ButtonEngineerGreen().bitmapData;
		
		[Embed(source = "Graphics2/professionWindow/ButtonJewelerBlue.png")]
		private var ButtonJewelerBlue:Class;
		public var buttonJewelerBlue:BitmapData = new ButtonJewelerBlue().bitmapData;
		
		[Embed(source = "Graphics2/professionWindow/ButtonJewelerGreen.png")]
		private var ButtonJewelerGreen:Class;
		public var buttonJewelerGreen:BitmapData = new ButtonJewelerGreen().bitmapData;
		
		[Embed(source = "Graphics2/professionWindow/HelfBacking.png")]
		private var HelfBacking:Class;
		public var helfBacking:BitmapData = new HelfBacking().bitmapData;
		
		//--------------------------------------MAIL--------------------------------------\\
		
		[Embed(source = "Graphics2/MailBox/mailBack.png")]
		private var MailBack:Class;
		public var mailBack:BitmapData = new MailBack().bitmapData;
		
		[Embed(source = "Graphics2/MailBox/mailFront.png")]
		private var MailFront:Class;
		public var mailFront:BitmapData = new MailFront().bitmapData;
		
		[Embed(source = "Graphics2/MailBox/mailPaper.png")]
		private var MailPaper:Class;
		public var mailPaper:BitmapData = new MailPaper().bitmapData;
		
		[Embed(source = "Graphics2/MailBox/mailStamp.png")]
		private var MailStamp:Class;
		public var mailStamp:BitmapData = new MailStamp().bitmapData;
		//_________________________________________________________________________________\\
		
		[Embed(source = "Graphics2/Tips/TipUp.png")]
		private var TipUp:Class;
		public var tipUp:BitmapData = new TipUp().bitmapData;
		
		[Embed(source = "Graphics2/Tips/TipMini.png")]
		private var TipMini:Class;
		public var tipMini:BitmapData = new TipMini().bitmapData;
		
		[Embed(source="Graphics2/Tips/TipMiniWin.png")]
		private var TipMiniWin:Class;
		public var tipMiniWin:BitmapData = new TipMiniWin().bitmapData;
		
		[Embed(source = "Graphics2/Tips/TipWindowUp.png")]
		private var TipWindowUp:Class;
		public var tipWindowUp:BitmapData = new TipWindowUp().bitmapData;
		
		[Embed(source = "Graphics2/Tips/BlickDownLeft.png")]
		private var BlickDownLeft:Class;
		public var blickDownLeft:BitmapData = new BlickDownLeft().bitmapData;
		
		[Embed(source = "Graphics2/Tips/BlickUpLeft.png")]
		private var BlickUpLeft:Class;
		public var blickUpLeft:BitmapData = new BlickUpLeft().bitmapData;
		
		[Embed(source = "Graphics2/Tips/BlickUpRight.png")]
		private var BlickUpRight:Class;
		public var blickUpRight:BitmapData = new BlickUpRight().bitmapData;
		
		[Embed(source = "Graphics2/Tips/Bubble.png")]
		private var Bubble:Class;
		public var bubble:BitmapData = new Bubble().bitmapData;
		
		[Embed(source = "Graphics2/Tips/CalendarBubble.png")]
		private var CalendarBubble:Class;
		public var calendarBubble:BitmapData = new CalendarBubble().bitmapData;
		
		[Embed(source = "Graphics2/Tips/DialogTail.png")]
		private var DialogTail:Class;
		public var dialogTail:BitmapData = new DialogTail().bitmapData;
		
		[Embed(source = "Graphics2/TablePaperBacking.png")]
		private var TablePaperBacking:Class;
		public var tablePaperBacking:BitmapData = new TablePaperBacking().bitmapData;
		
		[Embed(source = "Graphics2/TablePlate.png")]
		private var TablePlate:Class;
		public var tablePlate:BitmapData = new TablePlate().bitmapData;
		
		//-----------------------------------DAILY BONUS WINDOW----------------------------//
		
		[Embed(source = "Graphics2/dailyBonusWindow/DailyBonusBackingUp.png")]
		private var DailyBonusBackingUp:Class;
		public var dailyBonusBackingUp:BitmapData = new DailyBonusBackingUp().bitmapData;
		
		[Embed(source = "Graphics2/dailyBonusWindow/DailyBonusBackingBack.png")]
		private var DailyBonusBackingBack:Class;
		public var dailyBonusBackingBack:BitmapData = new DailyBonusBackingBack().bitmapData;
		
		[Embed(source = "Graphics2/dailyBonusWindow/Tentacle1.png")]
		private var Tentacle1:Class;
		public var tentacle1:BitmapData = new Tentacle1().bitmapData;
		
		[Embed(source = "Graphics2/dailyBonusWindow/Tentacle2.png")]
		private var Tentacle2:Class;
		public var tentacle2:BitmapData = new Tentacle2().bitmapData;
		
		[Embed(source = "Graphics2/dailyBonusWindow/Tentacle3.png")]
		private var Tentacle3:Class;
		public var tentacle3:BitmapData = new Tentacle3().bitmapData;
		
		[Embed(source = "Graphics2/dailyBonusWindow/Tentacle4.png")]
		private var Tentacle4:Class;
		public var tentacle4:BitmapData = new Tentacle4().bitmapData;
		
		[Embed(source = "Graphics2/dailyBonusWindow/Tentacle5.png")]
		private var Tentacle5:Class;
		public var tentacle5:BitmapData = new Tentacle5().bitmapData;
		
		[Embed(source = "Graphics2/dailyBonusWindow/Tentacle6.png")]
		private var Tentacle6:Class;
		public var tentacle6:BitmapData = new Tentacle6().bitmapData;
		
		[Embed(source = "Graphics2/dailyBonusWindow/Tentacle7.png")]
		private var Tentacle7:Class;
		public var tentacle7:BitmapData = new Tentacle7().bitmapData;
		
		[Embed(source = "Graphics2/dailyBonusWindow/Tentacle8.png")]
		private var Tentacle8:Class;
		public var tentacle8:BitmapData = new Tentacle8().bitmapData;
		
		[Embed(source = "Graphics2/dailyBonusWindow/DailyBonusBubble1.png")]
		private var DailyBonusBubble1:Class;
		public var dailyBonusBubble1:BitmapData = new DailyBonusBubble1().bitmapData;
		
		[Embed(source = "Graphics2/dailyBonusWindow/DailyBonusBubble2.png")]
		private var DailyBonusBubble2:Class;
		public var dailyBonusBubble2:BitmapData = new DailyBonusBubble2().bitmapData;
		
		[Embed(source = "Graphics2/dailyBonusWindow/DailyBonusBubble3.png")]
		private var DailyBonusBubble3:Class;
		public var dailyBonusBubble3:BitmapData = new DailyBonusBubble3().bitmapData;
		
		[Embed(source = "Graphics2/dailyBonusWindow/DailyBonusBubble4.png")]
		private var DailyBonusBubble4:Class;
		public var dailyBonusBubble4:BitmapData = new DailyBonusBubble4().bitmapData;
		
		[Embed(source = "Graphics2/dailyBonusWindow/DailyBonusBubble5.png")]
		private var DailyBonusBubble5:Class;
		public var dailyBonusBubble5:BitmapData = new DailyBonusBubble5().bitmapData;
		
		[Embed(source = "Graphics2/dailyBonusWindow/DailyBonusBubble6.png")]
		private var DailyBonusBubble6:Class;
		public var dailyBonusBubble6:BitmapData = new DailyBonusBubble6().bitmapData;
		
		[Embed(source = "Graphics2/dailyBonusWindow/DailyBonusSimpleBack.png")]
		private var DailyBonusSimpleBack:Class;
		public var dailyBonusSimpleBack:BitmapData = new DailyBonusSimpleBack().bitmapData;
		
		[Embed(source = "Graphics2/dailyBonusWindow/DailyBonusTodayBack.png")]
		private var DailyBonusTodayBack:Class;
		public var dailyBonusTodayBack:BitmapData = new DailyBonusTodayBack().bitmapData;
		
		[Embed(source = "Graphics2/dailyBonusWindow/DailyBonusTomorrowBack.png")]
		private var DailyBonusTomorrowBack:Class;
		public var dailyBonusTomorrowBack:BitmapData = new DailyBonusTomorrowBack().bitmapData;
		
		[Embed(source = "Graphics2/dailyBonusWindow/DailyBonusItemBubble.png")]
		private var DailyBonusItemBubble:Class;
		public var dailyBonusItemBubble:BitmapData = new DailyBonusItemBubble().bitmapData;
		
		[Embed(source = "Graphics2/dailyBonusWindow/DailyBonusItemGlow.png")]
		private var DailyBonusItemGlow:Class;
		public var dailyBonusItemGlow:BitmapData = new DailyBonusItemGlow().bitmapData;
		
		//*********************************************************************************//
		
		[Embed(source="Graphics2/BuildIco.png")]
		private var BuildIco:Class;
		public var buildIco:BitmapData = new BuildIco().bitmapData;
		
		[Embed(source="Graphics2/storage/ProgressBar.png")]
		private var ProgressBar:Class;
		public var progressBar:BitmapData = new ProgressBar().bitmapData;
		
		[Embed(source = "Textures/ProgressBarPiece.png")]
		private var ProgressBarPiece:Class;
		public var progressBarPiece:BitmapData = new ProgressBarPiece().bitmapData;
		
		[Embed(source="Graphics2/SearchPanelBackingPiece.png")]
		private var SearchPanelBackingPiece:Class;
		public var searchPanelBackingPiece:BitmapData = new SearchPanelBackingPiece().bitmapData;
		
		[Embed(source = "Textures/Star.png")]
		private var Star:Class;
		public var star:BitmapData = new Star().bitmapData;
	
		[Embed(source="Textures/WhiteDot.png")]
		private var WhiteDot:Class;
		public var whiteDot:BitmapData = new WhiteDot().bitmapData;
		
		[Embed(source="Textures/CursorsPanelBg2.png")]
		private var CursorsPanelBg2:Class;
		public var cursorsPanelBg2:BitmapData = new CursorsPanelBg2().bitmapData;
		
		[Embed(source="Textures/CursorsPanelBg3.png")]
		private var CursorsPanelBg3:Class;
		public var cursorsPanelBg3:BitmapData = new CursorsPanelBg3().bitmapData;
		
		[Embed(source="Textures/CursorsPanelItemBg.png")]
		private var CursorsPanelItemBg:Class;
		public var cursorsPanelItemBg:BitmapData = new CursorsPanelItemBg().bitmapData;
		
		[Embed(source="Textures/CursorsPanelNewBg.png")]
		private var CursorsPanelNewBg:Class;
		public var cursorsPanelNewBg:BitmapData = new CursorsPanelNewBg().bitmapData;
		
		[Embed(source="Graphics2/CheckMark.png")]
		private var CheckMarkBig:Class;
		public var checkMarkBig:BitmapData = new CheckMarkBig().bitmapData;
		
		[Embed(source="Graphics2/Timer.png")]
		private var TimerDark:Class;
		public var timerDark:BitmapData = new TimerDark().bitmapData;
		
		[Embed(source="Textures/Equals.png")]
		private var Equals:Class;
		public var equals:BitmapData = new Equals().bitmapData;
		
		[Embed(source="Textures/TimerYellow.png")]
		private var TimerYellow:Class;
		public var timerYellow:BitmapData = new TimerYellow().bitmapData;
		
		[Embed(source="Graphics2/mini/ProductBacking.png")]
		private var ProductBacking:Class;
		public var productBacking:BitmapData = new ProductBacking().bitmapData;
		
		[Embed(source="Graphics2/ShopSpecialBacking.png")]
		private var QuestsMainBacking2:Class;
		public var questsMainBacking2:BitmapData = new QuestsMainBacking2().bitmapData;
		
		[Embed(source="Graphics2/ShopSpecialBacking1.png")]
		private var ShopSpecialBacking1:Class;
		public var shopSpecialBacking1:BitmapData = new ShopSpecialBacking1().bitmapData;
		
		[Embed(source="Graphics2/LevelUpItemBacking.png")]
		private var LevelUpItemBacking:Class;
		public var levelUpItemBacking:BitmapData = new LevelUpItemBacking().bitmapData;
		
		[Embed(source="Graphics2/CharsStatusBacking.png")]
		private var CharsStatusBacking:Class;
		public var charsStatusBacking:BitmapData = new CharsStatusBacking().bitmapData;
		
		[Embed(source="Graphics2/productionWindow/ArrowUp.png")]
		private var ArrowUp:Class;
		public var arrowUp:BitmapData = new ArrowUp().bitmapData;
		
		[Embed(source="Graphics2/CheckBoxEmpty.png")]
		private var CheckBox:Class;
		public var checkBox:BitmapData = new CheckBox().bitmapData;
		
		[Embed(source="Graphics2/CheckBoxFull.png")]
		private var CheckBoxPress:Class;
		public var checkBoxPress:BitmapData = new CheckBoxPress().bitmapData;
		
		[Embed(source="Graphics2/UpgradeArrow.png")]
		private var UpgradeArrow:Class;
		public var upgradeArrow:BitmapData = new UpgradeArrow().bitmapData;
		
		[Embed(source="Graphics2/mini/ProductionProgressBar.png")]
		private var ProductionProgressBar:Class;
		public var productionProgressBar:BitmapData = new ProductionProgressBar().bitmapData;
		
		[Embed(source="Graphics2/mini/ProductionProgressBarBacking.png")]
		private var ProductionProgressBarBacking:Class;
		public var productionProgressBarBacking:BitmapData = new ProductionProgressBarBacking().bitmapData;
		
		[Embed(source="Graphics2/BanksBackingItem.png")]
		private var BanksBackingItem:Class;
		public var banksBackingItem:BitmapData = new BanksBackingItem().bitmapData;		
		
		[Embed(source="Graphics2/BanksBackingItemBest.png")]
		private var BanksBackingItemBest:Class;
		public var banksBackingItemBest:BitmapData = new BanksBackingItemBest().bitmapData;
		
		[Embed(source="Graphics2/BankTiles/BankBonusDeepRibbon.png")]
		private var BankBonusDeepRibbon:Class;
		public var bankBonusDeepRibbon:BitmapData = new BankBonusDeepRibbon().bitmapData;
		
		[Embed(source="Graphics2/BankTiles/BankBonusDeepBack.png")]
		private var BankBonusDeepBack:Class;
		public var bankBonusDeepBack:BitmapData = new BankBonusDeepBack().bitmapData;
		
		[Embed(source="Graphics2/BankTiles/BanksSnail.png")]
		private var BanksSnail:Class;
		public var banksSnail:BitmapData = new BanksSnail().bitmapData;
		
		[Embed(source = "Graphics2/QuestIconBacking.png")]
		private var QuestIconBacking:Class;
		public var questIconBacking:BitmapData = new QuestIconBacking().bitmapData;
		
		[Embed(source="Textures/StripNew.png")]
		private var StripNew:Class;
		public var stripNew:BitmapData = new StripNew().bitmapData;
		
		/*[Embed(source="Graphics2/lastUpdate/UpgradeBttnBacking.png")]
		private var UpgradeBttnBacking:Class;
		public var upgradeBttnBacking:BitmapData = new UpgradeBttnBacking().bitmapData;*/
		
		/*[Embed(source="Graphics2/lastUpdate/UpgradeBttn.png")]
		private var UpgradeBttn:Class;
		public var upgradeBttn:BitmapData = new UpgradeBttn().bitmapData;*/
		
		/*[Embed(source="Graphics2/mini/MaterialIconRed.png")]
		private var MaterialIconRed:Class;
		public var materialIconRed:BitmapData = new MaterialIconRed().bitmapData;*/
		
		[Embed(source="Textures/InstantsTimer.png")]
		private var InstantsTimer:Class;
		public var instantsTimer:BitmapData = new InstantsTimer().bitmapData;
		
		[Embed(source="Graphics2/ChestCheckMark.png")]
		private var ChestCheckMark:Class;
		public var chestCheckMark:BitmapData = new ChestCheckMark().bitmapData;	
		
		[Embed(source="Graphics2/AchievementUnlockBacking.png")]
		private var AchievementUnlockBacking:Class;
		public var achievementUnlockBacking:BitmapData = new AchievementUnlockBacking().bitmapData;
		
		[Embed(source="Textures/RedBow.png")]
		private var RedBow:Class;
		public var redBow:BitmapData = new RedBow().bitmapData;
		
		[Embed(source="Graphics2/mini/ProductionProgressBarGreen.png")]
		private var ProductionProgressBarGreen:Class;
		public var productionProgressBarGreen:BitmapData = new ProductionProgressBarGreen().bitmapData;
	
		[Embed(source="Graphics2/LoadingBacking.png")]
		private var LoadingBacking:Class;
		public var loadingBacking:BitmapData = new LoadingBacking().bitmapData;
		
		[Embed(source="Textures/WallPost/Logo.png")]
		private var Logo:Class;
		public var logo:BitmapData = new Logo().bitmapData;
		
		[Embed(source="Textures/WallPost/IPlay.jpg")]
		private var IPlay:Class;
		public var iPlay:BitmapData = new IPlay().bitmapData;
		
		[Embed(source="Textures/WallPost/NewLvl.png")]
		private var NewLvl:Class;
		public var newLvl:BitmapData = new NewLvl().bitmapData;
		
		[Embed(source="Textures/WallPost/NewTerritory.png")]
		private var NewTerritory:Class;
		public var newTerritory:BitmapData = new NewTerritory().bitmapData;
		
		[Embed(source="Textures/WallPost/Gift.png")]
		private var Gift:Class;
		public var gift:BitmapData = new Gift().bitmapData;
		
		[Embed(source="Textures/WallPost/Achiev.png")]
		private var Achiev:Class;
		public var achiev:BitmapData = new Achiev().bitmapData;
		
		[Embed(source="Textures/WallPost/Material.png")]
		private var Material:Class;
		public var material:BitmapData = new Material().bitmapData;	
		
		///////////////////////////////////////LEVEL UP///////////////////////////////////////
		
		[Embed(source="Graphics2/levelUp/LevelUpBackingBot.png")]
		private var LevelUpBackingBot:Class;
		public var levelUpBackingBot:BitmapData = new LevelUpBackingBot().bitmapData;
		
		[Embed(source="Graphics2/levelUp/LevelUpBackingUp.png")]
		private var LevelUpBackingUp:Class;
		public var levelUpBackingUp:BitmapData = new LevelUpBackingUp().bitmapData;
		
		[Embed(source="Graphics2/levelUp/LevelUpBackingOctopusFish.png")]
		private var LevelUpBackingOctopusFish:Class;
		public var levelUpBackingOctopusFish:BitmapData = new LevelUpBackingOctopusFish().bitmapData;
		
		[Embed(source="Graphics2/levelUp/LevelUpCrab.png")]
		private var LevelUpCrab:Class;
		public var levelUpCrab:BitmapData = new LevelUpCrab().bitmapData;
		
		[Embed(source="Graphics2/levelUp/PaperClear.png")]
		private var PaperClear:Class;
		public var paperClear:BitmapData = new PaperClear().bitmapData;
		
		///////////////////////////////////////SHOP WINDOW///////////////////////////////////////
		
		[Embed(source="Graphics2/shopWindow/ShopBackingNew.png")]
		private var ShopBackingNew:Class;
		public var shopBackingNew:BitmapData = new ShopBackingNew().bitmapData;
		
		[Embed(source="Graphics2/shopWindow/ShopBackingNew2.png")]
		private var ShopBackingNew2:Class;
		public var shopBackingNew2:BitmapData = new ShopBackingNew2().bitmapData;
		
		[Embed(source="Graphics2/shopWindow/ShopButton.png")]
		private var ShopButton:Class;
		public var shopButton:BitmapData = new ShopButton().bitmapData;
		
		[Embed(source="Graphics2/shopWindow/ShopButtonRopeDown.png")]
		private var ShopButtonRopeDown:Class;
		public var shopButtonRopeDown:BitmapData = new ShopButtonRopeDown().bitmapData;
		
		[Embed(source="Graphics2/shopWindow/ShopButtonRopeUp.png")]
		private var ShopButtonRopeUp:Class;
		public var shopButtonRopeUp:BitmapData = new ShopButtonRopeUp().bitmapData;
		
		[Embed(source="Graphics2/shopWindow/ShopPlank.png")]
		private var ShopPlank:Class;
		public var shopPlank:BitmapData = new ShopPlank().bitmapData;
		
		[Embed(source="Graphics2/shopWindow/ShopPlankDown.png")]
		private var ShopPlankDown:Class;
		public var shopPlankDown:BitmapData = new ShopPlankDown().bitmapData;
		
		[Embed(source="Graphics2/shopWindow/ShopRoof.png")]
		private var ShopRoof:Class;
		public var shopRoof:BitmapData = new ShopRoof().bitmapData;
		
		[Embed(source="Graphics2/shopWindow/DecCoral.png")]
		private var DecCoral:Class;
		public var decCoral:BitmapData = new DecCoral().bitmapData;
		
		[Embed(source="Graphics2/shopWindow/DecShellBlue.png")]
		private var DecShellBlue:Class;
		public var decShellBlue:BitmapData = new DecShellBlue().bitmapData;
		
		[Embed(source="Graphics2/shopWindow/DecShellYellow.png")]
		private var DecShellYellow:Class;
		public var decShellYellow:BitmapData = new DecShellYellow().bitmapData;
		
		[Embed(source="Graphics2/shopWindow/DecStarRed.png")]
		private var DecStarRed:Class;
		public var decStarRed:BitmapData = new DecStarRed().bitmapData;
		
		[Embed(source="Graphics2/shopWindow/ShopTitleBacking.png")]
		private var ShopTitleBacking:Class;
		public var shopTitleBacking:BitmapData = new ShopTitleBacking().bitmapData;
		
		///////////////////////////////////////CONSTRUCT WINDOW/////////////////////////////////////
		
		[Embed(source="Graphics2/constructWindow/ConstructBackingUp.png")]
		private var ConstructBackingUp:Class;
		public var constructBackingUp:BitmapData = new ConstructBackingUp().bitmapData;
		
		[Embed(source="Graphics2/constructWindow/ConstructBackingBot.png")]
		private var ConstructBackingBot:Class;
		public var constructBackingBot:BitmapData = new ConstructBackingBot().bitmapData;
		
		[Embed(source="Graphics2/constructWindow/DecConstructStar1.png")]
		private var DecConstructStar1:Class;
		public var decConstructStar1:BitmapData = new DecConstructStar1().bitmapData;
		
		[Embed(source="Graphics2/constructWindow/DecConstructStar2.png")]
		private var DecConstructStar2:Class;
		public var decConstructStar2:BitmapData = new DecConstructStar2().bitmapData;
		
		[Embed(source="Graphics2/constructWindow/DecShell.png")]
		private var DecShell:Class;
		public var decShell:BitmapData = new DecShell().bitmapData;
		
		[Embed(source="Graphics2/productionWindow/TipTimerBacking.png")]
		private var TipTimerBacking:Class;
		public var tipTimerBacking:BitmapData = new TipTimerBacking().bitmapData;
		
		[Embed(source="Graphics2/ProductionReadyBacking.png")]
		private var ProductionReadyBacking:Class;
		public var productionReadyBacking:BitmapData = new ProductionReadyBacking().bitmapData;
		
		[Embed(source="Graphics2/productionWindow/LockedSlot.png")]
		private var LockedSlot:Class;
		public var lockedSlot:BitmapData = new LockedSlot().bitmapData;
		
		////////////////////////////////////QUEST WINDOW///////////////////////////////////////
		
		[Embed(source="Graphics2/questWindow/ItemBackingPaperBigDrec.png")]
		private var ItemBackingPaperBigDrec:Class;
		public var itemBackingPaperBigDrec:BitmapData = new ItemBackingPaperBigDrec().bitmapData;
		
		[Embed(source="Graphics2/questWindow/ItemBackingPaperBig.png")]
		private var ItemBackingPaperBig:Class;
		public var itemBackingPaperBig:BitmapData = new ItemBackingPaperBig().bitmapData;
		
		[Embed(source="Graphics2/questIcon/BackQuestIcon1.png")]
		private var BackQuestIcon1:Class;
		public var backQuestIcon1:BitmapData = new BackQuestIcon1().bitmapData;
		
		[Embed(source="Graphics2/questIcon/BackQuestIcon2.png")]
		private var BackQuestIcon2:Class;
		public var backQuestIcon2:BitmapData = new BackQuestIcon2().bitmapData;
		
		[Embed(source="Graphics2/HutBack.png")]
		private var HutBack:Class;
		public var hutBack:BitmapData = new HutBack().bitmapData;
		
		[Embed(source="Graphics2/SmallHutBack.png")]
		private var SmallHutBack:Class;
		public var smallHutBack:BitmapData = new SmallHutBack().bitmapData;
		
		[Embed(source="Graphics2/questWindow/CrabQuest.png")]
		private var CrabQuest:Class;
		public var crabQuest:BitmapData = new CrabQuest().bitmapData;
		
		[Embed(source="Graphics2/questWindow/QuestBackingBot.png")]
		private var QuestBackingBot:Class;
		public var questBackingBot:BitmapData = new QuestBackingBot().bitmapData;
		
		[Embed(source="Graphics2/questWindow/QuestBackingBonus.png")]
		private var QuestBackingBonus:Class;
		public var questBackingBonus:BitmapData = new QuestBackingBonus().bitmapData;
		
		[Embed(source="Graphics2/questWindow/DecSeaweed.png")]
		private var DecSeaweed:Class;
		public var decSeaweed:BitmapData = new DecSeaweed().bitmapData;
		
		[Embed(source="Graphics2/questWindow/QuestBackingTop.png")]
		private var QuestBackingTop:Class;
		public var questBackingTop:BitmapData = new QuestBackingTop().bitmapData;
		
		[Embed(source="Graphics2/questWindow/QuestTaskBackingNew.png")]
		private var QuestTaskBackingNew:Class;
		public var questTaskBackingNew:BitmapData = new QuestTaskBackingNew().bitmapData;
		
		[Embed(source="Graphics2/productionWindow/Lock.png")]
		private var Lock:Class;
		public var lock:BitmapData = new Lock().bitmapData;
		
		[Embed(source="Graphics2/guestWakeUpBot.png")]
		private var GuestWakeUpBot:Class;
		public var guestWakeUpBot:BitmapData = new GuestWakeUpBot().bitmapData;
		
		[Embed(source="Graphics2/FrGuestPanel.png")]
		private var FrGuestPanel:Class;
		public var frGuestPanel:BitmapData = new FrGuestPanel().bitmapData;
		
		///////////////////////COLLECTIONS//////////////////////////
		
		[Embed(source="Graphics2/collectionWindow/AddBttnBlue.png")]
		private var AddBttnBlue:Class;
		public var addBttnBlue:BitmapData = new AddBttnBlue().bitmapData;
		
		[Embed(source="Graphics2/collectionWindow/AddBttnGreen.png")]
		private var AddBttnGreen:Class;
		public var addBttnGreen:BitmapData = new AddBttnGreen().bitmapData;
		
		[Embed(source="Graphics2/collectionWindow/AddBttnBlueGrey.png")]
		private var AddBttnBlueGrey:Class;
		public var addBttnBlueGrey:BitmapData = new AddBttnBlueGrey().bitmapData;
		
		[Embed(source="Graphics2/collectionWindow/DecBank.png")]
		private var DecBank:Class;
		public var decBank:BitmapData = new DecBank().bitmapData;
		
		[Embed(source="Graphics2/collectionWindow/GiftBeckingCollectio.png")]
		private var GiftBeckingCollectio:Class;
		public var giftBeckingCollectio:BitmapData = new GiftBeckingCollectio().bitmapData;
		
		[Embed(source="Graphics2/collectionWindow/GiftBeckingCollection.png")]
		private var GiftBeckingCollection:Class;
		public var giftBeckingCollection:BitmapData = new GiftBeckingCollection().bitmapData;
		
		///////////////////////GAMBLE//////////////////////////
		
		[Embed(source="Graphics2/gambleWindow/shell_bot.png")]
		private var Shell_bot:Class;
		public var shell_bot:BitmapData = new Shell_bot().bitmapData;
		
		///////////////////////ACHIVEMENTS//////////////////////////
		
		[Embed(source="Graphics2/achivementsWindow/AchievStar.png")]
		private var AchievStar:Class;
		public var achievStar:BitmapData = new AchievStar().bitmapData;
		
		[Embed(source="Graphics2/achivementsWindow/AchievStarDisabled.png")]
		private var AchievStarDisabled:Class;
		public var achievStarDisabled:BitmapData = new AchievStarDisabled().bitmapData;
		
		[Embed(source="Graphics2/achivementsWindow/ButtonGrenn.png")]
		private var ButtonGrenn:Class;
		public var buttonGrenn:BitmapData = new ButtonGrenn().bitmapData;
		
		[Embed(source="Graphics2/achivementsWindow/CheckmarkBig.png")]
		private var CheckmarkBig:Class;
		public var checkmarkBig:BitmapData = new CheckmarkBig().bitmapData;
		
		[Embed(source="Graphics2/achivementsWindow/RibbonGrenn.png")]
		private var RibbonGrenn:Class;
		public var ribbonGrenn:BitmapData = new RibbonGrenn().bitmapData;
		
		[Embed(source="Graphics2/achivementsWindow/MainProgBarBluePiece.png")]
		private var MainProgBarBluePiece:Class;
		public var mainProgBarBluePiece:BitmapData = new MainProgBarBluePiece().bitmapData;
		
		[Embed(source="Graphics2/achivementsWindow/ProgBarBacking.png")]
		private var ProgBarBacking:Class;
		public var progBarBacking:BitmapData = new ProgBarBacking().bitmapData;
		
		///////////////////////CAPSULE//////////////////////////
		
		[Embed(source="Graphics2/capsuleWindow/CapsuleWindowBacking.png")]
		private var CapsuleWindowBacking:Class;
		public var capsuleWindowBacking:BitmapData = new CapsuleWindowBacking().bitmapData;
		
		[Embed(source="Graphics2/capsuleWindow/CapsuleWindowEqual.png")]
		private var CapsuleWindowEqual:Class;
		public var capsuleWindowEqual:BitmapData = new CapsuleWindowEqual().bitmapData;
		
		[Embed(source="Graphics2/capsuleWindow/CapsuleWindowPlus.png")]
		private var CapsuleWindowPlus:Class;
		public var capsuleWindowPlus:BitmapData = new CapsuleWindowPlus().bitmapData;
		
		[Embed(source="Graphics2/capsuleWindow/CapsuleWindowBackingPaperUp.png")]
		private var CapsuleWindowBackingPaperUp:Class;
		public var capsuleWindowBackingPaperUp:BitmapData = new CapsuleWindowBackingPaperUp().bitmapData;
		
		[Embed(source="Graphics2/capsuleWindow/CapsuleWindowBackingPaperDown.png")]
		private var CapsuleWindowBackingPaperDown:Class;
		public var capsuleWindowBackingPaperDown:BitmapData = new CapsuleWindowBackingPaperDown().bitmapData;
		
		///////////////////////TUTORIAL//////////////////////////
		
		[Embed(source="Graphics2/tutorial/TutorBoy.png")]
		private var TutorBoy:Class;
		public var tutorBoy:BitmapData = new TutorBoy().bitmapData;
		
		[Embed(source="Graphics2/tutorial/TutorGirl.png")]
		private var TutorGirl:Class;
		public var tutorGirl:BitmapData = new TutorGirl().bitmapData;
		
		[Embed(source="Graphics2/tutorial/TutorRadio.png")]
		private var TutorRadio:Class;
		public var tutorRadio:BitmapData = new TutorRadio().bitmapData;
		
		[Embed(source="Graphics2/ErrorOops.png")]
		private var ErrorOops:Class;
		public var errorOops:BitmapData = new ErrorOops().bitmapData;
		
		///////////////////////////ROULETTE WINDOW/////////////////////////////////////////
		
		[Embed(source="Graphics2/RouletteWindows/RouletteBacking.png")]
		private var RouletteBacking:Class;
		public var rouletteBacking:BitmapData = new RouletteBacking().bitmapData;
		
		[Embed(source="Graphics2/RouletteWindows/RouletteBubble.png")]
		private var RouletteBubble:Class;
		public var rouletteBubble:BitmapData = new RouletteBubble().bitmapData;
		
		[Embed(source="Graphics2/RouletteWindows/DecFish1.png")]
		private var DecFish1:Class;
		public var decFish1:BitmapData = new DecFish1().bitmapData;
		
		[Embed(source="Graphics2/RouletteWindows/DecFish2.png")]
		private var DecFish2:Class;
		public var decFish2:BitmapData = new DecFish2().bitmapData;
		
		[Embed(source="Graphics2/RouletteWindows/QuestionMark.png")]
		private var QuestionMark:Class;
		public var questionMark:BitmapData = new QuestionMark().bitmapData;
		
		[Embed(source="Graphics2/RouletteWindows/BlueRound.png")]
		private var BlueRound:Class;
		public var blueRound:BitmapData = new BlueRound().bitmapData;
		
		///////////////////////////NEW FREEBIE/////////////////////////////////////////
		
		[Embed(source="Graphics2/ParticleElements/particle_b1.png")]
		private var Particle_b1:Class;
		public var particle_b1:BitmapData = new Particle_b1().bitmapData;
		
		[Embed(source="Graphics2/ParticleElements/particle_b2.png")]
		private var Particle_b2:Class;
		public var particle_b2:BitmapData = new Particle_b2().bitmapData;
		
		[Embed(source="Graphics2/ParticleElements/particle_s1.png")]
		private var Particle_s1:Class;
		public var particle_s1:BitmapData = new Particle_s1().bitmapData;
		
		[Embed(source="Graphics2/ParticleElements/particle_s2.png")]
		private var Particle_s2:Class;
		public var particle_s2:BitmapData = new Particle_s2().bitmapData;
		
		[Embed(source="Graphics2/ParticleElements/particle_s3.png")]
		private var Particle_s3:Class;
		public var particle_s3:BitmapData = new Particle_s3().bitmapData;
		
		[Embed(source="Graphics2/ClearBubbleBacking.png")]
		private var ClearBubbleBacking:Class;
		public var clearBubbleBacking:BitmapData = new ClearBubbleBacking().bitmapData;
		
		[Embed(source="Graphics2/ApothecaryBubble.png")]
		private var ApothecaryBubble:Class;
		public var apothecaryBubble:BitmapData = new ApothecaryBubble().bitmapData;
		
		[Embed(source="Graphics2/ApothecaryHouse.png")]
		private var ApothecaryHouse:Class;
		public var apothecaryHouse:BitmapData = new ApothecaryHouse().bitmapData;
		
		[Embed(source="Graphics2/BackingGrad.png")]
		private var BackingGrad:Class;
		public var backingGrad:BitmapData = new BackingGrad().bitmapData;
		
		[Embed(source="Graphics2/ClearBubbleBacking_0.png")]
		private var ClearBubbleBacking_0:Class;
		public var clearBubbleBacking_0:BitmapData = new ClearBubbleBacking_0().bitmapData;
		
		[Embed(source="Graphics2/PaperGlow.png")]
		private var PaperGlow:Class;
		public var paperGlow:BitmapData = new PaperGlow().bitmapData;
		
		[Embed(source="Graphics2/QuestRewardWooden.png")]
		private var QuestRewardWooden:Class;
		public var questRewardWooden:BitmapData = new QuestRewardWooden().bitmapData;
		
		[Embed(source="Graphics2/QuestRewardFishes.png")]
		private var QuestRewardFishes:Class;
		public var questRewardFishes:BitmapData = new QuestRewardFishes().bitmapData;
		
		[Embed(source="Graphics2/PaperWithBacking.png")]
		private var PaperWithBacking:Class;
		public var paperWithBacking:BitmapData = new PaperWithBacking().bitmapData;
		
		[Embed(source="Graphics2/ProgressBars/BackingOne.png")]
		private var BackingOne:Class;
		public var backingOne:BitmapData = new BackingOne().bitmapData;
		
		[Embed(source="Graphics2/ProgressBars/HorseSlider.png")]
		private var HorseSlider:Class;
		public var horseSlider:BitmapData = new HorseSlider().bitmapData;
		
		[Embed(source="Graphics2/ProgressBars/HorseBacking.png")]
		private var HorseBacking:Class;
		public var horseBacking:BitmapData = new HorseBacking().bitmapData;
		
		[Embed(source="Graphics2/ProgressBars/ProductionBacking.png")]
		private var ProductionBacking:Class;
		public var productionBacking:BitmapData = new ProductionBacking().bitmapData;
		
		[Embed(source="Graphics2/ProgressBars/SliderOne.png")]
		private var SliderOne:Class;
		public var sliderOne:BitmapData = new SliderOne().bitmapData;
		
		[Embed(source="Graphics2/ProgressBars/HappyPanel.png")]
		private var HappyPanel:Class;
		public var happyPanel:BitmapData = new HappyPanel().bitmapData;
		
		[Embed(source="Graphics2/ProgressBars/HappySlider.png")]
		private var HappySlider:Class;
		public var happySlider:BitmapData = new HappySlider().bitmapData;
		
		[Embed(source="Graphics2/ProgressBars/BackingBank.png")]
		private var BackingBank:Class;
		public var backingBank:BitmapData = new BackingBank().bitmapData;
		
		[Embed(source="Graphics2/ProgressBars/SliderBank.png")]
		private var SliderBank:Class;
		public var sliderBank:BitmapData = new SliderBank().bitmapData;
		
		[Embed(source="Graphics2/ClearCrab.png")]
		private var ClearCrab:Class;
		public var clearCrab:BitmapData = new ClearCrab().bitmapData;
		
		[Embed(source="Graphics2/AnimalHungryBackingDark.png")]
		private var AnimalHungryBackingDark:Class;
		public var animalHungryBackingDark:BitmapData = new AnimalHungryBackingDark().bitmapData;
		
		[Embed(source="Graphics2/AnimalHungryBackingLight.png")]
		private var AnimalHungryBackingLight:Class;
		public var animalHungryBackingLight:BitmapData = new AnimalHungryBackingLight().bitmapData;
		
		[Embed(source="Graphics2/WorkerHouseBacking.png")]
		private var WorkerHouseBacking:Class;
		public var workerHouseBacking:BitmapData = new WorkerHouseBacking().bitmapData;
		
		[Embed(source="Graphics2/PresentBacking.png")]
		private var PresentBacking:Class;
		public var presentBacking:BitmapData = new PresentBacking().bitmapData;
		
		[Embed(source="Graphics2/BubbleTimerBack.png")]
		private var BubbleTimerBack:Class;
		public var bubbleTimerBack:BitmapData = new BubbleTimerBack().bitmapData;
		
		[Embed(source="Graphics2/DaylicIcon.png")]
		private var DaylicIcon:Class;
		public var daylicIcon:BitmapData = new DaylicIcon().bitmapData;
		
		[Embed(source="Graphics2/PaperScroll.png")]
		private var PaperScroll:Class;
		public var paperScroll:BitmapData = new PaperScroll().bitmapData;
		
		[Embed(source="Graphics2/GlowingBackingNew.png")]
		private var GlowingBackingNew:Class;
		public var glowingBackingNew:BitmapData = new GlowingBackingNew().bitmapData;
		
		[Embed(source="Graphics2/FreebieFishes.png")]
		private var FreebieFishes:Class;
		public var freebieFishes:BitmapData = new FreebieFishes().bitmapData;
		
		[Embed(source="Graphics2/IronBacking.png")]
		private var IronBacking:Class;
		public var ironBacking:BitmapData = new IronBacking().bitmapData;
		
		[Embed(source="Graphics2/TeritoryUp.png")]
		private var TeritoryUp:Class;
		public var teritoryUp:BitmapData = new TeritoryUp().bitmapData;
		
		[Embed(source="Graphics2/InformBacking.png")]
		private var InformBacking:Class;
		public var informBacking:BitmapData = new InformBacking().bitmapData;
		
		[Embed(source="Graphics2/TitleBgNew.png")]
		private var TitleBgNew:Class;
		public var titleBgNew:BitmapData = new TitleBgNew().bitmapData;
		
		[Embed(source="Graphics2/WorkerHouseBack.png")]
		private var WorkerHouseBack:Class;
		public var workerHouseBack:BitmapData = new WorkerHouseBack().bitmapData;
		
		[Embed(source="Graphics2/newspaper/Newspaper.png")]
		private var Newspaper:Class;
		public var newspaper:BitmapData = new Newspaper().bitmapData;
		
		[Embed(source="Graphics2/newspaper/TitleRus.png")]
		private var TitleRus:Class;
		public var titleRus:BitmapData = new TitleRus().bitmapData;
		
		[Embed(source="Graphics2/newspaper/TitleEng.png")]
		private var TitleEng:Class;
		public var titleEng:BitmapData = new TitleEng().bitmapData;
		
		[Embed(source="Graphics2/newspaper/TitleGer.png")]
		private var TitleGer:Class;
		public var titleGer:BitmapData = new TitleGer().bitmapData;
		
		[Embed(source="Graphics2/BackBigTurtle.png")]
		private var BackBigTurtle:Class;
		public var backBigTurtle:BitmapData = new BackBigTurtle().bitmapData;
		
		[Embed(source="Graphics2/Loading.png")]
		private var Loading:Class;
		public var loading:BitmapData = new Loading().bitmapData;
		
		[Embed(source="Graphics2/SearchFieldEmpty.png")]
		private var SearchFieldEmpty:Class;
		public var searchFieldEmpty:BitmapData = new SearchFieldEmpty().bitmapData;
		
		[Embed(source="Graphics2/InfoBttnPink.png")]
		private var InfoBttnPink:Class;
		public var infoBttnPink:BitmapData = new InfoBttnPink().bitmapData;
		
		[Embed(source="Graphics2/InfoBigIcon.png")]
		private var InfoBigIcon:Class;
		public var infoBigIcon:BitmapData = new InfoBigIcon().bitmapData;
		
		[Embed(source="Graphics2/PestNew.png")]
		private var PestNew:Class;
		public var pestNew:BitmapData = new PestNew().bitmapData;
		
		[Embed(source="Graphics2/hints/OctopusWife.png")]
		private var OctopusWife:Class;
		public var octopusWife:BitmapData = new OctopusWife().bitmapData;
		
		[Embed(source="Graphics2/hints/PaintImage.png")]
		private var PaintImage:Class;
		public var paintImage:BitmapData = new PaintImage().bitmapData;
		
		[Embed(source="Graphics2/hints/GirlClothes.png")]
		private var GirlClothes:Class;
		public var girlClothes:BitmapData = new GirlClothes().bitmapData;
		
		[Embed(source="Graphics2/hints/SickCancer.png")]
		private var SickCancer:Class;
		public var sickCancer:BitmapData = new SickCancer().bitmapData;
		
		[Embed(source="Graphics2/hints/OctupusFriends.png")]
		private var OctupusFriends:Class;
		public var octupusFriends:BitmapData = new OctupusFriends().bitmapData;

		[Embed(source="Graphics2/hints/FatSnale.png")]
		private var FatSnale:Class;
		public var fatSnale:BitmapData = new FatSnale().bitmapData;
		
		[Embed(source="Graphics2/hints/OctopusFlower.png")]
		private var OctopusFlower:Class;
		public var octopusFlower:BitmapData = new OctopusFlower().bitmapData;
		
		[Embed(source="Graphics2/SuchOk.png")]
		private var SuchOk:Class;
		public var suchOk:BitmapData = new SuchOk().bitmapData;
		
		[Embed(source="Graphics2/OctupusHand.png")]
		private var OctupusHand:Class;
		public var octupusHand:BitmapData = new OctupusHand().bitmapData;
		
		[Embed(source="Graphics2/ButtonList.png")]
		private var ButtonList:Class;
		public var buttonList:BitmapData = new ButtonList().bitmapData;
		
		[Embed(source="Graphics2/OctupusCup.png")]
		private var OctupusCup:Class;
		public var octupusCup:BitmapData = new OctupusCup().bitmapData;
		
		[Embed(source="Graphics2/OctupusFull.png")]
		private var OctupusFull:Class;
		public var octupusFull:BitmapData = new OctupusFull().bitmapData;
		
		[Embed(source="Graphics2/BubbleGroup.png")]
		private var BubbleGroup:Class;
		public var bubbleGroup:BitmapData = new BubbleGroup().bitmapData;
		
		[Embed(source="Graphics2/PlantBar.png")]
		private var PlantBar:Class;
		public var plantBar:BitmapData = new PlantBar().bitmapData;		
		
		[Embed(source="Graphics2/BubbleBackingBig.png")]
		private var BubbleBackingBig:Class;
		public var bubbleBackingBig:BitmapData = new BubbleBackingBig().bitmapData;
		
		[Embed(source="Graphics2/BoxTreasure.png")]
		private var BoxTreasure:Class;
		public var boxTreasure:BitmapData = new BoxTreasure().bitmapData;
		
		[Embed(source="Graphics2/ActionRibbonBg.png")]
		private var ActionRibbonBg:Class;
		public var actionRibbonBg:BitmapData = new ActionRibbonBg().bitmapData;
		
		[Embed(source="Graphics2/ActionItemBg.png")]
		private var ActionItemBg:Class;
		public var actionItemBg:BitmapData = new ActionItemBg().bitmapData;
		
		[Embed(source="Graphics2/NewsWindow/BubbleRT.png")]
		private var BubbleRT:Class;
		public var bubbleRT:BitmapData = new BubbleRT().bitmapData;	
		
		[Embed(source="Graphics2/NewsWindow/SeawheatLB.png")]
		private var SeawheatLB:Class;
		public var seawheatLB:BitmapData = new SeawheatLB().bitmapData;
		
		[Embed(source="Graphics2/NewsWindow/SeawheatRB.png")]
		private var SeawheatRB:Class;
		public var seawheatRB:BitmapData = new SeawheatRB().bitmapData;
		
		[Embed(source="Graphics2/NewsWindow/SnailLB.png")]
		private var SnailLB:Class;
		public var snailLB:BitmapData = new SnailLB().bitmapData;
		
		[Embed(source="Graphics2/NewsWindow/SnailLT.png")]
		private var SnailLT:Class;
		public var snailLT:BitmapData = new SnailLT().bitmapData;
		
		[Embed(source="Graphics2/NewsWindow/SnailRB.png")]
		private var SnailRB:Class;
		public var snailRB:BitmapData = new SnailRB().bitmapData;
		
		[Embed(source="Graphics2/HappyBgBottom.png")]
		private var HappyBgBottom:Class;
		public var happyBgBottom:BitmapData = new HappyBgBottom().bitmapData;
		
		[Embed(source="Graphics2/HappyBgTop.png")]
		private var HappyBgTop:Class;
		public var happyBgTop:BitmapData = new HappyBgTop().bitmapData;
		
		[Embed(source="Graphics2/BestPrice.png")]
		private var BestPrice:Class;
		public var bestPrice:BitmapData = new BestPrice().bitmapData;
		
		[Embed(source="Graphics2/BestPriceEN.png")]
		private var BestPriceEN:Class;
		public var bestPriceEN:BitmapData = new BestPriceEN().bitmapData;
		
		[Embed(source="Graphics2/BestChoice.png")]
		private var BestChoice:Class;
		public var bestChoice:BitmapData = new BestChoice().bitmapData;
		
		[Embed(source="Graphics2/BestChoiceEN.png")]
		private var BestChoiceEN:Class;
		public var bestChoiceEN:BitmapData = new BestChoiceEN().bitmapData;
		
		[Embed(source="Graphics2/RedLines.png")]
		private var RedLines:Class;
		public var redLines:BitmapData = new RedLines().bitmapData;
		
		[Embed(source="Graphics2/Pergament.png")]
		private var Pergament:Class;
		public var pergament:BitmapData = new Pergament().bitmapData;
		
		[Embed(source="Graphics2/wheel_new.png")]
		private var Wheel_new:Class;
		public var wheel_new:BitmapData = new Wheel_new().bitmapData;	
		
		[Embed(source="Graphics2/WheelBG.png")]
		private var WheelBG:Class;
		public var wheelBG:BitmapData = new WheelBG().bitmapData;
		
		[Embed(source="Graphics2/RouletteArrow.png")]
		private var RouletteArrow:Class;
		public var rouletteArrow:BitmapData = new RouletteArrow().bitmapData;
		
		[Embed(source="Graphics2/TicketLotto.png")]
		private var TicketLotto:Class;
		public var ticketLotto:BitmapData = new TicketLotto().bitmapData;
		
		[Embed(source="Graphics2/FlowerHouse.png")]
		private var FlowerHouse:Class;
		public var flowerHouse:BitmapData = new FlowerHouse().bitmapData;
		
		[Embed(source="Graphics2/CrabenChest.png")]
		private var CrabenChest:Class;
		public var crabenChest:BitmapData = new CrabenChest().bitmapData;
		
		[Embed(source="Graphics2/RouletteCenter.png")]
		private var RouletteCenter:Class;
		public var rouletteCenter:BitmapData = new RouletteCenter().bitmapData;
		
		[Embed(source="Graphics2/CrabPearl.png")]
		private var CrabPearl:Class;
		public var crabPearl:BitmapData = new CrabPearl().bitmapData;
		
		[Embed(source="Graphics2/JaneInvite.png")]
		private var JaneInvite:Class;
		public var janeInvite:BitmapData = new JaneInvite().bitmapData;
	
		[Embed(source="Graphics2/SharkWindow.png")]
		private var SharkWindow:Class;
		public var sharkWindow:BitmapData = new SharkWindow().bitmapData;
		
		[Embed(source="Graphics2/QuestsManagerBackingTop.png")]
		private var QuestsManagerBackingTop:Class;
		public var questsManagerBackingTop:BitmapData = new QuestsManagerBackingTop().bitmapData;
		
		[Embed(source="Graphics2/QuestsManagerBackingBot.png")]
		private var QuestsManagerBackingBot:Class;
		public var questsManagerBackingBot:BitmapData = new QuestsManagerBackingBot().bitmapData;
	
		[Embed(source="Graphics2/Paper/parerBackingBig.png")]
		private var ParerBackingBig:Class;
		public var parerBackingBig:BitmapData = new ParerBackingBig().bitmapData;
		
		[Embed(source="Graphics2/Backings/ComfortBacking.png")]
		private var ComfortBacking:Class;
		public var comfortBacking:BitmapData = new ComfortBacking().bitmapData;
		
		[Embed(source="Graphics2/bubbleBarter.png")]
		private var BubbleBarter:Class;
		public var bubbleBarter:BitmapData = new BubbleBarter().bitmapData;
		
		[Embed(source="Graphics2/ClockIcon.png")]
		private var ClockIcon:Class;
		public var clockIcon:BitmapData = new ClockIcon().bitmapData;
		
		[Embed(source="Graphics2/BlueStripe.png")]
		private var BlueStripe:Class;
		public var blueStripe:BitmapData = new BlueStripe().bitmapData;
		
		[Embed(source="Graphics2/FishDual.png")]
		private var FishDual:Class;
		public var fishDual:BitmapData = new FishDual().bitmapData;
		
		[Embed(source="Graphics2/BackingPicture.png")]
		private var BackingPicture:Class;
		public var backingPicture:BitmapData = new BackingPicture().bitmapData;
	
		
		[Embed(source="Graphics2/FbIcon.png")]
		private var FbIcon:Class;
		public var fbIcon:BitmapData = new FbIcon().bitmapData;
		
		
		[Embed(source="Graphics2/backgroundJoiningGroup.png")]
		private var BackgroundJoiningGroup:Class;
		public var backgroundJoiningGroup:BitmapData = new BackgroundJoiningGroup().bitmapData;
		
		
		[Embed(source="Graphics2/giftBox.png")]
		private var GiftBox:Class;
		public var giftBox:BitmapData = new GiftBox().bitmapData;
	
		[Embed(source="Graphics2/BankRibbon.png")]
		private var BankRibbon:Class;
		public var bankRibbon:BitmapData = new BankRibbon().bitmapData;
	
		[Embed(source="Graphics2/HippodromBacking.png")]
		private var HippodromBacking:Class;
		public var hippodromBacking:BitmapData = new HippodromBacking().bitmapData;
	
		[Embed(source="Graphics2/HippodromImage.png")]
		private var HippodromImage:Class;
		public var hippodromImage:BitmapData = new HippodromImage().bitmapData;
	
		[Embed(source="Graphics2/HorsePicture.png")]
		private var HorsePicture:Class;
		public var horsePicture:BitmapData = new HorsePicture().bitmapData;
	
		[Embed(source="Graphics2/CupGlow.png")]
		private var CupGlow:Class;
		public var cupGlow:BitmapData = new CupGlow().bitmapData;
	
		[Embed(source="Graphics2/EnergyImage.png")]
		private var EnergyImage:Class;
		public var energyImage:BitmapData = new EnergyImage().bitmapData;
	
		public function Windows():void
		{
			
		}
	}
}