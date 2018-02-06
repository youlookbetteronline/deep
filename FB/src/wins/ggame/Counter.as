/**
 * Created by Andrew on 15.05.2017.
 */
package wins.ggame {
	import buttons.ImageButton;
	import core.Size;
	import wins.BanksWindow;

	import core.Load;

	import flash.display.Bitmap;
	import flash.events.MouseEvent;

	import flash.text.TextField;

	import ui.UserInterface;

	import wins.PurchaseWindow;

	import wins.Window;

	public class Counter extends LayerX
	{
		private var back:Bitmap;
		private var plusBttn:ImageButton;
		private var countLabel:TextField;
		private var info:Object;
		private var currency:int;
		private var icon:Bitmap;;
		private var _searchEnabled:Boolean = true;

		public function Counter(currency:int, count:int, params:Object = null) {
			this.currency = currency;

			if(App.data.storage[currency])
			{
				info = App.data.storage[currency];
			}
			else
			{
				info = {};
				info.type   = params.type;
				info.view   = params.view;
				info.scale  = params.scale || 1;
			}

			//back = Window.backing(130, 45, 10, "itemBacking");
			back = new Bitmap(UserInterface.textures.moneyPanel);
			addChild(back);

			plusBttn = new ImageButton(UserInterface.textures.coinsPlusBttn, {});
			plusBttn.x = back.width - plusBttn.width * 0.5;
			plusBttn.y = 2;
			plusBttn.addEventListener(MouseEvent.CLICK, onPlus);
			addChild(plusBttn);
			plusBttn.visible = !(params && params.buy === false);
			_searchEnabled = !(params && params.searchEnabled == false);

			countLabel = Window.drawText(count.toString(), {
				width:		back.width,
				color:		0xfefefe,
				borderColor:0x0c4065,
				textAlign:	'center',
				fontSize:	22
			});
			countLabel.y = 9;
			addChild(countLabel);

			Load.loading(Config.getIcon(info.type, info.view), function(data:*):void {
			
				icon = new Bitmap(data.bitmapData);
				Size.size(icon, 40,40)
				icon.smoothing = true;
				icon.x = -15;
				icon.y = back.height * 0.5 - icon.height * 0.5 + 3;
				addChild(icon);
			});
			
			tip = function():Object {
				return {
					title:		info.title,
					text:		info.description
				}
			}
		}

		public function onPlus(e:MouseEvent):void {
			//window.getCurrency();
			if (currency == Stock.FANT) {
				Window.closeAll();
				new BanksWindow( { section:BanksWindow.REALS } ).show();
				return;
			}

			//var content:Array = PurchaseWindow.createContent('Energy', { view:App.data.storage[currency].preview } );
			var content:Array = PurchaseWindow.createContent("Energy", {inguest:0, view:App.data.storage[currency].view}, currency)
			if(content.length > 0 || true)
			{
				new PurchaseWindow( {
					popup:		true,
					width:		600,
					itemsOnPage:content.length,
					content:	content,
					title:		App.data.storage[currency].title,
					description:Locale.__e('flash:1472652747853'),
					searchEnabled:_searchEnabled
				}).show();
			}
		}

		public function update(count:int):void {
			countLabel.text = count.toString();
			if (int(countLabel.text) < 0)
				countLabel.text = String(0);
		}

		public function dispose():void
		{
			if(plusBttn)
				plusBttn.dispose();

			if(back)
			{
				if(back.parent)
					back.parent.removeChild(back);

				back = null;
			}

			if(countLabel && countLabel.parent)
			{
				countLabel.parent.removeChild(countLabel);
				countLabel = null;
			}

			if(icon && icon.parent)
			{
				icon.parent.removeChild(icon);
				icon = null;
			}
		}
	}
}
