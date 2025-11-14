CREATE TABLE Account (
    UserId NVARCHAR(50) PRIMARY KEY,
    UserEmail NVARCHAR(100) UNIQUE NOT NULL,
    UserPhone NVARCHAR(10) NOT NULL,
    UserPassword NVARCHAR(100) NOT NULL,
    UserName NVARCHAR(100) NOT NULL,
    UserRole NVARCHAR(50) NOT NULL,
    IdentityCard NVARCHAR(13) UNIQUE,
    UserAddress NVARCHAR(255),
    UserImage NVARCHAR(255),
    IsDeleted BIT DEFAULT 0 NOT NULL
);

CREATE TABLE Customer (
    CustomerId NVARCHAR(50) PRIMARY KEY,
    CustomerName NVARCHAR(50) NOT NULL,
    CustomerPhone NVARCHAR(10) NOT NULL,
    NumberOfPayment INT DEFAULT 0,
	IsDeleted BIT DEFAULT 0
);

CREATE TABLE Inventory (
    ItemId NVARCHAR(50) PRIMARY KEY,
    ItemName NVARCHAR(100) NOT NULL,
    ItemType NVARCHAR(50) NOT NULL,
    ItemPrice DECIMAL(10, 2) NOT NULL,
    ItemQuantity INT NOT NULL,
    ItemUnit NVARCHAR(20),
    ItemDescription NVARCHAR(255),
    IsDeleted BIT DEFAULT 0
);

CREATE TABLE Dish (
    DishId NVARCHAR(50) PRIMARY KEY,
    DishName NVARCHAR(100) NOT NULL,
    DishType NVARCHAR(50) NOT NULL,
    DishPrice DECIMAL(10, 2) NOT NULL,
    DishDescription NVARCHAR(255),
    DishImage NVARCHAR(255),
    DishStatus NVARCHAR(50) DEFAULT 'Available',
    IngredientStatus NVARCHAR(50) DEFAULT 'Sufficient'
);

CREATE TABLE Dish_Inventory (
    DishId NVARCHAR(50) FOREIGN KEY REFERENCES Dish(DishId),
    ItemId NVARCHAR(50) FOREIGN KEY REFERENCES Inventory(ItemId),
    QuantityUsed DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (DishId, ItemId)
);

CREATE TABLE Coupon (
    CouponId NVARCHAR(50) PRIMARY KEY,
    DiscountAmount DECIMAL(10, 2) NOT NULL,
    ExpirationDate DATE NULL,
    TimesUsed INT DEFAULT 0 NOT NULL,
    IsDeleted BIT DEFAULT 0 NOT NULL,
    [Description] NVARCHAR(255) NULL
);

CREATE TABLE [Table] (
    TableId NVARCHAR(50) PRIMARY KEY,
    TableStatus NVARCHAR(50) NOT NULL,
    NumberOfSeats INT NOT NULL,
    FloorNumber INT NULL,
    IsDeleted BIT DEFAULT 0
);

CREATE TABLE [Order] (
    OrderId NVARCHAR(50) PRIMARY KEY,
    UserId NVARCHAR(50) FOREIGN KEY REFERENCES Account(UserId) ON UPDATE CASCADE,
    CustomerId NVARCHAR(50) FOREIGN KEY REFERENCES Customer(CustomerId) NULL,
    OrderDate DATETIME DEFAULT GETDATE(),
    OrderStatus NVARCHAR(50) NOT NULL,
    OrderType NVARCHAR(20),
    OrderDescription NVARCHAR(255),
    CouponId NVARCHAR(50) FOREIGN KEY REFERENCES Coupon(CouponId) NULL,
    TableId NVARCHAR(50) FOREIGN KEY REFERENCES [Table](TableId) NULL,
    CustomerPhone NVARCHAR(10),
    Total DECIMAL(18, 2) DEFAULT 0,
	FinalPrice DECIMAL(18, 2) DEFAULT 0
);


CREATE TABLE OrderDetail (
    OrderDetailId NVARCHAR(50) PRIMARY KEY,
    OrderId NVARCHAR(50) FOREIGN KEY REFERENCES [Order](OrderId),
    DishList NVARCHAR(MAX) NOT NULL CHECK (ISJSON(DishList) = 1),
    Total DECIMAL(10, 2) NOT NULL 
);

CREATE TABLE Notification (
    NotificationId INT PRIMARY KEY IDENTITY(1,1),
    UserId NVARCHAR(50) FOREIGN KEY REFERENCES Account(UserId) ON UPDATE CASCADE,
    NotificationContent NVARCHAR(255),
    NotificationCreateAt DATETIME DEFAULT GETDATE(),
    UserRole NVARCHAR(50) NULL,
    UserName NVARCHAR(100) NULL,
    CreatorId NVARCHAR(50) NULL
);


-- Account
INSERT INTO Account (UserId, UserEmail, UserPhone, UserPassword, UserName, UserRole, IdentityCard, UserAddress, UserImage) VALUES
('EM001', 'admin@gmail.com', '0914678931', '123456', 'Nguyen Van An', 'Admin', '012345678901', '123 ABC Street, Hanoi', 'admin.jpg'),
('EM002', 'manager@gmail.com', '0357904621', '123456', 'Tran Thi Bich', 'Manager', '012345678902', '456 XYZ Street, Ho Chi Minh City', 'manager.jpg'),
('EM003', 'cashier@gmail.com', '0945683541', '123456', 'Le Van Cuong', 'Cashier', '012345678903', '789 DEF Street, Da Nang', 'cashier.jpg'),
('EM004', 'waiter1@gmail.com', '0987453217', '123456', 'Pham Thi Duyen', 'Waiter', '012345678904', '101 GHI Street, Hanoi', 'waiter1.jpg'),
('EM005', 'kitchenstaff@gmail.com', '0813678903', '123456', 'Nguyen Van Duc', 'Kitchen staff', '012345678905', '202 JKL Street, Ho Chi Minh City', 'waiter2.jpg');

-- Customer
INSERT INTO Customer (CustomerId, CustomerName, CustomerPhone, NumberOfPayment) VALUES
('CU001', 'Nguyen Van A', '0901234567', 5),
('CU002', 'Tran Thi B', '0902345678', 10),
('CU003', 'Le Van C', '0903456789', 2),
('CU004', 'Pham Thi D', '0904567890', 1);

-- Inventory
INSERT INTO Inventory (ItemId, ItemName, ItemType, ItemPrice, ItemQuantity, ItemUnit, ItemDescription, IsDeleted) VALUES
('IN001', 'Rice', 'Food', 20000, 100, 'kg', 'High-quality rice', 0),
('IN002', 'Pork belly', 'Food', 150000, 50, 'kg', 'Fresh pork', 0),
('IN003', 'Morning glory', 'Food', 10000, 20, 'kg', 'Fresh morning glory', 0),
('IN004', 'Coffee', 'Drink', 50000, 10, 'kg', 'Pure coffee beans', 0),
('IN005', 'Fish sauce', 'Food', 30000, 30, 'liter', 'Phu Quoc fish sauce', 0),
('IN006', 'Sugar', 'Food', 25000, 40, 'kg', 'White granulated sugar', 0);

-- Dish
INSERT INTO Dish (DishId, DishName, DishType, DishPrice, DishDescription, DishImage, DishStatus) VALUES
('DI001', 'Pho Bo', 'Food', 50000, 'Traditional Hanoi beef noodle soup', 'pho_bo.jpg', 'Available'),
('DI002', 'Bun Cha', 'Food', 40000, 'Hanoi grialled pork with vermicelli', 'bun_cha.jpg', 'Available'),
('DI003', 'Com Tam Suon', 'Food', 45000, 'Broken rice with grilled pork chop', 'com_tam.jpg', 'Available'),
('DI004', 'Black Coffee', 'Drink', 20000, 'Iced black coffee', 'cafe_den.jpg', 'Available'),
('DI005', 'Avocado Smoothie', 'Drink', 30000, 'Fresh avocado smoothie', 'sinh_to_bo.jpg', 'Available');

-- Dish_Inventory
INSERT INTO Dish_Inventory (DishId, ItemId, QuantityUsed) VALUES
('DI001', 'IN001', 1.00),
('DI001', 'IN002', 0.10),
('DI001', 'IN005', 0.05),
('DI002', 'IN001', 0.50),
('DI002', 'IN002', 0.20),
('DI002', 'IN003', 0.10),
('DI003', 'IN001', 0.50),
('DI003', 'IN002', 0.20),
('DI003', 'IN005', 0.10),
('DI004', 'IN004', 0.02),
('DI004', 'IN006', 0.01);

-- Coupon
INSERT INTO Coupon (CouponId, DiscountAmount, ExpirationDate, TimesUsed, [Description]) VALUES
('CO001', 10000, '2024-12-31', 0, '10,000 VND discount for all orders'),
('CO002', 20000, '2024-07-31', 0, '20,000 VND discount for orders over 200,000 VND');

-- Table
INSERT INTO [Table] (TableId, TableStatus, NumberOfSeats, FloorNumber, IsDeleted) VALUES
('TA001', 'Available', 4, 1, 0),
('TA002', 'Available', 6, 1, 0),
('TA003', 'Reserved', 2, 2, 0),
('TA004', 'Available', 8, 2, 0);

-- Order

-- Notification
INSERT INTO Notification (UserId, NotificationContent, UserRole) VALUES
('EM002', 'New order (OR002) needs processing', 'Manager'),
('EM001', 'Table TA003 has been paid', 'Admin');

