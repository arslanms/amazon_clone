var express = require('express');
var mysql = require('mysql');
var cookieParser = require('cookie-parser');
var session = require('express-session')
var passport = require('passport');
var LocalStrategy = require('passport-local').Strategy;
var MySQLStore = require('express-mysql-session')(session);
var async = require('async');

var app = express();

var bodyParser = require('body-parser');
app.use(bodyParser.json()); // support json encoded bodies
app.use(bodyParser.urlencoded({ extended: true })); // support encoded bodie

var { check, validationResult } = require('express-validator/check');
var { matchedData, sanitize } = require('express-validator/filter');

app.use(cookieParser());

var options = {
    host: 'localhost',
    port: 3306,
    user: 'root',
    password: 'root',
    database: 'mydb'
};

var sessionStore = new MySQLStore(options);

app.use(session({
  secret: 'klfanljfkvns',
  resave: false,
  saveUninitialized: false,
  store: sessionStore
}))

app.use(passport.initialize());
app.use(passport.session());



var db = mysql.createConnection({
	host     : 'localhost',
	user     : 'root',
	password : 'root',
	database : 'mydb',
});

db.connect((err) => {
	if (err)	{
		throw err;
	}
	console.log("MySQL connected");
});

passport.use(new LocalStrategy(
  function(username, password, done) {

  		let statement = "SELECT * FROM User WHERE UserID = ?";

  		db.query(statement, [username], (err, result) => {
  			if (err)
  				throw err;

  			if (result.length === 0)
  				return done(null, false);
  			else {
  				var db_password = result[0].Password;

	  			if (db_password === password)
  					return done(null, {userid : username});

  				return done(null, false);
  			}  			
  		});
    }
));

app.get('/', (req, res) => {
	
	let statement = "SELECT * FROM Item";
	db.query(statement, (err, result) => {
		if (err)
			throw err;
		res.send(result);
	});
});

app.get('/user/:id', function(req, res) {
    var id = req.params.id;
    let statement = "SELECT * FROM User WHERE User.UserID = ?";
    db.query(statement, [id], (err, result) =>	{
    	if (err)
    		throw err;
    	res.send(result);
    });
});

app.post('/user/:id/update', function(req, res) {

    var street = req.body.street;
    var id = req.params.id;

    let statement = "UPDATE User SET Street = ? WHERE UserID = ?";

    db.query(statement, [street, id], (err, result) =>	{
    	if (err)
    		throw err;
    	res.send(result);
    });
});

//TODO: Need to finish the checks of all the inputs.
app.post('/register', [check('userid').exists().withMessage('No UserID provided.'), check('first_name').exists().withMessage('No first name provided'),
	check('last_name').exists().withMessage('No last name provided'), check('password').exists().withMessage('No password provided'),
	check('type').isIn(['Admin', 'Customer', 'Vendor']).withMessage('You must be either an admin, customer, or vendor.'),
	check('email').isEmail().withMessage('Must be valid email'), check('phone').exists().withMessage('No phone provided'),
	check('address').exists().withMessage('No address provided'), check('city').exists().withMessage('No city provided'),
	check('zip').exists().withMessage('No zip provided'), check('country').exists().withMessage('No country provided'),
	check('state').exists().withMessage('No state provided').isLength({max:2}).withMessage('State must be 2 characters.'),
	sanitize('zip').toInt()], (req, res, next) =>	{
	var errors = validationResult(req);
	if (!errors.isEmpty()) {
		return res.status(422).json({ errors: errors.mapped() });
	}
	else	{
		//res.send({"ok": 1});
		var userid = req.body.userid;
		var first_name = req.body.first_name;
		var last_name = req.body.last_name;
		var email = req.body.email;
		var password = req.body.password;
		var type = req.body.type;
		var phone = req.body.phone;
		var address = req.body.address;
		var city = req.body.city;
		var state = req.body.state;
		var country = req.body.country;
		var zip = req.body.zip;

		let statemenet = "INSERT INTO User VALUES (?,?,?,?,CURDATE(),?,?,?,?,?,?,?,?)";
		var reg_return = new Object();

		db.query(statemenet, [userid, first_name, last_name, email, phone, password, address, zip, city, state, country, type], (err, result) => {
			if (err)
				throw err;
			reg_return.User = result;

			if (type == 'Customer')	{
				let type_statement = "INSERT INTO Customer VALUES(?)";
				db.query(type_statement, [userid], (err2, result2) => {
					if (err2)
						throw err2;
					reg_return.Type = result;
					res.send(reg_return);
				});
			}
			else if (type == 'Vendor')	{
				let type_statement = "INSERT INTO Vendor VALUES(?, ?, ?)";
				var store_name = req.body.store_name;
				var store_desc = req.body.store_desc;
				db.query(type_statement, [userid, store_name, store_desc], (err2, result2) => {
					if (err2)
						throw err2;
					reg_return.Type = result;
					res.send(reg_return);
				});
			}
			else {
				let type_statement = "INSERT INTO Admin VALUES(?)";
				db.query(type_statement, [userid], (err2, result2) => {
					if (err2)
						throw err2;
					reg_return.Type = result;
					res.send(reg_return);
				});
			}


			
		});
	}
});

app.post('/login', passport.authenticate('local', {successRedirect: '/profile', failureRedirec: '/login'}));

app.get('/profile', checkAuthentication, (req, res, next) => {
	console.log(req.user);
	console.log(req.isAuthenticated());
	res.send({profile : 1});
});

app.get('/logout', (req, res, next) => {
	req.logout();
	req.session.destroy(() => {
		res.clearCookie('connect.sid');
		res.redirect('/');
	});
});

app.post('/cart', [sanitize('itemid').toInt(), sanitize('quantity').toInt()],(req, res, next) => {
	/*
	`ItemID` INT UNSIGNED NOT NULL,
  	`CustomerID` VARCHAR(50) NOT NULL,
  	`Quantity` INT UNSIGNED NOT NULL,
	`CartID` INT UNSIGNED NOT NULL AUTO_INCREMENT
	*/

	var userid = req.user.userid;
	var itemid = req.body.itemid;
	var quantity = req.body.quantity;

	let statement_validation = "SELECT * FROM Customer WHERE Customer.UserID = ?";

	var cart_return = new Object();

	db.query(statement_validation, [userid], (err, result) => {


		if (err) {
			return db.rollback(function() {
        		throw err;
      		});
		}
		else if (result.length === 0)	{
			res.send({error: "Is not a customer"});
		}
		else {

			let quantity_check = "SELECT Quantity FROM Item WHERE ItemID = ?";

			db.query(quantity_check, [itemid], (err2, result2) => {

				if(err2)	{
					return db.rollback(function() {
        				throw err2;
      				});
				}

				var current_quantity = result2[0].Quantity;

				if (current_quantity - quantity >= 0)	{
					let statement_add_to_cart = "INSERT INTO `Shopping Cart` VALUES(?, ?, ?, 0)";

					db.query(statement_add_to_cart, [itemid, userid, quantity], (err3, result3) => {

						if(err3) {
							return db.rollback(function() {
        						throw err3;
      						});
						}

						res.send(result3);

					});
				}
				else {
					res.status(404).send({error:"Not enough quantity"});
				}
			});
		}
	});
});

app.post('/inventory', [sanitize('price').toInt(), sanitize('quantity').toInt()],(req, res, next) => {

	//Have to add a particular item to both the Item table and the Inventory table
	/*
	`Price` INT UNSIGNED NOT NULL COMMENT 'Holds the price of the particular item.',
  `Product_Name` VARCHAR(100) NOT NULL COMMENT 'Contains the name of the item.',
  `Type` VARCHAR(50) NULL COMMENT 'Contains the type of the item (e.x. Book, Clothing, Computer, etc.)',
  `ItemID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `Product_Desc` VARCHAR(1000) NULL COMMENT 'Contains a short description of the item.',
  `Quantity` INT UNSIGNED NOT NULL,
  `Picture` VARCHAR(50) NULL COMMENT 'Contains the file name of the picture (not the picture itself).',
PRIMARY KEY (`ItemID`))
	*/

	var userid = req.user.userid;
	var price = req.body.price;
	var prod_name = req.body.prod_name;
	var type = req.body.type;
	var prod_desc = req.body.prod_desc;
	var quantity = req.body.quantity;
	var picture = req.body.picture;

	let statement = "SELECT * FROM Vendor WHERE Vendor.UserID = ?";

	db.query(statement, [userid], (err, result) => {
		if (err) {
			return db.rollback(function() {
        		throw err;
      		});
		}
		else if (result.length === 0)	{
			res.send({error: "Is not a vendor"});
		}
		else {

			let insert_item_statement = "INSERT INTO Item VALUES(?, ?, ?, NULL, ?, ?, ?, ?)";

			db.query(insert_item_statement, [price, prod_name, type, prod_desc, quantity, picture, userid], (err2, result2) => {

				if (err2)	{
					return db.rollback(function() {
						throw err2;
					});
				}

				let item_id_statement = "SELECT ItemID FROM Item WHERE Item.Product_Name = ?";

				db.query(item_id_statement, [prod_name], (err3, result3) => {

					if (err3)	{
						return db.rollback(function() {
							throw err3;
						});
					}

					var itemid = result3[0].ItemID;

					/*
					`ItemID` INT UNSIGNED NOT NULL,
  					`VendorID` VARCHAR(50) NOT NULL,
  					`Quantity` INT UNSIGNED NOT NULL,
  					`InventoryID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
					PRIMARY KEY (`InventoryID`),
					*/
					let inventory_statement = "INSERT INTO Inventory VALUES(?, ?, ?, NULL)";

					db.query(inventory_statement, [itemid, userid, quantity], (err4, result4) => {

						if (err4)	{
							db.rollback(function() {
								throw err4;
							});
						}

						res.send(result4);

					});

				});

			});

		}

	});
});

app.get('/cart', (req, res, next) => {

	var customerid = req.user.userid;
	let statement = "SELECT * FROM `Shopping Cart` WHERE CustomerID = ?";

	db.query(statement, [customerid], (err, result) => {
		if (err)
			throw err;

		res.send(result);
	});

});

app.post('/payment', [sanitize('card_num').toInt(), sanitize('card_ccv').toInt(), sanitize('card_date').toInt(),
	sanitize('bill_zip').toInt()], (req, res, next) => {
	/*
	`Cardholder_FirstName` VARCHAR(50) NOT NULL,
  `Cardholder_LastName` VARCHAR(50) NOT NULL,
  `Card_Num` BIGINT UNSIGNED NOT NULL,
  `Card_CCV` INT UNSIGNED NOT NULL,
  `Card_ExpirDate` INT UNSIGNED NOT NULL,
  `Street` VARCHAR(50) NOT NULL,
  `ZIP` INT UNSIGNED NOT NULL,
  `City` VARCHAR(50) NOT NULL,
  `State` CHAR(2) NOT NULL,
  `Country` VARCHAR(50) NOT NULL,
  `CustomerID` VARCHAR(50) NOT NULL,
PRIMARY KEY (`Card_Num`),
	*/

	var customerid = req.user.userid;
	var card_firstname = req.body.card_firstname;
	var card_lastname = req.body.card_lastname;
	var card_num = req.body.card_num;
	var card_ccv = req.body.card_ccv;
	var card_date = req.body.card_date;
	var bill_street = req.body.bill_street;
	var bill_zip = req.body.bill_zip;
	var bill_city = req.body.bill_city;
	var bill_state = req.body.bill_state;
	var bill_country = req.body.bill_country;

	let statement = "INSERT INTO Payment VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

	db.query(statement, [card_firstname, card_lastname, card_num, card_ccv, card_date, bill_street, bill_zip, bill_city, bill_state, bill_country, customerid], (err, result) => {

		if (err)
			throw err;

		res.send(result);

	});

});

app.post('/checkout', (req, res, next) => {
	//We need a payment plan (identified by the card number) and all of the items in the user's shopping cart
	//Drop all of these items from the Shopping Cart table according to the user but need to keep some info for order/order details
	//Create orders/order details for every item that was in the shopping cart for that user. 

	var card_num = req.body.card_num;
	var customerid = req.user.userid;
	var delivery_type = req.body.delivery_type;

	let statement_shoppingcart = "SELECT * FROM `Shopping Cart` WHERE CustomerID = ?";

	db.query(statement_shoppingcart, [customerid], (err, result) => {

		if (err)	{
			db.rollback(function() {
				throw err;
			});
		}

		//for (var i = 0; i < result.length; i++) {
		async.forEachOf(result, function(value, key, callback) {


			//For each of these items we want to make an order along with order details

			/*
			`OrderID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  			`Shipped_Date` DATE NULL,
  			`Ordered_Date` DATE NULL,
  			`Delivery_Type` VARCHAR(50) NULL,
  			`Tracking_Num` BIGINT NULL,
  			`Shipment_Company` VARCHAR(50) NULL,
  			`VendorID` VARCHAR(50) NOT NULL,
  			`CustomerID` VARCHAR(50) NOT NULL,
  			`Street` VARCHAR(50) NOT NULL,
  			`ZIP` INT NOT NULL,
  			`City` VARCHAR(50) NOT NULL,
  			`State` CHAR(2) NOT NULL,
  			`Country` VARCHAR(50) NOT NULL,
			PRIMARY KEY (`OrderID`),

			`OrderID` INT UNSIGNED NOT NULL,
  			`ItemID` INT UNSIGNED NOT NULL,
  			`Quantity` INT UNSIGNED NOT NULL,
  			`OrderDetailID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  			INDEX `ItemID_idx` (`ItemID` ASC),
  			INDEX `OrderID_idx` (`OrderID` ASC),
			PRIMARY KEY (`OrderDetailID`),
			*/

			let payment_info = "SELECT * FROM Payment WHERE (Payment.CustomerID = ?) AND (Payment.Card_Num = ?)";

			db.query(payment_info, [customerid, card_num], (err2, result2) => {

				if (err2)	{
					db.rollback(function() {
						callback(err2);
					});
				}


				var billing_info = result2[0];

				let order_statement = "INSERT INTO `Order`(`OrderID`, `Shipped_Date`, `Ordered_Date`," + 
				"`Delivery_Type`, `Tracking_Num`, `Shipment_Company`, `VendorID`, `CustomerID`, `Street`, `ZIP`, `City`, `State`, `Country`," +
				"`ItemID`, `Quantity`) VALUES  (NULL, NULL, CURDATE(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
				var tracking_num = 124545474764;
				var shipment_company = 'Quick Boys Inc';

				let vendor_statement = "SELECT UserID FROM Item WHERE Item.ItemID = ?";

				db.query(vendor_statement, [value.ItemID], (err6, result6) => {

					if(err6)	{
						db.rollback(function() {
							callback(err6);
						});						
					}

					var vendor = result6[0].UserID;

				db.query(order_statement, [delivery_type, tracking_num, shipment_company, vendor, customerid,
					billing_info.Street, billing_info.ZIP, billing_info.City, billing_info.State, billing_info.Country, value.ItemID, value.Quantity], (err3, result3) => {



					if (err3)	{
						db.rollback(function() {
							callback(err3);
						});
					}

					let quantity_statement = "SELECT Quantity FROM Item WHERE ItemID = ?";

					db.query(quantity_statement, [value.ItemID], (err4, result4) => {

						if (err4)	{
							db.rollback(function() {
								callback(err4);
							});
						}

						var old_quantity = result4[0].Quantity;

						if (old_quantity - value.Quantity >= 0)	{

							let update_statement = "UPDATE Item SET Quantity = ? WHERE ItemID = ?";

							var new_quantity = old_quantity - value.Quantity;
							db.query(update_statement, [new_quantity, value.ItemID], (err5, result5) => {

								if (err5)	{
									db.rollback(function() {
										callback(err5);
									});
								}
							});
						}
						else {

							res.send({status: -1, msg: "Not enough in stock to purchase"});

						}

					});

				}); 
			});
			});
			callback();
		}, function(err)	{

		});
	});

	res.send({status: 1});
});

passport.serializeUser(function(user, done) {
	done(null, user);
});

passport.deserializeUser(function(user, done) {
	done(null, user);
});

function checkAuthentication(req,res,next){
    if(req.isAuthenticated()){
        //if user is looged in, req.isAuthenticated() will return true
        console.log("Is authenticated"); 
        next();
    } else{
    	console.log("Is not authenticated");
        res.redirect("/");
    }
}



app.listen('3000', () =>	{
	console.log("Server is running on port 3000");
});