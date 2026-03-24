# FMS Maintenance Staff App

A SwiftUI app for fleet management maintenance staff. Built with the FMS\_SS design system (orange accent, dark-friendly cards, SF Symbols).

## Folder Structure

```
maintance11/
├── Maintenance/                     ← All app source code lives here
│   ├── MaintenanceAppTheme.swift    ← Color palette & tab bar config
│   ├── MaintenanceTabView.swift     ← Root TabView (Repair · Service · Profile)
│   ├── StaticData.swift             ← Shared models + legacy task/vehicle data
│   │
│   ├── Models/
│   │   ├── RepairModels.swift       ← RepairTask, ServiceTask, InventoryItem, etc.
│   │   └── RepairStaticData.swift   ← Sample repair & service tasks + parts catalog
│   │
│   ├── ViewModels/
│   │   ├── MaintenanceDashboardViewModel.swift
│   │   ├── MaintenanceTaskDetailViewModel.swift
│   │   ├── MaintenanceProfileViewModel.swift
│   │   └── RepairTaskViewModel.swift  ← RepairTaskVM · RepairDetailVM · ServiceTaskVM
│   │
│   └── Views/
│       ├── RepairTaskListView.swift      ← Repair task list with filter chips + bell badge
│       ├── RepairTaskDetailView.swift    ← Detail: vehicle info, inventory, history, actions
│       ├── PartsRequestSheet.swift       ← Dropdown/custom parts request → submit to admin
│       ├── ServiceTaskListView.swift     ← Service task list with progress bars
│       ├── ServiceTaskDetailView.swift   ← Checklist by category + add parts + mark complete
│       ├── MaintenanceStaffRootView.swift
│       ├── MaintenanceDashboardView.swift
│       ├── MaintenanceTaskDetailView.swift
│       ├── SparePartsRequestSheet.swift
│       ├── MaintenanceProfilePage1View.swift
│       ├── MaintenanceProfilePage2View.swift
│       ├── MaintenanceProfileSetupView.swift
│       ├── MaintenanceProfileEditView.swift
│       ├── MaintenanceApplicationSubmittedView.swift
│       ├── CameraPreviewView.swift
│       └── VINScannerView.swift
│
├── maintance.xcodeproj/
├── maintanceTests/
└── maintanceUITests/
```

## Repair Flow

| Status | What the staff member sees |
|---|---|
| **Assigned** | Task card with vehicle info, inventory requirements, admin name |
| **Request Parts** | Sheet with pre-filled inventory list + dropdown/custom part picker + optional reason |
| **Parts Requested** | Card shows pending badge; awaits admin fulfilment |
| **Parts Ready** | 🔔 Bell notification badge on tab; green banner on card |
| **Start Work** | Tap → ETA picker (hours + minutes) → status: Under Maintenance + countdown |
| **Repair Done** | Tap "Mark Repair Done" → timestamp recorded |

## Service Flow (6-Month)

- Grouped checklist (18 items across 8 categories) with progress bar
- Add required parts from 25-item catalog or type custom
- "Mark Service Complete" unlocks only when all checklist items are ticked

## Entry Point

Set `MaintenanceTabView` as the root view in your `@main` App struct.
