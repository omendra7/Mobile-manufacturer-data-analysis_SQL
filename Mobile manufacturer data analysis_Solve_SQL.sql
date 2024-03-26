--SQL Advance Case Study

--1.	List all the states in which we have customers who have bought cellphones from 2005 till today.

--Q1--BEGIN 

Select [State] from DIM_LOCATION as L 
inner join FACT_TRANSACTIONS as F  on F.IDLocation=L.IDLocation
where YEAR(F.[Date])>=2005 
group by L.[State]


--Q1--END

--2.	What state in the US is buying the most 'Samsung' cell phones?

--Q2--BEGIN
	
select [state] from (select Top 1 L.[State],sum(F.Quantity) as [Tot_qty] from FACT_TRANSACTIONS as F 
inner join DIM_LOCATION as L on F.IDLocation=L.IDLocation
inner join DIM_MODEL as MO on MO.IDModel=F.IDModel
inner join DIM_MANUFACTURER as M on M.IDManufacturer=MO.IDManufacturer
where M.Manufacturer_Name='Samsung' and L.Country='US'
group by L.[State]
order by [Tot_qty] desc) as T1


--Q2--END

--3.	Show the number of transactions for each model per zip code per state.

--Q3--BEGIN      
	
select L.ZipCode ,MO.IDModel,L.[State],Count(F.IDCustomer) as [Total Transaction] from FACT_TRANSACTIONS as F 
inner join DIM_LOCATION as L on F.IDLocation=L.IDLocation
inner join DIM_MODEL as MO on MO.IDModel=F.IDModel
group by L.[State],L.ZipCode ,MO.IDModel


--Q3--END

--4.	Show the cheapest cellphone (Output should contain the price also)

--Q4--BEGIN

select M.Manufacturer_Name,MO.Model_Name,MO.IDModel from DIM_MODEL as MO
inner join DIM_MANUFACTURER as M on M.IDManufacturer=MO.IDManufacturer
where Unit_price= (select MIN(Unit_price) from DIM_MODEL);



--Q4--END

--5.	Find out the average price for each model in the top5 manufacturers in terms of sales quantity and order by average price.

--Q5--BEGIN


 with TB1 as (select Top 5 M.Manufacturer_Name ,M.IDManufacturer,Sum(F.Quantity)as Tot_qty ,AVG(F.TotalPrice) as [avgPrice] 
 from FACT_TRANSACTIONS as F 
 inner join DIM_MODEL as Mo on Mo.IDModel=F.IDModel
 inner join DIM_MANUFACTURER as M on M.IDManufacturer=Mo.IDManufacturer
 group by M.Manufacturer_Name,M.IDManufacturer
 order by Tot_qty desc,[avgPrice]desc),
 TB2 as (select Mo.Model_Name ,Mo.IDManufacturer,AVG(F.TotalPrice) as [Avg] from FACT_TRANSACTIONS as F
 inner join DIM_MODEL as Mo on Mo.IDModel=f.IDModel
 group by Mo.Model_Name,Mo.IDManufacturer)
 select Model_Name,[Avg] as Average_Price from TB2 as T2 inner join TB1 as T1 on T2.IDManufacturer=T1.IDManufacturer



--Q5--END

--6.	List the names of the customers and the average amount spent in 2009, where the average is higher than 500

--Q6--BEGIN


 Select C.IDCustomer, C.Customer_Name, AVG(F.TotalPrice) as [Average Amount] from DIM_CUSTOMER as C 
 inner join FACT_TRANSACTIONS as F on C.IDCustomer=F.IDCustomer
 where YEAR(F.[Date])=2009 
 group by C.Customer_Name,C.IDCustomer
 having  AVG(F.TotalPrice)>500


--Q6--END

--7.	List if there is any model that was in the top 5 in terms of quantity, simultaneously in 2008, 2009 and 2010
	
--Q7--BEGIN  
	
	
 Select T1.Model_Name  from (select top 5 Mo.Model_Name,Mo.IDmodel ,SUM(F.Quantity) as TotQty from FACT_TRANSACTIONS as F
 inner join DIM_MODEL as Mo on Mo.IDModel=F.IDModel
 where YEAR(F.[Date])=2008 
 group by Mo.Model_Name,Mo.IDmodel
 order by TotQty desc) as T1 inner join
 (select top 5 Mo.Model_Name,Mo.IDmodel ,SUM(F.Quantity) as TotQty from FACT_TRANSACTIONS as F
 inner join DIM_MODEL as Mo on Mo.IDModel=F.IDModel
 where YEAR(F.[Date])=2009
 group by Mo.Model_Name,Mo.IDmodel
 order by TotQty desc) as T2 on T1.Model_Name=T2.Model_Name inner join
 (select top 5 Mo.Model_Name,Mo.IDmodel ,SUM(F.Quantity) as TotQty from FACT_TRANSACTIONS as F
 inner join DIM_MODEL as Mo on Mo.IDModel=F.IDModel
 where YEAR(F.[Date])=2010
 group by Mo.Model_Name,Mo.IDmodel
 order by TotQty desc) as T3 on T3.Model_Name=T2.Model_Name

--Q7--END	

--8.	Show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with the 2nd top sales in the year of 2010.

--Q8--BEGIN

 select * from( select row_number() over(order by sum(F.TotalPrice) desc) as R, M.Manufacturer_Name ,sum(F.TotalPrice) as Tot_Amt,
 YEAR(F.[Date]) as [Year]
 from FACT_TRANSACTIONS as F 
 inner join DIM_MODEL As Mo on Mo.IDModel=F.IDModel
 inner join DIM_MANUFACTURER as M on M.IDManufacturer=Mo.IDManufacturer
 where YEAR(F.[Date])=2009 
 group by  M.Manufacturer_Name,YEAR(F.[Date]))as T1
 where R=2 union all
 select * from (select row_number() over(order by sum(F.TotalPrice) desc) as R, M.Manufacturer_Name ,sum(F.TotalPrice) as Tot_Amt,
 YEAR(F.[Date]) as [Year]
 from FACT_TRANSACTIONS as F 
 inner join DIM_MODEL As Mo on Mo.IDModel=F.IDModel
 inner join DIM_MANUFACTURER as M on M.IDManufacturer=Mo.IDManufacturer
 where YEAR(F.[Date])=2010 
 group by  M.Manufacturer_Name,YEAR(F.[Date])) as T2
 where R=2

--Q8--END

--9.	Show the manufacturers that sold cellphones in 2010 but did not in 2009.

--Q9--BEGIN
	
 select Manufacturer_Name from (select  M.Manufacturer_Name ,sum(F.TotalPrice) as Tot_Amt
 from FACT_TRANSACTIONS as F 
 inner join DIM_MODEL As Mo on Mo.IDModel=F.IDModel
 inner join DIM_MANUFACTURER as M on M.IDManufacturer=Mo.IDManufacturer
 where YEAR(F.[Date])=2010 
 group by M.Manufacturer_Name , YEAR(F.[Date]))as T1
 except
 select Manufacturer_Name from (select  M.Manufacturer_Name ,sum(F.TotalPrice) as Tot_Amt
 from FACT_TRANSACTIONS as F 
 inner join DIM_MODEL As Mo on Mo.IDModel=F.IDModel
 inner join DIM_MANUFACTURER as M on M.IDManufacturer=Mo.IDManufacturer
 where YEAR(F.[Date])=2009
 group by M.Manufacturer_Name , YEAR(F.[Date])) as T2


--Q9--END

--10.	Find top 100 customers and their average spend, average quantity by each year. Also find the percentage of change in their spend.

--Q10--BEGIN
	

select TBL1.IDCustomer,TBL1.Customer_Name , TBL1.[Year],TBL1.Avg_Spend,TBL1.Avg_Qty,case when TBL2.[Year] is not null then
((TBL1.Avg_Spend-TBL2.Avg_Spend)/TBL2.Avg_Spend )* 100 
else NULL
end as 'YOY in Average Spend' from
(select C.IDcustomer,C.Customer_Name,AVG(F.TotalPrice) as Avg_Spend ,AVG(F.Quantity) as Avg_Qty ,
YEAR(F.Date) as [Year] from DIM_CUSTOMER as c 
left join FACT_TRANSACTIONS as F on F.IDCustomer=C.IDCustomer 
where C.IDCustomer in (Select top 10 C.IDCustomer from DIM_CUSTOMER as c 
left join FACT_TRANSACTIONS as F on F.IDCustomer=C.IDCustomer 
group by C.IDCustomer 
order by Sum(F.TotalPrice) desc)
group by C.IDcustomer,C.Customer_Name,YEAR(F.Date)) as TBL1 
left join 
(select C.IDcustomer,C.Customer_Name,AVG(F.TotalPrice) as Avg_Spend ,AVG(F.Quantity) as Avg_Qty ,
YEAR(F.Date) as [Year] from DIM_CUSTOMER as c 
left join FACT_TRANSACTIONS as F on F.IDCustomer=C.IDCustomer 
where C.IDCustomer in (Select top 10 C.IDCustomer from DIM_CUSTOMER as c 
left join FACT_TRANSACTIONS as F on F.IDCustomer=C.IDCustomer 
group by C.IDCustomer 
order by Sum(F.TotalPrice) desc)
group by C.IDcustomer,C.Customer_Name,YEAR(F.Date)) as TBL2 
on TBL1.IDCustomer=TBL2.IDCustomer and TBL2.[Year]=TBL1.[Year]-1

--Q10--END
	