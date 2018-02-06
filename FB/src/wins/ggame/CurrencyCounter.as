/**
 * Created by Andrew on 12.05.2017.
 */
package wins.ggame {
	import buttons.ImageButton;
	import core.Size;
	import wins.BanksWindow;

	import core.Load;

	import core.TimeConverter;

	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	import ui.UserInterface;

	import wins.PurchaseWindow;
	import wins.SimpleWindow;
	import wins.Window;

	public class CurrencyCounter extends LayerX {

		private var back:Bitmap;
		private var plusBttn:ImageButton;

		private var countLabel:TextField;

		private var info:Object;
		private var currency:int;
		private var icon:Bitmap;

		public function CurrencyCounter(currency:int, params:Object = null) {
			this.currency = currency;

			info = App.data.storage[currency];

			//back = Window.backing(130, 45, 10, "itemBacking");
			back = new Bitmap(UserInterface.textures.moneyPanel)
			addChild(back);

			plusBttn = new ImageButton(UserInterface.textures.coinsPlusBttn, {});
			plusBttn.x = back.width - plusBttn.width * 0.5;
			plusBttn.y = 2;
			plusBttn.addEventListener(MouseEvent.CLICK, onPlus);
			addChild(plusBttn);
			plusBttn.visible = !(params && params.buy === false);

			countLabel = Window.drawText(App.user.stock.count(currency).toString(), {
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
				Size.size(icon, 40, 40)
				icon.smoothing = true;
				icon.x = -15;
				icon.y = back.height * 0.5 - icon.height * 0.5 + 3;
				addChild(icon);
			});

			App.self.addEventListener(AppEvent.ON_CHANGE_STOCK, update);

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

			//var content:Array = PurchaseWindow.createContent('Energy', { out:currency } );
			var content:Array = PurchaseWindow.createContent("Energy", {inguest:0, view:App.data.storage[currency].view}, currency)

			if(content.length > 0 || true)
			{
				new PurchaseWindow( {
					popup:		true,
					width:		600,
					itemsOnPage:content.length,
					content:	content,
					title:		App.data.storage[currency].title,
					description:Locale.__e('flash:1472652747853')
				}).show();
			}
		}

		public function update(e:AppEvent = null):void {
			countLabel.text = App.user.stock.count(currency).toString();
			//plusBttn.removeEventListener(MouseEvent.CLICK, onPlus);
		}

		public function dispose():void
		{
			App.self.removeEventListener(AppEvent.ON_CHANGE_STOCK, update);

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

