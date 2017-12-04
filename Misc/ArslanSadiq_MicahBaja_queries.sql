CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 ;
USE `mydb` ;

CREATE TABLE IF NOT EXISTS `mydb`.`Item` (
  `Price` INT UNSIGNED NOT NULL COMMENT 'Holds the price of the particular item.',
  `Product_Name` VARCHAR(100) NOT NULL COMMENT 'Contains the name of the item.',
  `Type` VARCHAR(50) NULL COMMENT 'Contains the type of the item (e.x. Book, Clothing, Computer, etc.)',
  `ItemID` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'Unique ID to identify an item',
  `Product_Desc` VARCHAR(1000) NULL COMMENT 'Contains a short description of the item.',
  `Quantity` INT UNSIGNED NOT NULL,
  `Picture` VARCHAR(50) NULL COMMENT 'Contains the file name of the picture (not the picture itself).',
  PRIMARY KEY (`ItemID`))
ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS `mydb`.`User` (
  `UserID` VARCHAR(50) NOT NULL COMMENT 'The username of the User. It is unique so no two users can have the same username',
  `First_Name` VARCHAR(50) NULL,
  `Last Name` VARCHAR(50) NULL,
  `E-mail` VARCHAR(50) NOT NULL,
  `Date_Joined` DATE NULL,
  `Phone_Number` VARCHAR(50) NULL,
  `Password` VARCHAR(100) NOT NULL COMMENT 'Contains an encrypted password of the customer. Have to figure out encryption',
  `Street` VARCHAR(50) NULL,
  `ZIP` INT NULL,
  `City` VARCHAR(50) NULL,
  `State` CHAR(2) NULL,
  `Country` VARCHAR(50) NULL,
  `Type_Account` VARCHAR(10) NULL COMMENT 'Either \'Admin\', \'Customer\', or \'Vendor\'',
  PRIMARY KEY (`UserID`))
ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS `mydb`.`Customer` (
  `UserID` VARCHAR(50) NOT NULL COMMENT 'Holds the ID of this customer. Will be used to identify the customer. Because we do not want a customer to have the same userID as a vendor and admin, we make it the primary key and a foreign key to the User table (UserID)',
  PRIMARY KEY (`UserID`),
  CONSTRAINT `UserID`
    FOREIGN KEY (`UserID`)
    REFERENCES `mydb`.`User` (`UserID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS `mydb`.`Vendor` (
  `UserID` VARCHAR(50) NOT NULL COMMENT 'This is the ID of the vendor to identify them. Is both the primary key and foreign key to reference the User table',
  `Name` VARCHAR(50) NULL COMMENT 'Name of the store.',
  `Description` VARCHAR(200) NULL COMMENT 'Description of what the vendor sells and stuff.',
  PRIMARY KEY (`UserID`),
  UNIQUE INDEX `VendorID_UNIQUE` (`UserID` ASC),
  CONSTRAINT `UserID`
    FOREIGN KEY (`UserID`)
    REFERENCES `mydb`.`User` (`UserID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS `mydb`.`Order` (
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
  UNIQUE INDEX `OrderID_UNIQUE` (`OrderID` ASC),
  INDEX `CustomerID_idx` (`CustomerID` ASC),
  INDEX `VendorID_idx` (`VendorID` ASC),
  CONSTRAINT `CustomerID`
    FOREIGN KEY (`CustomerID`)
    REFERENCES `mydb`.`Customer` (`UserID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `VendorID`
    FOREIGN KEY (`VendorID`)
    REFERENCES `mydb`.`Vendor` (`UserID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS `mydb`.`OrderDetails` (
  `OrderID` INT UNSIGNED NOT NULL,
  `ItemID` INT UNSIGNED NOT NULL,
  `Quantity` INT UNSIGNED NOT NULL,
  `OrderDetailID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  INDEX `ItemID_idx` (`ItemID` ASC),
  INDEX `OrderID_idx` (`OrderID` ASC),
  PRIMARY KEY (`OrderDetailID`),
  CONSTRAINT `ItemID`
    FOREIGN KEY (`ItemID`)
    REFERENCES `mydb`.`Item` (`ItemID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `OrderID`
    FOREIGN KEY (`OrderID`)
    REFERENCES `mydb`.`Order` (`OrderID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS `mydb`.`Payment` (
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
  INDEX `CustomerID_idx` (`CustomerID` ASC),
  CONSTRAINT `CustomerID`
    FOREIGN KEY (`CustomerID`)
    REFERENCES `mydb`.`Customer` (`UserID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS `mydb`.`Inventory` (
  `ItemID` INT UNSIGNED NOT NULL,
  `VendorID` VARCHAR(50) NOT NULL,
  `Quantity` INT UNSIGNED NOT NULL,
  `InventoryID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`InventoryID`),
  INDEX `ItemID_idx` (`ItemID` ASC),
  INDEX `VendorID_idx` (`VendorID` ASC),
  CONSTRAINT `ItemID`
    FOREIGN KEY (`ItemID`)
    REFERENCES `mydb`.`Item` (`ItemID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `VendorID`
    FOREIGN KEY (`VendorID`)
    REFERENCES `mydb`.`Vendor` (`UserID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS `mydb`.`Shopping Cart` (
  `ItemID` INT UNSIGNED NOT NULL,
  `CustomerID` VARCHAR(50) NOT NULL,
  `Quantity` INT UNSIGNED NOT NULL,
  `CartID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`CartID`),
  INDEX `CustomerID_idx` (`CustomerID` ASC),
  INDEX `ItemID_idx` (`ItemID` ASC),
  CONSTRAINT `CustomerID`
    FOREIGN KEY (`CustomerID`)
    REFERENCES `mydb`.`Customer` (`UserID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `ItemID`
    FOREIGN KEY (`ItemID`)
    REFERENCES `mydb`.`Item` (`ItemID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS `mydb`.`Admin` (
  `UserID` VARCHAR(50) NOT NULL COMMENT 'Contains the unique ID of this admin.',
  PRIMARY KEY (`UserID`),
  CONSTRAINT `UserID`
    FOREIGN KEY (`UserID`)
    REFERENCES `mydb`.`User` (`UserID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS `mydb`.`Privilege` (
  `PrivilegeID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `AdminID` VARCHAR(50) NOT NULL,
  `Privilege` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`PrivilegeID`),
  INDEX `AdminID_idx` (`AdminID` ASC),
  CONSTRAINT `AdminID`
    FOREIGN KEY (`AdminID`)
    REFERENCES `mydb`.`Admin` (`UserID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS `mydb`.`Review` (
  `ReviewID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `CustomerID` VARCHAR(50) NOT NULL,
  `VendorID` VARCHAR(50) NOT NULL,
  `OrderID` INT UNSIGNED NOT NULL,
  `Upvotes` INT NOT NULL DEFAULT 0,
  `Rating` INT UNSIGNED NOT NULL,
  `Date_Posted` DATE NOT NULL,
  `Text` VARCHAR(4000) NOT NULL,
  PRIMARY KEY (`ReviewID`),
  INDEX `CustomerID_idx` (`CustomerID` ASC),
  INDEX `VendorID_idx` (`VendorID` ASC),
  INDEX `OrderID_idx` (`OrderID` ASC),
  CONSTRAINT `CustomerID`
    FOREIGN KEY (`CustomerID`)
    REFERENCES `mydb`.`Customer` (`UserID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `VendorID`
    FOREIGN KEY (`VendorID`)
    REFERENCES `mydb`.`Vendor` (`UserID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `OrderID`
    FOREIGN KEY (`OrderID`)
    REFERENCES `mydb`.`Order` (`OrderID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


CREATE TABLE IF NOT EXISTS `mydb`.`Return` (
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
  `VendorID` VARCHAR(50) NOT NULL,
  INDEX `VendorID_idx` (`VendorID` ASC),
  PRIMARY KEY (`Card_CCV`),
  CONSTRAINT `VendorID`
    FOREIGN KEY (`VendorID`)
    REFERENCES `mydb`.`Vendor` (`UserID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;