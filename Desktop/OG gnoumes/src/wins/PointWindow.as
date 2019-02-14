package wins 
{
	import enixan.Color;
	import enixan.Size;
	import enixan.Util;
	import enixan.components.Button;
	
	/**
	 * ...
	 * @author 
	 */
	public class PointWindow extends Window 
	{
		
		public function PointWindow(params:Object = null) 
		{
			if (!params) params = { };
			
			params.width = 480;
			params.height = 50 + Util.countProps(Main.storage.points) * 70;
			
			super(params);
			
		}
		
		override public function draw():void {
			
			super.draw();
			
			var data:Object = Main.storage.points;
			var list:Array = [];
			for (var s:* in data) {
				data[s]['id'] = s;
				list.push(data[s]);
			}
			list.sortOn('name');
			
			for (var i:int = 0; i < list.length; i++ ) {
				var object:Object = list[i];
				
				if (!object.name)
					object['name'] = s;
				
				var bttn:Button = new Button( {
					label:		object.name,
					color1:		object.color,
					color2:		Color.light(object.color, -0x33),
					width:		300,
					height:		60,
					click:		onClick,
					onClickParams:	object
				});
				bttn.x = 50;
				bttn.y = 30 + 70 * i;
				container.addChild(bttn);
				
				var edit:Button = new Button( {
					label:		'Настроить',
					color1:		0x444444,
					color2:		0x333333,
					width:		72,
					height:		60,
					click:		onEditClick,
					onClickParams:	object
				});
				edit.x = bttn.x + bttn.width + 10;
				edit.y = bttn.y;
				container.addChild(edit);
			}
			
		}
		
		private function onClick(object:Object):void {
			Main.app.mainView.addPoint(object.id);
			close();
		}
		private function onEditClick(object:Object):void {
			wins.PointEditWindow.edit(object);
		}
	}
}