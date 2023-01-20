select
	*
from
	PortfolioProject..NashvilleHousing;

--altering and Updating the table to include a standardized date format

alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = CONVERT(date,SaleDate);

-- Populating Property Address data with NULL value
select
	a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and	a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and	a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

-- Breaking Property Address into columns (Address, City) using substring

select *
from PortfolioProject..NashvilleHousing;

select
SUBSTRING(PropertyAddress, 1, charindex(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, charindex(',',PropertyAddress) + 1, LEN(PropertyAddress)) as City
from PortfolioProject..NashvilleHousing;

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, charindex(',',PropertyAddress) -1);

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, charindex(',',PropertyAddress) + 1, LEN(PropertyAddress))

-- -- Breaking Property Address into columns (Address, City, State) using Parsename

select 
parsename(replace(OwnerAddress,',','.'),3) as Address,
parsename(replace(OwnerAddress,',','.'),2) as City,
parsename(replace(OwnerAddress,',','.'),1) as State
from PortfolioProject..NashvilleHousing;

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress,',','.'),3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress,',','.'),2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress,',','.'),1)


-- Changing Y and N to Yes and No in "SoldAsVacant" column
select
	Soldasvacant,
	CASE when Soldasvacant = 'Y' THEN 'Yes'
		 when Soldasvacant = 'N' THEN 'No'
		 else Soldasvacant
	END
from PortfolioProject..NashvilleHousing;

update NashvilleHousing
set SoldAsVacant = CASE when Soldasvacant = 'Y' THEN 'Yes'
		 when Soldasvacant = 'N' THEN 'No'
		 else Soldasvacant
	END

-- Remove Duplicates
--detecting the duplicates using rownumber

with RowNumCTE as (
select 
	ROW_NUMBER() over (
		partition by ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SalePrice,
					 LegalReference
					 ORDER BY
						UniqueID
					) as row_num,
		*
from PortfolioProject..NashvilleHousing
)
select *
from RowNumCTE
where row_num > 1;

with RowNumCTE as (
select 
	ROW_NUMBER() over (
		partition by ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SalePrice,
					 LegalReference
					 ORDER BY
						UniqueID
					) as row_num,
		*
from PortfolioProject..NashvilleHousing
)
delete
from RowNumCTE
where row_num > 1;

--Delete unused columns

alter table PortfolioProject..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;
