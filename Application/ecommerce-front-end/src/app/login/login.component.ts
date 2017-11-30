import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { UserService } from '../user.service';
import { User } from '../objects/user';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})
export class LoginComponent implements OnInit {

  constructor(private router:Router, private user:UserService) { }

  ngOnInit() {
  }

  loginUser(e) {
    console.log(e);
    var username = e.target.elements[0].value;
    var password = e.target.elements[1].value;
    console.log("Username:  ", username);
    console.log("Password:  ", password);
    if (username == 'admin' && password == 'admin') {
      this.router.navigate(['dashboard']);
      this.user.setUserLoggedIn(username);
    }
  }
}
