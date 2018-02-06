package wins
{
	import buttons.MoneyButton;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author 
	 */
	public class ProgressBar extends Sprite
	{
		private var barL:Bitmap = new Bitmap(/*Window.textures.cookingPanelBarLeft*/); //cookingPanelBarLeft
		private var barM:Bitmap = new Bitmap(/*Window.textures.cookingPanelBarM*/);
		private var barR:Bitmap = new Bitmap(/*Window.textures.cookingPanelBarRight*/);
		
		//private var cookingPanelBarBg:Bitmap = new Bitmap(Window.textures.cookingPanelBarBg);
		
		private var buyBttn:MoneyButton;
		public var timer:TextField;
		private var win:*;
		private var w:int;
		private var maska:Shape;
		
		private var Xs:int = 0;
		private var Xf:int = 0;
		
		public var bar:CookingPanelBar;
		private var delta:int;
		private var barWidth:int;
		public var scale:Number = 1;
		
		private var timeFormat:uint = TimeConverter.H_M_S;
		
		private var isTimer:Boolean = true;
		
		private var timeSize:int;
		private var timeColor:int;
		private var timeborderColor:int;
		private var cook:Boolean = false;
		private var typeLine:String;
		private var rot:int;
		
		
		public function ProgressBar(settings:Object, cook:Boolean = false)
		{
			this.w 			= settings.width;
			this.win 		= settings.win;
			timeSize 		= settings.timeSize || 24;
			timeborderColor = settings.timeborderColor || 0x613200;
			timeColor 		= settings.timeColor || 0xffffff;
			typeLine 		= settings.typeLine || 'mainProgBarBluePiece';
			rot				= settings.rot || 0;
			this.cook 		= cook;
			
			if(settings.hasOwnProperty('isTimer'))isTimer = settings.isTimer;
			
			timeFormat = settings.timeFormat || TimeConverter.H_M_S
			
			var container:Sprite = new Sprite();
			
			barWidth = settings.width;
			
			if (settings.hasOwnProperty('scale')) scale = settings.scale;
			bar = new CookingPanelBar(barWidth / scale, typeLine,cook);
			bar.scaleX = bar.scaleY = scale;
			bar.rotation = rot;
			addChild(bar);
			
			bar.x = 18;
			bar.y = 14;
			
			delta = -bar.width + 12;
			
			maska = new Shape();
			maska.graphics.beginFill(0x000000, 0.6);
			maska.graphics.drawRect(0, 0, barWidth+5, bar.height+7);
			maska.graphics.endFill();
			addChild(maska);
			maska.x = 17; 
			maska.y = 10;
			
			bar.mask = maska;
			bar.visible = false;
		
			if (isTimer)
			{
				timer = Window.drawText(TimeConverter.timeToStr(127), {
					color:			timeColor,
					borderColor:	timeborderColor,
					fontSize:		timeSize,
					textAlign:		'center',
					width:			settings.width - 20
				});
				//timer.border = true;
				addChild(timer);
				timer.y = bar.height - timer.textHeight / 2 + 2;
				
				timer.x = (settings.width - timer.width) / 2 + 25;
				if (settings.hasOwnProperty('timerX')) 
				{
					timer.x += settings.timerX;	
				}
				if (settings.hasOwnProperty('timerY')) 
				{
					timer.y += settings.timerY;	
				}
				timer.height = timer.textHeight;
				
				timer.visible = false;
			}
		}
		
		public function start():void
		{
			if (timer)
				timer.visible = true;
			
			bar.visible = true;
		}
		
		public function set time(value:int):void
		{
			if(timeFormat == TimeConverter.H_M_S)
				timer.text = TimeConverter.timeToStr(value);
			else
				timer.text = TimeConverter.minutesToStr(value);
		}
		
		public function set progress(value:Number):void
		{
			maska.width = barWidth * value;
		}
		
		public function dispose():void
		{
			win = null;
			bar.dispose();
		}
	}
}

import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import wins.Window;

internal class CookingPanelBar extends Sprite {
	
	private var bgL:Bitmap = new Bitmap(/*Window.textures.progressBarPink*/);//cookingBarL
	private var bgM:Bitmap = new Bitmap(/*Window.textures.cookingBarM*/);
	private var bgR:Bitmap = new Bitmap(/*Window.textures.cookingBarR*/);
	private var lines:Bitmap = new Bitmap(Window.textures.progressBar);//cookingPanelBarLines
	private var Xs:int = 0;
	private var maska:Shape;
	
	public function CookingPanelBar(_width:int, typeLine:String,cook:Boolean = false) {
		var progress:Bitmap = Window.backingShort(_width, typeLine);
		addChild(progress);
		if (cook) {
			addChild(lines);
			Xs = _width + 10 - lines.width;
			lines.x = Xs;	
			
			maska = new Shape();
			maska.graphics.beginFill(0x000000, 0.6);
			maska.graphics.drawRoundRect(1, 1, _width - 2, bgR.height - 2, 15, 15);
			maska.graphics.endFill();
			addChild(maska);
			
			lines.mask = maska;
			
			App.self.setOnEnterFrame(refresh);
		}
	}
	
	private function refresh(e:Event = null):void {
		if (lines.x < Xs + 40) {
			lines.x += 1;
		} else {
			lines.x = Xs;
		}
	}
	
	public function dispose():void {
		App.self.setOffEnterFrame(refresh);
	}
}