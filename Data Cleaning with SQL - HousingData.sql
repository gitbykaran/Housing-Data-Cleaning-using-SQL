---  Lets look at the data

--- Converting Sale Date to Standard Format

select saledateconverted
from dbo.housingdata

alter table housingdata
add saledateconverted Date

update housingdata
set saledateconverted =  CONVERT(date,SaleDate)

---- filling property address null values using PARCEL ID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from dbo.housingdata a
join dbo.housingdata b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from dbo.housingdata a
join dbo.housingdata b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 

select * from housingdata
where 4 is null

--- seperating address into (address,city,state) columns

select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,len(PropertyAddress))
from housingdata

alter table housingdata
add propertysplitaddress nvarchar(255)

update housingdata
set propertysplitaddress =  SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)

alter table housingdata
add propertysplitcity nvarchar(255)

update housingdata
set propertysplitcity =  SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,len(PropertyAddress))

select * from housingdata

--- splitting owner's address

select PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1) 
from housingdata

alter table housingdata
add ownersplitaddress nvarchar(255)

update housingdata
set ownersplitaddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

alter table housingdata
add ownercity nvarchar(255)

update housingdata
set ownercity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

alter table housingdata
add ownerstate nvarchar(255)

update housingdata
set ownerstate = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select * from housingdata

--- Converting 'Y' & 'N'to 'YES'& 'NO'

select SoldAsVacant , CASE when SoldAsVacant = 'Y' then 'Yes' 
							when SoldAsVacant = 'N' then 'No'
							else SoldAsVacant
							end 
from housingdata

update housingdata
set SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes' 
							when SoldAsVacant = 'N' then 'No'
							else SoldAsVacant
							end 

select Distinct(SoldAsVacant), COUNT(SoldAsVacant) 
from housingdata
group by SoldAsVacant


--- Removing Duplicates Data from the Table

with duplicatesCTE AS(
select * , ROW_NUMBER() Over (Partition By ParcelID,PropertyAddress,Saleprice,
SaleDate,LegalReference order by UniqueID) duplicates
from housingdata
)
delete  from duplicatesCTE
where duplicates > 1

--- confirming the deleted duplicates
with duplicatesCTE AS(
select * , ROW_NUMBER() Over (Partition By ParcelID,PropertyAddress,Saleprice,
SaleDate,LegalReference order by UniqueID) duplicates
from housingdata
)
select * from duplicatesCTE
where duplicates > 1

--- Deleting Unsual Columns

select * from housingdata

alter table housingdata
drop column PropertyAddress,OwnerAddress,TaxDistrict

alter table housingdata
drop column SaleDate

--- cleaned data
select * from housingdata