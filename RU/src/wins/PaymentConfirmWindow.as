package wins 
{
	import buttons.Button;
	import core.Load;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class PaymentConfirmWindow extends Window 
	{
		public var background:Bitmap;
		public var text:TextField;
		public var countText:TextField;
		public var questionMark:TextField;
		public var diamond:Bitmap;
		public var denyBttn:Button;
		public var applyBttn:Button;
		
		public function PaymentConfirmWindow(settings:Object=null) 
		{
			if (settings == null) {
				settings = new Object();
			}
			
			settings['count'] = settings.count;
			settings['event'] = settings.event;
			settings['title'] = settings.title;
			settings['text'] = settings.text;
			settings['width'] = 490;
			settings['height'] = 230;			
			settings['hasTitle'] = true;
			settings['hasButtons'] = true;
			settings['hasPaginator'] = false;
			settings['callback'] = settings.callback || null;			
			settings['mID'] = ((settings.mID == undefined) ||(settings.mID == '')||(App.user.stock.count(settings.mID) <= 0))?Stock.FANT:settings.mID;			
			settings['faderAsClose'] = false;
			settings['faderClickable'] = false;			
			settings['popup'] = true;			
			
			super(settings);	
		}
		
		override public function drawBackground():void {
			background = backing(settings.width, settings.height, 30, 'paperWithBacking');
			layer.addChild(background);
			background.y = 10;
		}
		
		override public function drawTitle():void 
		{
			titleLabel = titleText( {
				title				: settings.title,
				color				: settings.fontColor,
				multiline			: settings.multiline,
				fontSize			: settings.fontSize,				
				textLeading	 		: settings.textLeading,				
				borderColor 		: settings.fontBorderColor,			
				borderSize 			: settings.fontBorderSize,						
				shadowBorderColor	: settings.shadowBorderColor || settings.fontColor,
				width				: settings.width - 140,
				textAlign			: 'center',
				sharpness 			: 50,
				thickness			: 50,
				border				: true
			})
			
			titleLabel.x = (settings.width - titleLabel.width) * .5;
			titleLabel.y = 0;
			titleLabel.mouseChildren = titleLabel.mouseEnabled = false;
		//	headerContainer.addChild(titleLabel);
			headerContainer.y = -10;
			headerContainer.mouseEnabled = false;
		}
		
		override public function drawBody():void 
		{
			//drawMirrowObjs('diamondsTop', settings.width / 2 - settings.titleWidth / 2 - 1, settings.width / 2 + settings.titleWidth / 2 + 1, -40, true, true);
			
			text = drawText(settings.text, {//Вы действительно хотите заплатить?
				width		:400,
				fontSize	:28,
				textAlign	:"center",
				color		:0x83532d,
				borderColor	:0xffffff,
				multiline	:true,
				wrap		:true
			});
			
			layer.addChild(text);
			text.x = (background.x + (background.width / 2)) - (text.width / 2) + 5;
			text.y = background.y + (background.height / 2) - 15;
			
			countText = drawText(""+settings.count, {
				width		:275,
				fontSize	:43,
				textAlign	:"center",
				color		:0xc3e3f8,
				borderColor	:0x222363,
				multiline	:true,
				wrap		:true
			});
				
			layer.addChild(countText);
			countText.x = text.x + 90;
			countText.y = text.y - 55;
			
			questionMark = drawText("?", {
				width		:400,
				fontSize	:50,
				textAlign	:"center",
				color		:0x83532d,
				borderColor	:0xffffff,
				multiline	:true,
				wrap		:true
			});
			
			//layer.addChild(questionMark);
			questionMark.x = countText.x - 30;
			questionMark.y = countText.y - 5;
			
			diamond = new Bitmap();
			layer.addChild(diamond);
			Load.loading(
				Config.getIcon(App.data.storage[settings.mID].type, App.data.storage[settings.mID].preview),
				function(data:Bitmap):void{
					diamond.bitmapData = data.bitmapData;
					diamond.scaleX = diamond.scaleY = 0.4;
					diamond.smoothing = true;
					diamond.x = countText.x + 65;
					diamond.y = text.y - 55;
				}
			);
			
			denyBttn = new Button( {
				width:155,
				height:45,
				fontSize:25,
				caption:Locale.__e("flash:1382952380008"),//Отменить
				bgColor:[0xf3c68d,0xdaa677]
			});
		
			layer.addChild(denyBttn);
			denyBttn.x = background.x + (background.width / 2) - denyBttn.width - 10;
			denyBttn.y = background.y + background.height - denyBttn.height - 30;
			denyBttn.addEventListener(MouseEvent.CLICK, close);
			
			applyBttn = new Button( {
				width:155,
				height:45,
				fontSize:30,
				caption:Locale.__e("flash:1448460114881"),//Подтвердить
				bgColor:[0x9bc6fb, 0x5b8cf5],
				//borderColor:[0xb0dcff,0x3b6cd5]
				bevelColor:[0xb0dcff,0x3b6cd5]
			});
			
			layer.addChild(applyBttn);
			applyBttn.x = background.x + (background.width / 2) + 20;
			applyBttn.y = background.y + background.height - applyBttn.height - 30;
			applyBttn.addEventListener(MouseEvent.CLICK, onConfirmBttn);
		}	
		
		public function onConfirmBttn(e:MouseEvent):void {
			if (settings.confirm is Function) {
				settings.confirm();
			}
			close();
		}
	}

}