package hlp 
{
	import com.junkbyte.console.Cc;
	import core.Log;
	import utils.Saver;
	/**
	 * ...
	 * @author Andrey S
	 */
	public class ConsoleCommands {
		public static function enableSlashCommands():void {
			Cc.commandLine = true;
			Cc.addSlashCommand('add', function():void {
				QickResourcesBuyManager.init();
				Cc.visible = false;
			});
			Cc.addSlashCommand('addsid', function(sidNum:int):void {
				QickResourcesBuyManager.initBySid(sidNum);
				Cc.visible = false;
			});
			Cc.addSlashCommand('add2', function():void {
				PropsTool.init();
				Cc.visible = false;
			});
			Cc.addSlashCommand('remove2', function():void {
				PropsTool.remove();
				Cc.visible = false;
			});
			Cc.addSlashCommand('fakeMode', function():void {
				App.self.fakeMode = !App.self.fakeMode;
				Log.alert('fake mode = '+String(App.self.fakeMode));
				Cc.visible = false;
			});
			Cc.addSlashCommand('getsid', function(sidNum:int):void {
				QickResourcesBuyManager.getSid(sidNum);
				Cc.visible = false;
			});
			Cc.addSlashCommand('q+', function(qid:int):void {
				QickResourcesBuyManager.addQuest(qid);
				Cc.visible = false;
			});
			Cc.addSlashCommand('getupd', function(qid:int):void {
				QickResourcesBuyManager.getupd(qid);
				Cc.visible = false;
			});
			Cc.addSlashCommand('gitems', function(list:String):void {
				QickResourcesBuyManager.getItems(list);
				Cc.visible = false;
			});
			Cc.addSlashCommand('sm', function():void {
				Saver.saveMapUnits();
				Cc.visible = false;
			});
		}
	}
}