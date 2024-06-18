--//

--Cleaning Data in SQL

Select *
From PortfolioProject..NashvilleHousing


--Standardize date format

Select SaleDateConverted, Convert(date,SaleDate)
From PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
Set SaleDate = Convert(date,SaleDate)

Alter table PortfolioProject..NashvilleHousing
Add SaleDateConverted Date;

Update PortfolioProject..NashvilleHousing
Set SaleDateConverted = Convert(date,SaleDate)


--Populate Property address data

Select *
From PortfolioProject..NashvilleHousing
--where PropertyAddress is Null
order by ParcelID

Select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing A
join PortfolioProject..NashvilleHousing B
   on A.ParcelID = B.ParcelID
   and A.[UniqueID ] <> B.[UniqueID ]
   WHERE a.PropertyAddress is NULL

Update A
Set a.PropertyAddress = IsNull(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing A
join PortfolioProject..NashvilleHousing B
   on A.ParcelID = B.ParcelID
   and A.[UniqueID ] <> B.[UniqueID ]
   WHERE a.PropertyAddress is NULL


-- Break out addresses into separate coulumns i.e. address,city,state

Select PropertyAddress
From PortfolioProject..NashvilleHousing

Select 
substring (PropertyAddress, 1, charindex(',',PropertyAddress) -1) as Address ,
substring (PropertyAddress, charindex(',',PropertyAddress)+1, len(PropertyAddress)) as City
From PortfolioProject..NashvilleHousing


Alter table PortfolioProject..NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set PropertySplitAddress = substring (PropertyAddress, 1, charindex(',',PropertyAddress) -1)


Alter table PortfolioProject..NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set PropertySplitCity = substring (PropertyAddress, charindex(',',PropertyAddress)+1, len(PropertyAddress))

Select *
From PortfolioProject..NashvilleHousing


Select 
PARSENAME(Replace(OwnerAddress, ',','.'),3),
PARSENAME(Replace(OwnerAddress, ',','.'),2),
PARSENAME(Replace(OwnerAddress, ',','.'),1)
From PortfolioProject..NashvilleHousing

--//
Alter table PortfolioProject..NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',','.'),3)

--//
Alter table PortfolioProject..NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',','.'),2)

--//
Alter table PortfolioProject..NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update PortfolioProject..NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',','.'),1)



--Setting Y and N to Yes and No in 'Sold as vacant' coloumn to make it distinct to two values

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant , 
Case
   When SoldAsVacant = 'Y' then 'Yes' 
   When SoldAsVacant = 'N' then 'No'
   Else SoldAsVacant
 End
From PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
Set SoldAsVacant = Case
 When SoldAsVacant = 'Y' then 'Yes' 
 When SoldAsVacant = 'N' then 'No'
 Else SoldAsVacant
 End


 -- Remove Duplicates

 With RowNumCTE AS (
 Select *,
	Row_Number() Over (
	Partition by ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 Order by UniqueID
				 ) as Row_Num

From PortfolioProject..NashvilleHousing
--Order by ParcelID
)

Select *  --Used delete here to remove duplicates
From RowNumCTE
Where Row_Num >1
order by PropertyAddress



--Delete unsused coloumns

Select *
From PortfolioProject..NashvilleHousing

Alter table PortfolioProject..NashvilleHousing
Drop Column PropertyAddress, SaleDate, OwnerAddress, TaxDistrict