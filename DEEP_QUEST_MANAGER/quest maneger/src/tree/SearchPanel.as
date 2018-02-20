package tree 
{
	
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.StageDisplayState;

	public class SearchPanel extends Sprite
	{
		public var bttnSearch:ImageButton;
		public var bttnBreak:ImageButton;
		public var searchField:TextField;
		private var update:Function
		
		public var settings:Object = {
			callback:	null,
			stop:		null,
			caption:	null,
			hasIcon:	true
		}
		
		public function SearchPanel(settings:Object = null)
		{
			if (!settings)
				settings = { };
			for (var item:* in settings)
				this.settings[item] = settings[item];
			
			
			settings['target'] = App.treeManeger.currentTree;
			drawSearch();
			
			if(settings.caption)
				text = settings.caption;
		}
			
		private function drawSearch():void {
			
			
			
			var searchBg:Shape = new Shape();
			searchBg.graphics.lineStyle(2, 0x6f340a, 1, true);
			searchBg.graphics.beginFill(0xf2d8aa,1);
			searchBg.graphics.drawRoundRect(0, 0, 210, 25, 15, 15);
			searchBg.graphics.endFill();
			
			addChild(searchBg);
			searchBg.x = 0;
			searchBg.y = 10;
			
			bttnBreak = new ImageButton(Textures.textures['stopBttnIco'], { scaleX:0.7, scaleY:0.7, shadow:true } );
			addChild(bttnBreak);
			bttnBreak.x = searchBg.x + searchBg.width - bttnBreak.width - 4;
			bttnBreak.y = searchBg.y + 5;
			bttnBreak.addEventListener(MouseEvent.CLICK, onBreakEvent);
			
			searchField = UI.drawText("",{ 
				color:0x502f06,
				borderColor:0xf8f2e0,
				fontSize:16,
				input:true
			});
			
			searchField.x =  0;
			searchField.y = 11;
			searchField.width = bttnBreak.x - 2 - searchField.x;
			searchField.height = searchField.textHeight + 2;
			
			addChild(searchField);
			
			searchField.addEventListener(Event.CHANGE, onInputEvent);
			searchField.addEventListener(FocusEvent.FOCUS_IN, onFocusEvent);
			searchField.addEventListener(FocusEvent.FOCUS_OUT, onUnFocusEvent);
		}
		
		
		public function onFocusEvent(e:FocusEvent):void {
			if (App.self.stage.displayState != StageDisplayState.NORMAL) {
				App.self.stage.displayState = StageDisplayState.NORMAL;
			}
			
			if (text == settings.caption)
				text = "";
		}
		
		public function onUnFocusEvent(e:FocusEvent):void {
			if(settings.caption && text == "")
				text = settings.caption;
		}
		
		private function onInputEvent(e:Event):void {
			
			search(e.target.text);
		}
		
		private function onSearchEvent(e:MouseEvent):void {
			//if (!searchPanel.visible) {
			//	searchField.text = "";
			//}
			//searchPanel.visible = !searchPanel.visible;
		}
		
		public function onBreakEvent(e:MouseEvent):void {
			searchField.text = "";
			search();
			//searchPanel.visible = false;
		}
		
		public function set text(value:String):void {
			searchField.text = value;
		}
		public function get text():String {
			return searchField.text;
		}
		
		public function search(query:String = "", isCallBack:Boolean = true):Array {
			if ( query == "" )
			{
				App.treeManeger.showFirst();
				//settings.target.y = 0;
				//settings.target.x = 0;
				return null;
			}
			var _point:Point = App.treeManeger.currentTree.getCoordAndGlow(query);
			if (_point.x == 0 && _point.y == 0)
				return null;
			App.treeManeger.currentTree.x = -_point.x * App.treeManeger.currentTree.scaleX + App.self.stage.stageWidth / 2 - 60;
			App.treeManeger.currentTree.y = -_point.y * App.treeManeger.currentTree.scaleY + App.self.stage.stageHeight / 2 - 50;
			
			if (App.self.navigator)
				App.self.navigator.redrawUp();
			return null;
		}
	}
}	