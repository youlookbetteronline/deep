package wins 
{
	import buttons.Button;
	import core.Numbers;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class SimpleRewardWindow extends Window 
	{
		private var bonus:Object;
		private var contentSprite:Sprite = new Sprite();;
		private var item:RewardItem;
		private var backDesc2:Shape
		public function SimpleRewardWindow(settings:Object=null) 
		{
			if (settings.hasOwnProperty('bonus'))
				this.bonus = settings.bonus;
			settings['title'] = Locale.__e('flash:1393579648825');
			settings['fontColor']  = 0xffffff;
			settings['fontBorderColor'] = 0x116011;
			settings['borderColor']  = 0x116011;
			settings['shadowColor']  = 0x116011;
			settings['fontSize']   = 42;
			settings['fontBorderSize']  = 3;
			settings['shadowSize']   = 2;
			settings['hasPaginator']  = false;
			settings['width'] = 620;
			settings['height'] = 320;
			if (Numbers.countProps(bonus) > 4)
				settings['height'] = 440;
			super(settings);
		}

		override public function drawBackground():void 
		{
			var background:Bitmap = backing(settings.width, settings.height, 50, 'paperScroll');
			layer.addChild(background);
		}
		
		override public function drawBody():void 
		{
			drawRibbon();
			titleLabel.y += 11;
			exit.y -= 20;
			
			var backDesc:Shape = new Shape();
			backDesc.graphics.beginFill(0xfceaaf);
			backDesc.graphics.drawRect(0, 0, 470, 60)
			backDesc.graphics.endFill();
			backDesc.filters = [new BlurFilter(30, 0, 10)];
			backDesc.x = (settings.width - backDesc.width) / 2;
			backDesc.y = 40;
			bodyContainer.addChild(backDesc);
			
			var descText:TextField = Window.drawText(Locale.__e('flash:1503318940595'), {
				color		:0x804116,
				fontSize	:32,
				width		:380,
				border		:false,
				textAlign	:"center"
			});
			descText.x = (settings.width - descText.width) / 2;
			descText.y = backDesc.y + (backDesc.height - descText.height) / 2;
			bodyContainer.addChild(descText);
			
			var backHeight:int = Numbers.countProps(bonus)>4?225:110
			backDesc2 = new Shape();
			backDesc2.graphics.beginFill(0xffffff, .6);
			backDesc2.graphics.drawRect(0, 0, 470, backHeight)
			backDesc2.graphics.endFill();
			backDesc2.filters = [new BlurFilter(30, 0, 10)];
			backDesc2.x = (settings.width - backDesc2.width) / 2;
			backDesc2.y = backDesc.y + backDesc.height + 15;
			bodyContainer.addChild(backDesc2);
			
			var rewBttn:Button = new Button({
				caption		:Locale.__e('flash:1382952380298'),
				fontSize	:38,
				width		:210,
				height		:56
			});
			rewBttn.x = (settings.width - rewBttn.width) / 2;
			rewBttn.y = settings.height - rewBttn.height - 25;	
			bodyContainer.addChild(rewBttn);
			rewBttn.addEventListener(MouseEvent.CLICK, onTake);
			
			contentChange();
		}
		
		private function onTake(e:*):void 
		{
			if (e.currentTarget.mode == Button.DISABLED)
				return;
			Window.closeAll();
		}
		
		override public function contentChange():void 
		{
			var X:int = 0;
			var Y:int = 0;
			for (var i:int = 0; i < Numbers.countProps(bonus) ; i++)
			{
				item = new RewardItem(Numbers.getProp(bonus, i).key, Numbers.getProp(bonus, i).val);
				contentSprite.addChild(item);
				item.x = X;
				item.y = Y;
				if ((i + 1) % 4 == 0)
				{
					Y += item.height + 20;
					X = 0;
				}
				else
					X += item.bg.width + 25;
			}
			contentSprite.x = 125;
			contentSprite.y = 170;
			bodyContainer.addChild(contentSprite)
		}

	}

}
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.Shape;
import flash.display.Sprite;
import flash.text.TextField;
import wins.Window;

internal class RewardItem extends LayerX
{
	public var bg:Shape = new Shape();
	private var sid:int;
	private var count:int;
	private var bitmap:Bitmap = new Bitmap();
	public function RewardItem(sid:int, count:int)
	{
		this.count = count;
		this.sid = sid;
		bg.graphics.beginFill(0xf9d2ac, 1)
		bg.graphics.drawCircle(0, 0, 45)
		bg.graphics.endFill();
		addChild(bg);
		
		Load.loading(Config.getIcon(App.data.storage[sid].type, App.data.storage[sid].preview), onLoad) 
		
		this.tip = function():Object
		{
			return{
				title	:App.data.storage[sid].title,
				text	:App.data.storage[sid].description
			}
		}
	}
	
	private function onLoad(data:*):void 
	{
		bitmap.bitmapData = data.bitmapData
		Size.size(bitmap, 65, 65);
		bitmap.smoothing = true;
		bitmap.x = bg.x + (bg.width - bitmap.width) / 2 - bg.width / 2;
		bitmap.y = bg.y + (bg.height - bitmap.height) / 2 - bg.height / 2;
		addChild(bitmap);
		
		var countText:TextField = Window.drawText('x'+String(count), {
			color		:0xffffff,
			borderColor	:0x7f3d0e,
			fontSize	:32,
			textAlign	:"center"
		});
		countText.x = bitmap.x + bitmap.width - countText.width / 2;
		countText.y = bitmap.y + bitmap.height - countText.height / 2;
		addChild(countText);
	}
}