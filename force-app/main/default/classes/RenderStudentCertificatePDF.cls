public with sharing class RenderStudentCertificatePDF {
    public RenderStudentCertificatePDF() {

    }
    public void generateStudentCertificate(Id trainingId){
        List<contentVersion> pdfs = new List<contentVersion>();

        List<Participant__c> participants = [SELECT Id,Training__c,Status__c, Training__r.Name,Contact_Name__r.Name, Training__r.End_Date__c, Training__r.Trainer_Contact__r.Name
        FROM Participant__c
        WHERE Training__c =:trainingId and Status__c ='Participated'];

        for(Participant__c participant : participants){
            contentVersion newFile = renderPdf(participant.Id);
            pdfs.add(newFile);
        }

        insert pdfs;

    

    }
    public contentVersion renderPDF(Id participantId) {
        PageReference certificatePage = Page.StudentCertificate;
        certificatePage.getParameters().put('id', participantId);
        Blob pdfBlob = certificatePage.getContent();
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.ContentLocation = 'S';
        contentVersion.PathOnClient = 'StudentCertificateDemo.pdf';
        contentVersion.Title = 'Student Certificate';
        contentVersion.VersionData = pdfBlob;
        contentVersion.FirstPublishLocationId = participantId;
        return contentVersion;

    }
}