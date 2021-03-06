/*
 *   GRANITE DATA SERVICES
 *   Copyright (C) 2006-2015 GRANITE DATA SERVICES S.A.S.
 *
 *   This file is part of the Granite Data Services Platform.
 *
 *   Granite Data Services is free software; you can redistribute it and/or
 *   modify it under the terms of the GNU Lesser General Public
 *   License as published by the Free Software Foundation; either
 *   version 2.1 of the License, or (at your option) any later version.
 *
 *   Granite Data Services is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser
 *   General Public License for more details.
 *
 *   You should have received a copy of the GNU Lesser General Public
 *   License along with this library; if not, write to the Free Software
 *   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301,
 *   USA, or see <http://www.gnu.org/licenses/>.
 */
package org.granite.test.tide.spring
{
    import org.flexunit.Assert;
    import org.flexunit.async.Async;
    import org.granite.persistence.PersistentSet;
    import org.granite.test.tide.data.Consent;
    import org.granite.test.tide.data.Document;
    import org.granite.test.tide.data.DocumentList;
    import org.granite.test.tide.data.DocumentPayload;
    import org.granite.test.tide.data.Patient5;
    import org.granite.tide.BaseContext;
    import org.granite.tide.data.ChangeMerger;
    import org.granite.tide.data.ChangeRef;
    import org.granite.tide.data.ChangeSet;
    import org.granite.tide.data.ChangeSetBuilder;
    import org.granite.tide.data.CollectionChanges;
    import org.granite.tide.events.TideResultEvent;
    
    
    public class TestSpringChangeSetEntityRemote5 {
		
		private var _ctx:BaseContext = MockSpring.getInstance().getContext();
		
		
		[Before]
		public function setUp():void {
			MockSpring.reset();
			_ctx = MockSpring.getInstance().getSpringContext();
			MockSpring.getInstance().token = new MockSimpleCallAsyncToken(_ctx);
			
			MockSpring.getInstance().addComponents([ChangeMerger]);
			_ctx.meta_uninitializeAllowed = false;
		}
        
        
        [Test(async)]
		public function testChangeSetEntityRemote7():void {
			var patient:Patient5 = new Patient5();
			patient.uid = "P1";
			patient.id = 1;
			patient.version = 0;
			patient.consents = new PersistentSet();
			
			_ctx.patient = _ctx.meta_mergeExternalData(patient);
			_ctx.meta_clearCache();
			
			patient = _ctx.patient as Patient5;
			
			var consent:Consent = new Consent();
			consent.patient = patient;
			patient.consents.addItem(consent);
			
			var documentList:DocumentList = new DocumentList();
			consent.documentList = documentList;
			var document:Document = new Document();
			document.documentLists.addItem(documentList);
			
			documentList.documents = new PersistentSet();
			document.payload = new DocumentPayload();
			document.payload.document = document;
			documentList.documents.addItem(document);
			
			// Simulate remote call with local merge of arguments
			var changeSet:ChangeSet = new ChangeSetBuilder(_ctx).buildChangeSet();
			
			_ctx.tideService.applyChangeSet1(changeSet, Async.asyncHandler(this, resultHandler, 1000, [ documentList, document ]));
		}
		
		[Test(async)]
		public function testChangeSetEntityRemote8():void {
			var patient:Patient5 = new Patient5();
			patient.uid = "P1";
			patient.id = 1;
			patient.version = 0;
			patient.consents = new PersistentSet();
			
			_ctx.patient = _ctx.meta_mergeExternalData(patient);
			_ctx.meta_clearCache();
			
			patient = _ctx.patient as Patient5;
			
			var consent:Consent = new Consent();
			consent.patient = patient;
			patient.consents.addItem(consent);
			
			var documentList:DocumentList = new DocumentList();
			consent.documentList = documentList;
			var document:Document = new Document();
			document.documentLists.addItem(documentList);
			
			documentList.documents = new PersistentSet();
			document.payload = new DocumentPayload();
			document.payload.document = document;
			documentList.documents.addItem(document);
			
			// Simulate remote call with local merge of arguments
			var changeSet:ChangeSet = new ChangeSetBuilder(_ctx).buildChangeSet();
			
			_ctx.tideService.applyChangeSet2(changeSet, Async.asyncHandler(this, resultHandler, 1000, [ documentList, document ]));
		}

		private function resultHandler(event:TideResultEvent, pass:Object = null):void {
			
			var patient:Patient5 = Patient5(_ctx.patient);
			
			Assert.assertTrue("Document list initialized", patient.consents.getItemAt(0).documentList.documents.isInitialized());
			Assert.assertEquals("Document list size", 1, patient.consents.getItemAt(0).documentList.documents.length);
			Assert.assertFalse("Context not dirty", _ctx.meta_dirty);
			
			var document2:Document = new Document();
			var payload2:DocumentPayload = new DocumentPayload();
			document2.payload = payload2;
			document2.documentLists = new PersistentSet();
			payload2.document = document2;
			patient.consents.getItemAt(0).documentList.documents.addItem(document2);
			
			var changeSet:ChangeSet = new ChangeSetBuilder(_ctx).buildChangeSet();
			
			_ctx.tideService.apply2ChangeSet(changeSet, Async.asyncHandler(this, result2Handler, 1000, pass.concat(document2)));
		}
		
		private function result2Handler(event:TideResultEvent, pass:Object = null):void {			
			var patient:Patient5 = Patient5(_ctx.patient);
			
			Assert.assertTrue("Document list initialized", patient.consents.getItemAt(0).documentList.documents.isInitialized());
			Assert.assertEquals("Document list size", 2, patient.consents.getItemAt(0).documentList.documents.length);
			Assert.assertFalse("Context not dirty", _ctx.meta_dirty);			
			
			patient.consents.getItemAt(0).documentList.documents.removeItemAt(0);
			
			var changeSet:ChangeSet = new ChangeSetBuilder(_ctx).buildChangeSet();
			
			_ctx.tideService.removeDocument(changeSet, Async.asyncHandler(this, result3Handler, 1000, pass));
		}
		
		private function result3Handler(event:TideResultEvent, pass:Object = null):void {
			var patient:Patient5 = Patient5(_ctx.patient);
			
			Assert.assertEquals("Document list", 1, patient.consents.getItemAt(0).documentList.documents.length);
			Assert.assertFalse("Context not dirty", _ctx.meta_dirty);
		}
	}
}


import mx.rpc.events.AbstractEvent;

import org.flexunit.Assert;
import org.granite.persistence.PersistentSet;
import org.granite.reflect.Type;
import org.granite.test.tide.data.Consent;
import org.granite.test.tide.data.Document;
import org.granite.test.tide.data.DocumentList;
import org.granite.test.tide.data.DocumentPayload;
import org.granite.test.tide.data.Patient5;
import org.granite.test.tide.spring.MockSpringAsyncToken;
import org.granite.tide.BaseContext;
import org.granite.tide.data.Change;
import org.granite.tide.data.ChangeRef;
import org.granite.tide.data.ChangeSet;
import org.granite.tide.data.CollectionChanges;
import org.granite.tide.invocation.InvocationCall;

class MockSimpleCallAsyncToken extends MockSpringAsyncToken {
	
	private var _ctx:BaseContext;
	
	function MockSimpleCallAsyncToken(ctx:BaseContext):void {
		super(null);
		_ctx = ctx;
	}
	
	protected override function buildResponse(call:InvocationCall, componentName:String, op:String, params:Array):AbstractEvent {
		var patient:Patient5 = Patient5(_ctx.patient);
		var consent:Consent = patient.consents.getItemAt(0) as Consent;
		
		if (componentName == "tideService" && op.indexOf("applyChangeSet") == 0) {
			if (!(params[0] is ChangeSet))
				return buildFault("Illegal.Argument");

			var patientb:Patient5 = new Patient5();
			patientb.id = patient.id;
			patientb.uid = patient.uid;
			patientb.version = patient.version;
			patientb.name = patient.name;
			patientb.consents = new PersistentSet(false);
			
			var consentb:Consent = new Consent();
			consentb.uid = consent.uid;
			consentb.id = 1;
			consentb.version = 0;
			var documentListb:DocumentList = new DocumentList();
			documentListb.uid = consent.documentList.uid;
			documentListb.id = 1;
			documentListb.version = 0;
			documentListb.documents = new PersistentSet(false);			
			
			consentb.documentList = documentListb;
			consentb.patient = patientb;
			
			var documentc:Document = new Document();
			documentc.uid = consent.documentList.documents.getItemAt(0).uid;
			documentc.id = 1;
			documentc.version = 1;
			documentc.documentLists = new PersistentSet(false);
			var payloadc:DocumentPayload = new DocumentPayload();
			payloadc.uid = consent.documentList.documents.getItemAt(0).payload.uid;
			payloadc.id = 1;
			payloadc.version = 0;
			payloadc.document = documentc;
			documentc.payload = payloadc;
			
			var documentListc:DocumentList = new DocumentList();
			documentListc.uid = consent.documentList.uid;
			documentListc.id = 1;
			documentListc.version = 0;
			documentListc.documents = new PersistentSet();
			documentListc.documents.addItem(documentc);
			
			var change1:Change = new Change(Type.forClass(Document).name, documentc.uid, documentc.id, 0);
			var collChanges1:CollectionChanges = new CollectionChanges();
			collChanges1.addChange(1, null, documentListc);
			change1.changes.documentLists = collChanges1;
			
			var change2:Change = new Change(Type.forClass(Patient5).name, patient.uid, patient.id, patientb.version);
			var collChanges2:CollectionChanges = new CollectionChanges();
			collChanges2.addChange(1, null, consentb);
			change2.changes.consents = collChanges2;
			
			if (op == "applyChangeSet1") {
				return buildResult(null, null, [[ 'UPDATE', new ChangeSet([ change1 ]) ], [ 'PERSIST', documentListc ],
					[ 'PERSIST', payloadc ], [ 'UPDATE', new ChangeSet([ change2 ]) ], [ 'PERSIST', consentb ], [ 'PERSIST', documentc ]]);
			}
			else if (op == "applyChangeSet2") {
				return buildResult(null, null, [[ 'PERSIST', documentListc ], [ 'PERSIST', payloadc ], [ 'PERSIST', consentb ], [ 'PERSIST', documentc ], 
					[ 'UPDATE', new ChangeSet([ change1 ]) ], [ 'UPDATE', new ChangeSet([ change2 ]) ]]);
			}
		}
		else if (componentName == "tideService" && op.indexOf("apply2ChangeSet") == 0) {
			var cs:ChangeSet = ChangeSet(params[0]);
			
			documentListc = new DocumentList();
			documentListc.uid = cs.changes[0].uid;
			documentListc.id = cs.changes[0].id;
			documentListc.version = 1;
			documentListc.documents = new PersistentSet();
			
			documentc = new Document();
			documentc.uid = cs.changes[0].changes.documents.changes[0].value.uid;
			documentc.id = 2;
			documentc.version = 1;
			documentc.documentLists = new PersistentSet();
			documentc.documentLists.addItem(documentListc);
			payloadc = new DocumentPayload();
			payloadc.uid = cs.changes[0].changes.documents.changes[0].value.payload.uid;
			payloadc.id = 2;
			payloadc.version = 0;
			payloadc.document = documentc;
			documentc.payload = payloadc;
			
			var documentc2:Document = new Document();
			documentc2 = new Document();
			documentc2.uid = consent.documentList.documents.getItemAt(0).uid;
			documentc2.id = 1;
			documentc2.version = 1;
			documentc2.documentLists = new PersistentSet();
			documentc2.documentLists.addItem(documentListc);
			var payloadc2:DocumentPayload = new DocumentPayload();
			payloadc2.uid = consent.documentList.documents.getItemAt(0).payload.uid;
			payloadc2.id = 1;
			payloadc2.version = 0;
			payloadc2.document = documentc2;
			documentc2.payload = payloadc2;
			
			documentListc.documents.addItem(documentc2);
			documentListc.documents.addItem(documentc);
			
			change1 = new Change(Type.forClass(Document).name, documentc.uid, documentc.id, 0);
			collChanges1 = new CollectionChanges();
			collChanges1.addChange(1, null, documentListc);
			change1.changes.documentLists = collChanges1;
			
			return buildResult(null, null, [[ 'PERSIST', payloadc ], [ 'PERSIST', documentc ], [ 'UPDATE', new ChangeSet([ change1 ]) ]]);
		}
		else if (componentName == "tideService" && op.indexOf("removeDocument") == 0) {
			cs = ChangeSet(params[0]);

			var docRef0:ChangeRef = new ChangeRef(Type.forClass(Document).name, cs.changes[0].changes.documents.changes[0].value.uid, 
				cs.changes[0].changes.documents.changes[0].value.id);
			
			change1 = new Change(Type.forClass(DocumentList).name, cs.changes[0].uid, cs.changes[0].id, cs.changes[0].version+1);
			collChanges1 = new CollectionChanges();
			collChanges1.addChange(-1, null, docRef0);
			change1.changes.documents = collChanges1;
			
			var docRef:ChangeRef = new ChangeRef(Type.forClass(Document).name, cs.changes[0].changes.documents.changes[0].value.uid, 
				cs.changes[0].changes.documents.changes[0].value.id);
			
			return buildResult(null, null, [[ 'UPDATE', new ChangeSet([ change1 ]) ], [ 'REMOVE', docRef ]]);
		}
		
		return buildFault("Server.Error");
	}
}
