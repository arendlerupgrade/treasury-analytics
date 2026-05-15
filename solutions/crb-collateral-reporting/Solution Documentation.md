# Solution Documentation — CRB Collateral Reporting

## Calculated Fields

### Custom SQL Query (core)

#### 4% Rules

**Formula:**
```
IF [dpd]<[Parameters].[Parameter 1 1] then [sum_principal_balance]*.04 end
```

**Summary:** Conditional expression — returns different values based on a logical condition.

---

#### 4% Total

**Formula:**
```
SUM([10% Rules (copy)_502714354247798787])+sum([Calculation_502714354249547782])
```

**Summary:** Aggregation — computes the SUM of the referenced field.

---

#### HI Rules

**Formula:**
```
IF [dpd]<[Parameters].[Parameter 1 1] AND [product_type] = 'HOME_IMPROVEMENT' then [sum_principal_balance]*[Calculation_1544734683916591108] end
```

**Summary:** Conditional expression — returns different values based on a logical condition.

---

#### HI Total 

**Formula:**
```
SUM([4% Rules (copy)_1544734683916001283])+sum([Calculation_502714354249547782])
```

**Summary:** Aggregation — computes the SUM of the referenced field.

---

#### BRB Issuance 

**Formula:**
```
IF [brbflag] = 'BRB' then 'BRB' else '' END
```

**Summary:** Conditional expression — returns different values based on a logical condition.

---

#### OID

**Formula:**
```
if {max([effective_date])} = [effective_date] then [hi_oid] end
```

**Summary:** Conditional expression — returns different values based on a logical condition.

---

#### 30D Balance

**Formula:**
```
IF [DPD Penalty 25% Component (copy)_1440870451905261568] = '0 - '+str([Parameters].[Parameter 1 1]-1)+' Days' AND [snapshot_date] >= ifnull([sl_close_or_org_date],today())+30 THEN [sum_principal_balance] end
```

**Summary:** Conditional expression — returns a value or null depending on a condition.

---

#### Origination Aging

**Formula:**
```
IF [snapshot_date] >= ifnull([sl_close_or_org_date],today())+30 AND [dpd]<[Parameters].[Parameter 1 1] then 'More Than 30 Days' else '30 Days or Less' end
```

**Summary:** Conditional expression — returns a value or null depending on a condition.

---

#### Current Balance

**Formula:**
```
IF [DPD Penalty 25% Component (copy)_1440870451905261568] = '0 - '+str([Parameters].[Parameter 1 1]-1)+' Days' THEN [sum_principal_balance] end
```

**Summary:** Conditional expression — returns different values based on a logical condition.

---

#### BRB Issuance

**Formula:**
```
IF [brbflag] = 'BRB' then 'BRB'
elseif [brbflag] = 'EF' then 'EF'
 else 'CRB' END
```

**Summary:** Conditional expression — returns different values based on a logical condition.

---

#### 10% Rules

**Formula:**
```
IF [snapshot_date] >= ifnull([sl_close_or_org_date],today())+30 AND [dpd]<[Parameters].[Parameter 1 1] THEN [sum_principal_balance]*.1
END
```

**Summary:** Conditional expression — returns a value or null depending on a condition.

---

#### DPD Component

**Formula:**
```
IF isnull([dpd]) = FALSE AND int([dpd]) >= [Parameters].[Parameter 1 1] AND int([dpd]) <= [Parameters].[Parameter 2 1] then [sum_principal_balance]*.25 
ELSEIF isnull([dpd]) = FALSE AND int([dpd]) > [Parameters].[Parameter 2 1] then [sum_principal_balance]

END
```

**Summary:** Conditional expression — returns a value or null depending on a condition.

---

#### DPD Penalty Total

**Formula:**
```
sum([DPD Penalty 25% Component (copy)_502714354251042823])+sum([Calculation_502714354249547782])
```

**Summary:** Aggregation — computes the SUM of the referenced field.

---

#### 10% Total

**Formula:**
```
SUM([Calculation_502714354246930433])+sum([Calculation_502714354249547782])
```

**Summary:** Aggregation — computes the SUM of the referenced field.

---

#### Total Collateral

**Formula:**
```
if sum([10% Rules (copy)_502714354247798787]) > SUM([federated.0lkefag07pbdq41gt37dl0tg8kz4].[Calculation_262334739023294465]) AND sum([10% Rules (copy)_502714354247798787]) > sum([4% Rules (copy)_1544734683916001283])   then [10% Total (copy)_502714354254147594] 
elseif sum([4% Rules (copy)_1544734683916001283]) > SUM([federated.0lkefag07pbdq41gt37dl0tg8kz4].[Calculation_262334739023294465]) then [4% Total (copy)_1544734683921825797]


else SUM([federated.0lkefag07pbdq41gt37dl0tg8kz4].[Calculation_262334739023294465]) end
```

**Summary:** Conditional expression — returns different values based on a logical condition.

---

#### DPD Rate

**Formula:**
```
IF isnull([dpd]) = FALSE AND int([dpd]) >= [Parameters].[Parameter 1 1] AND int([dpd]) <= [Parameters].[Parameter 2 1] then .25 
ELSEIF isnull([dpd]) = FALSE AND int([dpd]) > [Parameters].[Parameter 2 1] then 1
END
```

**Summary:** Conditional expression — returns a value or null depending on a condition.

---

#### Days Past Due 

**Formula:**
```
IF isnull([dpd]) = FALSE AND int([dpd]) >= [Parameters].[Parameter 1 1] AND int([dpd]) <= [Parameters].[Parameter 2 1] then str([Parameters].[Parameter 1 1])+' - '+str([Parameters].[Parameter 2 1])+' Days'
ELSEIF isnull([dpd]) = FALSE AND int([dpd]) > [Parameters].[Parameter 2 1] then '+'+str([Parameters].[Parameter 2 1]+1)+' Days'
ELSE '0 - '+str([Parameters].[Parameter 1 1]-1)+' Days'
END
```

**Summary:** Conditional expression — returns a value or null depending on a condition.

---

#### DPD Penalty 100% Component

**Formula:**
```
IF isnull([dpd]) = FALSE AND int([dpd]) > [Parameters].[Parameter 2 1] then [sum_principal_balance] END
```

**Summary:** Conditional expression — returns a value or null depending on a condition.

---

#### Issuing Vs Seasoner

**Formula:**
```
IF  [investor_id] = 5000002 THEN 'Issuing'
ELSEIF [investor_id] = 5000003 THEN 'Seasoner'


ELSEIF [investor_id] = 5000005 THEN 'Issuing'
ELSEIF [investor_id] = 5000006 THEN 'Seasoner'

ELSEIF [investor_id] = 7000002 THEN 'Issuing'
ELSEIF [investor_id] = 7000003 THEN 'Seasoner'

END
```

**Summary:** Conditional expression — returns different values based on a logical condition.

---

#### Principal Balance 

**Formula:**
```
[sum_principal_balance]
```

**Summary:** Custom calculated field — see formula for details.

---

### Custom SQL Query (core) (2)

#### HFS

**Formula:**
```
IF [purchase_date] > today() AND [is_seasoned] = 'N' THEN [principal_balance]
END
```

**Summary:** Conditional expression — returns different values based on a logical condition.

---

#### HFS Collateral

**Formula:**
```
[Calculation_262334739022725120]*.25
```

**Summary:** Custom calculated field — see formula for details.

---

## Parameters

### Toggle

- **Data type:** string
- **Current value:** "Item"
- **Allowable values:** "Item", "Delta"

### 25% Start

- **Data type:** integer
- **Current value:** 30
- **Allowable values:** Any (any)

### Days Back In Time

- **Data type:** integer
- **Current value:** 2
- **Allowable values:** Any (any)

### 25% End

- **Data type:** integer
- **Current value:** 59
- **Allowable values:** Any (any)

### Toggle 

- **Data type:** string
- **Current value:** "Days Back"
- **Allowable values:** "Days Back", "All"

## Relational Model

**Data objects (2):** `Custom SQL Query`, `Custom SQL Query1`

*(Relationship structure not explicitly declared in XML — review workbook for join logic.)*

