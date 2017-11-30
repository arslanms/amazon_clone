export class User {
  userID: string;       // VARCHAR(50) NOT NULL
  first_name: string;   // VARCHAR(50) NULL,
  last_name: string     // VARCHAR(50) NULL,
  email: string         // VARCHAR(50) NOT NULL COMMENT 'Will be used as the username for logging in
  date_joined: Date;    // DATE NULL
  phone_number: string; // VARCHAR(50) NULL
  password: string;     // VARCHAR(100) NOT NULL COMMENT 'Contains an encrypted password of the customer
  street: string;       // VARCHAR(50) NULL
  zip: number;          // INT NULL
  city: string;         // VARCHAR(50) NULL
  state: string;        // CHAR(2) NULL
  country:string;       // VARCHAR(50) NULL,
  type_account: string; // VARCHAR(10) NULL COMMENT 'Either \'Admin\', \'Customer\', or \'Vendor\''
}