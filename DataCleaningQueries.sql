/*
Data Cleaning Queries
*/

Select *
From PortfolioProject..HousingData

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select SaleDate, CONVERT(date, SaleDate)
From PortfolioProject..HousingData

UPDATE HousingData
SET SaleDate = CONVERT(date, SaleDate)

--The above query did not work for some reason so we do try a different method

ALTER Table HousingData
Add SaleDateConverted Date;

UPDATE HousingData
SET SaleDateConverted = CONVERT(date, SaleDate)

Select SaleDateConverted
From PortfolioProject..HousingData

--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address Data


Select *
From PortfolioProject..HousingData
--Where PropertyAddress is Null
Order by ParcelID


Select a.ParcelID, a.PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..HousingData a
JOIN PortfolioProject..HousingData b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..HousingData a
JOIN PortfolioProject..HousingData b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress
From PortfolioProject..HousingData
--Where PropertyAddress is Null
--Order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
From PortfolioProject..HousingData

ALTER Table HousingData
Add PropertySplitAddress Nvarchar(255);

UPDATE HousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

ALTER Table HousingData
Add PopertySplitCity Nvarchar(255);

UPDATE HousingData
SET PopertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select *
From PortfolioProject..HousingData



Select OwnerAddress
From PortfolioProject..HousingData

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as City,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as State
From PortfolioProject..HousingData


ALTER Table HousingData
Add OwnerSplitAddress Nvarchar(255);

UPDATE HousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER Table HousingData
Add OwnerSplitCity Nvarchar(255);

UPDATE HousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER Table HousingData
Add OwnerSplitState Nvarchar(255);

UPDATE HousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
From PortfolioProject..HousingData


--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..HousingData
Group By SoldAsVacant
Order By 2


Select SoldAsVacant,
	CASE When SoldAsVacant = 'Y' Then 'Yes'
		 When SoldAsvacant = 'N' Then 'No'
		 ELSE SoldAsVacant
		 END
From PortfolioProject..HousingData

Update HousingData
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
		 When SoldAsvacant = 'N' Then 'No'
		 ELSE SoldAsVacant
		 END



-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
				) row_num
From PortfolioProject..HousingData
--Order By ParcelID
)

DELETE
From RowNumCTE
Where row_num > 1
--Order By PropertyAddress


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From PortfolioProject..HousingData

ALTER TABLE PortfolioProject..HousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate