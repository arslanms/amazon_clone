import { Injectable } from '@angular/core';
import { User } from './objects/user';

@Injectable()
export class UserService {

   private user: User = {
    userID : null,
    first_name: null,
    last_name: null,
    email: null,    
    date_joined: null,
    phone_number: null,
    password: null,
    street: null,
    zip: null,
    city: null,
    state: null,
    country: null,
    type_account: null
  };

  constructor() {
  }

  setUserLoggedIn( user ) {
  	this.user.userID = user;
  }

  getUser() {
  	return this.user;
  }

  getUserLoggedIn() {
  	return this.user.userID;
  }

}
