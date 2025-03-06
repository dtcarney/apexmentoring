public with sharing class RenderPDFDemo {
    public void renderPDF(Id participantId) {
        PageReference certificatePage = Page.ParticipantCertificateDemo;
        certificatePage.getParameters().put('id', participantId);
        Blob pdfBlob = certificatePage.getContent();
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.ContentLocation = 'S';
        contentVersion.PathOnClient = 'ParticiapntCertificateDemo.pdf';
        contentVersion.Title = 'Participant Certificate';
        contentVersion.VersionData = pdfBlob;
        contentVersion.FirstPublishLocationId = participantId;
        insert contentVersion;

    }
}