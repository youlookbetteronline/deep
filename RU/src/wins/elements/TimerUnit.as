package wins.elements 
{
	import com.greensock.TweenMax;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import wins.Window;

	public class TimerUnit extends LayerX {
		
		public var background:Bitmap;
		
		public var bitmap:Bitmap;
		public var bg:Bitmap;
		public var titleLabel:TextField;
		public var timeLabel:TextField;
		public var time:Object = {};
		
		private var settings:Object = {
			width:200,
			height:50,
			time:{started:0,duration:0},
			backGround:'collectionRewardBacking',
			timerTextPars: {
				fontSize:34,
				textAlign:"center",
				letterSpacing:3,
				color:0xffe779,
				borderColor:0x6f3817,
				shadowColor:0x6f3817,
				shadowSize:1
			},
			titleTextPars: {
				fontSize:26,
				textAlign:"center",
				//letterSpacing:3,
				color:0xfffbe2,
				borderColor:0x814f31,
				shadowColor:0x814f31,
				shadowSize:1
			}
		};
		
		public function TimerUnit(settings:Object = null) {
			for (var prop:* in settings) {
				this.settings[prop] = settings[prop];
			}
			time.started = settings.time.started;
			time.duration = settings.time.duration;
			//if(settings.backGround != 'none'){
				drawBackground();
			//}
			drawTime();
			drawTitle();
			//if (settings.backGround == 'glow') {
				//background.height = settings.height + titleLabel.height / 2;
				//background.width = Math.max(settings.width,titleLabel.width,timeLabel.width);
				//background.y = titleLabel.y;
			//}
		}
		
		public function drawTitle():void {
			titleLabel = Window.drawText(Locale.__e('flash:1393581955601'), settings.titleTextPars);
			titleLabel.width = titleLabel.textWidth + 5;
			titleLabel.height = titleLabel.textHeight + 5;
			titleLabel.x = (settings.width - titleLabel.width) / 2;
			titleLabel.y = bg.y-titleLabel.height+20;
			addChild(titleLabel);
		}
		
		public function start():void {
			this.visible = true;
			App.self.setOnTimer(updateDuration);
		}
		
		public function drawBackground():void {
			//if (settings.backGround == 'glow') {
				//background = new Bitmap(Window.textures[settings.backGround]);
			//}else{
				//background = Window.backing(settings.width, settings.height, 25, settings.backGround);
			//}
			bg= Window.backing(140,60, 25,'collectionItemBacking');
			addChild(bg);
		}
		
		public function drawTime():void {
			//потом поменять обратно на 3600
			//var timeVal:int = time.duration * 3600 - (App.time - time.started);
			var timeVal:int = time.duration * 3600 - (App.time - time.started);
			settings.timerTextPars['width'] = settings.width;
			timeLabel = Window.drawText(TimeConverter.timeToDays(timeVal), {
				fontSize:37,
				autoSize:"center",
				textAlign:"centr",
				color:0xFCE830,
				borderColor:0x402000				
			});
			addChild(timeLabel);
			timeLabel.x = bg.x + bg.width / 2 - timeLabel.width / 2;
			timeLabel.y = bg.y+bg.height/2-timeLabel.textHeight/2;
		}
		
		public function updateDuration():void {
			//var timeVal:int = time.duration * 3600 - (App.time - time.started);
			var timeVal:int = time.duration * 3600 - (App.time - time.started);
			timeLabel.text = TimeConverter.timeToStr(timeVal);
			if (timeVal <= 0) {
				App.self.setOffTimer(updateDuration);
				if (settings.hasOwnProperty('callback')) {
					settings['callback']();
				//}else {
					//this.visible = false;
				}
			}
		}
		
	}
}	