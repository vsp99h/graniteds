/*
 *   GRANITE DATA SERVICES
 *   Copyright (C) 2006-2015 GRANITE DATA SERVICES S.A.S.
 *
 *   This file is part of the Granite Data Services Platform.
 *
 *                               ***
 *
 *   Community License: GPL 3.0
 *
 *   This file is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published
 *   by the Free Software Foundation, either version 3 of the License,
 *   or (at your option) any later version.
 *
 *   This file is distributed in the hope that it will be useful, but
 *   WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 *                               ***
 *
 *   Available Commercial License: GraniteDS SLA 1.0
 *
 *   This is the appropriate option if you are creating proprietary
 *   applications and you are not prepared to distribute and share the
 *   source code of your application under the GPL v3 license.
 *
 *   Please visit http://www.granitedataservices.com/license for more
 *   details.
 */
package org.granite.tide {

    import org.granite.tide.events.TideFaultEvent;
    import org.granite.tide.events.TideResultEvent;
    

    /**
     * 	TideResponder defines a simple responder for remote calls
     * 	It allows to keep a token object between the call and the result/fault handler
     *  It also allows to add many result/fault handlers that will all be triggered by the origin call
     * 	
     * 	@author William DRAI
     */
    public class TideResponder implements ITideMergeResponder {
        
        private var _resultHandlers:Array = new Array();
        private var _faultHandlers:Array = new Array();
        private var _token:Object;
        private var _mergeWith:Object = null;
        
        
        public function TideResponder(resultHandler:Function, faultHandler:Function, token:Object = null, mergeWith:Object = null):void {
            if (resultHandler != null)
                _resultHandlers.push(resultHandler);
            if (faultHandler != null)
                _faultHandlers.push(faultHandler);   
            _token = token;
            _mergeWith = mergeWith;
        }
        
        /**
         * 	Add result/fault handlers
         * 
         *  @param resultHandler a result handler method
         *  @param faultHandler a fault handler method
         */
        public function addHandlers(resultHandler:Function = null, faultHandler:Function = null):void {
            if (resultHandler != null)
                _resultHandlers.push(resultHandler);
            if (faultHandler != null)
                _faultHandlers.push(faultHandler);
        }
        
        /**
         * 	Result handler method
         * 
         *  @param event result event
         */
        public function result(event:TideResultEvent):void {
            for each (var resultHandler:Function in _resultHandlers) { 
                if (_token != null)
                    resultHandler(event, _token);
                else
                    resultHandler(event);
            }
        }
        
        /**
         * 	Fault handler method
         * 
         *  @param event fault event
         */
        public function fault(event:TideFaultEvent):void {
            for each (var faultHandler:Function in _faultHandlers) {
                if (_token != null)
                    faultHandler(event, _token);
                else
                    faultHandler(event);
            }
        } 
        
        
        public function get mergeResultWith():Object {
            return _mergeWith;
        }
    }
}