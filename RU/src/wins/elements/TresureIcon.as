package wins.elements 
{
	import buttons.ImageButton;
	import buttons.SimpleButton;
	import core.Load;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import wins.Window;
	/**
	 * ...
	 * @author 
	 */
	public class TresureIcon extends SimpleButton
	{
		public var bg:Bitmap;
		private var bttn:ImageButton;
		
		public var sid:int;
		public var roomSid:int;
		public var isFocused:Boolean = false;
		
		public function TresureIcon(sid:int, roomSid:int) 
		{
			this.sid = sid;
			this.roomSid = roomSid;
			
			drawBody();
			
		}
		
		private function drawBody():void 
		{
			bg = new Bitmap(Window.textures.productBacking2);
			bg.smoothing = true;
			bg.height = bg.width = 80;
			addChild(bg);
			bg.visible = false;
			
			bttn = new ImageButton(new BitmapData(1, 1, true, 0));
			addChild(iconCont);
			iconCont.addChild(bttn);
			bttn.y = -10;
			bttn.x = 8;		
			
			Load.loading(Config.getImage('interface', 'box_open'), function(data:*):void {
				if(bttn){
					bttn.bitmapData = data.bitmapData;
					bttn.bitmap.smoothing = true;
					bttn.scaleX = bttn.scaleY = 0.86;
					
					bg.visible = true;
					
					addGlow(Window.textures.iconEff, 0);
				}
			});
		}
		
		private var iconCont:LayerX = new LayerX();
		private var container:Sprite = new Sprite();
		public function addGlow(bmd:BitmapData, layer:int, scale:Number = 1):void
		{
			var btm:Bitmap = new Bitmap(bmd);
			container = new Sprite();
			container.addChild(btm);
			btm.scaleX = btm.scaleY = scale;
			btm.smoothing = true;
			btm.x = -btm.width / 2;
			btm.y = -btm.height / 2;
			
			addChildAt(container, layer);
			
			
			container.mouseChildren = false;
			container.mouseEnabled = false;
			
			container.x = bg.width / 2;
			container.y = bg.height / 2;
			
			App.self.setOnEnterFrame(rotateBtm);
			iconCont.glowingColor = 0xffffff;
			iconCont.startGlowing();
		}
		
		private function rotateBtm(e:Event):void 
		{
			container.rotation += 1;
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			if (bttn) {
				bttn.dispose();
				bttn = null;
			}
			if (bg && bg.parent) {
				bg.parent.removeChild(bg);
				bg = null;
			}
			
			if (parent) {
				parent.removeChild(this);
			}
		}
		
	}

}