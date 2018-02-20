package 
{
	import flash.display.BitmapData;
	/**
	 * ...
	 * @author ...
	 */
	public class Textures 
	{
		
		[Embed(source = "sprites/WindowBacking.png")]
		private static var WindowBacking:Class;
		private static var _windowBacking:BitmapData = new WindowBacking().bitmapData;
		
		[Embed(source = "sprites/QuestsSmallBackingBottomPiece.png")]
		private static var QuestsSmallBackingBottomPiece:Class;
		private static var _questsSmallBackingBottomPiece:BitmapData = new QuestsSmallBackingBottomPiece().bitmapData;
		
		[Embed(source = "sprites/QuestsSmallBackingTopPiece.png")]
		private static var QuestsSmallBackingTopPiece:Class;
		private static var _questsSmallBackingTopPiece:BitmapData = new QuestsSmallBackingTopPiece().bitmapData;
		
		
		[Embed(source = "sprites/StopBttnIco.png")]
		private static var StopBttnIco:Class;
		private static var _stopBttnIco:BitmapData = new StopBttnIco().bitmapData;
		
		[Embed(source = "sprites/QuestTaskBackingBot.png")]
		private static var QuestTaskBackingBot:Class;
		private static var _questTaskBackingBot:BitmapData = new QuestTaskBackingBot().bitmapData;
		
		[Embed(source = "sprites/QuestTaskBackingTop.png")]
		private static var QuestTaskBackingTop:Class;
		private static var _questTaskBackingTop:BitmapData = new QuestTaskBackingTop().bitmapData;
		
		[Embed(source = "sprites/QuestTaskBackingTopMini.png")]
		private static var QuestTaskBackingTopMini:Class;
		private static var _questTaskBackingTopMini:BitmapData = new QuestTaskBackingTopMini().bitmapData;
		
		[Embed(source = "sprites/BubbleBackingBig.png")]
		private static var BubbleBackingBig:Class;
		private static var _bubbleBackingBig:BitmapData = new BubbleBackingBig().bitmapData;
		
		[Embed(source = "sprites/FullscreenBttnBig.png")]
		private static var FullscreenBttnBig:Class;
		private static var _fullscreenBttnBig:BitmapData = new FullscreenBttnBig().bitmapData;
		
		[Embed(source = "sprites/Arrow.png")]
		private static var Arrow:Class;
		private static var _arrow:BitmapData = new Arrow().bitmapData;
		
		[Embed(source = "sprites/SystemMinus.png")]
		private static var SystemMinus:Class;
		private static var _systemMinus:BitmapData = new SystemMinus().bitmapData;
		
		[Embed(source = "sprites/SystemPlus.png")]
		private static var SystemPlus:Class;
		private static var _systemPlus:BitmapData = new SystemPlus().bitmapData;
		
		[Embed(source="sprites/TradingPostBackingMain.png")]
		private static var TradingPostBackingMain:Class;
		private static var _tradingPostBackingMain:BitmapData = new TradingPostBackingMain().bitmapData;
		
		[Embed(source="sprites/envelope.png")]
		private static var Envelope:Class;
		private static var _envelope:BitmapData = new Envelope().bitmapData;
		
		[Embed(source="sprites/Tick.png")]
		private static var Tick:Class;
		private static var _tick:BitmapData = new Tick().bitmapData;
		
		[Embed(source="sprites/NavigateIco.png")]
		private static var NavIco:Class;
		private static var _navIco:BitmapData = new NavIco().bitmapData;
		
		public static var textures:Object = {
			windowBacking: 						_windowBacking,
			questsSmallBackingTopPiece:			_questsSmallBackingTopPiece,
			questsSmallBackingBottomPiece:		_questsSmallBackingBottomPiece,
			stopBttnIco:						_stopBttnIco,
			questTaskBackingTop:				_questTaskBackingTop,
			bubbleBackingBig:					_bubbleBackingBig,
			questTaskBackingTopMini:			_questTaskBackingTopMini,
			questTaskBackingBot:				_questTaskBackingBot,
			tradingPostBackingMain:				_tradingPostBackingMain,
			fullscreenBttnBig:					_fullscreenBttnBig,
			arrow:								_arrow,
			systemPlus:							_systemPlus,
			systemMinus:						_systemMinus,
			tick:								_tick,
			envelope:							_envelope,
			navIco:								_navIco
		};
		public function Textures() 
		{
			
		}
		
	}

}