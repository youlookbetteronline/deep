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
		
		[Embed(source = "Graphics2/Honeycomb.png")]
		private var Honeycomb:Class;
		public var honeycomb:BitmapData = new Honeycomb().bitmapData;		
		
		[Embed(source = "Graphics2/Community.png")]
		private var Community:Class;
		public var community:BitmapData = new Community().bitmapData;
		
		[Embed(source = "Graphics2/HandIco.png")]
		private var HandIco:Class;
		public var handIco:BitmapData = new HandIco().bitmapData;	
		
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
		
		[Embed(source = "Graphics2/AmuletFullSmall.png")]
		private var AmuletFullSmall:Class;
		public var amuletFullSmall:BitmapData = new AmuletFullSmall().bitmapData;		
		
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
		
		[Embed(source="Graphics/cursors/CursorWoodCollect.png")]
		private var CursorWoodCollect:Class;
		public var cursorWoodCollect:BitmapData = new CursorWoodCollect().bitmapData;
		
		[Embed(source="Graphics/cursors/CursorBuildingIn.png")]
		private var CursorBuildingIn:Class;
		public var cursorBuildingIn:BitmapData = new CursorBuildingIn().bitmapData;
		
		[Embed(source="Graphics/cursors/CursorAccelerator.png")]
		private var CursorAccelerator:Class;
		public var cursorAccelerator:BitmapData = new CursorAccelerator().bitmapData;
		
		[Embed(source="Graphics/cursors/CursorStoneCollect.png")]
		private var CursorStoneCollect:Class;
		public var cursorStoneCollect:BitmapData = new CursorStoneCollect().bitmapData;
		
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
		
		[Embed(source="Graphics/units/WaterIcon.png")]
		private var WaterIcon:Class;
		public var waterIcon:BitmapData = new WaterIcon().bitmapData;
		
		[Embed(source = "Graphics/CollectionChest.png")]
		private var CollectionChest:Class;
		public var collectionChest:BitmapData = new CollectionChest().bitmapData;
		
		[Embed(source = "Graphics/CollectionBook.png")]
		private var CollectionBook:Class;
		public var collectionBook:BitmapData = new CollectionBook().bitmapData;
		
		[Embed(source = "Graphics/Clever.png")]
		private var Clever:Class;
		public var clever:BitmapData = new Clever().bitmapData;
		
		[Embed(source = "Graphics2/Gamble/WheelArrow.png")]
		private var WheelArrow:Class;
		public var wheelArrow:BitmapData = new WheelArrow().bitmapData;
		
		[Embed(source = "Graphics2/Gamble/WheelOfFortune.png")]
		private var WheelOfFortune:Class;
		public var wheelOfFortune:BitmapData = new WheelOfFortune().bitmapData;
		
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
		
		[Embed(source = "Graphics/Hole.png")]
		private var Hole:Class;
		public var hole:BitmapData = new Hole().bitmapData;
		
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
		
		[Embed(source="Graphics2/MainBttnBacking.png")]
		private var MainBttnBacking:Class;
		public var mainBttnBacking:BitmapData = new MainBttnBacking().bitmapData;
		
		[Embed(source="Graphics2/friendspanel/SearchBttn.png")]
		private var SearchBttn:Class;
		public var searchBttn:BitmapData = new SearchBttn().bitmapData;
		
		[Embed(source="Graphics2/AchieveEmptyStar.png")]
		private var AchieveEmptyStar:Class;
		public var achieveEmptyStar:BitmapData = new AchieveEmptyStar().bitmapData;
		
		[Embed(source="Graphics2/CoinsIcon.png")]
		private var CoinsIcon:Class;
		public var coinsIcon:BitmapData = new CoinsIcon().bitmapData;
		
		/*[Embed(source="Graphics2/EnergyIcon.png")]
		private var EnergyIcon:Class;
		public var energyIcon:BitmapData = new EnergyIcon().bitmapData;*/
		
		[Embed(source="Graphics2/FantsIcon.png")]
		private var FantsIcon:Class;
		public var fantsIcon:BitmapData = new FantsIcon().bitmapData;
		
		[Embed(source="Graphics2/envelope.png")]
		private var Envelope:Class;
		public var envelope:BitmapData = new Envelope().bitmapData;
		
		[Embed(source="Graphics2/RobotIcon.png")]
		private var RobotIcon:Class;
		public var robotIcon:BitmapData = new RobotIcon().bitmapData;
		
		[Embed(source="Graphics2/RobotIcon2.png")]
		private var RobotIcon2:Class;
		public var robotIcon2:BitmapData = new RobotIcon2().bitmapData;
		
		[Embed(source="Graphics2/RobotIcon3.png")]
		private var RobotIcon3:Class;
		public var robotIcon3:BitmapData = new RobotIcon3().bitmapData;
		
		[Embed(source="Graphics2/InterCalendarIco.png")]
		private var InterCalendarIco:Class;
		public var interCalendarIco:BitmapData = new InterCalendarIco().bitmapData;
		
		[Embed(source="Graphics2/CalendarIcoNew.png")]
		private var CalendarIcoNew:Class;
		public var calendarIcoNew:BitmapData = new CalendarIcoNew().bitmapData;
		
		[Embed(source="Graphics2/RouletteIcon.png")]
		private var RouletteIcon:Class;
		public var rouletteIcon:BitmapData = new RouletteIcon().bitmapData;
		
		[Embed(source="Graphics2/WinterEventInformerIcon.png")]
		private var WinterEventInformerIcon:Class;
		public var winterEventInformerIcon:BitmapData = new WinterEventInformerIcon().bitmapData;
		
		[Embed(source="Graphics2/GiftLuckyBag.png")]
		private var GiftLuckyBag:Class;
		public var giftLuckyBag:BitmapData = new GiftLuckyBag().bitmapData;
		
		/*[Embed(source="Graphics2/CoinsPlusBttn.png")]
		private var CoinsPlusBttn:Class;
		public var coinsPlusBttn:BitmapData = new CoinsPlusBttn().bitmapData;*/
		
		/*[Embed(source="Graphics2/FantsPlusBttn.png")]
		private var FantsPlusBttn:Class;
		public var fantsPlusBttn:BitmapData = new FantsPlusBttn().bitmapData;*/
		
		[Embed(source="Graphics2/EnergyPlusBttn.png")]
		private var EnergyPlusBttn:Class;
		public var energyPlusBttn:BitmapData = new EnergyPlusBttn().bitmapData;
		
		/*[Embed(source="Graphics2/EnergySlider.png")]
		private var EnergySlider:Class;
		public var energySlider:BitmapData = new EnergySlider().bitmapData;*/
		
		[Embed(source="Graphics2/EnergySlider2.png")]
		private var EnergySlider2:Class;
		public var energySlider2:BitmapData = new EnergySlider2().bitmapData;
		
		[Embed(source = "Graphics2/GuestAction.png")]
		private var GuestAction:Class;
		public var guestAction:BitmapData = new GuestAction().bitmapData;
		
		[Embed(source = "Graphics2/GuestActionGold.png")]
		private var GuestActionGold:Class;
		public var guestActionGold:BitmapData = new GuestActionGold().bitmapData;
		
		/*[Embed(source="Graphics2/ExpIcon.png")]
		private var ExpIcon:Class;
		public var expIcon:BitmapData = new ExpIcon().bitmapData;*/
		
		[Embed(source="Graphics2/ExpIco.png")]
		private var ExpIco:Class;
		public var expIco:BitmapData = new ExpIco().bitmapData;
		
		/*[Embed(source="Graphics2/ExpSlider.png")]
		private var ExpSlider:Class;
		public var expSlider:BitmapData = new ExpSlider().bitmapData;*/
		
		[Embed(source="Graphics2/friendspanel/StopIcon.png")]
		private var StopIcon:Class;
		public var stopIcon:BitmapData = new StopIcon().bitmapData;
		
		[Embed(source="Graphics2/friendspanel/StopIconNew.png")]
		private var StopIconNew:Class;
		public var stopIconNew:BitmapData = new StopIconNew().bitmapData;
		//Системные кнопки
		
		[Embed(source="Graphics2/menuPanel/SystemFullscreen.png")]
		private var SystemFullscreen:Class;
		public var systemFullscreen:BitmapData = new SystemFullscreen().bitmapData;
		
		[Embed(source="Graphics2/menuPanel/SystemScreenshot.png")]
		private var SystemScreenshot:Class;
		public var systemScreenshot:BitmapData = new SystemScreenshot().bitmapData;
		
		[Embed(source="Graphics2/menuPanel/SystemSound.png")]
		private var SystemSound:Class;
		public var systemSound:BitmapData = new SystemSound().bitmapData;
		
		[Embed(source="Graphics2/menuPanel/SystemPlus.png")]
		private var SystemPlus:Class;
		public var systemPlus:BitmapData = new SystemPlus().bitmapData;
		
		[Embed(source="Graphics2/menuPanel/SystemDiamond.png")]
		private var SystemDiamond:Class;
		public var systemDiamond:BitmapData = new SystemDiamond().bitmapData;
		
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
		
		/*[Embed(source="Graphics2/BlueCristal.png")]
		private var BlueCristal:Class;
		public var blueCristal:BitmapData = new BlueCristal().bitmapData;*/
		
		[Embed(source="Graphics2/Cookie.png")]
		private var Cookie:Class;
		public var cookie:BitmapData = new Cookie().bitmapData;
		
		[Embed(source="Graphics2/Cookie2.png")]
		private var Cookie2:Class;
		public var cookie2:BitmapData = new Cookie2().bitmapData;
		
		[Embed(source="Graphics2/Cookie3.png")]
		private var Cookie3:Class;
		public var cookie3:BitmapData = new Cookie3().bitmapData;
		
		[Embed(source="Graphics2/Dinamite.png")]
		private var Dinamite:Class;
		public var dinamite:BitmapData = new Dinamite().bitmapData;
		
		[Embed(source="Graphics2/Knife.png")]
		private var Knife:Class;
		public var knife:BitmapData = new Knife().bitmapData;
		
		[Embed(source="Graphics2/BoxWithCandy.png")]
		private var BoxWithCandy:Class;
		public var boxWithCandy:BitmapData = new BoxWithCandy().bitmapData;
		
		[Embed(source="Graphics2/Crystal_bowl.png")]
		private var Crystal_bowl:Class;
		public var crystal_bowl:BitmapData = new Crystal_bowl().bitmapData;
		
		[Embed(source="Graphics2/Light_sphere.png")]
		private var Light_sphere:Class;
		public var lightSphere:BitmapData = new Light_sphere().bitmapData;
		
		[Embed(source="Graphics2/MinePick.png")]
		private var MinePick:Class;
		public var minePick:BitmapData = new MinePick().bitmapData;
		
		[Embed(source="Graphics2/FireKnife.png")]
		private var FireKnife:Class;
		public var fireKnife:BitmapData = new FireKnife().bitmapData;
		
		[Embed(source="Graphics2/UnfreezePotion.png")]
		private var UnfreezePotion:Class;
		public var unfreezePotion:BitmapData = new UnfreezePotion().bitmapData;
		
		[Embed(source="Graphics2/Nitro.png")]
		private var Nitro:Class;
		public var nitro:BitmapData = new Nitro().bitmapData;
		
		[Embed(source="Graphics2/thin_dagger.png")]
		private var ThinDagger:Class;
		public var thinDagger:BitmapData = new ThinDagger().bitmapData;
		
		[Embed(source="Graphics2/axe.png")]
		private var Axe:Class;
		public var axe:BitmapData = new Axe().bitmapData;
		
		[Embed(source="Graphics2/BreadboardKnife.png")]
		private var BreadboardKnife:Class;
		public var breadboardKnife:BitmapData = new BreadboardKnife().bitmapData;
		
		[Embed(source="Graphics2/TentStockExp.png")]
		private var TentStockExp:Class;
		public var tentStockExp:BitmapData = new TentStockExp().bitmapData;
		
		[Embed(source="Graphics2/EnergyPanel.png")]
		private var EnergyPanel:Class;
		public var energyPanel:BitmapData = new EnergyPanel().bitmapData;
		
		[Embed(source="Graphics2/NewQuestIco.png")]
		private var NewQuestIco:Class;
		public var newQuestIco:BitmapData = new NewQuestIco().bitmapData;
		
		/*[Embed(source="Graphics2/ExpPanel.png")]
		private var ExpPanel:Class;
		public var expPanel:BitmapData = new ExpPanel().bitmapData;*/
		
		[Embed(source="Graphics2/GemsPanel.png")]
		private var GemsPanel:Class;
		public var gemsPanel:BitmapData = new GemsPanel().bitmapData;
		
		[Embed(source="Graphics2/OpenTerIcon.png")]
		private var OpenTerIcon:Class;
		public var openTerIcon:BitmapData = new OpenTerIcon().bitmapData;
		
		/*[Embed(source="Graphics2/GoldenPearl.png")]
		private var GoldenPearl:Class;
		public var goldenPearl:BitmapData = new GoldenPearl().bitmapData;*/
		
		/*[Embed(source="Graphics2/MoneyPanel.png")]
		private var MoneyPanel:Class;
		public var moneyPanel:BitmapData = new MoneyPanel().bitmapData;*/
		
		[Embed(source="Graphics2/WorkerPanel.png")]
		private var WorkerPanel:Class;
		public var workerPanel:BitmapData = new WorkerPanel().bitmapData;
		
		[Embed(source="Graphics2/Compass.png")]
		private var Compass:Class;
		public var compass:BitmapData = new Compass().bitmapData;
		
		[Embed(source="Graphics2/HomeBttnIco.png")]
		private var HomeBttnIco:Class;
		public var homeBttnIco:BitmapData = new HomeBttnIco().bitmapData;
		
		[Embed(source="Graphics2/ItemCounter.png")]
		private var ItemCounter:Class;
		public var itemCounter:BitmapData = new ItemCounter().bitmapData;
		
		[Embed(source="Graphics2/valentineIco.png")]
		private var ValentineIco:Class;
		public var valentineIco:BitmapData = new ValentineIco().bitmapData;
		
		[Embed(source="Graphics2/friendIcoBacking.png")]
		private var FriendIcoBacking:Class;
		public var friendIcoBacking:BitmapData = new FriendIcoBacking().bitmapData;
		
		
		
		/*[Embed(source="Graphics2/DecorTopLiana.png")]
		private var DecorTopLiana:Class;
		public var decorTopLiana:BitmapData = new DecorTopLiana().bitmapData;
		
		[Embed(source="Graphics2/DecorBotHameleo.png")]
		private var DecorBotHameleo:Class;
		public var decorBotHameleo:BitmapData = new DecorBotHameleo().bitmapData;*/	
		
		/*[Embed(source="Graphics2/BigBang.png")]
		private var BigBang:Class;
		public var bigBang:BitmapData = new BigBang().bitmapData;*/
		
		/*[Embed(source="Graphics2/HelpBttn.png")]
		private var HelpBttn:Class;
		public var helpBttn:BitmapData = new HelpBttn().bitmapData;*/
		
		/*[Embed(source="Graphics2/SheIco.png")]
		private var SheIco:Class;
		public var sheIco:BitmapData = new SheIco().bitmapData;*/
		
		/*[Embed(source="Graphics2/HeIco.png")]
		private var HeIco:Class;
		public var heIco:BitmapData = new HeIco().bitmapData;*/
		
		/*[Embed(source = "Graphics/BarElement.png")]
		private var BarElement:Class;
		public var barElement:BitmapData = new BarElement().bitmapData;*/
		
		/*[Embed(source="Graphics2/PanelDecorHor.png")]
		private var PanelDecorHor:Class;
		public var panelDecorHor:BitmapData = new PanelDecorHor().bitmapData;*/
		
		/*[Embed(source="Graphics2/PanelDecorVer.png")]
		private var PanelDecorVer:Class;
		public var panelDecorVer:BitmapData = new PanelDecorVer().bitmapData;*/
		
		/*[Embed(source = "Graphics/BarElement.png")]
		private var BarElement:Class;
		public var barElement:BitmapData = new BarElement().bitmapData;
		[Embed(source = "Graphics/BarElement.png")]
		private var BarElement:Class;
		public var barElement:BitmapData = new BarElement().bitmapData;
		[Embed(source = "Graphics/BarElement.png")]
		private var BarElement:Class;
		public var barElement:BitmapData = new BarElement().bitmapData;
		[Embed(source = "Graphics/BarElement.png")]
		private var BarElement:Class;
		public var barElement:BitmapData = new BarElement().bitmapData;
		[Embed(source = "Graphics/BarElement.png")]
		private var BarElement:Class;
		public var barElement:BitmapData = new BarElement().bitmapData;[Embed(source = "Graphics/BarElement.png")]
		private var BarElement:Class;
		public var barElement:BitmapData = new BarElement().bitmapData;[Embed(source = "Graphics/BarElement.png")]
		private var BarElement:Class;
		public var barElement:BitmapData = new BarElement().bitmapData;[Embed(source = "Graphics/BarElement.png")]
		private var BarElement:Class;
		public var barElement:BitmapData = new BarElement().bitmapData;*/
		
		/*[Embed(source="Graphics2/Exp3.png")]
		private var Exp3:Class;
		public var exp3:BitmapData = new Exp3().bitmapData;*/
		
		/*[Embed(source="Graphics2/Coins3.png")]
		private var Coins3:Class;
		public var coins3:BitmapData = new Coins3().bitmapData;*/
		
		/*[Embed(source="Graphics2/Coins5.png")]
		private var Coins5:Class;
		public var coins5:BitmapData = new Coins5().bitmapData;*/
		
		/*[Embed(source="Graphics2/CursorBacking.png")]
		private var CursorBacking:Class;
		public var cursorBacking:BitmapData = new CursorBacking().bitmapData;*/
		
		/*[Embed(source="Graphics2/friendspanel/Star.png")]
		private var Star:Class;
		public var star:BitmapData = new Star().bitmapData;*/
		
		/*[Embed(source="Graphics/MainBttnBacking.png")]
		private var MainBttnBacking2:Class;
		public var mainBttnBacking2:BitmapData = new MainBttnBacking2().bitmapData;*/
		
		/*[Embed(source="Graphics/TheGame.png")]
		private var TheGame:Class;
		public var theGame:BitmapData = new TheGame().bitmapData;*/
		
		/*[Embed(source="Graphics/CollectionIcon.png")]
		private var CollectionIcon:Class;
		public var collectionIcon:BitmapData = new CollectionIcon().bitmapData;*/
		
		/*[Embed(source="Graphics/FullscreenBacking.png")]
		private var FullscreenBacking:Class;
		public var fullscreenBacking:BitmapData = new FullscreenBacking().bitmapData;*/
		
		/*[Embed(source="Graphics2/EnergyBolt.png")]
		private var EnergyBolt:Class;
		public var energyBolt:BitmapData = new EnergyBolt().bitmapData;*/
		
		/*[Embed(source="Graphics/cursors/CursorWaterDrop.png")]
		private var CursorWaterDrop:Class;
		public var cursorWaterDrop:BitmapData = new CursorWaterDrop().bitmapData;*/
		
		/*[Embed(source = "Graphics/WishListBttn.png")]
		private var WishListBttn:Class;
		public var wishListBttn:BitmapData = new WishListBttn().bitmapData;*/
		
		/*[Embed(source="Graphics/units/NoJam.png")]
		private var NoJam:Class;
		public var noJam:BitmapData = new NoJam().bitmapData;*/
		
		/*[Embed(source="Graphics/units/NoPlace.png")]
		private var NoPlace:Class;
		public var noPlace:BitmapData = new NoPlace().bitmapData;*/
		
		/*[Embed(source="Graphics/units/NoTarget.png")]
		private var NoTarget:Class;
		public var noTarget:BitmapData = new NoTarget().bitmapData;*/
		
		/*[Embed(source="Graphics/units/StackIsReady.png")]
		private var StackIsReady:Class;
		public var stackIsReady:BitmapData = new StackIsReady().bitmapData;*/
		
		/*[Embed(source="Graphics/units/CoinsUnitIcon.png")]
		private var CoinsUnitIcon:Class;
		public var coinsUnitIcon:BitmapData = new CoinsUnitIcon().bitmapData;*/
		
		/*[Embed(source="Graphics/icons/tradeIcon.png")]
		private var TradeIcon:Class;
		public var tradeIcon:BitmapData = new TradeIcon().bitmapData;*/
		
		/*[Embed(source="Graphics/loaders/alien_boy.png")]
		private var Alien_boy:Class;
		public var alien_boy:BitmapData = new Alien_boy().bitmapData;*/
		
		/*[Embed(source="Graphics/loaders/alien_girl.png")]
		private var Alien_girl:Class;
		public var alien_girl:BitmapData = new Alien_girl().bitmapData;*/
		
		/*[Embed(source="Graphics/loaders/alien_fat.png")]
		private var Alien_fat:Class;
		public var alien_fat:BitmapData = new Alien_fat().bitmapData;*/
		
		/*[Embed(source="Graphics/loaders/techno.png")]
		private var Techno:Class;
		public var techno:BitmapData = new Techno().bitmapData;*/
		
		/*[Embed(source="Graphics/icons/Character1.png")]
		private var Character1:Class;
		public var character1:BitmapData = new Character1().bitmapData;*/
		
		/*[Embed(source="Graphics/icons/Character2.png")]
		private var Character2:Class;
		public var character2:BitmapData = new Character2().bitmapData;*/
		
		/*[Embed(source = "Graphics/icons/Character3.png")]
		private var Character3:Class;
		public var character3:BitmapData = new Character3().bitmapData;*/
		
		/*[Embed(source = "Graphics/icons/GiftIcon.png")]
		private var GiftIcon:Class;
		public var giftIcon:BitmapData = new GiftIcon().bitmapData;*/
		
		/*[Embed(source="Graphics/icons/FriendsIcon.png")]
		private var FriendsIcon:Class;
		public var friendsIcon:BitmapData = new FriendsIcon().bitmapData;*/	
		
		/*[Embed(source="Graphics/units/PandaAvatar.png")]
		private var PandaAvatar:Class;
		public var pandaAvatar:BitmapData = new PandaAvatar().bitmapData;*/	
		
		/*[Embed(source="Graphics/QuestArrow.png")]
		private var QuestArrow:Class;
		public var questArrow:BitmapData = new QuestArrow().bitmapData;	*/
		
		/*[Embed(source = "Graphics/icons/Alert_error.png")]
		private var Alert_error:Class;
		public var alert_error:BitmapData = new Alert_error().bitmapData;*/
		
		/*[Embed(source = "Graphics/icons/Alert_storage.png")]
		private var Alert_storage:Class;
		public var alert_storage:BitmapData = new Alert_storage().bitmapData;*/
		
		/*[Embed(source = "Graphics/icons/Alert_techno.png")]
		private var Alert_techno:Class;
		public var alert_techno:BitmapData = new Alert_techno().bitmapData;*/
		
		/*[Embed(source="Graphics/icons/TutorialChar1.png")]
		private var TutorialChar1:Class;
		public var tutorialChar1:BitmapData = new TutorialChar1().bitmapData;*/
		
		/*[Embed(source="Graphics/icons/TutorialChar2.png")]
		private var TutorialChar2:Class;
		public var tutorialChar2:BitmapData = new TutorialChar2().bitmapData;*/
		
		/*[Embed(source="Graphics/icons/TutorialChar3.png")]
		private var TutorialChar3:Class;
		public var tutorialChar3:BitmapData = new TutorialChar3().bitmapData;*/
		
		/*[Embed(source="Graphics/icons/TutorialChar4.png")]
		private var TutorialChar4:Class;
		public var tutorialChar4:BitmapData = new TutorialChar4().bitmapData;*/
		
		/*[Embed(source="Graphics/Mouse.png")]
		private var Mouse:Class;
		public var mouse:BitmapData = new Mouse().bitmapData;*/
		
		/*[Embed(source="Graphics/FullscreenBttnBig.png")]
		private var FullscreenBttnBig:Class;
		public var fullscreenBttnBig:BitmapData = new FullscreenBttnBig().bitmapData;*/
		
		/*[Embed(source="Graphics/GlowBg.png")]
		private var GlowBg:Class;
		public var glowBg:BitmapData = new GlowBg().bitmapData;	*/
		
		/*[Embed(source = "Graphics2/BuyMoreBttnBacking.png")]
		private var BuyMoreBttnBacking:Class;
		public var buyMoreBttnBacking:BitmapData = new BuyMoreBttnBacking().bitmapData;*/
		
		/*[Embed(source = "Graphics/JamBar.png")]
		private var JamBar:Class;
		public var jamBar:BitmapData = new JamBar().bitmapData;
		
		[Embed(source = "Graphics/JamSlider.png")]
		private var JamSlider:Class;
		public var jamSlider:BitmapData = new JamSlider().bitmapData;*/
		
		/*[Embed(source="Graphics/units/BearIconTake.png")]
		private var BearIconTake:Class;
		public var bearIconTake:BitmapData = new BearIconTake().bitmapData;*/
		
		/*[Embed(source="Graphics2/icons/Man.png")]
		private var ManIcon:Class;
		public var manIcon:BitmapData = new ManIcon().bitmapData;*/
		
		/*[Embed(source="Graphics2/icons/Woman.png")]
		private var WomanIcon:Class;
		public var womanIcon:BitmapData = new WomanIcon().bitmapData;*/
		
		/*[Embed(source="Graphics2/icons/StumpyInstanceIco.png")]
		private var StumpyInstanceIco:Class;
		public var stumpyInstanceIco:BitmapData = new StumpyInstanceIco().bitmapData;*/
		
		/*[Embed(source="Graphics2/Tresure.png")]
		private var Tresure:Class;
		public var tresure:BitmapData = new Tresure().bitmapData;*/
		
		/*[Embed(source="Graphics2/PanelCorner.png")]
		private var PanelCorner:Class;
		public var panelCorner:BitmapData = new PanelCorner().bitmapData;*/
		
		/*[Embed(source="Graphics2/friendspanel/PanelCornerBig.png")]
		private var PanelCornerBig:Class;
		public var panelCornerBig:BitmapData = new PanelCornerBig().bitmapData;*/
		
		/*[Embed(source="Graphics2/friendspanel/PanelCornerLittle.png")]
		private var PanelCornerLittle:Class;
		public var panelCornerLittle:BitmapData = new PanelCornerLittle().bitmapData;*/
		
		/*[Embed(source="Graphics2/friendspanel/CloseBttn.png")]
		private var CloseBttn:Class;
		public var closeBttn:BitmapData = new CloseBttn().bitmapData;*/
		
		/*[Embed(source="Graphics2/RobotPlusBttn.png")]
		private var RobotPlusBttn:Class;
		public var robotPlusBttn:BitmapData = new RobotPlusBttn().bitmapData;*/
		
		/*[Embed(source="Graphics2/SimpleCounterGreen.png")]
		private var SimpleCounterGreen:Class;
		public var simpleCounterGreen:BitmapData = new SimpleCounterGreen().bitmapData;*/
		
		/*[Embed(source="Graphics/units/BearIconStone.png")]
		private var BearIconStone:Class;
		public var bearIconStone:BitmapData = new BearIconStone().bitmapData;*/
		
		/*[Embed(source="Graphics/units/BearIconWood.png")]
		private var BearIconWood:Class;
		public var bearIconWood:BitmapData = new BearIconWood().bitmapData;*/
		
		/*[Embed(source="Graphics/units/BearIconJam.png")]
		private var BearIconJam:Class;
		public var bearIconJam:BitmapData = new BearIconJam().bitmapData;*/
		
		/*[Embed(source="Graphics/units/BearIconKick.png")]
		private var BearIconKick:Class;
		public var bearIconKick:BitmapData = new BearIconKick().bitmapData;*/		
		
		/*[Embed(source = "Graphics/SpoonIcon.png")]
		private var SpoonIcon:Class;
		public var spoonIcon:BitmapData = new SpoonIcon().bitmapData;*/		
		
		/*[Embed(source = "Graphics/units/RepairUnitIcon.png")]
		private var RepairUnitIcon:Class;
		public var repairUnitIcon:BitmapData = new RepairUnitIcon().bitmapData;*/	
		
		/*[Embed(source="Graphics/CraftSlider.png")]
		private var CraftSlider:Class;
		public var craftSlider:BitmapData = new CraftSlider().bitmapData;	
		
		[Embed(source="Graphics/CraftSliderBg.png")]
		private var CraftSliderBg:Class;
		public var craftSliderBg:BitmapData = new CraftSliderBg().bitmapData;*/
		
		/*[Embed(source = "Graphics/Checked.png")]
		private var Checked:Class;
		public var checked:BitmapData = new Checked().bitmapData;*/
		
		/*[Embed(source="Graphics/units/BearAvatar.png")]
		private var BearAvatar:Class;
		public var bearAvatar:BitmapData = new BearAvatar().bitmapData;*/
		
		/*[Embed(source="Graphics/Tick.png")]
		private var Tick:Class;
		public var tick:BitmapData = new Tick().bitmapData;*/
		
		/*[Embed(source="Graphics/units/BearIconHand.png")]
		private var BearIconHand:Class;
		public var bearIconHand:BitmapData = new BearIconHand().bitmapData;*/
		
		/*[Embed(source="Graphics/units/HandUnitIcon.png")]
		private var HandUnitIcon:Class;
		public var handUnitIcon:BitmapData = new HandUnitIcon().bitmapData;*/
		
		/*[Embed(source="Graphics/units/CloudsLabel.png")]
		private var CloudsLabel:Class;
		public var cloudsLabel:BitmapData = new CloudsLabel().bitmapData;*/
		
		/*[Embed(source = "Graphics/PanelFriends.png")]
		private var PanelFriends:Class;
		public var panelFriends:BitmapData = new PanelFriends().bitmapData;*/
		
		/*[Embed(source = "Graphics/SimpleCounter.png")]
		private var SimpleCounter:Class;
		public var simpleCounter:BitmapData = new SimpleCounter().bitmapData;*/
		
		/*[Embed(source="Graphics/units/BearLoader.png")]
		private var BearLoader:Class;
		public var bearLoader:BitmapData = new BearLoader().bitmapData;*/
		
		/*[Embed(source="Graphics/units/GirlLoader.png")]
		private var GirlLoader:Class;
		public var girlLoader:BitmapData = new GirlLoader().bitmapData;	*/	
		
		/*[Embed(source = "Graphics/GiftLabel.png")]
		private var GiftLabel:Class;
		public var giftLabel:BitmapData = new GiftLabel().bitmapData;*/		
		
		/*[Embed(source = "Graphics/Female.png")]
		private var Female:Class;
		public var female:BitmapData = new Female().bitmapData;	*/
		
		/*[Embed(source = "Graphics/Male.png")]
		private var Male:Class;
		public var male:BitmapData = new Male().bitmapData;	*/
		
		/*[Embed(source="Graphics/units/BoyLoader.png")]
		private var BoyLoader:Class;
		public var boyLoader:BitmapData = new BoyLoader().bitmapData;*/
		
		/*[Embed(source = "Graphics/icons/BearIcon.png")]
		private var BearIcon:Class;
		public var bearIcon:BitmapData = new BearIcon().bitmapData;*/
		
		/*[Embed(source="Graphics/JamSmallIcon.png")]
		private var JamSmallIcon:Class;
		public var jamSmallIcon:BitmapData = new JamSmallIcon().bitmapData;*/
		
		/*[Embed(source = "Graphics2/WigwamWorker/VigCounterBacking.png")]
		private var VigCounterBacking:Class;
		public var vigCounterBacking:BitmapData = new VigCounterBacking().bitmapData;*/
		
		[Embed(source = "Graphics2/WhishlistPlusBttn.png")]
		private var WhishlistPlusBttn:Class;
		public var whishlistPlusBttn:BitmapData = new WhishlistPlusBttn().bitmapData;
		
		[Embed(source = "Graphics2/chair_green.png")]
		private var Chair_green:Class;
		public var chair_green:BitmapData = new Chair_green().bitmapData;
		
		[Embed(source = "Graphics2/basketIcon.png")]
		private var BasketIcon:Class;
		public var basketIcon:BitmapData = new BasketIcon().bitmapData;
		
		/*[Embed(source = "Graphics/FantsBar.png")]
		private var FantsBar:Class;
		public var fantsBar:BitmapData = new FantsBar().bitmapData;*/
		
		/*[Embed(source="Graphics/BearBar.png")]
		private var BearBar:Class;
		public var bearBar:BitmapData = new BearBar().bitmapData;*/
		
		/*[Embed(source = "Graphics/EnergyBar.png")]
		private var EnergyBar:Class;
		public var energyBar:BitmapData = new EnergyBar().bitmapData;*/
		
		/*[Embed(source = "Graphics/StopBacking.png")]
		private var StopBacking:Class;
		public var stopBacking:BitmapData = new StopBacking().bitmapData;*/
		
		/*[Embed(source = "Graphics/CursorsBacking.png")]
		private var CursorsBacking:Class;
		public var cursorsBacking:BitmapData = new CursorsBacking().bitmapData;*/
		
		/*[Embed(source = "Graphics/OpenArrow.png")]
		private var OpenArrow:Class;
		public var openArrow:BitmapData = new OpenArrow().bitmapData;*/
		
		/*[Embed(source = "Graphics/HomeBttnBacking.png")]
		private var HomeBttnBacking:Class;
		public var homeBttnBacking:BitmapData = new HomeBttnBacking().bitmapData;*/
		
		//[Embed(source="Graphics2/PlantBar.png")]
		//private var PlantBar:Class;
		//public var plantBar:BitmapData = new PlantBar().bitmapData;
		
		public function PanelsLib():void 
		{
		
		}
	}
}