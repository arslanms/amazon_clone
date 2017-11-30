import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-checkout',
  templateUrl: './checkout.component.html',
  styleUrls: ['./checkout.component.css']
})
export class CheckoutComponent implements OnInit {

  constructor() { }

  ngOnInit() {
  }

  placeOrder(e) {
  	console.log("clicked");
  	console.log(document.getElementById("hard-address-street").innerHTML);
  	var inputValue = (<HTMLInputElement>document.getElementById("optionShipp1")).checked;
  	console.log(inputValue);
  }
}
