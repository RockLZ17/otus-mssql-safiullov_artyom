--1. 
 
create database FORMULA_1

use FORMULA_1

-- 2. 

CREATE TABLE [Drivers] (
    [Driver_id] int  NOT NULL ,
    [Driver_name] nvarchar(255)  NOT NULL ,
    [Driver_country] nvarchar(255)  NOT NULL ,
    [Driver_birth] date  NOT NULL ,
    CONSTRAINT [PK_Drivers] PRIMARY KEY CLUSTERED (
        [Driver_id] ASC
    )
)

CREATE TABLE [Constructors] (
    [Constructor_id] int  NOT NULL ,
    [Constructor_name] nvarchar(255)  NOT NULL ,
    [Constructor_engine] nvarchar(255)  NOT NULL ,
    [Constructor_country] nvarchar(255)  NOT NULL ,
    CONSTRAINT [PK_Constructors] PRIMARY KEY CLUSTERED (
        [Constructor_id] ASC
    )
)

CREATE TABLE [Circuits] (
    [Circuit_id] int  NOT NULL ,
    [Circuit_name] nvarchar(255)  NOT NULL ,
    [Circuit_country] nvarchar(255)  NOT NULL ,
    CONSTRAINT [PK_Circuits] PRIMARY KEY CLUSTERED (
        [Circuit_id] ASC
    )
)

CREATE TABLE [Grands_Prix] (
    [Grands_Prix_id] int  NOT NULL ,
    [Circuit_id] int  NOT NULL ,
    [Season] tinyint  NOT NULL ,
    [First_place_driver_id] int  NOT NULL ,
    [Second_place_driver_id] int  NOT NULL ,
    [Third_place_driver_id] int  NOT NULL ,
    [First_place_constructor_id] int  NOT NULL ,
    [Second_place_constructor_id] int  NOT NULL ,
    [Third_place_constructor_id] int  NOT NULL ,
    [Driver_polesitter_id] int  NOT NULL ,
    [Constructor_polesitter_id] int  NOT NULL ,
    [Driver_fastest_lap_id] int  NOT NULL ,
    [Constructor_fastest_lap_id] int  NOT NULL ,
    CONSTRAINT [PK_Grands_Prix] PRIMARY KEY CLUSTERED (
        [Grands_Prix_id] ASC
    )
)

ALTER TABLE [Grands_Prix] WITH CHECK ADD CONSTRAINT [FK_Grands_Prix_Circuit_id] FOREIGN KEY([Circuit_id])
REFERENCES [Circuits] ([Circuit_id])

ALTER TABLE [Grands_Prix] CHECK CONSTRAINT [FK_Grands_Prix_Circuit_id]

ALTER TABLE [Grands_Prix] WITH CHECK ADD CONSTRAINT [FK_Grands_Prix_First_place_driver_id] FOREIGN KEY([First_place_driver_id])
REFERENCES [Drivers] ([Driver_id])

ALTER TABLE [Grands_Prix] CHECK CONSTRAINT [FK_Grands_Prix_First_place_driver_id]

ALTER TABLE [Grands_Prix] WITH CHECK ADD CONSTRAINT [FK_Grands_Prix_Second_place_driver_id] FOREIGN KEY([Second_place_driver_id])
REFERENCES [Drivers] ([Driver_id])

ALTER TABLE [Grands_Prix] CHECK CONSTRAINT [FK_Grands_Prix_Second_place_driver_id]

ALTER TABLE [Grands_Prix] WITH CHECK ADD CONSTRAINT [FK_Grands_Prix_Third_place_driver_id] FOREIGN KEY([Third_place_driver_id])
REFERENCES [Drivers] ([Driver_id])

ALTER TABLE [Grands_Prix] CHECK CONSTRAINT [FK_Grands_Prix_Third_place_driver_id]

ALTER TABLE [Grands_Prix] WITH CHECK ADD CONSTRAINT [FK_Grands_Prix_First_place_constructor_id] FOREIGN KEY([First_place_constructor_id])
REFERENCES [Constructors] ([Constructor_id])

ALTER TABLE [Grands_Prix] CHECK CONSTRAINT [FK_Grands_Prix_First_place_constructor_id]

ALTER TABLE [Grands_Prix] WITH CHECK ADD CONSTRAINT [FK_Grands_Prix_Second_place_constructor_id] FOREIGN KEY([Second_place_constructor_id])
REFERENCES [Constructors] ([Constructor_id])

ALTER TABLE [Grands_Prix] CHECK CONSTRAINT [FK_Grands_Prix_Second_place_constructor_id]

ALTER TABLE [Grands_Prix] WITH CHECK ADD CONSTRAINT [FK_Grands_Prix_Third_place_constructor_id] FOREIGN KEY([Third_place_constructor_id])
REFERENCES [Constructors] ([Constructor_id])

ALTER TABLE [Grands_Prix] CHECK CONSTRAINT [FK_Grands_Prix_Third_place_constructor_id]

ALTER TABLE [Grands_Prix] WITH CHECK ADD CONSTRAINT [FK_Grands_Prix_Driver_polesitter_id] FOREIGN KEY([Driver_polesitter_id])
REFERENCES [Drivers] ([Driver_id])

ALTER TABLE [Grands_Prix] CHECK CONSTRAINT [FK_Grands_Prix_Driver_polesitter_id]

ALTER TABLE [Grands_Prix] WITH CHECK ADD CONSTRAINT [FK_Grands_Prix_Constructor_polesitter_id] FOREIGN KEY([Constructor_polesitter_id])
REFERENCES [Constructors] ([Constructor_id])

ALTER TABLE [Grands_Prix] CHECK CONSTRAINT [FK_Grands_Prix_Constructor_polesitter_id]

ALTER TABLE [Grands_Prix] WITH CHECK ADD CONSTRAINT [FK_Grands_Prix_Driver_fastest_lap_id] FOREIGN KEY([Driver_fastest_lap_id])
REFERENCES [Drivers] ([Driver_id])

ALTER TABLE [Grands_Prix] CHECK CONSTRAINT [FK_Grands_Prix_Driver_fastest_lap_id]

ALTER TABLE [Grands_Prix] WITH CHECK ADD CONSTRAINT [FK_Grands_Prix_Constructor_fastest_lap_id] FOREIGN KEY([Constructor_fastest_lap_id])
REFERENCES [Constructors] ([Constructor_id])

ALTER TABLE [Grands_Prix] CHECK CONSTRAINT [FK_Grands_Prix_Constructor_fastest_lap_id]


--3
CREATE NONCLUSTERED INDEX ix_index
    ON formula_1.dbo.grands_prix (Driver_polesitter_id, Driver_fastest_lap_id)