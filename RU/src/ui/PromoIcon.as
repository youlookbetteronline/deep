package ui 
{
	import core.Load;
	import core.Size;
	import core.TimeConverter;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import wins.ActionInformerWindow;
	import wins.BanksWindow;
	import wins.PremiumActionWindow;
	import wins.PromoWindow;
	import wins.SaleLimitWindow;
	import wins.SalesWindow;
	import wins.ThematicalSaleWindow;
	import wins.TriggerPromoWindow;
	/**
	 * ...
	 * @author 
	 */
	public class PromoIcon extends SalesIcon 
	{
		public function PromoIcon(promo:Object, params:Object=null) 
		{
			super(promo, params);
		}
		
		override public function onClick(e:MouseEvent = null):void 
		{
			var target:*;
			if (e) 
			{
				target = e.currentTarget;
				target.hideGlowing();
				target.hidePointing();
			}
			
			if (App.data.actions.hasOwnProperty(pID))
			{
				var action:Object = App.data.actions[pID];
				
				if (action.bg && action.bg == 'ActionInformerWindow') 
				{
					new ActionInformerWindow( { pID:pID } ).show();
					return;
				}	
				if (action.bg && action.bg == 'SaleLimitWindow') 
				{
					new SaleLimitWindow( { pID:pID } ).show();
					return;
				}
				if (action.bg && action.bg == 'PremiumActionWindow') 
				{
					new PremiumActionWindow( { pID:pID } ).show();
					return;
				}				
			}
			
			if (target.settings['sale'] == 'premium')
			{
				new SaleLimitWindow({pID:pID}).show();
				return;
			}
			
			if (target.settings['sale'] == 'bankSale')
			{
				new BanksWindow().show();
				return;
			}
			
			if ( App.data.actions.hasOwnProperty(pID) && App.data.actions[pID].type == 3)
			{
				new TriggerPromoWindow( { pID:pID } ).show();
				return;
			}
			
			if (target.settings['sale'] == 'promo' && App.data.actions.hasOwnProperty(pID))
			{
				new PromoWindow( { pID:pID } ).show();
				App.user.unprimeAction(pID);
				return;
			}
			
			if (target.settings['sale'] == 'bankSale' && !App.isSocial('SP'))
			{
				new BanksWindow().show();
				return;
			}
			
			if (target.settings['sale'] == 'sales' && App.data.sales.hasOwnProperty(pID))
			{
				new SalesWindow({
						ID:pID,
						action:App.data.sales[pID],
						mode:SalesWindow.SALES
					}).show();
				return;
			}
			
			if (target.settings['sale'] == 'bigSale' && App.data.bigsale.hasOwnProperty(pID))
			{
				new ThematicalSaleWindow({ pID:pID }).show();
				return;
			}
			
			if (App.data.bulks.hasOwnProperty(pID))
			{
				new SalesWindow( {
					action:App.data.bulks[pID],
					pID:pID,
					mode:SalesWindow.BULKS,
					width:670,
					title:Locale.__e('flash:1385132402486')
				}).show();
				return;
			}
		}
		
		override protected function drawTitle():void 
		{
			drawPromoIcon();
		}
		
	}

}