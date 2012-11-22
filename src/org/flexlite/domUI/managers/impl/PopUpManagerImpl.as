package org.flexlite.domUI.managers.impl
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import org.flexlite.domUI.components.Rect;
	import org.flexlite.domUI.core.DomGlobals;
	import org.flexlite.domUI.core.IContainer;
	import org.flexlite.domUI.core.IUIComponent;
	import org.flexlite.domUI.core.IVisualElement;

	[ExcludeClass]
	
	/**
	 * 窗口弹出管理器实现类
	 * @author DOM
	 */
	public class PopUpManagerImpl extends EventDispatcher
	{
		/**
		 * 构造函数
		 */		
		public function PopUpManagerImpl()
		{
		}
		
		/**
		 * 模态窗口列表
		 */		
		private var popUpList:Vector.<PopUpData> = new Vector.<PopUpData>();
		/**
		 * 根据popUp获取对应的popUpData
		 */		
		private function findPopUpData(popUp:IVisualElement):PopUpData
		{
			for each(var data:PopUpData in popUpList)
			{
				if(data.popUp==popUp)
					return data;
			}
			return null;
		}
		/**
		 * 弹出一个窗口。<br/>
		 * @param popUp 要弹出的窗口
		 * @param modal 是否启用模态。即禁用弹出窗口所在层以下的鼠标事件。默认false。
		 * @param center 是否居中窗口。等效于在外部调用centerPopUp()来居中。默认true。
		 */		
		public function addPopUp(popUp:IVisualElement,modal:Boolean=false,center:Boolean=true):void
		{
			var data:PopUpData = findPopUpData(popUp);
			if(data)
			{
				data.modal = modal;
				popUp.removeEventListener(Event.REMOVED,onRemoved);
			}
			else
			{
				data = new PopUpData(popUp,modal);
				popUpList.push(data);
			}
			if(center)
				centerPopUp(popUp);
			DomGlobals.systemManager.popUpContainer.addElement(popUp);
			if(popUp is IUIComponent)
				IUIComponent(popUp).isPopUp = true;
			if(modal)
			{
				updateModal();
			}
			popUp.addEventListener(Event.REMOVED,onRemoved);
		}
		
		/**
		 * 从舞台移除
		 */		
		private function onRemoved(event:Event):void
		{
			var index:int = 0;
			for each(var data:PopUpData in popUpList)
			{
				if(data.popUp==event.target)
				{
					if(data.popUp is IUIComponent)
						IUIComponent(data.popUp).isPopUp = false;
					data.popUp.removeEventListener(Event.REMOVED,onRemoved);
					popUpList.splice(index,1);
					updateModal();
					break;
				}
				index++;
			}
		}
		
		private var _modalMask:IVisualElement;
		/**
		 * 模态遮罩层对象。若不设置，默认创建一个填充色为白色，透明度0.5的Rect对象作为模态遮罩。
		 */
		public function get modalMask():IVisualElement
		{
			return _modalMask;
		}
		public function set modalMask(value:IVisualElement):void
		{
			if(_modalMask==value)
				return;
			if(_modalMask&&_modalMask.parent)
				DomGlobals.systemManager.popUpContainer.removeElement(_modalMask);
			_modalMask = value;
			if(_modalMask)
			{
				_modalMask.percentHeight = _modalMask.percentWidth = NaN;
				_modalMask.top = _modalMask.bottom = _modalMask.left = _modalMask.right = 0;
				DomGlobals.systemManager.popUpContainer.addElement(_modalMask);
			}
			updateModal();
		}

		
		/**
		 * 更新窗口模态效果
		 */		
		private function updateModal():void
		{
			var popUpContainer:IContainer = DomGlobals.systemManager.popUpContainer;
			if(!modalMask)
			{
				_modalMask = new Rect();
				_modalMask.alpha = 0.5;
				_modalMask.top = _modalMask.left = _modalMask.right = _modalMask.bottom = 0;
				popUpContainer.addElement(_modalMask);
			}
			var found:Boolean = false;
			for(var i:int = popUpContainer.numElements-1;i>=0;i--)
			{
				var element:IVisualElement = popUpContainer.getElementAt(i);
				var data:PopUpData = findPopUpData(element);
				if(data&&data.modal)
				{
					found = true;
					break;
				}
			}
			if(found)
			{
				if(popUpContainer.getElementIndex(modalMask)<i)
					i--;
				popUpContainer.setElementIndex(modalMask,i);
			}
			modalMask.visible = found;
		}
		
		/**
		 * 移除由addPopUp()方法弹出的窗口。
		 * @param popUp 要移除的窗口
		 */		
		public function removePopUp(popUp:IVisualElement):void
		{
			if(popUp && popUp.parent&&findPopUpData(popUp))
			{
				DomGlobals.systemManager.popUpContainer.removeElement(popUp);
			}
		}
		
		/**
		 * 将指定窗口居中显示
		 * @param popUp 要居中显示的窗口
		 */
		public function centerPopUp(popUp:IVisualElement):void
		{
			popUp.percentHeight = popUp.percentWidth = NaN;
			popUp.top = popUp.bottom = popUp.left = popUp.right = NaN;
			popUp.verticalCenter = popUp.horizontalCenter = 0;
		}
		
		/**
		 * 将指定窗口的层级调至最前
		 * @param popUp 要最前显示的窗口
		 */		
		public function bringToFront(popUp:IVisualElement):void
		{
			var data:PopUpData = findPopUpData(popUp);
			if(data&&popUp.parent)
			{
				var popUpContainer:IContainer = DomGlobals.systemManager.popUpContainer;
				popUp.removeEventListener(Event.REMOVED,onRemoved);
				popUpContainer.setElementIndex(popUp,popUpContainer.numElements-1);
				popUp.addEventListener(Event.REMOVED,onRemoved);
				updateModal();
			}
		}
	}
}
import org.flexlite.domUI.core.IVisualElement;

class PopUpData
{
	public function PopUpData(popUp:IVisualElement,modal:Boolean)
	{
		this.popUp = popUp;
		this.modal = modal;
	}
	
	public var popUp:IVisualElement;
	
	public var modal:Boolean;
}
