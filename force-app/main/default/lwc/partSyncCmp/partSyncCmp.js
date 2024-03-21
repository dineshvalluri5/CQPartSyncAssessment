import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPartsResponse from '@salesforce/apex/CQPartProcessController.SyncPartsProcess';

export default class PartSyncCmp extends LightningElement {
	@track showSpinner = false;

	handleSyncProcess() {
		this.showSpinner = true
		getPartsResponse().then(result => {
			this.showSpinner = false
			if(result && result.responseMessage === 'Success' && result.statusCode === 200) {
				this.showSpinner = false
				const evt = new ShowToastEvent({
					title: 'Success',
					message: 'Parts Sync Completed',
					variant: 'success',
					mode: 'dismissable'
				});
				this.dispatchEvent(evt);
			} else {
				this.showSpinner = false
				const evt = new ShowToastEvent({
					title: 'Error',
					message: result,
					variant: 'error',
					mode: 'dismissable'
				});
				this.dispatchEvent(evt);
			}
		}).catch(error => {
			console.log('error-->', error);
		})
	}
}