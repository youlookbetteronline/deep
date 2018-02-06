package ui 
{
	import com.greensock.easing.Linear;
	import com.greensock.TweenLite;
	import core.Log;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import wins.Window;
	
	public class ProgressBar extends Sprite
	{
		private var slider:Sprite = new Sprite();
		public var maxWidth:int;
		private var time:int;
		private var value:Number = 0;
		
		private var _label:TextField;
		
		public var params:Object = {
			background:		'progressBar',
			barLine:		'',
			auto:			true,
			textUpdate:		false,
			removeOnComplete:true,
			ease:			Linear.easeOut
		}
		
		public function ProgressBar(time:uint, maxWidth:int = 110, params:Object = null) 
		{	
			if (!params) params = { };
			for (var s:* in params)
				this.params[s] = params[s];
			
			this.maxWidth = maxWidth;
			this.time = time;
			
			var bitmap:Bitmap = new Bitmap(UserInterface.textures.progressBar);
			addChild(bitmap);
			slider.x = 2;
			slider.y = 2;
			addChild(slider);
			
			_label = Window.drawText("", {
				fontSize:14,
				width:(maxWidth > 20) ? maxWidth : 20,
				color:0xf1ff29,
				borderColor:0x0e4b8b,
				borderSize:2,
				textAlign:"center"
			});
			
			addChild(_label);
		}
		
		public function set label(text:String):void {
			_label.text = text;
			_label.x = -12;
			_label.y = -1;
		}
		
		public function get label():String {
			return _label.text;
		}
		
		private var tween:TweenLite;
		public function start(currentProgress:Number = 0):void {
			
			if (tween) {
				tween.kill();
			}
			
			if (currentProgress > 1) currentProgress = 1;
			if (currentProgress < 0) currentProgress = 0;
			UserInterface.slider(slider, currentProgress * maxWidth, maxWidth, "progressSlider");
			
			var childs:int = slider.numChildren;
			while (childs--) {
				var mask:* = slider.getChildAt(childs);
				if (mask is Shape) break;
			}
			
			mask.x = -mask.width + mask.width * currentProgress;
			
			tween = TweenLite.to(mask, time - time * currentProgress, { x:0, ease:params.ease, onUpdate:function():void {
				if (params.textUpdate)
					label = TimeConverter.timeToStr(int(time - (mask.width + mask.x) * time / mask.width));
			}, onComplete:function():void {
				if (params.removeOnComplete)
					dispose();
				
				dispatchEvent(new AppEvent(AppEvent.ON_FINISH));
			}});
		}
		
		public function dispose():void {
			if (tween) tween.kill();
			if (parent) parent.removeChild(this);
		}
		
		/*
		public function stop():void {
			App.self.setOffEnterFrame(progess);
		}
		
		public function progess():void {
			value += step;
			value = Math.round(value);
			UserInterface.slider(slider, value, maxWidth, "progressSlider");
			
			if (value >= maxWidth) {
				stop();
				dispatchEvent(new AppEvent(AppEvent.ON_FINISH));	
			}
			
			Log.alert('Progress: ' + value);
		}
		*/
		
	}

}