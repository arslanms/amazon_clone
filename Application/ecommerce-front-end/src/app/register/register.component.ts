import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { User } from '../objects/user';

@Component({
  selector: 'app-register',
  templateUrl: './register.component.html',
  styleUrls: ['./register.component.css']
})
export class RegisterComponent implements OnInit {

  constructor(private router:Router) { }

  ngOnInit() {
  }

  registerUser(e) {
    var userName = e.target.elements[0].value;
    var firstName = e.target.elements[1].value;
    var lastName = e.target.elements[2].value;
    var email = e.target.elements[3].value;
    var password = e.target.elements[4].value;
    var phone = e.target.elements[5].value;
    var addressStreet = e.target.elements[6].value;
    var addressCity = e.target.elements[7].value;
    var addressState = e.target.elements[8].value;
    var addressZip = e.target.elements[9].value;
    var addressCountry = e.target.elements[10].value;
    var DOBDD = e.target.elements[11].value;
    var DOBMM = e.target.elements[12].value;
    var DOBYYYY = e.target.elements[13].value;
    var gender = e.target.elements[14].value;
    var cardNum = e.target.elements[15].value;
    var cardCVC = e.target.elements[16].value;
    var cardExpMM = e.target.elements[17].value;
    var cardExpYYYY = e.target.elements[18].value;

    var newUser: User = {
      userID : null,
      first_name: firstName,
      last_name: lastName,
      email: email,    
      date_joined: null,
      phone_number: phone,
      password: password,
      street: addressStreet,
      zip: addressZip,
      city: addressCity,
      state: addressState,
      country: addressCountry,
      type_account: null
    };
    console.log("User Name:      ", userName)
    console.log("First Name:     ", firstName);
    console.log("Last Name:      ", lastName);
    console.log("Email:          ", email);
    console.log("Password:       ", password);
    console.log("Phone:          ", phone);
    console.log("Street Address: ", addressStreet);
    console.log("Address City:   ", addressCity);
    console.log("Address State:  ", addressState);
    console.log("Address Zip:    ", addressZip);
    console.log("Address Contry: ", addressCountry);
    console.log("DOBDD:          ", DOBDD);
    console.log("DOBMM:          ", DOBMM);
    console.log("DOBYYYY:        ", DOBYYYY);
    console.log("Gender:         ", gender);
    console.log("CardNum:        ", cardNum);
    console.log("CardCVC:        ", cardCVC);
    console.log("CardExpMM:      ", cardExpMM);
    console.log("CardExpYYYY:    ", cardExpYYYY);
    console.log(newUser);
  }
}
