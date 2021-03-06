package shell.controller {
	import org.puremvc.as3.multicore.patterns.observer.Notification;	
	
	import shell.FabricationRoutingDemoShellConstants;	
	import shell.model.ModuleDescriptor;	
	import shell.model.ListProxy;	
	
	import org.puremvc.as3.multicore.interfaces.INotification;	
	import org.puremvc.as3.multicore.utilities.fabrication.patterns.command.SimpleFabricationCommand;	
	
	/**
	 * @author Darshan Sawardekar
	 */
	public class RemoveModuleCommand extends SimpleFabricationCommand {
		
		override public function execute(note:INotification):void {
			var moduleDescriptor:ModuleDescriptor = note.getBody() as ModuleDescriptor;
			var moduleListProxy:ListProxy = retrieveProxy(ListProxy.NAME) as ListProxy;
			
			moduleListProxy.remove(moduleDescriptor);
			executeCommand(ChangeSelectedModuleCommand, null);
		}
	}
}
