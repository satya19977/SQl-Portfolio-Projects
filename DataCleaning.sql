
select * 
from PortfolioProject.dbo.housing

-- Standardize Date Format

select saledateupdated 
from  PortfolioProject.dbo.housing

alter table housing
add saledateupdated date

update housing
set saledateupdated = convert(date,saledate)

--Populate   null  property address

select  PropertyAddress 
from PortfolioProject.dbo.housing
where PropertyAddress is null



update a
set propertyaddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.housing a
JOIN PortfolioProject.dbo.housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Break up  address column using delimiter

select  
substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as address
,substring(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) as address
from PortfolioProject.dbo.housing

alter table housing
add PropertySplitAddress nchar(255)

update housing
set PropertySplitAddress = substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)

alter table housing
add PropertySplitCity nchar(255)

update housing
set PropertySplitCity = substring(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))

select * 
from PortfolioProject.dbo.housing


select OwnerAddress
from PortfolioProject.dbo.housing

select PARSENAME(replace(OwnerAddress,',','.'),3)
,PARSENAME(replace(OwnerAddress,',','.'),2)
,PARSENAME(replace(OwnerAddress,',','.'),1)
from PortfolioProject.dbo.housing

alter table housing
add OwnerSplitAddress nchar(255)

update housing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

alter table housing
add OwnerSplitCity  nchar(255)

update housing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

alter table housing
add OwnerSplitState  nchar(255)

update housing
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)

select *
from PortfolioProject.dbo.housing

-- Make changes to "sold in vacant" field

select distinct(soldasvacant), count(soldasvacant)
from PortfolioProject.dbo.housing
group by SoldAsVacant

select  soldasvacant
,case when soldasvacant = 'Y' then 'Yes'
	  when soldasvacant = 'N' then 'No'
	  else soldasvacant
	  end
from PortfolioProject.dbo.housing

update housing
set SoldAsVacant = case when soldasvacant = 'Y' then 'Yes'
	  when soldasvacant = 'N' then 'No'
	  else soldasvacant
	  end


--Remove Duplicates
with rownumcte as (
select *, ROW_NUMBER() over (partition by parcelid,propertyaddress,saledate,saleprice,legalreference order by uniqueid) row_num
from PortfolioProject.dbo.housing)


delete from rownumcte
where row_num >1

--Delete useless columns

alter table  housing
drop column owneraddress,propertyaddress,taxdistrict







