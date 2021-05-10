create user employee identified by emppass account unlock;
grant employee_role to employee;
create user client identified by clipass account unlock;
grant client_role to client;

create role employee_role;
grant create session to employee_role;
grant execute on addClient to employee_role;
grant execute on addRemainder to employee_role;
grant execute on addContract to employee_role;
grant execute on getTariffs to employee_role;
grant execute on sys.dbms_crypto to employee_role;


create role client_role;
grant create session to client_role;
grant execute on getClientData to client_role;
grant execute on changeTariff to client_role;
grant execute on getTariffs to client_role;
grant execute on balanceReplenishment to client_role;
grant execute on moneyTransfer to client_role;
grant execute on debits to client_role;
grant execute on sendSMS to client_role;
grant execute on sendMMS to client_role;
grant execute on useInternet to client_role;
grant execute on startCall to client_role;
grant execute on endCall to client_role;
grant execute on sys.dbms_crypto to employee_role;



create table Contract
(
Id INTEGER GENERATED ALWAYS AS IDENTITY
(START WITH 1 INCREMENT BY 1) primary key,
PhoneNumber nvarchar2 (14) UNIQUE NOT NULL,
RegistrationDate DATE NOT NULL,
TariffPlanId int NOT NULL,
ClientId int NOT NULL,
EmployeeId int NOT NULL, 
RemainderId int,
CONSTRAINT fk_TariffPlanId FOREIGN KEY (TariffPlanId) REFERENCES TariffPlan(Id),
CONSTRAINT fk_ClientId FOREIGN KEY (ClientId) REFERENCES Client(Id),
CONSTRAINT fk_EmployeeId FOREIGN KEY (EmployeeId) REFERENCES Employees(Id),
CONSTRAINT CheckPhoneNumber check(PhoneNumber LIKE '+37533%')
);
alter table contract modify (TariffPlanId visible, ClientId visible, EmployeeId visible);
alter table Contract add (RemainderId int not null);
alter table Contract drop column RemainderId;
alter table Contract add constraint fk_RemainderId
            foreign key (RemainderId) references Remainder(Id);

commit;
create table Remainder
(
Id INTEGER GENERATED ALWAYS AS IDENTITY
(START WITH 1 INCREMENT BY 1) primary key,
Balance decimal(5,2) not null,
Minutes nvarchar2(50) not null,
SMS nvarchar2(50) not null,
MMS nvarchar2(50) not null,
Megabytes nvarchar2(50) not null
);


create table Calls
(
Id INTEGER GENERATED ALWAYS AS IDENTITY
(START WITH 1 INCREMENT BY 1),
InterlocutorNumber nvarchar2 (14) NOT NULL,
CallDuration INTERVAL DAY(0) TO SECOND NOT NULL,
CallDate DATE NOT NULL,
ContractId int,
CONSTRAINT fkCalls_ContractId FOREIGN KEY (ContractId) REFERENCES Contract(Id)
);
alter table Calls modify (CallDate visible, ContractId visible);
alter table Calls add (CallDuration INTERVAL DAY(0) TO SECOND);
alter table Calls drop column CallDuration;
alter table Calls modify CallDate TIMESTAMP;

create table Client
(
Id INTEGER GENERATED ALWAYS AS IDENTITY
(START WITH 1 INCREMENT BY 1) primary key,
Name nvarchar2(50) NOT NULL,
Surname nvarchar2(50) NOT NULL,
SecondName nvarchar2(50),
PassportNumber nvarchar2(50) NOT NULL UNIQUE,
IssuedBy nvarchar2(50) NOT NULL,
Town nvarchar2(50) NOT NULL,
Street nvarchar2(50) NOT NULL,
BuildingNumber nvarchar2(10) NOT NULL,
Password nvarchar2(2000) default NULL
);

alter table Client modify (Password visible);
alter table Client add (BuildingNumber nvarchar2(10));
alter table Client drop column BuildingNumber;

CREATE TABLE Employees
(
Id INTEGER GENERATED ALWAYS AS IDENTITY
(START WITH 1 INCREMENT BY 1) primary key,
Name nvarchar2(50) NOT NULL,
Surname nvarchar2(50) NOT NULL,
SecondName nvarchar2(50),
Login nvarchar2(50) NOT NULL,
Password nvarchar2(2000) NOT NULL,
Position nvarchar2(50) NOT NULL
);
insert into Employees(Name, Surname, SecondName, Login, Password, Position)
 values('Игорь','Петровский','Валерьевич','admin','admin','admin');
  select*from Employees;
create table TariffPlan
(
Id INTEGER GENERATED ALWAYS AS IDENTITY
(START WITH 1 INCREMENT BY 1) primary key,
Name nvarchar2(50) NOT NULL,
Price nvarchar2(5) NOT NULL,
ServiceId int,
CONSTRAINT fk_ServiceId FOREIGN KEY(ServiceId) REFERENCES Services(Id)
);
alter table TariffPlan modify (ServiceID invisible);
alter table TariffPlan add (DailyDebit decimal(5,2));
alter table TariffPlan drop column Price;
select*from Services;
delete from Services;

delete from TARIFFPLAN;
create table Services
(
Id INTEGER GENERATED ALWAYS AS IDENTITY
(START WITH 1 INCREMENT BY 1) primary key,
Minutes nvarchar2(50) default '0',
SMS nvarchar2(50) default '0',
MMS nvarchar2(50) default '0',
Megabytes nvarchar2(50) default '0'
);

create table Debit
(
Id INTEGER GENERATED ALWAYS AS IDENTITY
(START WITH 1 INCREMENT BY 1) primary key,
DebitDate Date NOT NULL,
Amount decimal(5,2) NOT NULL,
ContractId int,
CONSTRAINT fkDebit_ContractId FOREIGN KEY(ContractId) REFERENCES Contract(Id)
);

drop table Services;
drop table Employees;
drop table AdditionalServices;
drop table AdditionalServicesPrices;
drop table Contract;
drop table Client;
drop table TariffPlan;
drop table Debit;
drop table Causes;
drop table Calls;

alter table Client modify (Position visible);
alter table Client add (Password nvarchar2(2000));

create or replace function get_user_cursor(in_login in nvarchar2, in_password in nvarchar2)
return sys_refcursor
as
user_cur sys_refcursor;
  begin
    open user_cur for select * from Employees where Login=in_login and Password=in_password;
    return user_cur;
  end get_user_cursor;
  
create or replace procedure findUser(in_login in Employees.Login%TYPE, in_password in Employees.Password%TYPE, user_cur out sys_refcursor)
is
invalid_user exception;
check_count number;
encode_key varchar2(2000) := 'mobileOperator12';
encode_mode number;
encode_pass raw(2000);
begin
encode_mode := DBMS_CRYPTO.ENCRYPT_AES128 + DBMS_CRYPTO.CHAIN_CBC + DBMS_CRYPTO.PAD_PKCS5;
encode_pass := DBMS_CRYPTO.ENCRYPT(utl_i18n.string_to_raw (in_password, 'AL32UTF8'), encode_mode,
    utl_i18n.string_to_raw (encode_key, 'AL32UTF8'));
select count(*) into check_count from Employees where Login=in_login and Password=encode_pass;
  if check_count!=0 then user_cur := get_user_cursor(in_login, encode_pass);
  else raise invalid_user;
  end if;
  dbms_output.enable();
  dbms_sql.return_result(user_cur);
  exception 
  when invalid_user then
  raise_application_error(-20000,'Проверьте введенные данные');
end findUser;


CREATE or replace PROCEDURE addEmployee(in_name in Employees.Name%TYPE, in_surname in Employees.Surname%TYPE,
in_secondname in Employees.SecondName%TYPE, in_login in Employees.Login%TYPE, in_password in Employees.Password%TYPE, in_position in Employees.Position%TYPE)
IS
user_exists number;
curr_user_exists exception;
encode_key varchar2(2000) := 'mobileOperator12';
encode_mode number;
encode_pass raw(2000);
invaliddata exception;
begin
    if in_name is null or in_surname is null or in_secondname is null or in_login is null or in_password is null or in_position is null
    then raise invaliddata;
    end if;
    encode_mode := DBMS_CRYPTO.ENCRYPT_AES128 + DBMS_CRYPTO.CHAIN_CBC + DBMS_CRYPTO.PAD_PKCS5;
    
    encode_pass := DBMS_CRYPTO.ENCRYPT(utl_i18n.string_to_raw (in_password, 'AL32UTF8'),
        encode_mode, utl_i18n.string_to_raw (encode_key, 'AL32UTF8'));
    SELECT COUNT(*) into user_exists from Employees where Employees.Login = in_login;
    if user_exists != 0 then raise curr_user_exists;
        else insert into Employees (Name, Surname, SecondName, Login, Password, Position)
        values (in_name, in_surname, in_secondname, in_login,encode_pass,in_position);
    end if;
    exception
    when curr_user_exists then
    raise_application_error(-20001, 'Пользователь с таким логином существует');
    when invaliddata then
    raise_application_error(-20029, 'Проверьте введенные данные');
  commit;
end addEmployee;

create or replace procedure addService(in_mins in Services.Minutes%TYPE, in_sms in Services.SMS%TYPE,
in_mms in Services.MMS%TYPE, in_megabytes in Services.Megabytes%TYPE)
is
begin
  insert into Services(Minutes, SMS, MMS, Megabytes) values (in_mins, in_sms, in_mms, in_megabytes);
  commit;
end;

select * from Services;
CREATE or replace PROCEDURE addTariffPlan(in_name in TariffPlan.Name%TYPE, in_price in TariffPlan.Price%TYPE,
in_mins in Services.Minutes%TYPE, in_sms in Services.SMS%TYPE,
in_mms in Services.MMS%TYPE, in_megabytes in Services.Megabytes%TYPE)
IS
service_id int;
tariff_exists number;
curr_tariff_exists exception;
invaliddata exception;
begin
    if in_name is null or in_price is null or in_mins is null or in_sms is null or in_mms is null or in_megabytes is null then raise invaliddata;
    end if;
    SELECT COUNT(*) into tariff_exists from TariffPlan where TariffPlan.Name = in_name; 
    if tariff_exists != 0 then raise curr_tariff_exists;
        else addService(in_mins,in_sms,in_mms,in_megabytes);
    end if;
    select MAX(Id) into service_id from Services;
    insert into TariffPlan(Name, Price,DAILYDEBIT, ServiceId) values (in_name,in_price,in_price/30, service_id);
    exception
    when curr_tariff_exists then
    raise_application_error(-20002, 'Такой тариф уже существует');
    when invaliddata then
    raise_application_error(-20028, 'Проверьте введенные данные');
  commit;
end addTariffPlan;

create or replace procedure addClient(in_name in Client.Name%TYPE, in_surname in Client.Surname%TYPE, in_secondname in Client.SecondName%TYPE,
in_passportnumber in Client.PassportNumber%TYPE, in_issuedby in Client.IssuedBy%TYPE, in_town in Client.Town%TYPE, in_street in Client.Street%TYPE,
in_buildingnumber in Client.BuildingNumber%TYPE)
is
begin
  insert into Client(Name, Surname, SecondName, PassportNumber, IssuedBy, Town, Street, BuildingNumber)
  values (in_name, in_surname, in_secondname, in_passportnumber, in_issuedby, in_town, in_street, in_buildingnumber);
  commit;
end;

create or replace procedure addRemainder(in_tariff in TariffPlan.Name%TYPE)
is 
mins nvarchar2(50);
sms nvarchar2(50);
mms nvarchar2(50);
megabytes nvarchar2(50);
balance decimal(5,2);
begin
    select Services.Minutes into mins from TariffPlan join Services on TariffPlan.ServiceId=Services.Id where TariffPlan.Name=in_tariff;
    select Services.SMS into sms from TariffPlan join Services on TariffPlan.ServiceId=Services.Id where TariffPlan.Name=in_tariff;
    select Services.MMS into mms from TariffPlan join Services on TariffPlan.ServiceId=Services.Id where TariffPlan.Name=in_tariff;
    select Services.Megabytes into megabytes from TariffPlan join Services on TariffPlan.ServiceId=Services.Id where TariffPlan.Name=in_tariff;
    select TariffPlan.Price into balance from TariffPlan join Services on TariffPlan.ServiceId=Services.Id where TariffPlan.Name=in_tariff;
    insert into Remainder(Balance, Minutes, SMS, MMS, Megabytes) values (balance, mins, sms, mms, megabytes);
    commit;
end;

CREATE or replace PROCEDURE addContract(in_number in Contract.PhoneNumber%TYPE, 
in_tariff in TariffPlan.Name%TYPE, in_name in Client.Name%TYPE, in_surname in Client.Surname%TYPE,
in_secondname in Client.SecondName%TYPE,
in_passportnumber in Client.PassportNumber%TYPE, in_issuedby in Client.IssuedBy%TYPE, 
in_town in Client.Town%TYPE, in_street in Client.Street%TYPE,
in_buildingnumber in Client.BuildingNumber%TYPE, in_emplid in Contract.EmployeeId%TYPE)
IS
tariff_id number;
remainder_id number;
n number;
priceT decimal(5,2);
client_id number;
number_exists number;
passport_exists number;
curr_number_exists exception;
number_valid exception;
curr_passport_exists exception;
encode_key varchar2(2000) := 'mobileOperator12';
encode_mode number;
encode_issuedby raw(2000);
encode_passportnumber raw(2000);
encode_town raw(2000);
encode_street raw(2000);
encode_buildingnumber raw(2000);
invaliddata exception;
begin
    if in_number is null or in_name is null or in_surname is null or in_secondname is null or in_tariff is null or in_passportnumber is null or in_issuedby is null
    or in_town is null or in_street is null or in_buildingnumber is null then raise invaliddata;
    end if;
    encode_mode := DBMS_CRYPTO.ENCRYPT_AES128 + DBMS_CRYPTO.CHAIN_CBC + DBMS_CRYPTO.PAD_PKCS5;
    encode_issuedby := DBMS_CRYPTO.ENCRYPT(utl_i18n.string_to_raw (in_issuedby, 'AL32UTF8'),
        encode_mode, utl_i18n.string_to_raw (encode_key, 'AL32UTF8'));
    encode_passportnumber := DBMS_CRYPTO.ENCRYPT(utl_i18n.string_to_raw (in_passportnumber, 'AL32UTF8'),
        encode_mode, utl_i18n.string_to_raw (encode_key, 'AL32UTF8'));
    encode_town := DBMS_CRYPTO.ENCRYPT(utl_i18n.string_to_raw (in_town, 'AL32UTF8'),
        encode_mode, utl_i18n.string_to_raw (encode_key, 'AL32UTF8'));
    encode_street := DBMS_CRYPTO.ENCRYPT(utl_i18n.string_to_raw (in_street, 'AL32UTF8'),
        encode_mode, utl_i18n.string_to_raw (encode_key, 'AL32UTF8'));
    encode_buildingnumber := DBMS_CRYPTO.ENCRYPT(utl_i18n.string_to_raw (in_buildingnumber, 'AL32UTF8'),
        encode_mode, utl_i18n.string_to_raw (encode_key, 'AL32UTF8'));
    SELECT COUNT(*) into number_exists from Contract where Contract.PhoneNumber = in_number;   
    SELECT COUNT(*) into passport_exists from Client where Client.PassportNumber = encode_passportnumber;
    
    if in_number like('+37533%') then n:=1;
        else raise number_valid;
        end if;
    if number_exists != 0 then raise curr_number_exists;
        elsif passport_exists!=0 then raise curr_passport_exists;
    end if;
    addClient(in_name, in_surname, in_secondname, encode_passportnumber, encode_issuedby, encode_town, encode_street, encode_buildingnumber);
    addRemainder(in_tariff);
    select Id into tariff_id from TariffPlan where Name=in_tariff;
    select Price into priceT from TariffPlan where Name=in_tariff;
    select MAX(Id) into client_id from Client;
    select MAX(Id) into remainder_id from Remainder;
    insert into Contract(PhoneNumber, RegistrationDate, TariffPlanId, ClientId, EmployeeId, RemainderId)
                values(in_number, CURRENT_TIMESTAMP, tariff_id, client_id, in_emplid, remainder_id);
    commit;
    exception
    when curr_number_exists then
    raise_application_error(-20003, 'Такой номер уже используется');
    when curr_passport_exists then
    raise_application_error(-20004, 'Номер паспорта уже привязан к другому номеру');
    when number_valid then
    raise_application_error(-20005, 'Неверный формат ввода номера или код не соответствует коду компании');
    when invaliddata then
    raise_application_error(-20030, 'Проверьте введенные данные');
end addContract;

CREATE or replace PROCEDURE getTariffs(tariff out sys_refcursor)
IS
begin
open tariff for select Name from TariffPlan;
end getTariffs;
commit;

create or replace procedure registrationClient(in_number in Contract.PhoneNumber%TYPE,
in_passportnumber in Client.PassportNumber%TYPE, in_password in Client.Password%TYPE)
IS
encode_key varchar2(2000) := 'mobileOperator12';
encode_mode number;
encode_passnum varchar2(2000);
encode_password varchar2(2000);
data_contains number;
not_found exception;
begin
      encode_mode := DBMS_CRYPTO.ENCRYPT_AES128 + DBMS_CRYPTO.CHAIN_CBC + DBMS_CRYPTO.PAD_PKCS5;
      encode_passnum := DBMS_CRYPTO.ENCRYPT(utl_i18n.string_to_raw (in_passportnumber, 'AL32UTF8'),
        encode_mode, utl_i18n.string_to_raw (encode_key, 'AL32UTF8'));
      encode_password := DBMS_CRYPTO.ENCRYPT(utl_i18n.string_to_raw (in_password, 'AL32UTF8'),
        encode_mode, utl_i18n.string_to_raw (encode_key, 'AL32UTF8'));
       select Count(*) into data_contains from Contract join Client on Contract.Id=Client.Id and Contract.PhoneNumber=in_number and Client.PassportNumber=encode_passnum and Client.Password is NULL;
      if data_contains=0 then raise not_found;
          else update Client set Password = encode_password where PassportNumber=encode_passnum;
      end if;
      exception when not_found then
      raise_application_error(-20006, 'Личные данные не найдены либо учетная запись уже существует');
      commit;
end registrationClient;
commit;

create or replace function get_client_cursor(in_login in nvarchar2, in_password in nvarchar2)
return sys_refcursor
as
user_cur sys_refcursor;
  begin
    open user_cur for select Contract.Id, Contract.PhoneNumber, Client.Password from Client join Contract on Client.Id=Contract.ClientId where Contract.PhoneNumber=in_login and Client.Password=in_password;
    return user_cur;
  end get_client_cursor;
  
create or replace procedure findClient(in_login in Contract.PhoneNumber%TYPE, in_password in Client.Password%TYPE, user_cur out sys_refcursor)
is
invalid_user exception;
check_count number;
encode_key varchar2(2000) := 'mobileOperator12';
encode_mode number;
encode_pass raw(2000);
begin
encode_mode := DBMS_CRYPTO.ENCRYPT_AES128 + DBMS_CRYPTO.CHAIN_CBC + DBMS_CRYPTO.PAD_PKCS5;
encode_pass := DBMS_CRYPTO.ENCRYPT(utl_i18n.string_to_raw (in_password, 'AL32UTF8'), encode_mode,
    utl_i18n.string_to_raw (encode_key, 'AL32UTF8'));
select count(*) into check_count from Client join Contract on Contract.ClientId=Client.Id where Contract.PhoneNumber=in_login and Client.Password=encode_pass;
  if check_count!=0 then user_cur := get_client_cursor(in_login, encode_pass);
  else raise invalid_user;
  end if;
  dbms_output.enable();
  dbms_sql.return_result(user_cur);
  exception 
  when invalid_user then
  raise_application_error(-20007,'Проверьте введенные данные');
end findClient;

create or replace procedure getClientData(in_id in Contract.Id%TYPE, curs out sys_refcursor)
is
begin
  open curs for select Contract.PhoneNumber,Remainder.Balance, Remainder.Minutes, Remainder.SMS, 
  Remainder.MMS, Remainder.Megabytes from Contract join Remainder on Contract.RemainderId=Remainder.Id where Contract.Id=in_id;
end;

create or replace procedure changeTariff(in_id in Contract.Id%TYPE, in_tariff in TariffPlan.Name%TYPE)
is
currbalance decimal(5,2);
mins nvarchar2(50);
sms1 nvarchar2(50);
mms1 nvarchar2(50);
megabytes1 nvarchar2(50);
curr_tariff number;
curr_tariff_exc exception;
notmoney exception;
tarid int;
remid int;
begin
    select COUNT(*) into curr_tariff from Contract join TariffPlan on Contract.TariffPlanId=TariffPlan.Id where TariffPlan.Name=in_tariff and Contract.Id=in_id;
    select Remainder.Balance into currbalance from Contract join Remainder on Contract.RemainderId=Remainder.Id where Contract.Id=in_id;
    if currbalance<0 then raise notmoney;
    end if;
    if curr_tariff!=0 then raise curr_tariff_exc;
    end if;
    select TariffPlan.Id into tarid from TariffPlan where Name=in_tariff;
    select Contract.RemainderId into remid from Contract where Id=in_id;
    select Services.Minutes into mins from TariffPlan join Services on TariffPlan.ServiceId=Services.Id where TariffPlan.Name=in_tariff;
    select Services.SMS into sms1 from TariffPlan join Services on TariffPlan.ServiceId=Services.Id where TariffPlan.Name=in_tariff;
    select Services.MMS into mms1 from TariffPlan join Services on TariffPlan.ServiceId=Services.Id where TariffPlan.Name=in_tariff;
    select Services.Megabytes into megabytes1 from TariffPlan join Services on TariffPlan.ServiceId=Services.Id where TariffPlan.Name=in_tariff;
    update Remainder set Remainder.Minutes=mins,Remainder.SMS=sms1, Remainder.MMS=mms1, Remainder.Megabytes=megabytes1 where Remainder.Id=remid;
         update Contract set TariffPlanId=tarid where Contract.Id=in_id;
     exception 
  when curr_tariff_exc then
  raise_application_error(-20008,'Вы уже подключены к данному тарифу');
  when notmoney then
  raise_application_error(-20009,'Пополните баланс и продолжите операцию');
  commit;
end changeTariff;

create or replace procedure balanceReplenishment(in_id in Contract.Id%TYPE, in_summ decimal)
is
curr_balance decimal(5,2);
balanceOutOfRange exception;
remid int;
begin
    select Remainder.Balance into curr_balance from Contract join Remainder on Remainder.Id=Contract.RemainderId where Contract.Id=in_id;
    if curr_balance+in_summ>100 then raise balanceOutOfRange;
    end if;
    select Contract.RemainderId into remid from Contract where Id=in_id;
    curr_balance:=in_summ+curr_balance;
    update Remainder set Remainder.Balance=curr_balance where Remainder.Id=remid;
    exception 
  when balanceOutOfRange then
  raise_application_error(-20010,'Баланс не может быть больше 100 руб.');
  commit;
end balanceReplenishment;

create or replace procedure moneyTransfer(in_id in Contract.Id%TYPE, in_summ decimal, in_phone in Contract.PhoneNumber%TYPE)
is
newb decimal(5,2);
num_check number;
num_exist number;
balanceSender decimal(5,2);
balanceReciever decimal(5,2);
nfound exception;
samenum exception;
balanceOutOfRange exception;
balanceNegative exception;
remidS int;
remidR int;
begin
    select Remainder.Balance into balanceSender from Contract join Remainder on Remainder.Id=Contract.RemainderId where Contract.Id=in_id;
    select Remainder.Balance into balanceReciever from Contract join Remainder on Remainder.Id=Contract.RemainderId where Contract.PhoneNumber=in_phone;
    select COUNT(*) into num_check from Contract where Contract.PhoneNumber=in_phone;
    select COUNT(*) into num_exist from Contract where Contract.PhoneNumber=in_phone and Contract.Id=in_id;
    select Contract.RemainderId into remidS from Contract where Id=in_id;
    select Contract.RemainderId into remidR from Contract where PhoneNumber=in_phone;
    if num_exist!=0 then raise samenum;
    end if;
    if num_check=0 then raise nfound;
    end if;
    if balanceReciever+in_summ>100 then raise balanceOutOfRange;
    end if;
    if balanceSender-in_summ<0 then raise balanceNegative;
    end if;
    balanceSender:=balanceSender-in_summ;
    balanceReciever:=balanceReciever+in_summ;
    update Remainder set Remainder.Balance=balanceSender where Remainder.Id=remidS;
    update Remainder set Remainder.Balance=balanceReciever where Remainder.Id=remidR;
    commit;
    select Remainder.Balance into newb from Contract join Remainder on Remainder.Id=Contract.RemainderId where Contract.Id=in_id;
    debits(in_id,in_summ);
    exception 
  when balanceNegative then
  raise_application_error(-20011,'Не хватает средств');
  when balanceOutOfRange then
  raise_application_error(-20012,'Баланс получателя не может составлять 100 руб.');
  when nfound then
  raise_application_error(-20013,'Данного номера не существует');
  when samenum then
  raise_application_error(-20014,'Нельзя перевести деньги на свой номер');
  commit;
end moneyTransfer;

create or replace procedure sendSMS(in_id in Contract.Id%TYPE)
is
smscount int;
currbalance decimal(5,2);
smscountch nvarchar2(50);
remid int;
notenaughsms exception;
notmoney exception;
newb decimal(5,2);
begin
    select RemainderId into remid from Contract where Contract.Id=in_id;
    select Remainder.SMS into smscountch from Contract join Remainder on Contract.RemainderId=Remainder.Id where Contract.Id=in_id;
    select Remainder.Balance into currbalance from Contract join Remainder on Contract.RemainderId=Remainder.Id where Contract.Id=in_id;
    smscount:=1;
    if smscountch!='безлимит' then smscount:=smscountch;
      end if;
      if currbalance<0 then raise notmoney;
        elsif smscount!=0 and smscountch!='безлимит' then update Remainder set SMS=cast (smscount-1 as nvarchar2(50)) where Id=remid;
        elsif currbalance>0 and smscountch!='безлимит' then update Remainder set Balance=currbalance-0.5 where Id=remid;
      end if;
      commit;
       select Remainder.Balance into newb from Contract join Remainder on Contract.RemainderId=Remainder.Id where Contract.Id=in_id;
    if smscountch!='безлимит' and currbalance>newb then debits(in_id,currbalance-newb);
    end if;
    exception
    when notenaughsms then
    raise_application_error(-20015,'Не хватает свободных SMS или не хватает средств');
    when notmoney then
    raise_application_error(-20016,'Пополните счет и повторите операцию');
    commit;
end;

create or replace procedure sendMMS(in_id in Contract.Id%TYPE)
is
newb decimal(5,2);
mmscount int;
currbalance decimal(5,2);
mmscountch nvarchar2(50);
remid int;
notenaughmms exception;
notmoney exception;
begin
    select RemainderId into remid from Contract where Contract.Id=in_id;
    select Remainder.MMS into mmscountch from Contract join Remainder on Contract.RemainderId=Remainder.Id where Contract.Id=in_id;
    select Remainder.Balance into currbalance from Contract join Remainder on Contract.RemainderId=Remainder.Id where Contract.Id=in_id;
    mmscount:=1;
    if mmscountch!='безлимит' then mmscount:=mmscountch;
      end if;
      if currbalance<0 then raise notmoney;
        elsif mmscount!=0 and mmscountch!='безлимит' then update Remainder set MMS=cast (mmscount-1 as nvarchar2(50)) where Id=remid;
        elsif currbalance>0 and mmscountch!='безлимит' then update Remainder set Balance=currbalance-0.5 where Id=remid;
      end if;
      commit;
    select Remainder.Balance into newb from Contract join Remainder on Contract.RemainderId=Remainder.Id where Contract.Id=in_id;
    if mmscountch!='безлимит' and currbalance>newb then debits(in_id,currbalance-newb);
    end if;
    exception
    when notenaughmms then
    raise_application_error(-20017,'Не хватает свободных MMS или не хватает средств');
    when notmoney then
    raise_application_error(-20018,'Пополните счет и повторите операцию');
    commit;
end;

create or replace procedure useInternet(in_id in Contract.Id%TYPE, in_mbcount in decimal)
is
diffmb decimal(5,2);
newb decimal(5,2);
mbcount decimal(5,2);
currbalance decimal(5,2);
mbcountch nvarchar2(50);
remid int;
notenaughmms exception;
notmoney exception;
begin
    select RemainderId into remid from Contract where Contract.Id=in_id;
    select Remainder.Megabytes into mbcountch from Contract join Remainder on Contract.RemainderId=Remainder.Id where Contract.Id=in_id;
    select Remainder.Balance into currbalance from Contract join Remainder on Contract.RemainderId=Remainder.Id where Contract.Id=in_id;
    mbcount:=1;
    if mbcountch!='безлимит' 
      then mbcount:=mbcountch;
          diffmb:=mbcount-in_mbcount;
      end if;
      if currbalance<0 then raise notmoney;
        elsif mbcount>0 and mbcountch!='безлимит' and diffmb>0 then update Remainder set Megabytes=cast (mbcount-in_mbcount as nvarchar2(50)) where Id=remid;
        elsif diffmb<=0 and mbcountch!='безлимит' then update Remainder set Megabytes=cast(0 as nvarchar2(50)), Balance=currbalance-(0.05*(-diffmb)) where Id=remid;
      end if;
      commit;
    select Remainder.Balance into newb from Contract join Remainder on Contract.RemainderId=Remainder.Id where Contract.Id=in_id;
    if mbcountch!='безлимит' and currbalance>newb then debits(in_id,currbalance-newb);
    end if;
    exception
    when notenaughmms then
    raise_application_error(-20019,'Не хватает свободных мегабайтов или не хватает средств');
    when notmoney then
    raise_application_error(-20020,'Пополните счет и повторите операцию');
    commit;
end;


create or replace procedure startCall(in_id in Contract.Id%TYPE, in_phone in Calls.InterlocutorNumber%TYPE)
is
myph int;
myphex exception;
countofcalls int;
currbalance decimal(5,2);
mins int;
minsch nvarchar2(50);
notmoney exception;
ce exception;
numnotf exception;
begin
      if in_phone not like '+375%' then raise numnotf;
      end if;
      select COUNT(*) into myph from Contract where PhoneNumber=in_phone and Id=in_id;
      if myph!=0 then raise myphex;
      end if;
      select Remainder.Balance into currbalance from Contract join Remainder on Contract.RemainderId=Remainder.Id where Contract.Id=in_id;
      select Remainder.Minutes into minsch from Contract join Remainder on Contract.RemainderId=Remainder.Id where Contract.Id=in_id;
      select COUNT(*) into countofcalls from Calls where InterlocutorNumber=in_phone and CallDuration is null;
      if countofcalls!=0 then raise ce;
      end if;
      countofcalls:=0;
      select COUNT(*) into countofcalls from Calls where ContractId=in_id and CallDuration is null;
      if countofcalls!=0 then raise ce;
      end if;
      if minsch!='безлимит' then mins:=minsch;
      end if;
      if currbalance<0 then raise notmoney;
      else insert into Calls(InterlocutorNumber, CallDate, ContractId) values (in_phone,CURRENT_TIMESTAMP, in_id);
      end if;
    exception
    when notmoney then
    raise_application_error(-20021,'Пополните счет и повторите операцию');
     when ce then
    raise_application_error(-20022,'Невозможно набрать указанный номер или вы уже с кем-то соединены');
    when myphex then
    raise_application_error(-20023,'Невозможно набрать свой номер');
    when numnotf then
    raise_application_error(-20024,'Проверьте введенный номер');
    commit;
end;
select * from Employees;


create or replace PROCEDURE getTariffs(tariff out sys_refcursor)
IS
begin
open tariff for select Name from TariffPlan;
  dbms_output.enable();
  dbms_sql.return_result(tariff);
end getTariffs;


create or replace procedure endCall(in_id in Contract.Id%TYPE)
is
totalmins int;
diffmin decimal(5,2);
currbalance decimal(5,2);
mins int;
newb decimal(5,2);
minsch nvarchar2(50);
iscall exception;
callnum int;
remid int;
cd TIMESTAMP;
callinterval INTERVAL DAY TO SECOND;
begin
  select RemainderId into remid from Contract where Contract.Id=in_id;
  select Remainder.Balance into currbalance from Contract join Remainder on Contract.RemainderId=Remainder.Id where Contract.Id=in_id;
  select Remainder.Minutes into minsch from Contract join Remainder on Contract.RemainderId=Remainder.Id where Contract.Id=in_id;
  select count(*) into callnum from Calls where Calls.ContractId=in_id and Calls.CallDuration is null;
  if callnum=0 then raise iscall;
  end if;
  select CallDate into cd from Calls where Calls.ContractId=in_id and Calls.CallDuration is null;
  callinterval:=CURRENT_TIMESTAMP-cd;
  totalmins:=EXTRACT(MINUTE FROM callinterval)+1;
  if minsch!='безлимит' then mins:=minsch;
  diffmin:=mins-totalmins;
  end if;
  if minsch!='безлимит' and diffmin>=0 then update Remainder set Minutes=cast(diffmin as nvarchar2(50)) where Remainder.Id=remid;
  elsif minsch!='безлимит' and diffmin<0 then update Remainder set Minutes='0', Balance=currbalance-(0.1*(-diffmin)) where Remainder.Id=remid;
  end if;
  update Calls set CallDuration=callinterval where Calls.ContractId=in_id and CallDuration is null;
  commit;
  select Remainder.Balance into newb from Contract join Remainder on Contract.RemainderId=Remainder.Id where Contract.Id=in_id;
    if minsch!='безлимит' and currbalance>newb then debits(in_id,currbalance-newb);
    end if;
  exception
    when iscall then
    raise_application_error(-20024,'Вы ни с кем не связаны');
    commit;
end;

create or replace procedure debits(in_id in Contract.Id%TYPE, in_amount in Debit.Amount%TYPE)
is
begin
    insert into Debit(DebitDate, Amount, ContractId) values (CURRENT_TIMESTAMP, in_amount, in_id);
    commit;
end;

create or replace procedure tariffDebits
is
cursor curs is select Contract.RemainderId, TariffPlan.DailyDebit
from Contract join TariffPlan on Contract.TariffPlanId=TariffPlan.Id;
c_remid Contract.RemainderId%TYPE;
c_debit TariffPlan.DailyDebit%TYPE;
conid int;
begin
  open curs;
    loop
      fetch curs into c_remid, c_debit;
      exit when curs%notfound;
      update Remainder set Balance=Balance-c_debit/24 where Remainder.Id=c_remid and Remainder.Balance>0;
      select Contract.Id into conid from Contract where Contract.RemainderId=c_remid;
      debits(conid,c_debit/24);
    end loop;
    commit;
end;

begin
tariffDebits;
end;

begin
dbms_scheduler.create_schedule(
  schedule_name => 'hourlyDebit',
  start_date => SYSTIMESTAMP,
  repeat_interval => 'freq=hourly; byminute=0',
  end_date        => NULL
);
end;

begin
dbms_scheduler.create_program(
  program_name => 'HD',
  program_type => 'STORED_PROCEDURE',
  program_action => 'tariffDebits',
  number_of_arguments =>0,
  enabled =>true
);
end;

begin
dbms_scheduler.create_job(
job_name =>'hourlyJob',
program_name => 'HD',
schedule_name => 'hourlyDebit',
enabled => true
);
end;

create or replace procedure getTar(curs out sys_refcursor)
is
begin
open curs for select Name, Price from TariffPlan;
end;

create or replace procedure getEmployees(curs out sys_refcursor)
is
begin
open curs for select Surname, Name, SecondName, Position from Employees;
end;

delete from Debit where amount=1;

SET SERVEROUTPUT ON;

---------------XML EXPORT/IMPORT
CREATE OR REPLACE DIRECTORY UTLDATA AS 'C:/XML';
DROP DIRECTORY UTLDATA;

CREATE OR REPLACE PACKAGE XML_PACKAGE IS
  PROCEDURE EXPORT_SERVICES_TO_XML;
  PROCEDURE IMPORT_SERVICES_FROM_XML;
END XML_PACKAGE;

CREATE OR REPLACE PACKAGE BODY XML_PACKAGE IS
PROCEDURE EXPORT_SERVICES_TO_XML
IS
  DOC  DBMS_XMLDOM.DOMDocument;
  XDATA  XMLTYPE;
  CURSOR XMLCUR IS
    SELECT XMLELEMENT("SERVICES",
      XMLAttributes('http://www.w3.org/2001/XMLSchema' AS "xmlns:xsi",
      'http://www.oracle.com/Employee.xsd' AS "xsi:nonamespaceSchemaLocation"),
      XMLAGG(XMLELEMENT("SERVICES",
        XMLELEMENT("ID",SER.ID),
        XMLELEMENT("MINUTES",SER.MINUTES),
        XMLELEMENT("SMS",SER.SMS),
        XMLELEMENT("MMS",SER.MMS),
        XMLELEMENT("MEGABYTES",SER.MEGABYTES)
      ))
) FROM SERVICES SER;
BEGIN
  OPEN XMLCUR;
    LOOP
      FETCH XMLCUR INTO XDATA;
    EXIT WHEN XMLCUR%NOTFOUND;
    END LOOP;
  CLOSE XMLCUR;
  DOC := DBMS_XMLDOM.NewDOMDocument(XDATA);
  DBMS_XMLDOM.WRITETOFILE(DOC, 'UTLDATA/services.xml');
END EXPORT_SERVICES_TO_XML;

PROCEDURE IMPORT_SERVICES_FROM_XML
IS
  L_CLOB CLOB;
  L_BFILE  BFILE := BFILENAME('UTLDATA', 'services.xml');

  L_DEST_OFFSET   INTEGER := 1;
  L_SRC_OFFSET    INTEGER := 1;
  L_BFILE_CSID    NUMBER  := 0;
  L_LANG_CONTEXT  INTEGER := 0;
  L_WARNING       INTEGER := 0;

  P                DBMS_XMLPARSER.PARSER;
  V_DOC            DBMS_XMLDOM.DOMDOCUMENT;
  V_ROOT_ELEMENT   DBMS_XMLDOM.DOMELEMENT;
  V_CHILD_NODES    DBMS_XMLDOM.DOMNODELIST;
  V_CURRENT_NODE   DBMS_XMLDOM.DOMNODE;

  SER SERVICES%ROWTYPE;
BEGIN
  DBMS_LOB.CREATETEMPORARY (L_CLOB, TRUE);
  DBMS_LOB.FILEOPEN(L_BFILE, DBMS_LOB.FILE_READONLY);

  DBMS_LOB.LOADCLOBFROMFILE (DEST_LOB => L_CLOB, SRC_BFILE => L_BFILE, AMOUNT => DBMS_LOB.LOBMAXSIZE,
    DEST_OFFSET => L_DEST_OFFSET, SRC_OFFSET => L_SRC_OFFSET, BFILE_CSID => L_BFILE_CSID,
    LANG_CONTEXT => L_LANG_CONTEXT, WARNING => L_WARNING);
  DBMS_LOB.FILECLOSE(L_BFILE);
  COMMIT;

   P := DBMS_XMLPARSER.NEWPARSER;

   DBMS_XMLPARSER.PARSECLOB(P,L_CLOB);

   V_DOC := DBMS_XMLPARSER.GETDOCUMENT(P);

   V_ROOT_ELEMENT := DBMS_XMLDOM.Getdocumentelement(v_Doc);

   V_CHILD_NODES := DBMS_XMLDOM.GETCHILDRENBYTAGNAME(V_ROOT_ELEMENT,'*');

   FOR i IN 0 .. DBMS_XMLDOM.GETLENGTH(V_CHILD_NODES) - 1
   LOOP

      V_CURRENT_NODE := DBMS_XMLDOM.ITEM(V_CHILD_NODES,i);

      DBMS_XSLPROCESSOR.VALUEOF(V_CURRENT_NODE,
        'ID/text()',SER.ID);
      DBMS_XSLPROCESSOR.VALUEOF(V_CURRENT_NODE,
        'MINUTES/text()',SER.MINUTES);
      DBMS_XSLPROCESSOR.VALUEOF(V_CURRENT_NODE,
        'SMS/text()',SER.SMS);
      DBMS_XSLPROCESSOR.VALUEOF(V_CURRENT_NODE,
        'MMS/text()',SER.MMS);
        DBMS_XSLPROCESSOR.VALUEOF(V_CURRENT_NODE,
        'MEGABYTES/text()',SER.MEGABYTES);
BEGIN
DBMS_OUTPUT.PUT_LINE('ID: '||SER.ID);
DBMS_OUTPUT.PUT_LINE('MINUTES: '||SER.MINUTES);
DBMS_OUTPUT.PUT_LINE('SMS: '||SER.SMS);
DBMS_OUTPUT.PUT_LINE('MMS: '||SER.MMS);
DBMS_OUTPUT.PUT_LINE('MEGABYTES: '||SER.MEGABYTES);
DBMS_OUTPUT.PUT_LINE('');
END;

   END LOOP;

  DBMS_LOB.FREETEMPORARY(L_CLOB);
  DBMS_XMLPARSER.FREEPARSER(P);
  DBMS_XMLDOM.FREEDOCUMENT(V_DOC);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
  DBMS_LOB.FREETEMPORARY(L_CLOB);
  DBMS_XMLPARSER.FREEPARSER(P);
  DBMS_XMLDOM.FREEDOCUMENT(V_DOC);
  RAISE_APPLICATION_ERROR(-20101, 'IMPORT XML ERROR'|| SQLERRM);
END IMPORT_SERVICES_FROM_XML;

END XML_PACKAGE;



begin
    XML_PACKAGE.EXPORT_SERVICES_TO_XML();
    XML_PACKAGE.IMPORT_SERVICES_FROM_XML();
end;

----------------------------------------------------------------------
create index debInd on Debit(ContractId);
drop index debInd;
create or replace procedure testRows
is
i number(8):=0;
begin
    while i< 100000
    loop
        insert into Debit(DebitDate,Amount, ContractId) values (CURRENT_TIMESTAMP, 1, 21);
        i:= i+1;
    end loop;
    commit;
    exception when others then raise_application_error(-20024,'Вы ни с кем не связаны');
end testRows;
begin
testRows;
end;
EXPLAIN PLAN FOR
SELECT * FROM Debit where ContractId>1;
SELECT * FROM TABLE (dbms_xplan.display);

delete from Debit where id>1000

drop index pr_ind;
drop table Table_1;

create table Table_1 (pr int);
create index pr_ind on Table_1(pr);

SELECT * FROM DEBIT ORDER BY id
begin
for i in 0..1000000
loop
insert into Table_1 values (i);
end loop;
end;