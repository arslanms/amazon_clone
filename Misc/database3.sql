-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`User`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`User` (
  `UserID` VARCHAR(50) NOT NULL,
  `First_Name` VARCHAR(50) NULL,
  `Last Name` VARCHAR(50) NULL,
  `E-mail` VARCHAR(50) NOT NULL COMMENT 'Will be used as the username for logging in.',
  `Date_Joined` DATE NULL,
  `Phone_Number` VARCHAR(50) NULL,
  `Password` VARCHAR(100) NOT NULL COMMENT 'Contains an encrypted password of the customer.',
  `Street` VARCHAR(50) NULL,
  `ZIP` INT NULL,
  `City` VARCHAR(50) NULL,
  `State` CHAR(2) NULL,
  `Country` VARCHAR(50) NULL,
  `Type_Account` VARCHAR(10) NULL COMMENT 'Either \'Admin\', \'Customer\', or \'Vendor\'',
  PRIMARY KEY (`UserID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Vendor`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Vendor` (
  `UserID` VARCHAR(50) NOT NULL COMMENT 'This is the ID of the vendor to identify them.',
  `Name` VARCHAR(50) NULL COMMENT 'Name of the vendor.',
  `Description` VARCHAR(200) NULL COMMENT 'Description of what the vendor sells and stuff.',
  PRIMARY KEY (`UserID`),
  UNIQUE INDEX `VendorID_UNIQUE` (`UserID` ASC),
  CONSTRAINT `UserID_Vendor`
    FOREIGN KEY (`UserID`)
    REFERENCES `mydb`.`User` (`UserID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Item`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Item` (
  `Price` INT UNSIGNED NOT NULL COMMENT 'Holds the price of the particular item.',
  `Product_Name` VARCHAR(100) NOT NULL COMMENT 'Contains the name of the item.',
  `Type` VARCHAR(50) NULL COMMENT 'Contains the type of the item (e.x. Book, Clothing, Computer, etc.)',
  `ItemID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `Product_Desc` VARCHAR(1000) NULL COMMENT 'Contains a short description of the item.',
  `Quantity` INT UNSIGNED NOT NULL,
  `Picture` VARCHAR(50) NULL COMMENT 'Contains the file name of the picture (not the picture itself).',
  `UserID` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`ItemID`),
  UNIQUE INDEX `Product_Name_UNIQUE` (`Product_Name` ASC),
  INDEX `fk_Item_1_idx` (`UserID` ASC),
  CONSTRAINT `fk_Item_1_Item`
    FOREIGN KEY (`UserID`)
    REFERENCES `mydb`.`Vendor` (`UserID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Customer`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Customer` (
  `UserID` VARCHAR(50) NOT NULL COMMENT 'Holds the ID of this customer. Will be used to identify the customer.',
  PRIMARY KEY (`UserID`),
  CONSTRAINT `UserID_Customer`
    FOREIGN KEY (`UserID`)
    REFERENCES `mydb`.`User` (`UserID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Order`
-- -----------------------------------------------------
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
  `ZIP` INT UNSIGNED NOT NULL,
  `City` VARCHAR(50) NOT NULL,
  `State` CHAR(2) NOT NULL,
  `Country` VARCHAR(50) NOT NULL,
  `ItemID` INT UNSIGNED NOT NULL,
  `Quantity` INT UNSIGNED NOT NULL,
  `Reviewed` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`OrderID`),
  UNIQUE INDEX `OrderID_UNIQUE` (`OrderID` ASC),
  INDEX `CustomerID_idx` (`CustomerID` ASC),
  INDEX `VendorID_idx` (`VendorID` ASC),
  CONSTRAINT `CustomerID_Order`
    FOREIGN KEY (`CustomerID`)
    REFERENCES `mydb`.`Customer` (`UserID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `VendorID_Order`
    FOREIGN KEY (`VendorID`)
    REFERENCES `mydb`.`Vendor` (`UserID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Payment`
-- -----------------------------------------------------
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
  CONSTRAINT `CustomerID_Payment`
    FOREIGN KEY (`CustomerID`)
    REFERENCES `mydb`.`Customer` (`UserID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Inventory`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Inventory` (
  `ItemID` INT UNSIGNED NOT NULL,
  `VendorID` VARCHAR(50) NOT NULL,
  `Quantity` INT UNSIGNED NOT NULL,
  `InventoryID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`InventoryID`),
  INDEX `ItemID_idx` (`ItemID` ASC),
  INDEX `VendorID_idx` (`VendorID` ASC),
  CONSTRAINT `ItemID_Inventory`
    FOREIGN KEY (`ItemID`)
    REFERENCES `mydb`.`Item` (`ItemID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `VendorID_Inventory`
    FOREIGN KEY (`VendorID`)
    REFERENCES `mydb`.`Vendor` (`UserID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Shopping Cart`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Shopping Cart` (
  `ItemID` INT UNSIGNED NOT NULL,
  `CustomerID` VARCHAR(50) NOT NULL,
  `Quantity` INT UNSIGNED NOT NULL,
  `CartID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`CartID`),
  INDEX `CustomerID_idx` (`CustomerID` ASC),
  INDEX `ItemID_idx` (`ItemID` ASC),
  CONSTRAINT `CustomerID_Cart`
    FOREIGN KEY (`CustomerID`)
    REFERENCES `mydb`.`Customer` (`UserID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `ItemID_Cart`
    FOREIGN KEY (`ItemID`)
    REFERENCES `mydb`.`Item` (`ItemID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Admin`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Admin` (
  `UserID` VARCHAR(50) NOT NULL COMMENT 'Contains the unique ID of this admin.',
  PRIMARY KEY (`UserID`),
  CONSTRAINT `UserID_Admin`
    FOREIGN KEY (`UserID`)
    REFERENCES `mydb`.`User` (`UserID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Privilege`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Privilege` (
  `PrivilegeID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `AdminID` VARCHAR(50) NOT NULL,
  `Privilege` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`PrivilegeID`),
  INDEX `AdminID_idx` (`AdminID` ASC),
  CONSTRAINT `AdminID_Privilege`
    FOREIGN KEY (`AdminID`)
    REFERENCES `mydb`.`Admin` (`UserID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Review`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Review` (
  `ReviewID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `CustomerID` VARCHAR(50) NOT NULL,
  `VendorID` VARCHAR(50) NOT NULL,
  `OrderID` INT UNSIGNED NOT NULL,
  `Rating` INT UNSIGNED NOT NULL,
  `Date_Posted` DATE NOT NULL,
  `Text` VARCHAR(4000) NOT NULL,
  PRIMARY KEY (`ReviewID`),
  INDEX `CustomerID_idx` (`CustomerID` ASC),
  INDEX `VendorID_idx` (`VendorID` ASC),
  INDEX `OrderID_idx` (`OrderID` ASC),
  CONSTRAINT `CustomerID_Review`
    FOREIGN KEY (`CustomerID`)
    REFERENCES `mydb`.`Customer` (`UserID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `VendorID_Review`
    FOREIGN KEY (`VendorID`)
    REFERENCES `mydb`.`Vendor` (`UserID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `OrderID_Review`
    FOREIGN KEY (`OrderID`)
    REFERENCES `mydb`.`Order` (`OrderID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Return`
-- -----------------------------------------------------
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
  CONSTRAINT `VendorID_Return`
    FOREIGN KEY (`VendorID`)
    REFERENCES `mydb`.`Vendor` (`UserID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
