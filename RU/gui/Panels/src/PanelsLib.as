package 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Security;
	

	public class PanelsLib extends Sprite 
	{		
		Security.allowDomain("*");
		Security.allowInsecureDomain("*");	
		
		//deep
		
		[Embed(source="Deep/glassMain.png")]
		private var GlassMain:Class;
		public var glassMain:BitmapData = new GlassMain().bitmapData;
		
		[Embed(source="Deep/MainFriendsPanelBG_2.png")]
		private var MainFriendsPanelBG_2:Class;
		public var mainFriendsPanelBG_2:BitmapData = new MainFriendsPanelBG_2().bitmapData;
		
		[Embed(source="Deep/MainLeftPanelBG_2.png")]
		private var MainLeftPanelBG_2:Class;
		public var mainLeftPanelBG_2:BitmapData = new MainLeftPanelBG_2().bitmapData;
		
		[Embed(source="Deep/MainRaightPanelBG_2.png")]
		private var MainRaightPanelBG_2:Class;
		public var mainRightPanelBG_2:BitmapData = new MainRaightPanelBG_2().bitmapData;
		
		[Embed(source = "Graphics/icons/StockIcon.png")]
		private var StockIcon:Class;
		public var stockIcon:BitmapData = new StockIcon().bitmapData;
		
		[Embed(source = "Graphics/icons/ShopIcon.png")]
		private var ShopIcon:Class;
		public var shopIcon:BitmapData = new ShopIcon().bitmapData;
		
		[Embed(source = "Graphics/icons/CollectionsIcon.png")]
		private var CollectionsIcon:Class;
		public var collectionsIcon:BitmapData = new CollectionsIcon().bitmapData;
		
		[Embed(source = "Graphics/icons/GiftsIcon.png")]
		private var GiftsIcon:Class;
		public var giftsIcon:BitmapData = new GiftsIcon().bitmapData;

		[Embed(source="Graphics/icons/mapIcon.png")]
		private var MapIcon:Class;
		public var mapIcon:BitmapData = new MapIcon().bitmapData;
		
		[Embed(source="Graphics/icons/PrixIcon.png")]
		private var PrixIcon:Class;
		public var prixIcon:BitmapData = new PrixIcon().bitmapData;
		
		[Embed(source="Graphics2/Bottom_right_back.png")]
		private var Bottom_right_back:Class;
		public var bottom_right_back:BitmapData = new Bottom_right_back().bitmapData;
		
		[Embed(source="Graphics2/Bottom_left_back.png")]
		private var Bottom_left_back:Class;
		public var bottom_left_back:BitmapData = new Bottom_left_back().bitmapData;
		
		[Embed(source="Graphics2/Crab.png")]
		private var Crab:Class;
		public var crab:BitmapData = new Crab().bitmapData;
		
		[Embed(source="Graphics2/Bottom_left_back_guest_seaweed.png")]
		private var Bottom_left_back_guest_seaweed:Class;
		public var bottom_left_back_guest_seaweed:BitmapData = new Bottom_left_back_guest_seaweed().bitmapData;
		
		[Embed(source="Graphics2/Bottom_right_back_guest.png")]
		private var Bottom_right_back_guest:Class;
		public var bottom_right_back_guest:BitmapData = new Bottom_right_back_guest().bitmapData;
		
		[Embed(source="Graphics2/Guest_home_button.png")]
		private var Guest_home_button:Class;
		public var guest_home_button:BitmapData = new Guest_home_button().bitmapData;
		
		[Embed(source="Graphics2/StopBttnGuestIco.png")]
		private var StopBttnGuestIco:Class;
		public var stopBttnGuestIco:BitmapData = new StopBttnGuestIco().bitmapData;
		
		[Embed(source="Graphics2/InterRoundBttn.png")]
		private var InterRoundBttn:Class;
		public var interRoundBttn:BitmapData = new InterRoundBttn().bitmapData;
		
		[Embed(source="Graphics2/CaveIcon.png")]
		private var CaveIcon:Class;
		public var caveIcon:BitmapData = new CaveIcon().bitmapData;
		
		[Embed(source="Graphics2/ChatIcon.png")]
		private var ChatIcon:Class;
		public var chatIcon:BitmapData = new ChatIcon().bitmapData;
		
		[Embed(source="Graphics2/RadarBacking.png")]
		private var RadarBacking:Class;
		public var radarBacking:BitmapData = new RadarBacking().bitmapData;
		
		[Embed(source="Graphics2/BackpackBttnIco.png")]
		private var BackpackBttnIco:Class;
		public var backpackBttnIco:BitmapData = new BackpackBttnIco().bitmapData;
		
		
		//UpPanel
		
		[Embed(source="Graphics2/MoneyPanel.png")]
		private var MoneyPanel:Class;
		public var moneyPanel:BitmapData = new MoneyPanel().bitmapData;
		
		[Embed(source="Graphics2/GoldenPearl.png")]
		private var GoldenPearl:Class;
		public var goldenPearl:BitmapData = new GoldenPearl().bitmapData;
		
		[Embed(source="Graphics2/CoinsPlusBttn.png")]
		private var CoinsPlusBttn:Class;
		public var coinsPlusBttn:BitmapData = new CoinsPlusBttn().bitmapData;
		
		[Embed(source="Graphics2/GreenPlusButton.png")]
		private var GreenPlusButton:Class;
		public var greenPlusButton:BitmapData = new GreenPlusButton().bitmapData;
		
		[Embed(source="Graphics2/BlueCristal.png")]
		private var BlueCristal:Class;
		public var blueCristal:BitmapData = new BlueCristal().bitmapData;
		
		[Embed(source="Graphics2/FantsPlusBttn.png")]
		private var FantsPlusBttn:Class;
		public var fantsPlusBttn:BitmapData = new FantsPlusBttn().bitmapData;
		
		[Embed(source="Graphics2/bubbles.png")]
		private var Bubbles:Class;
		public var bubbles:BitmapData = new Bubbles().bitmapData;
		
		[Embed(source="Graphics2/bubbles2.png")]
		private var Bubbles2:Class;
		public var bubbles2:BitmapData = new Bubbles2().bitmapData;
		
		[Embed(source="Graphics2/ExpPanel.png")]
		private var ExpPanel:Class;
		public var expPanel:BitmapData = new ExpPanel().bitmapData;
			
		[Embed(source="Graphics2/ExpSlider.png")]
		private var ExpSlider:Class;
		public var expSlider:BitmapData = new ExpSlider().bitmapData;		
		
		[Embed(source="Graphics2/ExpIcon.png")]
		private var ExpIcon:Class;
		public var expIcon:BitmapData = new ExpIcon().bitmapData;
		
		[Embed(source="Graphics2/EnergyIcon.png")]
		private var EnergyIcon:Class;
		public var energyIcon:BitmapData = new EnergyIcon().bitmapData;		
		
		[Embed(source="Graphics2/EnergySlider.png")]
		private var EnergySlider:Class;
		public var energySlider:BitmapData = new EnergySlider().bitmapData;		
		
		[Embed(source="Graphics2/HappySlider.png")]
		private var HappySlider:Class;
		public var happySlider:BitmapData = new HappySlider().bitmapData;	
		
		[Embed(source="Graphics2/HappyPanel.png")]
		private var HappyPanel:Class;
		public var happyPanel:BitmapData = new HappyPanel().bitmapData;	
		
		[Embed(source="Graphics2/Tick.png")]
		private var Tick:Class;
		public var tick:BitmapData = new Tick().bitmapData;		
		
		//Курсоры
		
		[Embed(source="Graphics2/StopBttnIco.png")]
		private var StopBttnIco:Class;
		public var stopBttnIco:BitmapData = new StopBttnIco().bitmapData;
		
		//Системные кнопки
		
		[Embed(source="Graphics2/FriendsAddBacking.png")]
		private var FriendsAddBacking:Class;
		public var friendsAddBacking:BitmapData = new FriendsAddBacking().bitmapData;
		
		//-----------------------------------------------------------------
		
		
		[Embed(source="Graphics2/Spark.png")]
		private var Spark:Class;
		public var spark:BitmapData = new Spark().bitmapData;
		
		[Embed(source = "Graphics2/BonusIco.png")]
		private var BonusIco:Class;
		public var bonusIco:BitmapData = new BonusIco().bitmapData;		
		
		[Embed(source = "Graphics2/PinkNewLabel.png")]
		private var PinkNewLabel:Class;
		public var pinkNewLabel:BitmapData = new PinkNewLabel().bitmapData;		
		
		[Embed(source = "Graphics2/InterBankSale.png")]
		private var InterBankSale:Class;
		public var interBankSale:BitmapData = new InterBankSale().bitmapData;		
		
		[Embed(source = "Graphics/CoinsPlusBttn2.png")]
		private var CoinsPlusBttn2:Class;
		public var coinsPlusBttn2:BitmapData = new CoinsPlusBttn2().bitmapData;
		
		[Embed(source = "Graphics/CoinsMinusBttn.png")]
		private var CoinsMinusBttn:Class;
		public var coinsMinusBttn:BitmapData = new CoinsMinusBttn().bitmapData;		
		
		[Embed(source="Graphics2/FrSlot.png")]
		private var FrSlot:Class;
		public var frSlot:BitmapData = new FrSlot().bitmapData;
		
		[Embed(source="Graphics/cursors/CursorLocked.png")]
		private var CursorLocked:Class;
		public var cursorLocked:BitmapData = new CursorLocked().bitmapData;
		
		[Embed(source="Graphics/cursors/CursorFertilizer.png")]
		private var CursorFertilizer:Class;
		public var cursorFertilizer:BitmapData = new CursorFertilizer().bitmapData;		
		
		//Курсоры
		
		[Embed(source = "Graphics/cursors/IconCursorMain.png")]
		private var IconCursorMain:Class;
		public var iconCursorMain:BitmapData = new IconCursorMain().bitmapData;
		
		[Embed(source="Graphics/cursors/IconCursorMove.png")]
		private var IconCursorMove:Class;
		public var iconCursorMove:BitmapData = new IconCursorMove().bitmapData;
		
		[Embed(source = "Graphics/cursors/IconCursorRemove.png")]
		private var IconCursorRemove:Class;
		public var iconCursorRemove:BitmapData = new IconCursorRemove().bitmapData;
		
		[Embed(source = "Graphics/cursors/IconCursorStock.png")]
		private var IconCursorStock:Class;
		public var iconCursorStock:BitmapData = new IconCursorStock().bitmapData;
		
		[Embed(source = "Graphics/cursors/IconCursorRotate.png")]
		private var IconCursorRotate:Class;
		public var iconCursorRotate:BitmapData = new IconCursorRotate().bitmapData;
		
		[Embed(source="Graphics/cursors/CursorMove.png")]
		private var CursorMove:Class;
		public var cursorMove:BitmapData = new CursorMove().bitmapData;
		
		[Embed(source="Graphics/cursors/CursorRemove.png")]
		private var CursorRemove:Class;
		public var cursorRemove:BitmapData = new CursorRemove().bitmapData;
		
		[Embed(source="Graphics/cursors/CursorStock.png")]
		private var CursorStock:Class;
		public var cursorStock:BitmapData = new CursorStock().bitmapData;
		
		[Embed(source="Graphics/cursors/CursorDefault.png")]
		private var CursorDefault:Class;
		public var cursorDefault:BitmapData = new CursorDefault().bitmapData;
		
		[Embed(source="Graphics/cursors/CursorRotate.png")]
		private var CursorRotate:Class;
		public var cursorRotate:BitmapData = new CursorRotate().bitmapData;
	
		[Embed(source="Graphics/cursors/CursorTake.png")]
		private var CursorTake:Class;
		public var cursorTake:BitmapData = new CursorTake().bitmapData;	
		
		[Embed(source = "Graphics/Legs.png")]
		private var Legs:Class;
		public var legs:BitmapData = new Legs().bitmapData;
		
		[Embed(source = "Graphics/Arrow.png")]
		private var Arrow:Class;
		public var arrow:BitmapData = new Arrow().bitmapData;
		
		[Embed(source="Graphics/CoinsMinusBttn10.png")]
		private var CoinsMinusBttn10:Class;
		public var coinsMinusBttn10:BitmapData = new CoinsMinusBttn10().bitmapData;	
		
		[Embed(source="Graphics/CoinsPlusBttn10.png")]
		private var CoinsPlusBttn10:Class;
		public var coinsPlusBttn10:BitmapData = new CoinsPlusBttn10().bitmapData;	
		
		[Embed(source = "Graphics/InterSleepIco.png")]
		private var InterSleepIco:Class;
		public var interSleepIco:BitmapData = new InterSleepIco().bitmapData;
		
		[Embed(source = "Graphics/LabelLeft.png")]
		private var LabelLeft:Class;
		public var labelLeft:BitmapData = new LabelLeft().bitmapData;
		
		[Embed(source = "Graphics/LabelBD1.png")]
		private var LabelBD1:Class;
		public var labelBD1:BitmapData = new LabelBD1().bitmapData;
		
		[Embed(source = "Graphics/LabelUC1.png")]
		private var LabelUC1:Class;
		public var labelUC1:BitmapData = new LabelUC1().bitmapData;
		
		[Embed(source = "Graphics/LabelBDEng.png")]
		private var LabelBDEng:Class;
		public var labelBDEng:BitmapData = new LabelBDEng().bitmapData;
		
		[Embed(source = "Graphics/LabelUCEng.png")]
		private var LabelUCEng:Class;
		public var labelUCEng:BitmapData = new LabelUCEng().bitmapData;
		
		[Embed(source = "Graphics/LabelBDJap.png")]
		private var LabelBDJap:Class;
		public var labelBDJap:BitmapData = new LabelBDJap().bitmapData;
		
		[Embed(source = "Graphics/LabelUCJap.png")]
		private var LabelUCJap:Class;
		public var labelUCJap:BitmapData = new LabelUCJap().bitmapData;
		
		[Embed(source = "Graphics/LabelBDPol.png")]
		private var LabelBDPol:Class;
		public var labelBDPol:BitmapData = new LabelBDPol().bitmapData;
		
		[Embed(source = "Graphics/LabelUCPol.png")]
		private var LabelUCPol:Class;
		public var labelUCPol:BitmapData = new LabelUCPol().bitmapData;
		
		[Embed(source="Graphics/Attantion.png")]
		private var Attantion:Class;
		public var attantion:BitmapData = new Attantion().bitmapData;
		
		[Embed(source="Graphics/ProgressYellowArrow.png")]
		private var ProgressYellowArrow:Class;
		public var progressYellowArrow:BitmapData = new ProgressYellowArrow().bitmapData;
		
		/*[Embed(source="Graphics/Territory.png")]
		private var Territory:Class;
		public var territory:BitmapData = new Territory().bitmapData;*/
		
		[Embed(source="Graphics/ProgressArrow.png")]
		private var ProgressArrow:Class;
		public var progressArrow:BitmapData = new ProgressArrow().bitmapData;
		
		[Embed(source="Graphics2/friendspanel/FriendsBacking.png")]
		private var FriendsBacking:Class;
		public var friendsBacking:BitmapData = new FriendsBacking().bitmapData;
		
		[Embed(source="Graphics2/friendspanel/FriendsBttnOne.png")]
		private var FriendsBttnOne:Class;
		public var friendsBttnOne:BitmapData = new FriendsBttnOne().bitmapData;
		
		[Embed(source = "Graphics2/friendspanel/FriendsBttnFew.png")]
		private var FriendsBttnFew:Class;
		public var friendsBttnFew:BitmapData = new FriendsBttnFew().bitmapData;
		
		[Embed(source = "Graphics2/friendspanel/FavoriteIconEnable.png")]
		private var FavoriteIconEnable:Class;
		public var favoriteIconEnable:BitmapData = new FavoriteIconEnable().bitmapData;
		
		[Embed(source = "Graphics2/friendspanel/FavoriteIconDisable.png")]
		private var FavoriteIconDisable:Class;
		public var favoriteIconDisable:BitmapData = new FavoriteIconDisable().bitmapData;
		
		[Embed(source="Graphics2/MainBttnBacking.png")]
		private var MainBttnBacking:Class;
		public var mainBttnBacking:BitmapData = new MainBttnBacking().bitmapData;
		
		[Embed(source="Graphics2/friendspanel/SearchBttn.png")]
		private var SearchBttn:Class;
		public var searchBttn:BitmapData = new SearchBttn().bitmapData;
		
		[Embed(source="Graphics2/AchieveEmptyStar.png")]
		private var AchieveEmptyStar:Class;
		public var achieveEmptyStar:BitmapData = new AchieveEmptyStar().bitmapData;
		
		[Embed(source="Graphics2/envelope.png")]
		private var Envelope:Class;
		public var envelope:BitmapData = new Envelope().bitmapData;
		
		[Embed(source="Graphics2/CalendarIcoNew.png")]
		private var CalendarIcoNew:Class;
		public var calendarIcoNew:BitmapData = new CalendarIcoNew().bitmapData;
		
		[Embed(source="Graphics2/EnergyPlusBttn.png")]
		private var EnergyPlusBttn:Class;
		public var energyPlusBttn:BitmapData = new EnergyPlusBttn().bitmapData;
		
		[Embed(source="Graphics2/EnergySlider2.png")]
		private var EnergySlider2:Class;
		public var energySlider2:BitmapData = new EnergySlider2().bitmapData;
		
		[Embed(source = "Graphics2/GuestAction.png")]
		private var GuestAction:Class;
		public var guestAction:BitmapData = new GuestAction().bitmapData;
		
		[Embed(source = "Graphics2/GuestActionGold.png")]
		private var GuestActionGold:Class;
		public var guestActionGold:BitmapData = new GuestActionGold().bitmapData;
	
		[Embed(source="Graphics2/ExpIco.png")]
		private var ExpIco:Class;
		public var expIco:BitmapData = new ExpIco().bitmapData;
	
		[Embed(source="Graphics2/friendspanel/StopIcon.png")]
		private var StopIcon:Class;
		public var stopIcon:BitmapData = new StopIcon().bitmapData;
		
		[Embed(source="Graphics2/friendspanel/StopIconNew.png")]
		private var StopIconNew:Class;
		public var stopIconNew:BitmapData = new StopIconNew().bitmapData;
		//Системные кнопки
		
		[Embed(source="Graphics2/menuPanel/SystemSound.png")]
		private var SystemSound:Class;
		public var systemSound:BitmapData = new SystemSound().bitmapData;
		
		[Embed(source="Graphics2/menuPanel/SystemFullscreen.png")]
		private var SystemFullscreen:Class;
		public var systemFullscreen:BitmapData = new SystemFullscreen().bitmapData;
		
		[Embed(source="Graphics2/menuPanel/UnloadIcon.png")]
		private var UnloadIcon:Class;
		public var unloadIcon:BitmapData = new UnloadIcon().bitmapData;
		
		[Embed(source="Graphics2/menuPanel/SystemPlus.png")]
		private var SystemPlus:Class;
		public var systemPlus:BitmapData = new SystemPlus().bitmapData;
		
		[Embed(source="Graphics2/menuPanel/SystemScreenshot.png")]
		private var SystemScreenshot:Class;
		public var systemScreenshot:BitmapData = new SystemScreenshot().bitmapData;
		
		[Embed(source="Graphics2/HelpBttnAttention.png")]
		private var HelpBttnAttention:Class;
		public var helpBttnAttention:BitmapData = new HelpBttnAttention().bitmapData;
		
		[Embed(source="Graphics2/male.png")]
		private var Male:Class;
		public var male:BitmapData = new Male().bitmapData;
		
		[Embed(source="Graphics2/female.png")]
		private var Female:Class;
		public var female:BitmapData = new Female().bitmapData;
		
		[Embed(source="Graphics2/menuPanel/SystemMinus.png")]
		private var SystemMinus:Class;
		public var systemMinus:BitmapData = new SystemMinus().bitmapData;
		
		[Embed(source="Graphics2/menuPanel/SettingsMusic.png")]
		private var SettingsMusic:Class;
		public var settingsMusic:BitmapData = new SettingsMusic().bitmapData;
		
		[Embed(source="Graphics2/menuPanel/SystemArrow.png")]
		private var SystemArrow:Class;
		public var systemArrow:BitmapData = new SystemArrow().bitmapData;
		
		[Embed(source="Graphics2/menuPanel/SystemBackground.png")]
		private var SystemBackground:Class;
		public var systemBackground:BitmapData = new SystemBackground().bitmapData;
		
		[Embed(source="Graphics2/menuPanel/SystemAnimate.png")]
		private var SystemAnimate:Class;
		public var systemAnimate:BitmapData = new SystemAnimate().bitmapData;
		
		[Embed(source="Graphics2/ProgressBar.png")]
		private var ProgressBar:Class;
		public var progressBar:BitmapData = new ProgressBar().bitmapData;
		
		[Embed(source="Graphics2/ProgressSlider.png")]
		private var ProgressSlider:Class;
		public var progressSlider:BitmapData = new ProgressSlider().bitmapData;
		
		[Embed(source="Graphics/Shadow.png")]
		private var Shadow:Class;
		public var shadow:BitmapData = new Shadow().bitmapData;
		
		[Embed(source="Graphics2/SimpleCounterRed.png")]
		private var SimpleCounterRed:Class;
		public var simpleCounterRed:BitmapData = new SimpleCounterRed().bitmapData;
		
		[Embed(source="Graphics2/SimpleCounterBlue.png")]
		private var SimpleCounterBlue:Class;
		public var simpleCounterBlue:BitmapData = new SimpleCounterBlue().bitmapData;
		
		[Embed(source="Graphics2/SimpleCounterYellow.png")]
		private var SimpleCounterYellow:Class;
		public var simpleCounterYellow:BitmapData = new SimpleCounterYellow().bitmapData;
		
		[Embed(source="Graphics2/EnergyIconSmall.png")]
		private var EnergyIconSmall:Class;
		public var energyIconSmall:BitmapData = new EnergyIconSmall().bitmapData;
	
		[Embed(source="Graphics2/Exp2.png")]
		private var Exp2:Class;
		public var exp2:BitmapData = new Exp2().bitmapData;
		
		[Embed(source="Graphics2/Exp4.png")]
		private var Exp4:Class;
		public var exp4:BitmapData = new Exp4().bitmapData;
		
		[Embed(source="Graphics2/friendspanel/SearchBackingLongInt.png")]
		private var SearchBackingLongInt:Class;
		public var searchBackingLongInt:BitmapData = new SearchBackingLongInt().bitmapData;
		
		[Embed(source="Graphics2/SaleBacking1.png")]
		private var SaleBacking1:Class;
		public var saleBacking1:BitmapData = new SaleBacking1().bitmapData;
		
		[Embed(source="Graphics2/SaleBacking2.png")]
		private var SaleBacking2:Class;
		public var saleBacking2:BitmapData = new SaleBacking2().bitmapData;
		
		[Embed(source="Graphics2/SaleBacking3.png")]
		private var SaleBacking3:Class;
		public var saleBacking3:BitmapData = new SaleBacking3().bitmapData;
		
		[Embed(source="Graphics2/SalesBackGlow.png")]
		private var SalesBackGlow:Class;
		public var salesBackGlow:BitmapData = new SalesBackGlow().bitmapData;
		
		[Embed(source="Graphics2/Dinamite.png")]
		private var Dinamite:Class;
		public var dinamite:BitmapData = new Dinamite().bitmapData;
	
		[Embed(source="Graphics2/NewQuestIco.png")]
		private var NewQuestIco:Class;
		public var newQuestIco:BitmapData = new NewQuestIco().bitmapData;
		
		[Embed(source="Graphics2/OpenTerIcon.png")]
		private var OpenTerIcon:Class;
		public var openTerIcon:BitmapData = new OpenTerIcon().bitmapData;
	
		[Embed(source="Graphics2/HomeBttnIco.png")]
		private var HomeBttnIco:Class;
		public var homeBttnIco:BitmapData = new HomeBttnIco().bitmapData;
		
		[Embed(source="Graphics2/valentineIco.png")]
		private var ValentineIco:Class;
		public var valentineIco:BitmapData = new ValentineIco().bitmapData;
		
		[Embed(source="Graphics2/friendIcoBacking.png")]
		private var FriendIcoBacking:Class;
		public var friendIcoBacking:BitmapData = new FriendIcoBacking().bitmapData;
		
		[Embed(source = "Graphics2/WhishlistPlusBttn.png")]
		private var WhishlistPlusBttn:Class;
		public var whishlistPlusBttn:BitmapData = new WhishlistPlusBttn().bitmapData;
		
		[Embed(source = "Graphics2/chair_green.png")]
		private var Chair_green:Class;
		public var chair_green:BitmapData = new Chair_green().bitmapData;
		
		[Embed(source = "Graphics2/basketIcon.png")]
		private var BasketIcon:Class;
		public var basketIcon:BitmapData = new BasketIcon().bitmapData;
		
		[Embed(source = "Graphics2/Smile.png")]
		private var Smile:Class;
		public var smile:BitmapData = new Smile().bitmapData;
		
		[Embed(source = "Graphics2/SmallCoinIconPl.png")]
		private var SmallCoinIconPl:Class;
		public var smallCoinIconPl:BitmapData = new SmallCoinIconPl().bitmapData;
		
		[Embed(source = "Graphics2/SmallEnergyIconPl.png")]
		private var SmallEnergyIconPl:Class;
		public var smallEnergyIconPl:BitmapData = new SmallEnergyIconPl().bitmapData; 
		
		[Embed(source = "Graphics2/Backpack.png")]
		private var Backpack:Class;
		public var backpack:BitmapData = new Backpack().bitmapData;
		
		[Embed(source = "Graphics2/TimerQuest.png")]
		private var TimerQuest:Class;
		public var timerQuest:BitmapData = new TimerQuest().bitmapData;
		
		[Embed(source = "Graphics2/TravelBg.png")]
		private var TravelBg:Class;
		public var travelBg:BitmapData = new TravelBg().bitmapData; 
		
		[Embed(source = "Graphics2/TargetBoy.png")]
		private var TargetBoy:Class;
		public var targetBoy:BitmapData = new TargetBoy().bitmapData; 
		
		[Embed(source = "Graphics2/TargetGirl.png")]
		private var TargetGirl:Class;
		public var targetGirl:BitmapData = new TargetGirl().bitmapData; 
		
		[Embed(source = "Graphics2/Ministock.png")]
		private var Ministock:Class;
		public var ministock:BitmapData = new Ministock().bitmapData;
		
		[Embed(source = "Graphics2/TimerTravelIcon.png")]
		private var TimerTravelIcon:Class;
		public var timerTravelIcon:BitmapData = new TimerTravelIcon().bitmapData; 
		
		[Embed(source = "Graphics2/AuctionIcon.png")]
		private var AuctionIcon:Class;
		public var auctionIcon:BitmapData = new AuctionIcon().bitmapData; 
		
		[Embed(source = "Graphics2/SettingsIcon.png")]
		private var SettingsIcon:Class;
		public var settingsIcon:BitmapData = new SettingsIcon().bitmapData; 
		
		[Embed(source = "Graphics2/favorite/AddFav.png")]
		private var AddFav:Class;
		public var addFav:BitmapData = new AddFav().bitmapData; 
		
		[Embed(source = "Graphics2/favorite/OffFav.png")]
		private var OffFav:Class;
		public var offFav:BitmapData = new OffFav().bitmapData; 
		
		[Embed(source = "Graphics2/favorite/OnFav.png")]
		private var OnFav:Class;
		public var onFav:BitmapData = new OnFav().bitmapData; 
		
		[Embed(source = "Graphics2/favorite/RemoveFav.png")]
		private var RemoveFav:Class;
		public var removeFav:BitmapData = new RemoveFav().bitmapData; 
		
		
		public function PanelsLib():void 
		{
		
		}
	}
}