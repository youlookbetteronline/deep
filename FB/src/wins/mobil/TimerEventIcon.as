package wins.mobil 
{
	import buttons.ImagesButton;
	import com.flashdynamix.motion.extras.BitmapTiler;
	import core.Load;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import units.Unit;
	import wins.Window;
	/**
	 * ...
	 * @author ...
	 */
	public class TimerEventIcon extends LayerX
	{
		private var bg:Bitmap;
		private var bgBMD:BitmapData;
		private var iconBMD:BitmapData;
		public var imageBttn:ImagesButton;
		private var timerlabel:TextField;
		
		public var params:Object = {
			width:		100,
			height:		100,
			hasTimer:	true
		}
		
		public var onClick:Function = null;
		public var endTime:int = 0;
		
		public function TimerEventIcon(params:Object = null) 
		{
			if (!params) params = { };
			for (var s:String in params) this.params[s] = params[s];
			
			endTime = params.endTime || 0;
			
			bg = new Bitmap(new BitmapData(this.params.width, this.params.height, true, 0));
			addChild(bg);
			
			if (this.params.hasOwnProperty('background')) {
				Load.loading(Config.getImage('content', this.params.background), function(data:Bitmap):void {
					bgBMD = data.bitmapData;
					draw();
				});
			}else {
				bgBMD = new BitmapData(this.params.width, this.params.height, true, 0);
			}
			
			if (this.params.hasOwnProperty('icon')) {
				Load.loading(Config.getImage('content', this.params.icon), function(data:Bitmap):void {
					iconBMD = data.bitmapData;
					draw();
				});
			}
			
			if (params.hasOwnProperty('onClick') && params.onClick != null) {
				onClick = params.onClick;
			}
			
			addEventListener(Event.REMOVED_FROM_STAGE, dispose);
		}
		
		public function get target():Unit {
			if (params.target && params.target is Unit)
				return params.target;
			
			return null;
		}
		
		private function draw():void {
			if (bgBMD) {
				if (!imageBttn) {
					imageBttn = new ImagesButton(bgBMD, (iconBMD) ? iconBMD : null);
					imageBttn.addEventListener(MouseEvent.CLICK, mouseClick);
					addChild(imageBttn);
					
					timerlabel = Window.drawText('', {
						fontSize:			18,
						width:				105,
						textAlign:			'center',
						color:				0xfffaf7,
						borderColor:		0x232b50
					});
					timerlabel.x = (bg.width - timerlabel.width) / 2;
					timerlabel.y = bg.height * .9 - timerlabel.height;
					addChild(timerlabel);
					
					if (params.hasTimer)
						App.self.setOnTimer(timer);
				}
				
				if (iconBMD) {
					imageBttn.icon = iconBMD;
				}
			}
		}
		
		private function timer():void {
			if (endTime - App.time >= 0 && timerlabel) {
				timerlabel.text = TimeConverter.timeToDays(endTime - App.time);
			}
		}
		
		private function mouseClick(e:MouseEvent):void {
			//TutorialManager.currentTarget = e.currentTarget;
			//if (TutorialManager.ACTIVE) return;
			
			if (onClick != null && !params.needParams) onClick();
			else if (onClick != null) onClick(params);
		}
		
		public function dispose(e:Event = null):void {
			if (imageBttn && onClick != null) {
				imageBttn.removeEventListener(MouseEvent.CLICK, mouseClick);
			}
			
			App.self.setOffTimer(timer);
			removeEventListener(Event.REMOVED_FROM_STAGE, dispose);
		}
	}
}