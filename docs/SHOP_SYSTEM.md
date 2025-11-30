# Shop System Documentation

## Overview

The Fingerfist shop system provides a comprehensive item purchasing interface with advanced features for item discovery, comparison, and purchase confirmation.

## Features

### ✅ Item Preview (C46)
- **Visual Preview**: Shows punch radius changes for combat items
- **Stat Comparison**: Before/After display for item effects
- **Preview Items**:
  - Shockwave Fist: Punch radius 32px → 64px (2x)
  - Iron Knuckles: Orange hitbox (knockback effect)
  - Fire Shield: Shield charge display
  - Greed Magnet: Magnet radius visualization (200px)

**Implementation:**
- Preview panel shows static player representation
- Punch hitbox visualized with ColorRect
- Stats formatted in two columns (Current vs. With Item)

### ✅ Hover Tooltips (C47)
- **Mouse Following**: Tooltip follows cursor at offset (+10, +10)
- **Real-time Info**: Name, description, cost
- **Affordability**: Color-coded (green = can afford, red = cannot)
- **Z-Index**: 100 (always on top)

**Tooltip Appearance:**
- Gold title for item name
- White description text
- Green/Red cost based on coins

### ✅ Purchase Confirmation (C48)
- **Confirmation Dialog**: Prevents accidental purchases
- **Remaining Coins**: Shows coins after purchase
- **Visual Feedback**: Background dimmed (50% alpha)
- **Auto-Save**: Triggers after successful purchase

**Dialog Flow:**
1. Click BUY button
2. Details panel dims
3. Confirmation appears
4. Yes → Purchase + Auto-save
5. No → Cancel

### ✅ Search & Sort (C49)
- **Search Field**: Real-time filter by name/description
- **Case Insensitive**: Matches partial text
- **Sort Options**:
  - Cost (ascending/descending)
  - Name (A-Z, Z-A)
- **Toggle Sorting**: Click button to reverse order

**Search Behavior:**
- Empty query = show all items
- Matches name OR description
- Works with category filter

**Sort Indicators:**
- ▼ = Ascending
- ▲ = Descending

## UI Layout

```
┌──────────────────────────────────────────────────────────┐
│ ITEM SHOP                             💰 Coins: 999      │
├──────────────────────────────────────────────────────────┤
│ [Search items...   ] [Sort: Cost ▼] [Sort: Name]        │
│ [All] [Combat] [Defense] [Economy] [Utility] [Ultimate] │
├──────────────────────────────────────────────────────────┤
│ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐                         │
│ │Item1│ │Item2│ │Item3│ │Item4│                         │
│ │ 300 │ │ 400 │ │ 500 │ │ 600 │                         │
│ └─────┘ └─────┘ └─────┘ └─────┘                         │
│ ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐                         │
│ │Item5│ │Item6│ │Item7│ │Item8│                         │
│ └─────┘ └─────┘ └─────┘ └─────┘                         │
├──────────────────────────────────────────────────────────┤
│ [BACK]                                                   │
└──────────────────────────────────────────────────────────┘

┌─────────────────────┐
│ ITEM PREVIEW        │ (Shows when item selected)
│  ┌───────┐          │
│  │Player │          │
│  │  (O)  │ Hitbox   │
│  └───────┘          │
│                     │
│ CURRENT    WITH ITEM│
│ Radius: 32 Radius:64│
│ Knock: ✗   Knock: ✓ │
└─────────────────────┘
```

## Item Categories

1. **Combat**: Offensive items (Iron Knuckles, Shockwave Fist)
2. **Defense**: Defensive items (Fire Shield, Golem Skin, Golem Blessing)
3. **Economy**: Coin-related (Greed Magnet)
4. **Utility**: Utility effects (Time Crystal)
5. **Ultimate**: Endgame items (Call of Wrath)

## Static Player Compatible

All shop features work with the static punch-based player:
- ✅ Preview shows static player at fixed position
- ✅ Punch radius correctly visualized
- ✅ Items enhance punch mechanics (radius, knockback, etc.)
- ✅ No movement required for item effects

## API Usage

### Checking Item Status
```gdscript
var is_owned = Global.is_item_owned("shockwave_fist")
var is_active = Global.is_item_active("shockwave_fist")
```

### Purchasing Items
```gdscript
Global.purchase_item(item_id)  # Marks as owned
Global.trigger_auto_save()     # Saves purchase
```

### Activating Items
```gdscript
Global.activate_item(item_id)
Global.deactivate_item(item_id)
```

## Search Examples

| Query | Matches |
|-------|---------|
| "punch" | Shockwave Fist ("Verdoppelt Attack-Radius") |
| "coin" | Greed Magnet ("Zieht Coins an") |
| "shield" | Fire Shield ("Negiert 1 Projektil") |
| "300" | Items costing 300 coins |

## Sorting Behavior

### Cost Ascending (Default)
Greed Magnet (300) → Iron Knuckles (400) → Shockwave Fist (500) → ...

### Cost Descending
Call of Wrath (1200) → Golem Skin (1000) → Fire Shield (800) → ...

### Name A-Z
Call of Wrath → Fire Shield → Golem Blessing → ...

### Name Z-A
Time Crystal → Shockwave Fist → Iron Knuckles → ...

## Performance

- **Search**: O(n) linear scan (9 items = fast)
- **Sort**: O(n log n) with Godot's sort_custom
- **Tooltips**: No performance impact (hidden when not needed)
- **Preview**: Lazy calculation (only on item select)

## Future Enhancements

- [ ] Animated item icons
- [ ] Sound effects for purchase
- [ ] Item rarity (Common, Rare, Legendary)
- [ ] Bulk purchase discounts
- [ ] Item bundles
- [ ] Refund system
- [ ] Wishlist feature

## Progress

**Commits 46-50**: Shop System Extensions ✅
- C46: Item Preview ✅
- C47: Hover Tooltips ✅
- C48: Purchase Confirmation ✅
- C49: Search & Sort ✅
- C50: Documentation ✅

**Overall Progress**: 50/70 commits (71%)

**Next Milestone**: M4 Assets & Polish (C51-60)
