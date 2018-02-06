package chat.gui 
{
	import bttns.SimpleButton;
	import bttns.UIBttn;
	import chat.ChatEvent;
	import chat.gui.ChatMessage;
	import empire.farm.Farm;
	import empire.farm.ui.SpriteUI;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	import hlp.TextUtil;
	import hlp.ToolsUtils;
	import wins.MassiveWindow;
	import wins.Window;
	import wins.elements.Scroll;
	
	/**
	 * ...
	 * @author Andrew
	 */
	
	public class ChatWindow extends SpriteUI {
		
		private var _chatButton:SimpleButton;
		private var _hidden:Boolean = true;
		private var _touched:Boolean = false;
		
		private var _openContainer:Sprite;
		private var _hiddenContainer:Sprite;
		private var _messages:Vector.<ChatMessage>;
		private var _enterPoint:Object = {x:0, y:0};
		private var _userInput:UserInput;
		private var _messagesContainer:Sprite;
		private var _lastContainerY:Number = 0;
		private var _mask:Shape;
		private var _scroll:Scroll;
		private var _chatY:int = 30;
		private var exit:UIBttn;
		
		[Embed(source="..//..//..//INTERFACE//chatButton.png")]
		public static var ButtonBMP:Class;
		public static var buttonBMP:BitmapData = new ButtonBMP().bitmapData;
		
		[Embed(source="..//..//..//INTERFACE//bigBacking.png")]
		public  var BigBacking:Class;
		public  var bigBacking:BitmapData = new BigBacking().bitmapData;
		
		[Embed(source="..//..//..//INTERFACE//smallBacking.png")]
		public  var SmallBacking:Class;
		public  var smallBacking:BitmapData = new SmallBacking().bitmapData;
		
		[Embed(source="..//..//..//INTERFACE//mirrowExit.png")]
		public  var MirrowExit:Class;
		public  var mirrowExit:BitmapData = new MirrowExit().bitmapData;
		
		private var _settings:Object = {
			width:260,
			height:420
		}
		public var originalX:int = 295;
		public var originalY:int = 5;
		
		public function ChatWindow(settings:Object)  {
			for (var property:String in settings){
				_settings[property] = settings[property];
			}
			
			drawBody();
			setMoveListeners();
		}
		
		private function onMouseUp(e:MouseEvent):void { touched = false};
		private function onMouseDown(e:MouseEvent):void { touched = true};
		
		private function onMouseMove(e:MouseEvent):void {
			if (_touched){
				this.x = App.self.stage.mouseX - _enterPoint.x;
				this.y = App.self.stage.mouseY - _enterPoint.y;
			}
		}
		
		public function show(e:MouseEvent = null):void {hidden = !_hidden};
		public function hide(e:* = null):void{ hidden = true};
		
		public function get touched():Boolean {return _touched};
		public function set touched(value:Boolean):void  {
			if (_touched == value) return;
			_touched = value;
			Farm.lockMouseEvent = value;
			if (value){
				_enterPoint = {x:App.self.stage.mouseX - this.x, y:App.self.stage.mouseY - this.y};
				App.self.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			}
			else {
				_enterPoint = {x:0, y:0};
				App.self.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			}
		}
		
		public function get hidden():Boolean { return _hidden};
		public function set hidden(value:Boolean):void {
			_hidden = value;
			_openContainer.visible = !_hidden;
			if (!_hidden){
				_userInput.setListeners();
				_chatButton.visible = false;
				refresh();
				this.y += 30;
			}
			else{
				_userInput.clearListeners();
				_chatButton.visible = true;
				this.x = originalX;
				this.y = originalY;
			}
		}
		
		private function drawBody():void{
			drawOpen();
			drawHide();
			_openContainer.visible = false;
		}
		
		public function refresh():void{
			
			if (_hidden){
				_chatButton.blinkMe(4);
				return;
			}
			
			var Y:int = 0;
			var chatMessage:ChatMessage;
			ToolsUtils.removeFromParent(_messagesContainer);
			_messagesContainer = new Sprite();
			_openContainer.addChild(_messagesContainer);
			_messagesContainer.y = _chatY;
		
			for each (var msg:Object in App.user.chat.messages){
				chatMessage = new ChatMessage(msg);
				chatMessage.x = 10;
				chatMessage.y = Y;
				Y += chatMessage.height + 5;
				_messagesContainer.addChild(chatMessage);
			}
			updateMask();
			if (_scroll != null && !_scroll.visible && _messagesContainer.height > _mask.height) {
				_scroll.visible = true;
				_openContainer.addEventListener(MouseEvent.MOUSE_WHEEL, _scroll.onWheel);
			}
			scrolling();
		}
		
		private function updateMask(e:ChatEvent = null):void{
			if (!_messagesContainer) return;
			ToolsUtils.removeFromParent(_mask);
			_mask = new Shape();
			_mask.graphics.beginFill(0xFDFF, 0.3);
			_mask.graphics.drawRect(0, 0, _settings.width - 30, _settings.height - _chatY - 10 - _userInput.height);
			_mask.graphics.endFill();
			_mask.x = 5;
			_mask.y = _chatY;
			_openContainer.addChild(_mask);
			_messagesContainer.mask = _mask;
		}
		
		private function addScroll():void{
			_scroll = new Scroll({percent:100});
			_scroll.height = 340;
			_scroll.width = 16;
			_scroll.y = 30;
			_scroll.x = _settings.width - _scroll.width + 8;
			_openContainer.addChild(_scroll);
			_scroll.visible = false;
			_scroll.addEventListener('changeScroll', scrolling);
		}
		
		private function scrolling(e:DataEvent = null):void {
			if (!_scroll.visible) return;
			
			var persent:int = _scroll.percent;
			if (persent < 5)
				persent = 0;
			
			if (persent > 95)
				persent = 100;
				
			var maxHeight:int = _messagesContainer.height - _mask.height + 20;
			_messagesContainer.y = _chatY - (maxHeight * persent) / 100;
		}
		
		private function setMoveListeners():void{
			//_chatButton.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			App.self.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
		}
		
		private function drawOpen():void{
			_openContainer = new Sprite();
			//var back:Bitmap = Window.backing(_settings.width, _settings.height, 50,Gui.windowsTextures.markBacking);
			var back:Bitmap = Window.backing(_settings.width, _settings.height, 50,bigBacking);
			_openContainer.addChild(back);
			back.alpha = 0.8;
			
			var back2:Bitmap = Window.backing(_settings.width, 30, 50,smallBacking);
			var moveContainer:Sprite = new Sprite();
			moveContainer.addChild(back2);
			moveContainer.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			back2.alpha = 0.9;
			_openContainer.addChild(moveContainer);
			
			addChild(_openContainer);
			
			addScroll();
			
			_userInput = new UserInput();
			_userInput.x = 10;
			_userInput.y = _settings.height - 40;
			_userInput.addEventListener(ChatEvent.SEND_MESSAGE, onSendMessage);
			_userInput.addEventListener(ChatEvent.CHANGE_UI_HEIGHT, updateMask);
			_openContainer.addChild(_userInput);
			
			updateMask();
			
			drawExit();
		}
		
		private function onSendMessage(e:ChatEvent):void {
			if (_userInput.text.length < 1 || _userInput.text == '\r') return;
			App.user.chat.sendMessage(_userInput.text);
			setTimeout(function():void{
				_userInput.text = '';
				_userInput.drawBack();
			}, 1);
		}
		
		private function drawHide():void{
			_hiddenContainer = new Sprite();
			_chatButton = new SimpleButton({bmd:buttonBMP});
			//_chatButton.doubleClickEnabled = true;
			//_chatButton.addEventListener(MouseEvent.DOUBLE_CLICK, show);
			_chatButton.addEventListener(MouseEvent.CLICK, show);
			_hiddenContainer.addChild(_chatButton);
			addChild(_hiddenContainer);
		}
		
		private function drawExit():void{
			exit = new UIBttn(UIBttn.CLOSE);
			exit.scaleX = exit.scaleY = 0.7;
			_openContainer.addChild(exit);
			exit.x = _settings.width - exit.width - 40;
			exit.y = - exit.height + 5;
			exit.onClick = hide;
			MassiveWindow.drawMirrowObj(mirrowExit, -exit.width / 2, _openContainer, exit.x + 20, exit.y+2);
		}
		
		public function dispose():void  {
			if (exit) {
				exit.dispose();
				ToolsUtils.removeFromParent(exit);
				exit = null;
			}
			
			if (_chatButton) {
				_chatButton.dispose();
				_chatButton.removeEventListener(MouseEvent.CLICK, show);
				_chatButton = null;
			}
			
			if (_userInput){
				_userInput.dispose();
				_userInput = null;
			}
			
			if (_scroll)  {
				_scroll.dispose();
				_scroll.removeEventListener('changeScroll', scrolling);
				_scroll = null;
			}
		}
	}
}