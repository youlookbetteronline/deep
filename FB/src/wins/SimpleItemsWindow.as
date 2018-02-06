package wins 
{
	import buttons.Button;
	import buttons.SimpleButton;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import flash.text.TextField;
	/**
	 * ...
	 * @author ...
	 */
	public class SimpleItemsWindow extends Window 
	{
		
		public function SimpleItemsWindow(settings:Object=null) 
		{
			settings['hasPaginator'] 	= false;
			settings['background'] 		= 'workerHouseBacking';
			settings['width'] 			= 530;
			settings['height'] 			= 280;
			settings['fontColor']		= 0xffffff;
			settings['fontBorderColor'] = 0x085c10;
			settings['borderColor'] 	= 0x085c10;
			settings['shadowColor'] 	= 0x085c10;
			settings['fontSize'] 		= 40;
			settings['fontBorderSize'] 	= 2;
			settings['shadowSize'] 		= 2;
			settings['hasRibbon'] 		= true;
			settings['title'] 			= Locale.__e('flash:1474469531767');
			super(settings);
			content = settings.content;
			
		}
		
		override public function drawBody():void {
			var X:int = 0;
			var itemContainer:Sprite = new Sprite();
			
			drawRibbon();
			titleLabel.y += 15;
			exit.y -= 20;
			exit.x -= 10;
			
			var description:TextField = Window.drawText(Locale.__e('flash:1508242663004'), {
				color		:0xfede33,
				borderColor	:0x6e411e,
				width		:350,
				fontSize	:34,
				multiline	:false,
				textAlign	:"left",
				wrap		:false,
				background	: false
			})

			var itemsBg:Shape = new Shape();
				itemsBg.graphics.beginFill(0xffffff);
				itemsBg.graphics.drawRect(0, 0, settings.width - 140, 100);
				itemsBg.graphics.endFill();
				itemsBg.filters = [new BlurFilter(40, 0, 2)];
				itemsBg.alpha = .4;
				
			for (var i:int = 0; i < content.length ; i++) 
			{
				var item:MaterialItem = new MaterialItem(content[i])
				item.x = X;
				itemContainer.addChild(item);
				X += item.width + 10;
			}	
			
			var bttn:Button = new Button( {
				width			:195,
				height			:60,
				radius			:19,
				fontSize		:36,
				textAlign		:'center',
				caption			:Locale.__e('flash:1505734812208'),
				fontBorderColor	:0x762e00,	
				bgColor			:[0xfed131,0xf8ab1a],
				bevelColor		:[0xf7fe9a, 0xf8ab1a]
			});
			
			bttn.x = (settings.width - bttn.width) / 2;
			bttn.y = settings.height - bttn.height - 25;
			
			
			description.x = (settings.width -  description.textWidth) / 2;
			description.y = 35;
			
			itemContainer.x = (settings.width - itemContainer.width) / 2;
			itemContainer.y = 100;
			
			itemsBg.x = (settings.width - itemsBg.width) / 2;
			itemsBg.y = itemContainer.y + (itemContainer.height - itemsBg.height) / 2;
			
			bodyContainer.addChild(itemsBg);
			bodyContainer.addChild(description);
			bodyContainer.addChild(itemContainer);
			bodyContainer.addChild(bttn);
		}
		
		override public function drawBackground():void 
		{
			super.drawBackground();
			var whiteBg:Bitmap = Window.backing(settings.width - 70, settings.height - 70, 30 , 'itemBacking' );
			whiteBg.x = whiteBg.y = 35;
			layer.addChild(whiteBg);
		}
		
	}

}
import adobe.utils.CustomActions;
import com.flashdynamix.motion.extras.BitmapTiler;
import core.Load;
import core.Size;
import flash.display.Bitmap;
import flash.display.BitmapData;

internal class MaterialItem extends LayerX
{
	public function MaterialItem (sid:int):void 
	{
		var item:Object = App.data.storage[sid];
		var bg:Bitmap = new Bitmap(new BitmapData(75, 75))
		bg.visible = false;
		addChild(bg)
		
		var icon:Bitmap = new Bitmap();
		
		Load.loading(Config.getIcon(item.type, item.preview), function (data:Bitmap):void 
		{
			icon.bitmapData = data.bitmapData;
			Size.size(icon, 75, 75);
			icon.smoothing = true;
			addChild(icon)
		})
	}
}