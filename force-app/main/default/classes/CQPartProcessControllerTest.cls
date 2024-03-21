@isTest
private class CQPartProcessControllerTest {
    
    public static final String HIGH_VOLUME_ACCOUNT = 'High Volume';
    public static final String LOW_VOLUME_ACCOUNT = 'Low Volume';
    public static final String PART_NAME = 'New part';
    public static final String PART_NUMBER = '62e3as3';
    
    @testSetup
    static void setupTestData() {
        User standardUser = TestFactoryUtility.createUser('Standard User');
        
        User stdUser = TestFactoryUtility.getUser('Standard User');
        
        System.runAs(stdUser) {
            Account highVolumeAccount = new Account(
                Name = HIGH_VOLUME_ACCOUNT
            );
            // Insert Account record
            insert highVolumeAccount;
            
            Account lowVolumeAccount = new Account(
                Name = LOW_VOLUME_ACCOUNT
            );
            insert lowVolumeAccount;
            
            // Create Part Record
            SQX_Part__c partRecord = new SQX_Part__c(
                Name = PART_NAME,
                Part_Number__c = PART_NUMBER
            );
            insert partRecord;
            
        }
    }
    
    
    @isTest
    static void testSyncParts() {
        User stdUser = TestFactoryUtility.getUser('Standard User');
        
        System.runAs(stdUser) {
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            
            Test.startTest();
            
            CQPartProcessController.CallOutResponseWrapper result = CQPartProcessController.SyncPartsProcess();
            
            Test.stopTest();
            
            Account highVolumeAccount = [SELECT Id, Name FROM Account WHERE Name =: HIGH_VOLUME_ACCOUNT];
            Account lowVolumeAccount = [SELECT Id, Name FROM Account WHERE Name =: LOW_VOLUME_ACCOUNT];
            
            List<SQX_Part__c> newParts = [SELECT Name, Part_Number__c, Active__c, Related_Account__c 
                                          FROM SQX_Part__c 
                                          WHERE Part_Number__c =: PART_NUMBER];
            
            System.assertEquals(1, newParts.size());
        }
    }
    
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('[{"_id":"62e3as3","Part Name":"Mock Part 1","Total Quantity Shipped":50}]');
            response.setStatusCode(200);
            return response;
        }
    }
}