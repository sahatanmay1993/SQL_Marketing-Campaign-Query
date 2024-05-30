create database Marketing_Campaign_Analysis;
use Marketing_Campaign_Analysis;

-- All the Table in the Schema
select * from campaign;
select * from CityData;
select * from CouponMapping;
select * from Customer;
select * from CustomerTransactionData;
select * from Item;

-- Note:- Year 2023 contain only Data of January Month

-- Different color segments (categories) provided by the company
select count(distinct Item_Category) as Number_of_color_segments from Item;

-- Different Coupon Types that are offered
select distinct CouponType from CouponMapping;

-- States where the company is currently delivering its products and services
select count(State) as Number_of_State from CityData;

-- Number of Pincode does one State have
select City_Name, count(Pincode) as Numer_of_Pincode from Customer as C
inner Join CityData as CD on C.City_ID = CD.City_ID
group by City_Name;

-- From the state where Purcahse were made
select City_Name,round(sum(PurchasingAmt)) as Total_Amount from CustomerTransactionData as CT
left join Customer as C on C.Customer_ID = CT.Cust_ID
left join CityData as CD on CD.City_ID = C.City_ID
group by City_Name
order by Total_Amount desc;

-- Maxmimum Sale and Minimum Sale
Select Item_Category, count(C.Item_Id) as Number_Of_Sale from CustomerTransactionData as C
left join item as I on C.Item_ID = I.Item_ID
group by Item_Category
order by Number_Of_Sale desc; 

-- Most Order came from which Order Type
Select OrderType, count(OrderType) as Number_Of_Sale from CustomerTransactionData
group by OrderType
order by Number_Of_Sale desc;

-- Total number and sum of sales (transactions) happened on Yearly Basis
SELECT Year(STR_TO_DATE(PurchaseDate,'%d-%m-%Y')) as Year,round(sum(PurchasingAmt),2) as Total_Sum, Count(Trans_ID) as Number_of_Transaction from CustomerTransactionData
group by Year
order by year;

-- Total number and sum of sales (transactions) happened on Monthly Basis
SELECT Month(STR_TO_DATE(PurchaseDate,"%d-%m-%Y")) as Month,round(sum(PurchasingAmt),2) as Total_Sum, Count(Trans_ID) as Number_of_Transaction from CustomerTransactionData
group by Month
order by Month;

# Company wants to understand the customer path to conversion as a potential purchaser based on our campaigns

-- Impact of Campaign lunch 
select distinct CampaignType, Tran, Year from
(select CampaignType, count(month(STR_TO_DATE(PurchaseDate,"%d-%m-%Y"))) over (partition by CampaignType,Year(STR_To_Date(PurchaseDate,"%d-%m-%Y"))) as Tran,
Year(STR_To_Date(PurchaseDate,"%d-%m-%Y")) as Year
from CustomerTransactionData as C
left join campaign as cam on C.Campaign_ID = cam.Campaign_ID
where CampaignType != ("")) as t
order by year;

-- Total number of transactions with campaign coupon vs Total number of transactions without campaign coupon
select "Without Coupons" AS CampaignCoupons,count(*) as Number_of_transactions from CustomerTransactionData
where Campaign_ID in ("")
union all
select "With Coupons" AS CampaignCoupons,count(*) as Number_of_transactions from CustomerTransactionData
where Campaign_ID !=("");

-- Number of customers with first purchase done with or without campaign coupons
Select "Without Coupons" AS CampaignCoupons,sum(First_Purchase) as First_Transaction_by_Customer from
(select Cust_ID,(STR_TO_DATE(PurchaseDate,"%d-%m-%Y")) as Date,
Campaign_ID, row_number() over (partition by Cust_ID order by (STR_TO_DATE(PurchaseDate,"%d-%m-%Y"))) as First_Purchase from CustomerTransactionData) as t
where First_Purchase = 1 and Campaign_ID in ("")
union all
Select "With Coupons" AS CampaignCoupons,sum(First_Purchase) as First_Transaction_by_Customer from
(select Cust_ID,(STR_TO_DATE(PurchaseDate,"%d-%m-%Y")) as Date,
Campaign_ID, row_number() over (partition by Cust_ID order by (STR_TO_DATE(PurchaseDate,"%d-%m-%Y"))) as First_Purchase from CustomerTransactionData) as t
where First_Purchase = 1 and Campaign_ID != ("");

-- Marketing team is interested in understanding the growth and decline pattern of the company in terms of new leads or sales amount by the customers

-- Customers that's acquired [New + Repeated]
select t1.Date, New_Customer, Repeat_Customer from
(select Date,count(Number_of_time_Purchase) as New_Customer from
(select Cust_ID, Year(STR_TO_DATE(PurchaseDate,"%d-%m-%Y")) as Date, 
row_number() over (partition by Cust_ID order by (STR_TO_DATE(PurchaseDate,"%d-%m-%Y"))) as Number_of_time_Purchase from CustomerTransactionData) as t
where Number_of_time_Purchase = 1
group by Date
order by Date) as t1
left join 
(select Date, count(Number_of_time_Purchase) as Repeat_Customer from
(select Cust_ID, Year(STR_TO_DATE(PurchaseDate,"%d-%m-%Y")) as Date, 
row_number() over (partition by Cust_ID order by (STR_TO_DATE(PurchaseDate,"%d-%m-%Y"))) as Number_of_time_Purchase from CustomerTransactionData) as t
where Number_of_time_Purchase != 1
group by Date
order by Date) as t2 on t1.date = t2.date;

select distinct CampaignType, Tran, Year from
(select CampaignType, count(month(STR_TO_DATE(PurchaseDate,"%d-%m-%Y"))) over (partition by CampaignType) as Tran,
Year(STR_To_Date(PurchaseDate,"%d-%m-%Y")) as Year
from CustomerTransactionData as C
left join campaign as cam on C.Campaign_ID = cam.Campaign_ID
where CampaignType != ("")) as t
order by year;