handleSave(event) {
        this.copyDraftToParticipants(event.detail.draftValues);
        this.saveParticipants();
        this.draftValues = [];
    }
    copyDraftToParticipants(draftValues) {
        draftValues.forEach((draftElement) => {
            this.participants.forEach((participantElement) => {
                if(draftElement.participantId === participantElement.participantId) {
                    if(draftElement.participantGPA) {
                        participantElement.participantGPA = draftElement.participantGPA;
                    }
                    if(draftElement.participantPassed !== null) {
                        participantElement.participantPassed = draftElement.participantPassed;
                    }
                }
            });
        });
    }
    saveParticipants() {
        updateParticipants({ serializedParticipants: JSON.stringify(this.participants) })
            .then(result => {
                JSON.stringify(result);
                this.showToast('Success', 'Your changes are saved.', 'success');
                this.errorMessage = '';
            })
            .catch(error => {
                this.error = JSON.stringify(error);
                this.errorMessage = this.error;
                this.showToast('Error', 'An error occurred while trying to save the changes.', 'error');
            });
    }