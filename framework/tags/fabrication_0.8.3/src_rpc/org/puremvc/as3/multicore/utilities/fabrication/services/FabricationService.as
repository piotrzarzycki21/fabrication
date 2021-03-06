package org.puremvc.as3.multicore.utilities.fabrication.services {
    import flash.events.EventDispatcher;
    import flash.utils.Dictionary;
    import flash.utils.setTimeout;

    import mx.core.mx_internal;
    import mx.managers.CursorManager;
    import mx.rpc.AsyncToken;
    import mx.rpc.Fault;
    import mx.rpc.events.FaultEvent;
    import mx.rpc.events.ResultEvent;
    import mx.utils.UIDUtil;

    import org.puremvc.as3.multicore.utilities.fabrication.injection.DependencyInjector;
    import org.puremvc.as3.multicore.utilities.fabrication.interfaces.IDisposable;
    import org.puremvc.as3.multicore.utilities.fabrication.patterns.facade.FabricationFacade;

    public class FabricationService extends EventDispatcher implements IDisposable {

        public var showBusyCursor:Boolean;

        private var injectionFieldsNames:Array;
        private var _calls:Dictionary;


        public function FabricationService()
        {
            _calls = new Dictionary(true);
        }

        public function createMockResult(mockData:Object, delay:int = 10):AsyncToken
        {

            var token:MockAsyncToken = createToken(delay);
            token.data = mockData;

            var uniqueId:String = UIDUtil.getUID(token);
            setTimeout(sendMockResult, delay, uniqueId);
            _calls[ uniqueId  ] = token;

            return token;
        }

        public function createMockFault(fault:Fault = null, delay:int = 10):AsyncToken
        {
            var token:AsyncToken = createToken(delay);
            token.data = fault;

            var uniqueId:String = UIDUtil.getUID(token);
            setTimeout(sendMockFault, delay, uniqueId);
            _calls[ uniqueId  ] = token;

            return token;
        }

        protected function sendMockResult(uniqueId:String):void
        {
            var token:MockAsyncToken = getToken(uniqueId);
            if (token) {

                var mockData:Object = token.data ? token.data : {};
                token.mx_internal::applyResult(ResultEvent.createEvent(mockData, token));

            }

        }


        private function createToken(delay:int):MockAsyncToken
        {
            var token:MockAsyncToken = new MockAsyncToken();

            if (showBusyCursor) {
                CursorManager.setBusyCursor();
            }
            return token;
        }

        protected function sendMockFault(uniqueId:String):void
        {
            var token:MockAsyncToken = getToken(uniqueId);
            if (token) {

                var fault:Fault = token.data ? token.data as Fault : null;
                token.mx_internal::applyFault(FaultEvent.createEvent(fault, token));

            }
        }

        private function getToken(uniqueId:String):MockAsyncToken
        {
            if (showBusyCursor) {
                CursorManager.removeBusyCursor();
            }

            if (_calls[ uniqueId ] is MockAsyncToken) {
                var token:MockAsyncToken = _calls[ uniqueId ];
                delete _calls[ uniqueId ];
                return token;
            }
            return null;
        }

        public function performInjections(facade:FabricationFacade):void
        {
            injectionFieldsNames = ( new DependencyInjector(facade, this) ).inject();
        }

        /**
         * @inheritDoc
         */
        public function dispose():void
        {
            for each(var uniqueId:String in _calls) {

                delete _calls[ uniqueId ];

            }
            _calls = null;

            if (injectionFieldsNames) {
                var injectedFieldsNum:uint = injectionFieldsNames.length;
                for (var i:int = 0; i < injectedFieldsNum; i++) {

                    var fieldName:String = "" + injectionFieldsNames[i];
                    var ob:Object = this[ fieldName ];
                    if (ob is IDisposable)
                        ( ob as IDisposable ).dispose();
                    this[ fieldName ] = null;
                }
                injectionFieldsNames = null;
            }

        }
    }
}

import mx.rpc.AsyncToken;

class MockAsyncToken extends AsyncToken {

    private var _data:Object;


    public function get data():Object
    {
        return _data;
    }

    public function set data(value:Object):void
    {
        _data = value;
    }
}