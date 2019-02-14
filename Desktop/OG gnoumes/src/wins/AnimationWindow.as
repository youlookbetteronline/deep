package wins 
{
	import com.greensock.TweenLite;
	import enixan.Util;
	import enixan.components.Button;
	import enixan.components.CheckBox;
	import enixan.components.NumericBox;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import wins.Window;
	
	public class AnimationWindow extends Window 
	{
		
		private var animInfo:AnimInfo;
		private var fromTitleLabel:TextField;
		private var toTitleLabel:TextField;
		private var fromLabel:TextField;
		private var toLabel:TextField;
		private var pingpongBox:CheckBox;
		private var numericBox:NumericBox;
		private var framesLabel:TextField;
		private var createBttn:Button;
		private var applyBttn:Button;
		
		private var interval:int;
		
		public function AnimationWindow(params:Object=null) 
		{
			if (!params) params = { };
			params.width = Main.appWidth - 250;
			params.height = 140;
			params.faderAlpha = 0;
			
			animInfo = params.animInfo;
			
			super(params);
			
			closeBttn.x = container.x + params.width - closeBttn.width - 4;
			closeBttn.y = container.y - closeBttn.height - 4;
			
			interval = setInterval(onUpdate, 100);
		}
		
		private function onUpdate():void {
			if (framesLabel && framesLabel.selectionBeginIndex == framesLabel.selectionEndIndex) {
				var select:int = framesLabel.selectionBeginIndex;
				var string:String = framesLabel.text;
				var prev:int = string.lastIndexOf(',', select - 1);
				var next:int = string.indexOf(',', select);
				var frame:String;
				
				if (prev == select - 1 && next > select) {
					frame = string.substring(prev + 1, next);
				}else if (prev < select && next >= select) {
					frame = string.substring(prev + 1, next);
				}else if (prev > 0 && next < 0) {
					frame = string.substring(prev + 1, string.length);
				}
				
				if (!isNaN(int(frame))) {
					Main.app.animationSetFrame(int(frame));
				}
			}
		}
		
		override public function draw():void {
			super.draw();
			
			container.x = -int(this.params.width * 0.5);
			container.y = Main.appHeight * 0.5 - this.params.height;
			
			fromTitleLabel = Util.drawText( {
				text:			'От:',
				color:			0xffffff
			});
			fromTitleLabel.x = 5;
			fromTitleLabel.y = 10;
			container.addChild(fromTitleLabel);
			
			fromLabel = Util.drawText( {
				text:			'0',
				width:			40,
				color:			0x111111,
				border:			true,
				borderColor:	0x000000,
				background:		true,
				backgroundColor:0xffffff,
				type:			'input',
				textAlign:		'center'
			});
			fromLabel.restrict = '0-9';
			fromLabel.maxChars = 3;
			fromLabel.x = fromTitleLabel.x + fromTitleLabel.width + 2;
			fromLabel.y = fromTitleLabel.y;
			container.addChild(fromLabel);
			
			toTitleLabel = Util.drawText( {
				text:			'До:',
				color:			0xffffff
			});
			toTitleLabel.x = fromLabel.x + fromLabel.width + 8;
			toTitleLabel.y = fromTitleLabel.y;
			container.addChild(toTitleLabel);
			
			toLabel = Util.drawText( {
				text:			toValue.toString(),
				width:			40,
				color:			0x111111,
				border:			true,
				borderColor:	0x000000,
				background:		true,
				backgroundColor:0xffffff,
				type:			'input',
				textAlign:		'center'
			});
			toLabel.restrict = '0-9';
			toLabel.maxChars = 3;
			toLabel.x = toTitleLabel.x + toTitleLabel.width + 2;
			toLabel.y = fromTitleLabel.y;
			container.addChild(toLabel);
			
			numericBox = new NumericBox( {
				current:	(animInfo) ? animInfo.repeat : 3,
				step:		1,
				minValue:	1,
				maxValue:	30
			});
			numericBox.x = 10;
			numericBox.y = toLabel.y + toLabel.height + 10;
			container.addChild(numericBox);
			
			pingpongBox = new CheckBox( {
				width:			16,
				height:			16,
				text:			'Вперед-назад',
				textParams:		{
					size:		12
				}
			});
			pingpongBox.x = 26;
			pingpongBox.y = numericBox.y + numericBox.height + 10;
			container.addChild(pingpongBox);
			
			framesLabel = Util.drawText( {
				text:			(animInfo) ? animInfo.chain.toString() : '',
				width:			params.width - 180,
				height:			params.height - 20,
				color:			0x111111,
				border:			true,
				borderColor:	0x000000,
				background:		true,
				backgroundColor:0xffffff,
				type:			'input',
				wordWrap:		true,
				multiline:		true
			});
			framesLabel.restrict = '\,0-9\s\l\n\t ';
			framesLabel.x = 170;
			framesLabel.y = 10;
			container.addChild(framesLabel);
			
			//
			createBttn = new Button( {
				width:		80,
				height:		27,
				label:		'Создать',
				click:		createChain
			});
			createBttn.x = 5;
			createBttn.y = pingpongBox.y + pingpongBox.height + 9;
			container.addChild(createBttn);
			
			/*applyBttn = new Button( {
				width:		80,
				height:		27,
				label:		'Применить',
				color1:		0x99cc33,
				color2:		0x669922,
				click:		apply
			});
			applyBttn.x = createBttn.x + createBttn.width;
			applyBttn.y = createBttn.y;
			container.addChild(applyBttn);
			if (!animInfo) applyBttn.state = Button.DISABLE;*/
		}
		
		private function get toValue():int {
			if (animInfo && animInfo.bmds.length > 0)
				return animInfo.bmds.length - 1;
			
			return 10;
		}
		
		private function createChain():void {
			var from:int = int(fromLabel.text);
			var to:int = int(toLabel.text);
			var i:int;
			var chain:Array = [];
			
			if (isNaN(from) || isNaN(to)) return;
			
			if (from > to) {
				for (i = 0; i < from - to + 1; i++)
					chain.push(from - i);
			}else {
				for (i = 0; i < to - from + 1; i++)
					chain.push(from + i);
			}
			
			var string:String = '';
			for (i = 0; i < chain.length; i++) {
				for (var j:int = 0; j < numericBox.value; j++) {
					string += ',' + chain[i].toString();
				}
			}
			
			if (pingpongBox.check) {
				for (i = chain.length - 2; i > 0; i--) {
					for (j = 0; j < numericBox.value; j++) {
						string += ',' + chain[i].toString();
					}
				}
			}
			
			framesLabel.text = string.substring(1, string.length);
		}
		private function apply():void {
			if (!animInfo) return;
			
			var array:Array = framesLabel.text.split(',');
			for (var i:int = 0; i < array.length; i++) {
				array[i] = int(array[i]);
				if (isNaN(array[i]) || animInfo.bmds.length <= array[i]) {
					array.splice(i, 1);
					i--;
				}
			}
			animInfo.animType = AnimInfo.ADVANCED_ANIMATION;
			animInfo.frame = array[0];
			animInfo.chain = array;
			
			Main.app.viewManager.view(animInfo);
		}
		
		override public function close(e:MouseEvent = null):void {
			if (interval) clearInterval(interval);
			
			createBttn.dispose();
			apply();
			
			super.close(e);
			
		}
		
	}

}