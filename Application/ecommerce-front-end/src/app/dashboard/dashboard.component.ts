import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { UserService } from '../user.service';

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.css']
})
export class DashboardComponent implements OnInit {

  constructor(private router:Router, private user:UserService) { }

  ngOnInit() {
    console.log("Logged in as: ", this.user.getUserLoggedIn());
    console.log(this.user.getUser());
  }

  logoutUser(e) {
  	console.log("LOGOUT");
  	this.router.navigate(['login']);
  }
}
